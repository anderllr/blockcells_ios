//
//  JustificaTableViewController.swift
//  BlockCells
//
//  Created by Anderson Rocha on 08/01/2018.
//  Copyright © 2018 BlockCells. All rights reserved.
//

import UIKit
import Firebase

class JustificaTableViewController: UITableViewController {

    let db = Database.database().reference()
    var telefone: String = ""
    @IBOutlet var TableViewJus: UITableView!
    
    var just: [Justificativa] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tel = TelefoneUserDefaults()
        self.telefone = tel.busca()
        
        buscaDados()
    }

    func buscaDados() {
        let raiz = db.child("celulares")
        
        let cfg = raiz.child(self.telefone).child("justificativa")
        
        let jusE = cfg.queryOrdered(byChild: "justificado").queryEqual(toValue: false)
        
        //Cria o ouvinte para as justificativas
        jusE.observe(DataEventType.childAdded, with: { (snapshot) in
            let dados = snapshot.value as? NSDictionary
            
            let jus = Justificativa()
            
            jus.id_jus = Int(snapshot.key)!
            jus.data_hora = dados?["data_hora"] as! String
            jus.desc_justificativa = dados?["desc_justificativa"] as! String
            jus.evento = dados?["evento"] as! String
            jus.justificado = dados?["justificado"] as! Bool
            jus.latitude = dados?["latitude"] as! Double
            jus.longitude = dados?["longitude"] as! Double
            
            self.just.append(jus)
            self.TableViewJus.reloadData()
            
        })
        
        jusE.observe(DataEventType.childRemoved, with: { (snapshot) in
            
            var indice = 0
            for jus in self.just {
                if jus.id_jus == Int(snapshot.key) {
                    self.just.remove(at: indice)
                }
                indice = indice + 1
            }
            self.TableViewJus.reloadData()
            
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return just.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellJustificar", for: indexPath)
        
        // Configure the cell...
        let jus = self.just[indexPath.row]
        
        cell.textLabel?.text = jus.evento
        cell.detailTextLabel?.text = jus.data_hora
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let totalJus = just.count
        
        if totalJus > 0 {
            let jus = self.just[indexPath.row]
            self.performSegue(withIdentifier: "segueJustifica", sender: jus)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueJustifica" {
            
            let jusViewController = segue.destination as! JustificaViewController
            
            jusViewController.jus = sender as! Justificativa
        }
    }

}
