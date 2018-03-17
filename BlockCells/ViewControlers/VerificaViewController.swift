//
//  VerificaViewController.swift
//  BlockCells
//
//  Created by Anderson Rocha on 11/11/17.
//  Copyright © 2017 BlockCells. All rights reserved.
//

import UIKit
import FirebaseAuth

class VerificaViewController: UIViewController {
    
    @IBOutlet weak var verifyCode: UITextField!
    let telefone = TelefoneUserDefaults()
    
    @IBAction func verificarCodigo(_ sender: Any) {
        
        if verifyCode.text?.count == 0 {
            let alerta = Alerta(titulo: "Verificação", mensagem: "Você deve informar um código")
            present(alerta.getAlerta(), animated: true, completion: nil)
        } else {
            if let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") {
                let credential = PhoneAuthProvider.provider().credential(
                    withVerificationID: verificationID,
                    verificationCode: verifyCode.text!)
                
                Auth.auth().signIn(with: credential) { (user, error) in
                    if let error = error {
                        let alerta = Alerta(titulo: "Autenticação", mensagem: error.localizedDescription)
                        self.present(alerta.getAlerta(), animated: true, completion: nil)
                    } else {
                        // User is signed in
                        //Se autenticou salva o código de autenticação para próximas inicializações
                        //Salva o telefone no UserDefaults
                        if let phoneNumber = user?.phoneNumber {
                            self.telefone.salvar(telefone: phoneNumber)
                            // Salva a instância de verificação
                            UserDefaults.standard.set(self.verifyCode.text!, forKey: "verifyCode")
                            
                            self.performSegue(withIdentifier: "segueVerificado", sender: nil)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func cancelaCodigo(_ sender: Any) {
        //Remove o código de verificação
        UserDefaults.standard.removeObject(forKey: "authVerificationID")
        UserDefaults.standard.removeObject(forKey: "verifyCode")
        telefone.remover()
        
        let autenticacao = Auth.auth()
        
        if autenticacao.currentUser != nil {
        
        do {
            try autenticacao.signOut()
            dismiss(animated: true, completion: nil)
        } catch {
            print("Erro ao deslogar usuário")
        }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Verifica se tem o id de verificação do contrário sai
        if UserDefaults.standard.string(forKey: "authVerificationID") == nil {
            dismiss(animated: true, completion: nil)
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
