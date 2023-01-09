//
//  ViewController.swift
//  StudentRealTimeDatabase
//
//  Created by ROY ALAMEH on 1/4/23.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableOutlet: UITableView!
    @IBOutlet weak var viewOutlet: UITextView!
    @IBOutlet weak var textFieldOutlet: UITextField!
    var ref: DatabaseReference!
    var names = [String]()

    override func viewDidLoad() {
        tableOutlet.delegate = self
        tableOutlet.dataSource = self
        super.viewDidLoad()
        // ref is now a reference to the database
        ref = Database.database().reference()
        //reading from the kUTTypeDatabase
        //automatically called at start and for every child added
        ref.child("names").observe(.childAdded) { snapshot in
            self.names.append(snapshot.value as! String)
            self.tableOutlet.reloadData()
        }
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        var name = textFieldOutlet.text!
        //names.append(name)
        print(names)
        ref.child("names").childByAutoId().setValue(name)
    }
    
    
    @IBAction func clearButton(_ sender: UIButton) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableOutlet.dequeueReusableCell(withIdentifier: "myCell")!
        cell.textLabel?.text = names[indexPath.row]
        return cell
    }
    
}

