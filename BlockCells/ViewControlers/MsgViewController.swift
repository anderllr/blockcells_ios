//
//  MsgViewController.swift
//  BlockCells
//
//  Created by Anderson Rocha on 23/09/17.
//  Copyright © 2017 BlockCells. All rights reserved.
//

import UIKit
import Firebase

class MsgViewController: UIViewController {
    
    let db = Database.database().reference()
    var telefone: String = ""
    
    @IBOutlet weak var txtMsgPadrao: UITextView!
    @IBOutlet weak var txtMsgVip: UITextView!
    @IBOutlet weak var swEnviaLocal: UISwitch!
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
        
        let cfg = raiz.child(self.telefone).child("msg")
        
        cfg.observe(DataEventType.value, with: { (dados) in
            // Captura o valor da configuração
            let value = dados.value as? NSDictionary
            
            self.txtMsgPadrao.text = value?["msg"] as! String
            self.txtMsgVip.text = value?["msg_vip"] as! String
            self.swEnviaLocal.setOn(value?["msgcomlocalizacao"] as! Bool, animated: true)
        })
        
    }
    
    func salvaDados() {
        
        let msg = Msg()
        let cfgDB = ConfigGeralDB()
        
        msg.msg = txtMsgPadrao.text
        msg.msg_vip = txtMsgVip.text
        msg.msgcomlocalizacao = swEnviaLocal.isOn
        
        cfgDB.salvaDados(obj: msg, fire: true)
        
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
