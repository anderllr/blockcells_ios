//
//  JustificaViewController.swift
//  BlockCells
//
//  Created by Anderson Rocha on 09/01/2018.
//  Copyright © 2018 BlockCells. All rights reserved.
//

import UIKit

class JustificaViewController: UIViewController {
    
    @IBOutlet weak var data_hora: UITextField!
    @IBOutlet weak var evento: UITextField!
    @IBOutlet weak var justificativa: UITextView!
    
    var jus = Justificativa()
    
    @IBAction func actSalvar(_ sender: Any) {
        if justificativa.text == "" {
            let alert = Alerta(titulo: "Justificativa", mensagem: "O preenchimento da justificativa é obrigatório")
            present(alert.getAlerta(), animated: true, completion: nil)
        } else {
            self.navigationController?.popToRootViewController(animated: true)

            salvaDados()
        }
    }
    
    func salvaDados() {
        
        let cfgDB = ConfigGeralDB()
        
        jus.desc_justificativa = justificativa.text
        jus.justificado = true
        
        cfgDB.salvaDados(obj: jus, fire: true)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        preencheValores()
        
        colocaBordaTextView()
    }

    func colocaBordaTextView() {
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        justificativa.layer.borderWidth = 0.8
        justificativa.layer.borderColor = borderColor.cgColor
        justificativa.layer.cornerRadius = 5.0
    }
    func preencheValores() {
        data_hora.text = jus.data_hora
        evento.text = jus.evento
        
        print("Justificativa número: \(jus.id_jus)")
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //para que o teclado não fique aberto
        view.endEditing(true)
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
