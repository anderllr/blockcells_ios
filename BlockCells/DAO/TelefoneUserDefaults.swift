//
//  TelefoneUserDefaults.swift
//  BlockCells
//
//  Created by Anderson Rocha on 25/09/17.
//  Copyright © 2017 BlockCells. All rights reserved.
//

import UIKit

class TelefoneUserDefaults {
    
    let chave = "telephoneNumber"
    var telefone: String = ""
    
    func salvar(telefone: String){
        
        //Primeiro recupera tarefas já salvas
       // telefone = busca()
        
        //adiciona o telefone que está recebendo
        UserDefaults.standard.set(telefone, forKey: chave)
        
    }
    
    func remover () {
        UserDefaults.standard.removeObject(forKey: chave)
    }
    
    func busca() -> String {
        
        let dados = UserDefaults.standard.object(forKey: chave)
        
        if dados != nil {
            return dados as! String
        }
        else {
            return ""
        }
        
    }
}
