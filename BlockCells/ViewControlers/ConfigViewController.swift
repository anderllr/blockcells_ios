//
//  ConfigViewController.swift
//  BlockCells
//
//  Created by Anderson Rocha on 23/09/17.
//  Copyright © 2017 BlockCells. All rights reserved.
//

import UIKit
import Firebase

class ConfigViewController: UIViewController {
    
    let db = Database.database().reference()
    var telefone: String = ""
    
    @IBOutlet weak var swControleRemoto: UISwitch!
    @IBOutlet weak var swInformaLocal: UISwitch!
    @IBOutlet weak var swAtivado: UISwitch!
    @IBOutlet weak var swEnviaSms: UISwitch!
    @IBOutlet weak var btnSalvar: UIButton!
    
    @IBAction func salvarAlteracoes(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        
        salvaDados()
        db.removeAllObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swControleRemoto.isEnabled = false
        
        let tel = TelefoneUserDefaults()
        self.telefone = tel.busca()
        
        habilitaSalvar()
        
        buscaDados()
    }
    
    func buscaDados() {
        let raiz = db.child("celulares")

        let cfg = raiz.child(self.telefone).child("config_geral")
        
        cfg.observe(DataEventType.value, with: { (dados) in
            // Captura o valor da configuração
            let value = dados.value as? NSDictionary
            
            self.swAtivado.setOn(value?["ativado"] as! Bool, animated: true)
            self.swControleRemoto.setOn(value?["controle_remoto"]  as! Bool, animated: true)
            self.swEnviaSms.setOn(value?["envia_sms"] as! Bool, animated: true)
            self.swInformaLocal.setOn(value?["informa_local"] as! Bool, animated: true)
            
        })
        
    }
    
    func salvaDados() {

        let cfg = ConfigGeral()
        let cfgDB = ConfigGeralDB()
        
        cfg.ativado = swAtivado.isOn
        cfg.controle_remoto = swControleRemoto.isOn
        cfg.envia_sms = swEnviaSms.isOn
        cfg.informa_local = swInformaLocal.isOn
        
        cfgDB.salvaDados(obj: cfg, fire: true)

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
