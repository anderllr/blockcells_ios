//
//  ViewController.swift
//  BlockCells
//
//  Created by Anderson Rocha on 18/09/17.
//  Copyright © 2017 BlockCells. All rights reserved.f
//

import UIKit
import MapKit
import AVFoundation
import CallKit
import MessageUI // Import MessageUI
import Firebase
import UserNotifications

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, CXCallObserverDelegate {
    
    var player = AVAudioPlayer()
    var observer : CXCallObserver?
    
    var gerLocal = CLLocationManager()
    @IBOutlet weak var lblSpeed: UILabel!
    @IBOutlet weak var lblJustifica: UILabel!
    
    var ativado: Bool = false
    var velocidade_min: Int = 0
    var velocidade_max: Int = 0
    var velocidade_alerta: Int = 0
    var execSom: Bool = true
    var execSomAlerta: Bool = true
    var latitude: Double = 0
    var longitude: Double = 0
    var speed: Int = 0
    var cont: Int = 0
    let application = UIApplication.shared
    
    let telefone = TelefoneUserDefaults()
    let emulating = EmulatorUserDefaults()
    let db = Database.database().reference()
    
    var just: [Justificativa] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       //Verifica se está em modo de emulador
        if emulating.busca() {
            //se estiver então: se tem um telefone se não tiver não loga, por enquanto apenas setar um fixo
            telefone.remover()
            if telefone.busca() == "" {
                telefone.salvar(telefone: "+5567999220123")
            } else {
                print("Achou telefone")
            }
        }
        //Inicializa os observes -[                                            do sistema
        iniciaGeral()
        
        self.execSom = true
        self.execSomAlerta = true
        self.latitude = 0
        self.longitude = 0
        
        self.observer = CXCallObserver()
        self.observer?.setDelegate(self, queue: nil)
        
        buscaAcessoRemoto()
        
        //Chama a função para autorização das notificações no ícone
        setBadgeIndicator()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        // Configurações referente à localização
        gerLocal.delegate = self
        gerLocal.desiredAccuracy = kCLLocationAccuracyBest
 //       gerLocal.requestWhenInUseAuthorization()
        gerLocal.allowsBackgroundLocationUpdates = true
        gerLocal.pausesLocationUpdatesAutomatically = false
        if #available(iOS 11.0, *) {
            gerLocal.showsBackgroundLocationIndicator = true
        } else {
            // Fallback on earlier versions
        }
 
        gerLocal.requestAlwaysAuthorization()
        gerLocal.startUpdatingLocation()
        
        verificaJustificativa()
    }
    
    @IBAction func actJustificar(_ sender: Any) {
        if self.just.count > 0 {
            self.performSegue(withIdentifier: "segueJustificar", sender: nil)
        }
    }
    
    func iniciaGeral() {
        //Dá start nas tabelas
        
        //ConfigGeral
        let cfGeral = ConfigGeralDB()
        cfGeral.inicializa()
    }
    
    func verificaJustificativa() {
        
        self.just.removeAll()
        
        self.lblJustifica.isHidden = true
        self.application.applicationIconBadgeNumber = 0
        
        let raiz = db.child("celulares")
        
        let cfg = raiz.child(self.telefone.busca()).child("justificativa")
        
        let jusE = cfg.queryOrdered(byChild: "justificado").queryEqual(toValue: false)
        
        //limpa a fila primeiro
        jusE.removeAllObservers()

        //Cria o ouvinte para os contatos
        jusE.observe(DataEventType.childAdded, with: { (snapshot) in
            let dados = snapshot.value as? NSDictionary
            
            let jus = Justificativa()
            
            jus.id_jus = Int(snapshot.key)!
            jus.data_hora = dados?["data_hora"] as! String
            jus.desc_justificativa = dados?["desc_justificativa"] as! String
            jus.evento = dados?["evento"] as! String
            jus.justificado = dados?["justificado"] as! Bool
            jus.latitude = dados?["latitude"] as! Double
            jus.longitude = dados?["longitude"] as! Double
            
            self.just.append(jus)
            self.lblJustifica.text = String(self.just.count)
            self.application.applicationIconBadgeNumber = self.just.count
            self.lblJustifica.reloadInputViews()
            
            if self.just.count > 0 {
                self.lblJustifica.isHidden = false
            }
            
        })
    }
    
    //Função para aparecer indicação de notificações no ícone
    func setBadgeIndicator() {
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .alert, .sound]) { _, _ in }
        } else {
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        }
        application.registerForRemoteNotifications()
    }
    
    func capturaUserD() {
        //Inicializa as variaveis do UserDefaults
        if let cfg = UserDefaults.standard.object(forKey: "config_geral") {
            let cfgDados = cfg as? NSDictionary
            self.ativado = cfgDados?["ativado"] as! Bool

        }
        
        if let km = UserDefaults.standard.object(forKey: "km") {
            let kmDados = km as? NSDictionary
            self.velocidade_min = kmDados?["velocidade_min"] as! Int
            self.velocidade_max = kmDados?["velocidade_max"] as! Int
            self.velocidade_alerta = kmDados?["velocidade_alerta"] as! Int
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocal = locations.last!
        
        self.longitude = userLocal.coordinate.longitude
        self.latitude = userLocal.coordinate.latitude
        
        if userLocal.speed > 0 {
            
            let speedkm = Int(userLocal.speed * 3.6)
            self.speed = speedkm
            
            self.alertSpeed(speed: speedkm)
            
            lblSpeed.text = String(speedkm)
        } else {
            self.speed = 0
            lblSpeed.text = "0"
        }
        
 //       print("Velocidade \(self.speed)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status != .authorizedAlways && status != .authorizedWhenInUse && status != .notDetermined {
            let alertController = UIAlertController(title: "Permissão de Localização", message: "Necessário permissão para acesso à sua localização", preferredStyle: .alert)
            
            let acaoConfiguracoes = UIAlertAction(title: "Abrir configurações?", style: .default, handler: { (alertaConfiguracoes) in
                if let configuracoes = NSURL(string: UIApplicationOpenSettingsURLString){
                    UIApplication.shared.open(configuracoes as URL)
                }
            })
            
            let acaoCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
            
            alertController.addAction(acaoConfiguracoes)
            alertController.addAction(acaoCancelar)
            
            present(alertController, animated: true, completion: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //desabilitar a barra de status
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //FUNÇÃO REFERENTE VELOCIDADE
    func alertSpeed (speed: Int) {
        //consulta o UserDefaults
        capturaUserD()
        if self.ativado {
            if speed >= self.velocidade_alerta && speed < self.velocidade_max {
                self.execSom = true
                if self.execSomAlerta {
                    self.execSomAlerta = false
                    self.executarSom(nomeSom: "beepblock")
                }
            }
            else
            //Trata velocidade máxima
            if speed > self.velocidade_max {
                if self.execSom {
                    self.execSom = false
                    self.executarSom(nomeSom: "sirene")
                    let cfGeral = ConfigGeralDB()
                    cfGeral.salvaLog(evento: "Excesso de Velocidade", descricao: "Excedeu velocidade:  \(self.velocidade_max)", latitude: self.latitude, longitude: self.longitude)
                    print("Entrou no excesso de velocidade")
                    //Verifica a justificativa para ver se incrementou
                    verificaJustificativa()
                }
            } else {
                self.execSom = true
                self.execSomAlerta = true
            }
        } else {
            self.execSom = true
            self.execSomAlerta = true
        }
    }
    
    func executarSom(nomeSom: String) {
        if let path = Bundle.main.path(forResource: nomeSom, ofType: "mp3") {
            //Encontrou o arquivo
            let url = URL(fileURLWithPath: path)
            
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                
            } catch {
                //PROCESS ERROR
            }
            
            let session = AVAudioSession.sharedInstance()
            
            //This process is to keep playing in background
            do {
                try session.setCategory(AVAudioSessionCategoryPlayback)
                try session.setActive(true)
            } catch {
                
            }
            
            player.play()
        } else {

        }
        
    }
    
    //Rotina da captura de ligação para ver se bloqueia
    func capturaLigacao(phoneNumber: String, obsLog: String) {
        //Executa para ver se não teve alteração
        capturaUserD()

        if self.ativado && self.speed > self.velocidade_min {
            //Aí verifica se bloqueia a ligação
            let block = Block(phoneNumber: phoneNumber, speed: self.speed, latitude: self.latitude, longitude: self.longitude )
            
            if block.isBlocked(obsLog: obsLog) {
                print("Bloqueado...")
                verificaJustificativa()
            } else {
                print("Liberado...")
            }
        }
    }
    
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        
        if call.hasConnected {
            capturaLigacao(phoneNumber: "00000", obsLog: "Atendeu Ligação")
        }
        else
            if call.isOutgoing {
                //print("Call outGoing \(call.uuid)")
                capturaLigacao(phoneNumber: "00000", obsLog: "Efetuou Ligação")
            }
            else
                if call.hasEnded {
                    print("Call hasEnded \(call.uuid)")
                }
                else
                    if call.isOnHold {
                        print("Call onHold \(call.uuid)")
                    }
                    else
                        if call.hasConnected {
                            print("Call connected \(call.uuid)")
                            
                        }
                        else
                        {
                            //print("Exception execute when call ringing \(call.uuid)")
                            capturaLigacao(phoneNumber: "00000", obsLog: "Ligação Recebida")
        }
        
    }
    
    func buscaAcessoRemoto() {
        
        let raiz = db.child("celulares")
        
        let cfg = raiz.child(self.telefone.busca()).child("solicitacao")
        
        cfg.observe(DataEventType.value, with: { (dados) in
            // Captura o valor da configuração
            
                let value = dados.value as? NSDictionary
                
                let cfGeral = ConfigGeralDB()
                let c = cfGeral.buscaCG()
                let s = Solicitacao()
                
            if let aceito = value?["aceito"] { // quer dizer que existe
                s.aceito = aceito as! Bool
                s.nome = value?["nome"] as! String
                s.username = value?["username"] as! String
                
                //Significa que foi solicitado acesso remoto
                if s.aceito {
                    if !c.controle_remoto { //Se não estiver sendo controlado avisa o usuário
                        let msg = s.nome + " está solicitando permissão para controle remoto. Permitir?"
                        //Faz o alerta de permissão
                        let alertController = UIAlertController(title: "Permissão de Acesso Remoto", message: msg, preferredStyle: .alert)
                        
                        let acaoAceitar = UIAlertAction(title: "Sim", style: .default, handler: { (alertaAceitar) in
                            //se aceitou iremos gravar a permissão remota
                            
                            c.controle_remoto = true
                            cfGeral.salvaDados(obj: c, fire: true)
                        })
                        
                        let acaoCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: { (alertaCancelar) in
                            //se não aceitou iremos gravar a negação na solicitacao
                            let cfGeral = ConfigGeralDB()
                            s.aceito = false
                            cfGeral.salvaDados(obj: s, fire: true)
                        })
                        
                        alertController.addAction(acaoAceitar)
                        alertController.addAction(acaoCancelar)
                        
                        self.present(alertController, animated: true, completion: nil)
                        
                    }
                } else {
                    //se modificou de controle remoto vou alterar a configuração
                    c.controle_remoto = false
                    cfGeral.salvaDados(obj: c, fire: true)
                }
            }
            
        })
        
    }
    
}

