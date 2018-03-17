//
//  HorarioViewController.swift
//  BlockCells
//
//  Created by Anderson Rocha on 23/09/17.
//  Copyright © 2017 BlockCells. All rights reserved.
//

import UIKit
import Firebase

class HorarioViewController: UIViewController {
    
    let db = Database.database().reference()
    var telefone: String = ""
    
    @IBOutlet weak var swSegunda: UISwitch!
    @IBOutlet weak var swTerca: UISwitch!
    @IBOutlet weak var swQuarta: UISwitch!
    @IBOutlet weak var swQuinta: UISwitch!
    @IBOutlet weak var swSexta: UISwitch!
    @IBOutlet weak var swSabado: UISwitch!
    @IBOutlet weak var swDomingo: UISwitch!
    @IBOutlet weak var dtUtilInicio: UIDatePicker!
    @IBOutlet weak var dtUtilFim: UIDatePicker!
    @IBOutlet weak var dtWeekendInicio: UIDatePicker!
    @IBOutlet weak var dtWeekendFim: UIDatePicker!
    @IBOutlet weak var btnSalvar: UIButton!
    
    @IBAction func salvarAlteracoes(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        
        salvaDados()
        db.removeAllObservers()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tel = TelefoneUserDefaults()
        self.telefone = tel.busca()
        
        buscaDados()
        
        habilitaSalvar()
    }

    func buscaDados() {
        let raiz = db.child("celulares")
        
        let cfg = raiz.child(self.telefone).child("horario")
        
        cfg.observe(DataEventType.value, with: { (dados) in
            // Captura o valor da configuração
            let value = dados.value as? NSDictionary
            

            self.swSegunda.setOn(value?["segunda"] as! Bool, animated: true)
            self.swTerca.setOn(value?["terca"] as! Bool, animated: true)
            self.swQuarta.setOn(value?["quarta"] as! Bool, animated: true)
            self.swQuinta.setOn(value?["quinta"] as! Bool, animated: true)
            self.swSexta.setOn(value?["sexta"] as! Bool, animated: true)
            self.swSabado.setOn(value?["sabado"] as! Bool, animated: true)
            self.swDomingo.setOn(value?["domingo"] as! Bool, animated: true)
            self.dtUtilInicio.setDate(self.stringToDate(horaStr: value?["util_inicio"] as! String), animated: true)
            self.dtUtilFim.setDate(self.stringToDate(horaStr: value?["util_fim"] as! String), animated: true)
            self.dtWeekendInicio.setDate(self.stringToDate(horaStr: value?["fds_inicio"] as! String), animated: true)
            self.dtWeekendFim.setDate(self.stringToDate(horaStr: value?["fds_fim"] as! String), animated: true)

        })
        
    }
    
    func salvaDados() {
        
        let horario = Horario()
        let cfgDB = ConfigGeralDB()
        
        horario.segunda = swSegunda.isOn
        horario.terca = swTerca.isOn
        horario.quarta = swQuarta.isOn
        horario.quinta = swQuinta.isOn
        horario.sexta = swSexta.isOn
        horario.sabado = swSabado.isOn
        horario.domingo = swDomingo.isOn
        horario.util_inicio = dateToStringHM(date: dtUtilInicio.date)
        horario.util_fim = dateToStringHM(date: dtUtilFim.date)
        horario.fds_inicio = dateToStringHM(date: dtWeekendInicio.date)
        horario.fds_fim = dateToStringHM(date: dtWeekendFim.date)
        
        cfgDB.salvaDados(obj: horario, fire: true)
        
    }
    
    func dateToStringHM (date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let strDate = dateFormatter.string(from: date)
        return(strDate)
    }
    
    func stringToDate(horaStr: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let dataHora: String = "01-01-2000 " + horaStr
 //       dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        let date = dateFormatter.date(from: dataHora) //according to date format your date string
        
        return date!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //para que o teclado não fique aberto
        view.endEditing(true)
    }
    
    func habilitaSalvar() {
        let cfgDB = ConfigGeralDB()
        let cfg = cfgDB.buscaCG()
        
        //significa que está sendo controlado remotamente então desabilita do salvar
        if cfg.controle_remoto {
            btnSalvar.isEnabled = false
            btnSalvar.backgroundColor = UIColor.gray
        }
    }

}
