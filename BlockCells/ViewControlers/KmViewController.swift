//
//  KmViewController.swift
//  BlockCells
//
//  Created by Anderson Rocha on 23/09/17.
//  Copyright © 2017 BlockCells. All rights reserved.
//

import UIKit
import Firebase

class KmViewController: UIViewController {
 
    let db = Database.database().reference()
    var telefone: String = ""
    
    @IBOutlet weak var txtKmMinimo: UITextField!
    @IBOutlet weak var txtKmMaximo: UITextField!
    @IBOutlet weak var txtKmAlerta: UITextField!
    @IBOutlet weak var swEnviaAlerta: UISwitch!
    @IBOutlet weak var swEmiteBip: UISwitch!
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
        
        let km = raiz.child(self.telefone).child("km")
        
        km.observe(DataEventType.value, with: { (dados) in
            
            // Captura o valor da configuração
            let value = dados.value as? NSDictionary
        
            if let kmMin = value!["velocidade_min"] {
                self.txtKmMinimo.text = String(describing: kmMin)
            }
            if let kmMax = value!["velocidade_max"] {
                self.txtKmMaximo.text = String(describing: kmMax)
            }
            if let kmAlerta = value!["velocidade_alerta"] {
                self.txtKmAlerta.text = String(describing: kmAlerta)
            }
            self.swEnviaAlerta.setOn(value?["envia_alerta"] as! Bool, animated: true)
            self.swEmiteBip.setOn(value?["emite_bip"] as! Bool, animated: true)

        })
        
    }
    
    func salvaDados() {
        
        let km = Km()
        let cfgDB = ConfigGeralDB()
        
        if let vMin = Int16(txtKmMinimo.text!) {
            km.velocidade_min = vMin
        }
        if let vMax = Int16(txtKmMaximo.text!) {
            km.velocidade_max = vMax
        }
        if let vAlerta = Int16(txtKmAlerta.text!) {
            km.velocidade_alerta = vAlerta
        }
        km.emite_bip = swEmiteBip.isOn
        km.envia_alerta = swEnviaAlerta.isOn
        
        cfgDB.salvaDados(obj: km, fire: true)
        
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
