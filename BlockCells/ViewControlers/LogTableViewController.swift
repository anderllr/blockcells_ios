//
//  LogTableViewController.swift
//  BlockCells
//
//  Created by Anderson Rocha on 23/09/17.
//  Copyright © 2017 BlockCells. All rights reserved.
//

import UIKit
import Firebase

class LogTableViewController: UITableViewController {
    
    let db = Database.database().reference()
    var telefone: String = ""
    
    var logs: [Log] = []

    @IBOutlet var tableView2: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tel = TelefoneUserDefaults()
        self.telefone = tel.busca()
        
        buscaDados()
    }
    
    func buscaDados() {
        let raiz = db.child("celulares")
        
        let logE = raiz.child(self.telefone).child("log_eventos")
        
        //Cria o ouvinte para os contatos
        logE.queryLimited(toLast: 30).observe(DataEventType.childAdded, with: { (snapshot) in
            let dados = snapshot.value as? NSDictionary
            
            let log = Log()
            
            log.id_log = Int(snapshot.key)!
            log.data_hora = dados?["data_hora"] as! String
            log.descricao = dados?["descricao"] as! String
            log.evento = dados?["evento"] as! String
            log.localizacao = dados?["localizacao"] as! Bool
            log.latitude = dados?["latitude"] as! Double
            log.longitude = dados?["longitude"] as! Double
            
            self.logs.append(log)
            self.tableView2.reloadData()
  
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return logs.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellLog", for: indexPath)

        // Configure the cell...
        let log = self.logs[indexPath.row]
        
        cell.textLabel?.text = log.evento
        cell.detailTextLabel?.text = log.descricao
        
        return cell
    }

}
