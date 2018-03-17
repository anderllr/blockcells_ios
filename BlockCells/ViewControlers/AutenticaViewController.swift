//
//  AutenticaViewController.swift
//  BlockCells
//
//  Created by Anderson Rocha on 07/11/17.
//  Copyright © 2017 BlockCells. All rights reserved.
//

import UIKit
import FirebaseAuth

class AutenticaViewController: UIViewController {
    
    @IBOutlet weak var btnAutenticar: UIButton!
    let telefone = TelefoneUserDefaults()
    let emulating = EmulatorUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Seta emulador para true ou false conforme a necessidade.
        emulating.salvar(emulating: false)
  
        //Trata para ver se está em modo de emulação
        
        if emulating.busca() {
            self.performSegue(withIdentifier: "segueLogado", sender: nil)
            return
        }
        
        //Muda o status do botão
//        self.btnAutenticar.isEnabled = false
//        self.btnAutenticar.setTitle("Verificando...", for: .disabled)
    
        //Ver se o usuário já está autenticado assim não precisa abrir a tela inicial do app
        
        let autenticacao = Auth.auth()
        var sLogado = false
     
        //por enquanto para testar no simulador
    //    self.performSegue(withIdentifier: "segueLogado", sender: nil)
        
        if telefone.busca() == "" {  /// se o telefone não está no UserDefaults então tem que autenticar
            self.btnAutenticar.isEnabled = true
            self.btnAutenticar.setTitle("Autenticar", for: .normal)
        } else {
            autenticacao.addStateDidChangeListener { (autenticacao, usuario) in
                if usuario != nil {
                    sLogado = true
                } else { //vai verificar se já existe código pronto de autenticação
                    if let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") {
                        if let verifyCode = UserDefaults.standard.string(forKey: "verifyCode") {
                            let credential = PhoneAuthProvider.provider().credential(
                                withVerificationID: verificationID,
                                verificationCode: verifyCode)
                            
                            Auth.auth().signIn(with: credential) { (user, error) in
                                if error == nil {
                                    // User is signed in
                                    //Se autenticou salva o código de autenticação para próximas inicializações
                                    // Salva a instância de verificação
                                    sLogado = true
                                }
                            }
                        }
                    }
                }
                
                if sLogado {
                   self.performSegue(withIdentifier: "segueLogado", sender: nil)
                } else {
                    self.btnAutenticar.isEnabled = true
                    self.btnAutenticar.setTitle("Autenticar", for: .normal)
                }
            }
        }

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
