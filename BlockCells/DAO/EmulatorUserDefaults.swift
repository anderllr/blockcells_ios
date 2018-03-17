//
//  EmulatorMode.swift
//  BlockCells
//
//  Created by Anderson Rocha on 25/01/2018.
//  Copyright © 2018 BlockCells. All rights reserved.
//

//
//  TelefoneUserDefaults.swift
//  BlockCells
//
//  Created by Anderson Rocha on 25/09/17.
//  Copyright © 2017 BlockCells. All rights reserved.
//

import UIKit

class EmulatorUserDefaults {
    
    let chave = "emulatorMode"
    var emulating: Bool = false
    
    func salvar(emulating: Bool){
        
        //adiciona o telefone que está recebendo
        UserDefaults.standard.set(emulating, forKey: chave)
        
    }
    
    func remover () {
        UserDefaults.standard.removeObject(forKey: chave)
    }
    
    func busca() -> Bool {
        
        let dados = UserDefaults.standard.object(forKey: chave)
        
        if dados != nil {
            return dados as! Bool
        }
        else {
            return false
        }
        
    }
}

