//
//  ConfigGeralDB.swift
//  BlockCells
//
//  Created by Anderson Rocha on 25/09/17.
//  Copyright © 2017 BlockCells. All rights reserved.
//

import Firebase

class ConfigGeralDB {
    let db = Database.database().reference()
    var telefone: String
    
    init() {
        let tel = TelefoneUserDefaults()
        self.telefone = tel.busca()
    }
    
    func inicializa() {
        //Monitora os dados do Firebase e grava no UserDefaults para ser usado na sequência
        
        let raiz = db.child("celulares")
        
        //de qualquer forma cria o observe
        let cfg = raiz.child(self.telefone)
        
        cfg.observe(DataEventType.value, with: { (snapshot) in
            
            
            // Captura o valor da configuração
            if let value = snapshot.value as? NSDictionary {
                
                //Agora trata individualmente os objetos
                //##### CONFIG GERAL ######
                let c = ConfigGeral()
                if let cfgGeral = value["config_geral"] as? NSDictionary {
                    c.ativado = cfgGeral["ativado"] as! Bool
                    c.controle_remoto = cfgGeral["controle_remoto"]  as! Bool
                    c.envia_sms = cfgGeral["envia_sms"] as! Bool
                    c.informa_local = cfgGeral["informa_local"] as! Bool
                    
                    self.salvaDados(obj: c, fire: false)
                } else {
                    self.geraValorPadrao(obj: ConfigGeral())
                }
                
                //##### MENSAGEM ######
                let m = Msg()
                if let msg = value["msg"] as? NSDictionary {
                    m.msg = msg["msg"] as! String
                    m.msg_vip = msg["msg_vip"] as! String
                    m.msgcomlocalizacao = msg["msgcomlocalizacao"] as! Bool
                    
                    self.salvaDados(obj: m, fire: false)
                } else {
                    self.geraValorPadrao(obj: Msg())
                }
                
                //##### KM ######
                let k = Km()
                if let km = value["km"] as? NSDictionary {
                    k.velocidade_min = km["velocidade_min"] as! Int16
                    k.velocidade_max = km["velocidade_max"] as! Int16
                    k.velocidade_alerta = km["velocidade_alerta"] as! Int16
                    k.emite_bip = km["emite_bip"] as! Bool
                    k.envia_alerta = km["envia_alerta"] as! Bool
                    
                    self.salvaDados(obj: k, fire: false)
                } else {
                    self.geraValorPadrao(obj: Km())
                }
                
                //##### HORARIO ######
                let h = Horario()
                if let hora = value["horario"] as? NSDictionary {
                    h.segunda = hora["segunda"] as! Bool
                    h.terca = hora["terca"] as! Bool
                    h.quarta = hora["quarta"] as! Bool
                    h.quinta = hora["quinta"] as! Bool
                    h.sexta = hora["sexta"] as! Bool
                    h.sabado = hora["sabado"] as! Bool
                    h.domingo = hora["domingo"] as! Bool
                    h.util_inicio = hora["util_inicio"] as! String
                    h.util_fim = hora["util_fim"] as! String
                    h.fds_inicio = hora["fds_inicio"] as! String
                    h.fds_fim = hora["fds_fim"] as! String
                    
                    self.salvaDados(obj: h, fire: false)
                } else {
                    self.geraValorPadrao(obj: Horario())
                }
                
                //##### SOLICITAÇÃO DE ACESSO REMOTO ######
                let s = Solicitacao()
                if let sol = value["solicitacao"] as? NSDictionary {
                    s.aceito = sol["aceito"] as! Bool
                    s.nome = sol["nome"] as! String
                    s.username = sol["username"] as! String
                    
                    
                    self.salvaDados(obj: s, fire: false)
                } else {
                    self.geraValorPadrao(obj: Solicitacao())
                }
                
            } else {
                //Como ainda não existe o telefone atribui então os valores
                self.geraValorPadrao(obj: NSData())

            }
        })
        
    }
    
    func geraValorPadrao(obj: AnyObject!) {

        
        //***** CONFIG GERAL *****//
        if obj is ConfigGeral || obj.isEqual(NSData()) {
            let c = ConfigGeral()
            c.ativado = true
            c.controle_remoto = false
            c.envia_sms = true
            c.informa_local = true
            
            self.salvaDados(obj: c, fire: true)
        }
        
        //***** MENSAGEM *****//
        if obj is Msg || obj.isEqual(NSData()) {
            let m = Msg()
            m.msg = "Em trânsito, celular é bloqueado app BlockCells, ao parar retornarei!"
            m.msg_vip = "Celular bloqueado (BlockCells) se URGENTE ligue novamente retornarei"
            m.msgcomlocalizacao = true
            
            self.salvaDados(obj: m, fire: true)
        }
        
        //***** KM *****//
        if obj is Km || obj.isEqual(NSData()) {
            let k = Km()
            k.velocidade_min = 20
            k.velocidade_max = 110
            k.velocidade_alerta = 95
            k.emite_bip = true
            k.envia_alerta = true
            
            self.salvaDados(obj: k, fire: true)
        }
        
        //***** HORARIO *****//
        if obj is Horario || obj.isEqual(NSData()) {
            let h = Horario()
            h.segunda = true
            h.terca = true
            h.quarta = true
            h.quinta = true
            h.sexta = true
            h.sabado = true
            h.domingo = true
            h.util_inicio = "00:00"
            h.util_fim = "23:59"
            h.fds_inicio = "00:00"
            h.fds_fim = "23:59"
            
            self.salvaDados(obj: h, fire: true)
        }
        
        //***** SOLICITAÇÃO DE ACESSO REMOTO *****//
        if obj is Solicitacao || obj.isEqual(NSData()) {
            let s = Solicitacao()
            s.nome = ""
            s.username = ""
            s.aceito = false
            
            self.salvaDados(obj: s, fire: true)
        }
    }
    
    func salvaDados(obj: AnyObject!, fire: Bool) {
        let raiz = db.child("celulares")
 
        //***** CONFIG GERAL *****//
        if let config = obj as? ConfigGeral {
            let cfg = raiz.child(self.telefone).child("config_geral")
            
            //converte a variável genérica
          //  let config = obj as! ConfigGeral
            
            //Cria dicionário para os dados dentro do snap
            let dados = [
                "ativado": config.ativado,
                "controle_remoto": config.controle_remoto,
                "envia_sms": config.envia_sms,
                "informa_local": config.informa_local
            ]
            
            //Salva no Firebase
            if (fire) {
                cfg.setValue(dados)
            }
            //Agora salva no local
            UserDefaults.standard.set(dados, forKey: "config_geral")
        }
        
        //***** MENSAGEM *****//
        if let msgRet = obj as? Msg {
            let msg = raiz.child(self.telefone).child("msg")
            
            //Cria dicionário para os dados dentro do snap
            let dadosMsg = [
                "msg": msgRet.msg,
                "msg_vip": msgRet.msg_vip,
                "msgcomlocalizacao": msgRet.msgcomlocalizacao
                ] as [String : Any]
            
            //Salva no Firebase
            if (fire) {
                msg.setValue(dadosMsg)
            }
            //Agora salva no local
            UserDefaults.standard.set(dadosMsg, forKey: "msg")
        }
        
        //***** KM *****//
        if let kmRet = obj as? Km {
            let km = raiz.child(self.telefone).child("km")
            
            //Cria dicionário para os dados dentro do snap
            let dadosKm = [
                "velocidade_min": kmRet.velocidade_min,
                "velocidade_max": kmRet.velocidade_max,
                "velocidade_alerta": kmRet.velocidade_alerta,
                "envia_alerta": kmRet.envia_alerta,
                "emite_bip": kmRet.emite_bip
                ] as [String : Any]
            
            //Salva no Firebase
            if (fire) {
                km.setValue(dadosKm)
            }
            //Agora salva no local
            UserDefaults.standard.set(dadosKm, forKey: "km")
        }
        
        //***** HORARIO *****//
        if let hrRet = obj as? Horario {
            let h = raiz.child(self.telefone).child("horario")
            
            //Cria dicionário para os dados dentro do snap
            let dadosHorario = [
                "segunda": hrRet.segunda,
                "terca": hrRet.terca,
                "quarta": hrRet.quarta,
                "quinta": hrRet.quinta,
                "sexta": hrRet.sexta,
                "sabado": hrRet.sabado,
                "domingo": hrRet.domingo,
                "util_inicio": hrRet.util_inicio,
                "util_fim": hrRet.util_fim,
                "fds_inicio": hrRet.fds_inicio,
                "fds_fim": hrRet.fds_fim

                ] as [String : Any]
            
            //Salva no Firebase
            if (fire) {
                h.setValue(dadosHorario)
            }
            //Agora salva no local
            UserDefaults.standard.set(dadosHorario, forKey: "horario")
        }
        
        //***** CONTATOS *****//
        if let conRet = obj as? Contato {
            let contato = raiz.child(self.telefone).child("contatovip").child(getString(str: String(conRet.id_contato)))
            
            //Cria dicionário para os dados dentro do snap
            let dadosCon = [
                "nome": conRet.nome,
                "fone": conRet.fone]

            //Salva no Firebase
            if (fire) {
                contato.setValue(dadosCon)
            }
        }
        
        //***** LOG *****//
        if let logRet = obj as? Log {
            let log = raiz.child(self.telefone).child("log_eventos").child(String(logRet.id_log))
            //Cria dicionário para os dados dentro do snap
            let dadosLog = [
                "data_hora": logRet.data_hora,
                "descricao": logRet.descricao,
                "evento": logRet.evento,
                "id": logRet.id_log,
                "latitude": logRet.latitude,
                "longitude": logRet.longitude,
                "localizacao": logRet.localizacao] as [String : Any]
            
            //Salva no Firebase
            if (fire) {
                log.setValue(dadosLog)
            }
        }
        
        //***** JUSTIFICATIVA *****//
        if let jusRet = obj as? Justificativa {
            let jus = raiz.child(self.telefone).child("justificativa").child(String(jusRet.id_jus))
            //Cria dicionário para os dados dentro do snap
            let dadosJus = [
                "data_hora": jusRet.data_hora,
                "evento": jusRet.evento,
                "desc_justificativa": jusRet.desc_justificativa,
                "id": jusRet.id_jus,
                "latitude": jusRet.latitude,
                "longitude": jusRet.longitude,
                "justificado": jusRet.justificado] as [String : Any]
            
            //Salva no Firebase
            if (fire) {
                jus.setValue(dadosJus)
            }
        }
        
        //***** SOLICITACAO DE ACESSO REMOTO *****//
        if let solRet = obj as? Solicitacao {
            let sol = raiz.child(self.telefone).child("solicitacao")
            
            //Cria dicionário para os dados dentro do snap
            let dadosSol = [
                "aceito": solRet.aceito,
                "nome": solRet.nome,
                "username": solRet.username
                
                ] as [String : Any]
            
            //Salva no Firebase
            if (fire) {
                sol.setValue(dadosSol)
            }
            //Agora salva no local
            UserDefaults.standard.set(dadosSol, forKey: "solicitacao")
        }
    }
    
    func buscaCG() -> ConfigGeral {
        
      //  let dados = UserDefaults.standard.object(forKey: "config_geral") as! [String:Bool]
        
        let c = ConfigGeral()
        
        if let cfgDados = UserDefaults.standard.object(forKey: "config_geral") {
            let dados =  cfgDados as! [String:Bool]
            c.ativado = dados["ativado"]!
            c.controle_remoto = dados["controle_remoto"]!
            c.envia_sms = dados["envia_sms"]!
            c.informa_local = dados["informa_local"]!
        } else {
            c.ativado = true
            c.controle_remoto = false
            c.envia_sms = true
            c.informa_local = true
        }
        
        return c
        
    }
    
    func getString(str: String) -> String {
        var strRet = str
        if (str.count == 1) {
            strRet = "00" + str
        }
        else if (str.count == 2) {
                strRet = "0" + str
        }
        return strRet
    }
    
    func salvaLog(evento: String, descricao: String, latitude: Double, longitude: Double) {

        //busca a data e hora atual
        let currentDateTime = Date()
        let data_hora = dateToStringBR(date: currentDateTime)
        
        //agora busca se tem localização
        var localizacao = false
        if latitude > 0.0 {
            localizacao = true
        }
        
        let log = Log()
        
        log.id_log = 1 //começa com 1 se for diferente mudará lá embaixo
        log.data_hora = data_hora
        log.evento = evento
        log.descricao = descricao
        log.localizacao = localizacao
        log.latitude = latitude
        log.longitude = longitude
        
        //Já entra e salva a justificativa que deverá ser tratada posteriormente
        self.salvaJus(data_hora: data_hora, evento: evento, latitude: latitude, longitude: longitude)
        
        let raiz = db.child("celulares").child(self.telefone)
        var id = 1
        raiz.observeSingleEvent(of: .value) { (snap) in
            if snap.hasChild("log_eventos") { //se existe a raiz busca a sequência
                let logE = raiz.child("log_eventos")
                
                //Cria o ouvinte para os contatos
                logE.queryLimited(toLast: 1).observe(DataEventType.childAdded, with: { (snapshot) in
                    //entrou no observe

                    if let idUltimo = Int(snapshot.key) {
                        id = idUltimo + 1
                    }
                    
                    log.id_log = id
                    
                    logE.removeAllObservers()
                    self.salvaDados(obj: log, fire: true)
                })
            } else {
                self.salvaDados(obj: log, fire: true)
            }
        }
    }
    
    //Salva a informação que precisa ser justificada
    func salvaJus(data_hora: String, evento: String, latitude: Double, longitude: Double) {
        
        let eventos = ["Excesso de Velocidade", "Efetuou Ligação", "Atendeu Ligação"]
        
        //Verifica se o evento gerado se refere a algum dos que geram obrigação de justificar
        if eventos.contains(evento) {
            let jus = Justificativa()
            
            jus.id_jus = 1 //começa com 1 se for diferente mudará lá embaixo
            jus.data_hora = data_hora
            jus.evento = evento
            jus.desc_justificativa = ""
            jus.justificado = false
            jus.latitude = latitude
            jus.longitude = longitude
            
            let raiz = db.child("celulares").child(self.telefone)
            var id = 1
            raiz.observeSingleEvent(of: .value) { (snapjus) in
                if snapjus.hasChild("justificativa") { //se existe a raiz busca a sequência
                    let jusE = raiz.child("justificativa")
                    
                    //Cria o ouvinte para os contatos
                    jusE.queryLimited(toLast: 1).observe(DataEventType.childAdded, with: { (snapshot) in
                        //entrou no observe
                        
                        if let idUltimo = Int(snapshot.key) {
                            id = idUltimo + 1
                        }
                        
                        jus.id_jus = id
                        
                        jusE.removeAllObservers()
                        self.salvaDados(obj: jus, fire: true)
                        
                    })
                } else {
                    self.salvaDados(obj: jus, fire: true)
                }
            }
        }
    }
    
    //Rotina que irá salvar os sms à enviar no Firebase para ser enviado através de algum dispositivo android
    func salvaSms(phoneNumber: String, msg: String) {
  
        let sms = db.child("sms")
        
        //Cria dicionário para os dados dentro do sms
        let smsMsg = [
            "phoneNumber": phoneNumber,
            "msg": msg,
            "from": self.telefone
        ]
        
        sms.childByAutoId().setValue(smsMsg)
        
    }
    
    func dateToStringBR (date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        let strDate = dateFormatter.string(from: date)
        return(strDate)
    }
    
    
}
