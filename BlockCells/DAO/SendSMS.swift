//
//  SendSMS.swift
//  BlockCells
//
//  Created by Anderson Rocha on 21/10/17.
//  Copyright © 2017 BlockCells. All rights reserved.
//

import UIKit
import MessageUI // Import MessageUI

class SendSMS {
    var phoneNumber: String
    var vip: Bool
    var latitude: Double
    var longitude: Double
    
    init(phoneNumber: String, vip: Bool, latitude: Double, longitude: Double) {
        self.phoneNumber = phoneNumber
        self.vip = vip
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // Send message para o Firebase para dali enviar por algum android
    func sendMessageFB() {
        let msg = retMsg()
        
        let cfg = ConfigGeralDB()
        cfg.salvaSms(phoneNumber: self.phoneNumber, msg: msg)
    }
    
    // Send a message através de WebService
    func sendMessage() {
        let caminho = self.retURLStr()
        if let url = URL(string: caminho) {
            let tarefa = URLSession.shared.dataTask(with: url) { (dados, requisicao, erro) in
                
                if erro == nil {
                    if let dadosRetorno = dados {
                        
                        do {
                            
                            if let objetoJson = try JSONSerialization.jsonObject(with: dadosRetorno, options: []) as? [String: Any] {
                                print(objetoJson)
                                //busca a chave dentro do json
                                if let msg = objetoJson["msg"] as? String {
                                    if msg == "SUCESSO" {
                                        self.logSMS(success: true)
                                    } else {
                                        self.logSMS(success: false)
                                    }
                                }
                            }
                            
                        } catch {
                            self.logSMS(success: false)
                        }
                    }
                } else {
                    self.logSMS(success: false)
                }
                
            }
            tarefa.resume()

        }
    }
    
    func isCellPhone() -> Bool {
        var cell = false
        //Vai tentar achar o 9 - no caso do Brasil
        if phoneNumber.suffix(9).prefix(1) == "9" {
            cell = true
        }
        
        return cell
    }
    
    func logSMS (success: Bool) {
        let config = ConfigGeralDB()
        
        var enviou = "Não enviou SMS"
        if success {
            enviou = "Enviou SMS"
        }
        config.salvaLog(evento: enviou, descricao: "\(enviou) para o número: \(phoneNumber) ",
            latitude: latitude, longitude: longitude)

    }
    
    func retURLStr() -> String {
        var urlStr = ""
        var local = false
        var msg = ""
        
        if let cfg = UserDefaults.standard.object(forKey: "config_geral") {
            let cfgDados = cfg as? NSDictionary
            local = cfgDados?["informa_local"] as! Bool
        }
        
        if let m = UserDefaults.standard.object(forKey: "msg") {
            let mDados = m as? NSDictionary
            
            if vip {
                msg = mDados?["msg_vip"] as! String
            } else {
                msg = mDados?["msg"] as! String
            }
            
            
            if local {  //Se estiver true é pq veio da configuração como true assim verifica para ver na questão da mensagem
                local = mDados?["msgcomlocalizacao"] as! Bool
            }
        }
        
        var linkLoc = ""
        if local { //monta o link da localização
            linkLoc = "http://maps.google.com/?q=" + String(latitude) + "," +
                String(longitude);
        }
        
        //Login Marcos Takimoto
        let caminho = "http://54.173.24.177/painel/api.ashx?action=sendsms&lgn=67999123122&pwd=856049&"
        
        urlStr = caminho + "msg=" + msg + " Local: " + linkLoc +  "&numbers=" + phoneNumber
        
        urlStr = urlStr.replacingOccurrences(of: " ", with: "%20")
        
        return urlStr
    }
    
    func retMsg() -> String {
        var local = false
        var msg = ""
        var msgRet = ""
        
        if let cfg = UserDefaults.standard.object(forKey: "config_geral") {
            let cfgDados = cfg as? NSDictionary
            local = cfgDados?["informa_local"] as! Bool
        }
        
        if let m = UserDefaults.standard.object(forKey: "msg") {
            let mDados = m as? NSDictionary
            
            if vip {
                msg = mDados?["msg_vip"] as! String
            } else {
                msg = mDados?["msg"] as! String
            }
            
            
            if local {  //Se estiver true é pq veio da configuração como true assim verifica para ver na questão da mensagem
                local = mDados?["msgcomlocalizacao"] as! Bool
            }
        }
        
        var linkLoc = ""
        if local { //monta o link da localização
            linkLoc = "http://maps.google.com/?q=" + String(latitude) + "," +
                String(longitude);
        }
        
        msgRet = msg + " Local: " + linkLoc
        
        return msgRet
    }

}
