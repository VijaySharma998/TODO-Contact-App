//
//  ViewController.swift
//  ToDoListApp
//
//  Created by Vijay Sharma on 08/09/24.
//

import UIKit
import RealmSwift

class Contact: Object  {
    @Persisted var firstName: String
    @Persisted var lastName: String
    
    convenience init(firstName: String, lastName: String) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var contactTblView: UITableView!
    
    var contactArr = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configuration()
    }
    @IBAction func addContactTapped(_ sender: UIBarButtonItem) {
        contactConfiguration(isAdd: true, index: 0)
    }
}

extension ViewController {
    func contactConfiguration(isAdd: Bool, index: Int) {
        let alertController = UIAlertController(title: isAdd ? "Add the contact" : "Update the contact", 
                                                message: isAdd ? "Please enter your contact details":"Please update your contact details" ,
                                                preferredStyle: .alert)
        
        let saveButton = UIAlertAction(title: isAdd ? "Save" : "Update", style: .default) { _ in
            
            if let firstName = alertController.textFields?.first?.text,
               let lastName = alertController.textFields?[1].text {
                print(firstName)
                print(lastName)
                let contact = Contact(firstName: firstName, lastName: lastName)
                if isAdd {
                    self.contactArr.append(contact)
                    DatabaseHelper.shared.saveContact(contact)
                } else {
                    //self.contactArr[index] = contact
                    DatabaseHelper.shared.updateContact(oldContact: self.contactArr[index],
                                                        newContact: contact)
                }
                
                self.contactTblView.reloadData()
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addTextField { firstNameTxt in
            
            firstNameTxt.placeholder = isAdd  ? "Enter your first name" : self.contactArr[index].firstName
            
        }
        alertController.addTextField { lastNameTxt in
            lastNameTxt.placeholder = isAdd ? "Enter your last name" : self.contactArr[index].lastName
        }
        alertController.addAction(saveButton)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }
    
    func configuration() {
        contactTblView.dataSource = self
        contactTblView.delegate = self
        contactTblView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        contactArr = DatabaseHelper.shared.getContact()
    }
}
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contactArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard var cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = contactArr[indexPath.row].firstName
        cell.detailTextLabel?.text = contactArr[indexPath.row].lastName
        return cell
    }
    
    
}
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editContact = UIContextualAction(style: .normal, title: "Edit") { _, _, _ in
            self.contactConfiguration(isAdd: false, index: indexPath.row)
        }
        editContact.image?.withTintColor(.black)
        let editImage = UIImage(systemName: "pencil")
        editContact.image = editImage
        
        let deleteContact = UIContextualAction(style: .destructive, title: nil) { _, _, _ in
            DatabaseHelper.shared.deleteContact(self.contactArr[indexPath.row])
            self.contactArr.remove(at: indexPath.row)
            
            self.contactTblView.reloadData()
        }
        let deleteImage = UIImage(systemName: "trash")
        deleteContact.image = deleteImage
        let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [editContact,deleteContact])
        return swipeActionsConfiguration
    }
}

