//
//  ValidaViewController.swift
//  BlockCells
//
//  Created by Anderson Rocha on 10/11/17.
//  Copyright © 2017 BlockCells. All rights reserved.
//

import UIKit
import FirebaseAuth

class ValidaViewController: UIViewController {
    
    @IBOutlet weak var nrTelefone: UITextField!
    @IBOutlet weak var btnEnviaVerifica: UIButton!
    
    
    @IBAction func enviaVerificacao(_ sender: Any) {
        
        self.btnEnviaVerifica.isEnabled = false
        self.nrTelefone.isEnabled = false
        self.btnEnviaVerifica.setTitle("Enviando...", for: .normal)
        
        
        var alerta = Alerta(titulo: "Telefone", mensagem: "Informe um telefone celular válido!")
        let autenticacao = Auth.auth()
        autenticacao.useAppLanguage()
        
        if let phoneNumber = nrTelefone.text {
            //limpa o número do telefone
            let telefone = "+55" + phoneNumber.replacingOccurrences(of: "[-()+ ]", with: "",options: .regularExpression)
            if telefone.count != 14 {
                present(alerta.getAlerta(), animated: true, completion: nil)
            } else {
//                PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
                PhoneAuthProvider.provider().verifyPhoneNumber(telefone, completion: { (verificationID, error) in
                    if let error = error {
                        alerta = Alerta(titulo: "Telefone", mensagem: error.localizedDescription)
                        self.present(alerta.getAlerta(), animated: true, completion: nil)
                        return
                    } else {
                        // Salva a instância de verificação
                        UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                        UserDefaults.standard.synchronize()
                        self.performSegue(withIdentifier: "segueValida", sender: nil)
                        let tel = TelefoneUserDefaults()
                        tel.salvar(telefone: telefone)
                        
                    }
                }
            )}
        } else {
            present(alerta.getAlerta(), animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnEnviaVerifica.isEnabled = false
        self.nrTelefone.isEnabled = false
        self.btnEnviaVerifica.setTitle("Verificando...", for: .normal)

        // Do any additional setup after loading the view.
        //Verifica se já não existe uma verificationID, se já existir já vai para a tela de verificação direto
        if UserDefaults.standard.string(forKey: "authVerificationID") != nil {
            self.performSegue(withIdentifier: "segueValida", sender: nil)
        } else {
        
            self.btnEnviaVerifica.isEnabled = true
            self.nrTelefone.isEnabled = true
            self.btnEnviaVerifica.setTitle("Enviar verificação...", for: .normal)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //para que o teclado não fique aberto
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
