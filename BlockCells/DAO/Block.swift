//
//  Block.swift
//  BlockCells
//
//  Created by Anderson Rocha on 20/10/17.
//  Copyright © 2017 BlockCells. All rights reserved.
//
//  Classe que irá tratar se deve bloquear ou não a ligação

import Foundation


class Block {
    var phoneNumber: String
    var speed: Int
    var latitude: Double
    var longitude: Double
    var segunda: Bool!
    var terca: Bool!
    var quarta: Bool!
    var quinta: Bool!
    var sexta: Bool!
    var sabado: Bool!
    var domingo: Bool!
    var util_inicio: String!
    var util_fim: String!
    var fds_inicio: String!
    var fds_fim: String!
    var lastCall: String = ""
    
    init(phoneNumber: String, speed: Int, latitude: Double, longitude: Double) {
        self.phoneNumber = phoneNumber
        self.speed = speed
        self.latitude = latitude
        self.longitude = longitude
      
        //busca os valores da UserDefaults
        if let cl = UserDefaults.standard.object(forKey: "lastCall") {
            self.lastCall = cl as! String
        }
        
        if let hr = UserDefaults.standard.object(forKey: "horario") {
            let hrDados = hr as? NSDictionary
            self.segunda = hrDados?["segunda"] as! Bool
            self.terca = hrDados?["terca"] as! Bool
            self.quarta = hrDados?["quarta"] as! Bool
            self.quinta = hrDados?["quinta"] as! Bool
            self.sexta = hrDados?["sexta"] as! Bool
            self.sabado = hrDados?["sabado"] as! Bool
            self.domingo = hrDados?["domingo"] as! Bool
            self.util_inicio = hrDados?["util_inicio"] as! String
            self.util_fim = hrDados?["util_fim"] as! String
            self.fds_inicio = hrDados?["fds_inicio"] as! String
            self.fds_fim = hrDados?["fds_fim"] as! String
        }
    }
    
    func isBlocked(obsLog: String) -> Bool {
        //ConfigGeral
        let cfGeral = ConfigGeralDB()
       // let cfg = cfGeral.buscaCG()
        
        //inicializa como false pois ainda não testou nenhuma regra, conforme a regra for valida marca como blocked = true
        var blocked = false
        
        //**** Se a partir de agora tivermos algum false já desabilita o bloqueio ****
        
        //Verifica se o dia está habilitado
        //Captura o dia da semana
        let today = Date()
        let calendar = Calendar.current
        // let weekDay = calendar!.components([.weekday], from: today)
        let myComponents = calendar.dateComponents([.weekday], from: today)
        let weekDay = myComponents.weekday
        
        //Inicializa a hora como útil
        var hrIni = self.util_inicio
        var hrFim = self.util_fim
        
        switch (weekDay) {
        case 1?:
            blocked = (self.domingo);
            hrIni = self.fds_inicio
            hrFim = self.fds_fim
            break;
        case 2?:
            blocked = (self.segunda);
            break;
        case 3?:
            blocked = (self.terca);
            break;
        case 4?:
            blocked = (self.quarta);
            break;
        case 5?:
            blocked = (self.quinta);
            break;
        case 6?:
            blocked = (self.sexta);
            break;
        case 7?:
            blocked = (self.sabado);
            hrIni = self.fds_inicio
            hrFim = self.fds_fim
            break;
        default:
            blocked = true
        }
        

        //Se está habilitado até aqui agora verifica se a hora
        
        if blocked { //blocked do intervalo de horas do dia

            let dtIniStr = self.dateToString(date: today) + " " + hrIni!
            let dtFimStr = self.dateToString(date: today) + " " + hrFim!
            
            let dtIni = self.stringToDate(dateStr: dtIniStr)
            let dtFim = self.stringToDate(dateStr: dtFimStr)
            
            blocked = today >= dtIni && today <= dtFim
            
        } //blocked do intervalo de horas do dia
        var vip: Bool = false
        //agora vai verificar o contato vip
        if blocked { // blocked do vip
            let dados = UserDefaults.standard.object(forKey: "contatovip")
            if  dados != nil {
                let contacts = dados as! Array<String>
                for cont in contacts {
                    let contact = cont as String
                    if (!vip) {
                        vip = self.isVip(contact: contact)
                        if vip {
                            if self.phoneNumber == self.lastCall {
                                blocked = false
                                cfGeral.salvaLog(evento: "Ligação Vip", descricao: "Liberou ligação do número \(self.phoneNumber)", latitude: self.latitude, longitude: self.longitude)
                            }
                        }
                    }
                } //fim do for
            }
        } // blocked do vip
        
        //Agora verifica para gravar o log e enviar o sms
        if blocked {
            cfGeral.salvaLog(evento: obsLog, descricao: "Ligação na velocidade:  \(self.speed)", latitude: self.latitude, longitude: self.longitude)
            
            //Envia o sms -- Não vai ter envio de sms pois não houve captura do número
      /*      if cfg.envia_sms {
                let sms = SendSMS(phoneNumber: self.phoneNumber, vip: vip, latitude: self.latitude, longitude: self.longitude)
                sms.sendMessage()
            }
        */
        }
        
        return blocked
    }
    
    func dateToString (date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let strDate = dateFormatter.string(from: date)
        return(strDate)
    }
    
    func stringToDate(dateStr: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        let date = dateFormatter.date(from: dateStr) //according to date format your date string
        
        return date!
    }
    
    func isVip (contact: String) -> Bool {
        var vip = false
        //aqui vai comparar se um número é igual ao outro
        let phoneClean = self.phoneNumber.replacingOccurrences(of: "[-()+ ]", with: "",options: .regularExpression)
        let contactClean = contact.replacingOccurrences(of: "[-()+ ]", with: "",options: .regularExpression)
        if phoneClean == contactClean {
            vip = true
        }
        //Tenta buscar num intervalo menor com substring, por conta de formas cadastrais
        if phoneClean.suffix(9) == contactClean.suffix(9) {
            vip = true
        }
        return vip
    }
}
