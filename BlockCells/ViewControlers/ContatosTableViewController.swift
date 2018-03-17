//
//  ContatosTableViewController.swift
//  BlockCells
//
//  Created by Anderson Rocha on 23/09/17.
//  Copyright © 2017 BlockCells. All rights reserved.
//

import UIKit
import Firebase
import ContactsUI

class ContatosTableViewController: UITableViewController, CNContactPickerDelegate {
    
    @IBOutlet var tableView2: UITableView!
    @IBOutlet weak var btnSalvar: UIBarButtonItem!
    
    let db = Database.database().reference()
    var telefone: String = ""
    
    var contatos: [Contato] = []
    
    @IBAction func voltar(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
        db.removeAllObservers()
    }
    
    @IBAction func addContact(_ sender: Any) {
        
        if contatos.count == 3 {
            let alerta = Alerta(titulo: "Excesso de contatos", mensagem: "Número máximo de contatos é 3")
            self.present(alerta.getAlerta(), animated: true, completion: nil)
        } else {

            let cnPicker = CNContactPickerViewController()
            cnPicker.delegate = self
            self.present(cnPicker, animated: true, completion: nil)
        }
        
    }
    
    func salvaContato(nome : String, fone: String) {
        
        let contato = Contato()
        let cfgDB = ConfigGeralDB()
        
        contato.id_contato = self.getInterval()
        contato.nome = nome
        contato.fone = fone

        cfgDB.salvaDados(obj: contato, fire: true)
    }
    
    func getInterval() -> Int {
        var encontrou: Bool = true
        var ind: Int = 0
        while encontrou {
            encontrou = false
            ind = ind + 1
            for i in 0 ..< self.contatos.count {
                if contatos[i].id_contato == ind {
                    encontrou = true
                }
            }
        }
        return ind
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {

        picker.dismiss(animated: true, completion: nil)
        
    }
    
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        picker.dismiss(animated: true, completion: nil)
        
        var nomeContato = ""
        var nrTelefone = ""
        
        //See if the contact has multiple phone numbers
        if contact.phoneNumbers.count > 1 {
            
            //If so we need the user to select which phone number we want them to use
            let multiplePhoneNumbersAlert = UIAlertController(title: "Escolha Um?", message: "Este contato tem múltiplos números, qual deles você quer usar?", preferredStyle: UIAlertControllerStyle.alert)
            
            //Loop through all the phone numbers that we got back
            for number in contact.phoneNumbers {
                
                //Each object in the phone numbers array has a value property that is a CNPhoneNumber object, Make sure we can get that
                let actualNumber = number.value as CNPhoneNumber
                
                //Get the label for the phone number
                var phoneNumberLabel = number.label
                
                //Strip off all the extra crap that comes through in that label
                phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "_", with: "")
                phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "$", with: "")
                phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "!", with: "")
                phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "<", with: "")
                phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: ">", with: "")
                
                //Create a title for the action for the UIAlertVC that we display to the user to pick phone numbers
                let actionTitle = phoneNumberLabel! + " - " + actualNumber.stringValue
                
                //Create the alert action
                let numberAction = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.default, handler: { (theAction) -> Void in
                   
                    //See if we can get A frist name
                    if contact.givenName != "" {
                        nomeContato = contact.givenName
                    }
                    //If Not check for a last name
                    if contact.familyName != "" {
                        nomeContato = nomeContato + " " + contact.familyName
                    }
                    
                    /* Não usarei imagem
                    // See if we can get image data
                    if let imageData = contact.imageData {
                        //If so create the image
                        //self.userImage = UIImage(data: imageData)!
                        print("Tinha imagem")
                    }
                    */
                    //Do what you need to do with your new contact information here!
                    //Get the string value of the phone number like this:
                    //self.numeroADiscar = actualNumber.stringValue
                    nrTelefone = actualNumber.stringValue
            
                    self.salvaContato(nome: nomeContato, fone: nrTelefone)
                    
                })
                
                //Add the action to the AlertController
                multiplePhoneNumbersAlert.addAction(numberAction)
                
            }
            
            //Add a cancel action
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (theAction) -> Void in
                //Cancel action completion
            })
            
            //Add the cancel action
            multiplePhoneNumbersAlert.addAction(cancelAction)
            
            //Present the ALert controller
            self.present(multiplePhoneNumbersAlert, animated: true, completion: nil)
            
        } else {
            
            //Make sure we have at least one phone number
            if contact.phoneNumbers.count > 0 {
                
                //If so get the CNPhoneNumber object from the first item in the array of phone numbers
                let actualNumber = (contact.phoneNumbers.first?.value)! as CNPhoneNumber
                
                //Get the label of the phone number
                var phoneNumberLabel = contact.phoneNumbers.first!.label
                
                //Strip out the stuff you don't need
                phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "_", with: "")
                phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "$", with: "")
                phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "!", with: "")
                phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "<", with: "")
                phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: ">", with: "")
                
                //Create an empty string for the contacts name
                //self.nameToSave = ""
                //See if we can get A frist name
                if contact.givenName != "" {
                    nomeContato = contact.givenName
                }
                //If Not check for a last name
                if contact.familyName != "" {
                    nomeContato = nomeContato + " " + contact.familyName
                }
                
                /* Não usarei imagem
                 // See if we can get image data
                 if let imageData = contact.imageData {
                 //If so create the image
                 //self.userImage = UIImage(data: imageData)!
                 }
                 */
                //Do what you need to do with your new contact information here!
                //Get the string value of the phone number like this:
                nrTelefone = actualNumber.stringValue
                
                self.salvaContato(nome: nomeContato, fone: nrTelefone)
                
            } else {
                
                //If there are no phone numbers associated with the contact I call a custom funciton I wrote that lets me display an alert Controller to the user
                let alert = UIAlertController(title: "Missing info", message: "You have no phone numbers associated with this contact", preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                present(alert, animated: true, completion: nil)
                
            }
        }
        

    
    }
    /*
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        
        // I only want single selection
        if contacts.count != 1 {
  //          print("Mais que dois")
    //        let alerta2 = UIAlertController(title: "Erro de seleção", message: "Selecione apenas um contato por vez!", preferredStyle: UIAlertControllerStyle.alert)
      //      self.present(alerta2, animated: true, completion: nil)
            
        } else {
            
            //Dismiss the picker VC
            picker.dismiss(animated: true, completion: nil)
            
            let contact: CNContact = contacts[0]
            
            //See if the contact has multiple phone numbers
            if contact.phoneNumbers.count > 1 {
                
                //If so we need the user to select which phone number we want them to use
                let multiplePhoneNumbersAlert = UIAlertController(title: "Which one?", message: "This contact has multiple phone numbers, which one did you want use?", preferredStyle: UIAlertControllerStyle.alert)
                
                //Loop through all the phone numbers that we got back
                for number in contact.phoneNumbers {
                    
                    //Each object in the phone numbers array has a value property that is a CNPhoneNumber object, Make sure we can get that
                    let actualNumber = number.value as CNPhoneNumber
                    
                    //Get the label for the phone number
                    var phoneNumberLabel = number.label
                    
                    //Strip off all the extra crap that comes through in that label
                    phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "_", with: "")
                    phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "$", with: "")
                    phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "!", with: "")
                    phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "<", with: "")
                    phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: ">", with: "")
                    
                    //Create a title for the action for the UIAlertVC that we display to the user to pick phone numbers
                    let actionTitle = phoneNumberLabel! + " - " + actualNumber.stringValue
                    
                    //Create the alert action
                    let numberAction = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.default, handler: { (theAction) -> Void in
                        
                        //See if we can get A frist name
                        if contact.givenName == "" {
                            
                            //If Not check for a last name
                            if contact.familyName == "" {
                                //If no last name set name to Unknown Name
                                print("Unknown Name 1")
                                //self.nameToSave = "Unknown Name"
                            }else{
                                //self.nameToSave = contact.familyName
                                print(contact.familyName)
                            }
                            
                        } else {
                            
                            //self.nameToSave = contact.givenName
                            print(contact.givenName)
                            
                        }
                        
                        // See if we can get image data
                        if let imageData = contact.imageData {
                            //If so create the image
                            //self.userImage = UIImage(data: imageData)!
                            print("Tinha imagem")
                        }
                        
                        //Do what you need to do with your new contact information here!
                        //Get the string value of the phone number like this:
                        //self.numeroADiscar = actualNumber.stringValue
                        print(actualNumber.stringValue)
                        
                    })
                    
                    //Add the action to the AlertController
                    multiplePhoneNumbersAlert.addAction(numberAction)
                    
                }
                
                //Add a cancel action
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (theAction) -> Void in
                    //Cancel action completion
                })
                
                //Add the cancel action
                multiplePhoneNumbersAlert.addAction(cancelAction)
                
                //Present the ALert controller
                self.present(multiplePhoneNumbersAlert, animated: true, completion: nil)
                
            } else {
                
                //Make sure we have at least one phone number
                if contact.phoneNumbers.count > 0 {
                    
                    //If so get the CNPhoneNumber object from the first item in the array of phone numbers
                    let actualNumber = (contact.phoneNumbers.first?.value)! as CNPhoneNumber
                    
                    //Get the label of the phone number
                    var phoneNumberLabel = contact.phoneNumbers.first!.label
                    
                    //Strip out the stuff you don't need
                    phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "_", with: "")
                    phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "$", with: "")
                    phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "!", with: "")
                    phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: "<", with: "")
                    phoneNumberLabel = phoneNumberLabel?.replacingOccurrences(of: ">", with: "")
                    
                    //Create an empty string for the contacts name
                    //self.nameToSave = ""
                    //See if we can get A frist name
                    if contact.givenName == "" {
                        //If Not check for a last name
                        if contact.familyName == "" {
                            //If no last name set name to Unknown Name
                            //self.nameToSave = "Unknown Name"
                            print("Unknown Name 2")
                        }else{
                            //self.nameToSave = contact.familyName
                            print(contact.familyName)
                        }
                    } else {
                        //nameToSave = contact.givenName
                        print(contact.givenName)
                    }
                    
                    // See if we can get image data
                    if let imageData = contact.imageData {
                        //If so create the image
                       // self.userImage = UIImage(data: imageData)
                        print("Imagem2")
                    }
                    
                    //Do what you need to do with your new contact information here!
                    //Get the string value of the phone number like this:
                    //self.numeroADiscar = actualNumber.stringValue
                    print(actualNumber.stringValue)
                    
                } else {
                    
                    //If there are no phone numbers associated with the contact I call a custom funciton I wrote that lets me display an alert Controller to the user
                    let alert = UIAlertController(title: "Missing info", message: "You have no phone numbers associated with this contact", preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    present(alert, animated: true, completion: nil)
                    
                }
            }
        }
        
    }
 */
 

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tel = TelefoneUserDefaults()
        self.telefone = tel.busca()
        
        buscaDados()
        
        habilitaSalvar()
    }

    func buscaDados() {
        let raiz = db.child("celulares")
        
        let contact = raiz.child(self.telefone).child("contatovip")
        
        //Cria o ouvinte para os contatos
        contact.queryOrderedByKey().observe(DataEventType.childAdded, with: { (snapshot) in
            let dados = snapshot.value as? NSDictionary
            
            let contato = Contato()
            
            contato.id_contato = Int(snapshot.key)!
            contato.nome = dados?["nome"] as! String
            contato.fone = dados?["fone"] as! String
            
            self.contatos.append(contato)
            self.tableView2.reloadData()
            
            //Agora salva no local
            var conts: [String] = []
            for c in self.contatos {
                conts.append(c.fone)
            }
             UserDefaults.standard.set(conts, forKey: "contatovip")
        })
        
        //Ouvinte para deleção de contatos
        contact.observe(DataEventType.childRemoved, with: { (snapshot) in
            
            var indice = 0
            for contato in self.contatos {
                if contato.id_contato == Int(snapshot.key) {
                    self.contatos.remove(at: indice)
                }
                indice = indice + 1
            }
            
            self.tableView.reloadData()
        })
        
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
        return contatos.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellContatos", for: indexPath)

        // Configure the cell...
        let contato = self.contatos[indexPath.row]

        cell.textLabel?.text = contato.nome
        cell.detailTextLabel?.text = contato.fone

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            let raiz = db.child("celulares")
            
            let contact = raiz.child(self.telefone).child("contatovip")
            
            let contato = self.contatos[indexPath.row]
            
            self.contatos.remove(at: indexPath.row)
            contact.child(getString(str: String(contato.id_contato)) ).removeValue()
        }
        
    }
    
    func habilitaSalvar() {
        let cfgDB = ConfigGeralDB()
        let cfg = cfgDB.buscaCG()
        
        //significa que está sendo controlado remotamente então desabilita do salvar
        if cfg.controle_remoto {
            btnSalvar.isEnabled = false
        }
    }


}
