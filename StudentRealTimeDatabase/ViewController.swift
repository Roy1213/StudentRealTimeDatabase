//
//  ViewController.swift
//  StudentRealTimeDatabase
//
//  Created by ROY ALAMEH on 1/4/23.
//

import UIKit
import FirebaseCore
import FirebaseDatabase

class Student {
    //line below is creating firebase reference
    var ref = Database.database().reference()
    var name : String
    var age : Int
    var key = ""
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    init (dict: [String: Any]) {
        //reading from firebase
        if let n = dict["name"] as? String {
            name = n
        }
        else {
            name = "cheese man"
        }
        if let a = dict["age"] as? Int {
            age = a
        }
        else {
            age = 500
        }
    }
    
    func saveToFirebase() {
        var dict = ["name" : name, "age" : age] as [String : Any]
        key = ref.child("students").childByAutoId().key ?? "0"
        ref.child("students").child(key).setValue(dict)
    }
    func deleteFromFirebase() {
        ref.child("students").child(key).removeValue()
    }
    func editOnFirebase() {
        let dict = ["name" : name, "age" : age] as! [String : Any]
        ref.child("students").child(key).updateChildValues(dict)
    }
    
    func equals(s1: Student) -> Bool {
        if s1.name == self.name && s1.age == age {
            return true
        }
        return false
    }
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var ageOutlet: UITextField!
    @IBOutlet weak var tableOutlet: UITableView!
    @IBOutlet weak var viewOutlet: UITextView!
    @IBOutlet weak var textFieldOutlet: UITextField!
    var ref: DatabaseReference!
    var names = [String]()
    var students = [Student]()
    var lastStudent = Student(name: "", age: 0)
    var selectedIndex = -1

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
        
        ref.child("students").observe(.childAdded) { snapshot in
            let dict = snapshot.value as! [String: Any]
            var student = Student(dict: dict)
            student.key = snapshot.key
            self.students.append(student)
            self.tableOutlet.reloadData()
        }
        ref.child("students").observe(.childRemoved) {snapshot in
            let key = snapshot.key
            for var i in 0 ..< self.students.count {
                if self.students[i].key == key {
                    self.students.remove(at: i)
                    break
                }
            }
            self.tableOutlet.reloadData()
        }
        
        ref.child("students").observe(.childChanged) {snapshot in
            let key = snapshot.key
            let value = snapshot.value as! [String : Any]
            for var i in 0 ..< self.students.count {
                if self.students[i].key == key {
                    self.students[i].name = value["name"] as! String
                    self.students[i].age = value["age"] as! Int
                }
            }
            self.tableOutlet.reloadData()
        }
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        var name = textFieldOutlet.text!
        //names.append(name)
        print(names)
        ref.child("names").childByAutoId().setValue(name)
    }
    
    
    @IBAction func saveButton(_ sender: UIButton) {
        let name = textFieldOutlet.text!
        let age = Int(ageOutlet.text!)!
        var stew = Student(name: name, age: age)
        stew.saveToFirebase()
        students.append(stew)
        tableOutlet.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableOutlet.dequeueReusableCell(withIdentifier: "myCell")!
        cell.textLabel?.text = students[indexPath.row].name
        cell.detailTextLabel?.text = String(students[indexPath.row].age)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath:IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            students[indexPath.row].deleteFromFirebase()
            students.remove(at: indexPath.row)
        }
        tableOutlet.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        print(selectedIndex)
    }
    
    
    @IBAction func editAction(_ sender: UIButton) {
        students[selectedIndex].name = textFieldOutlet.text!
        students[selectedIndex].age = Int(ageOutlet.text!)!
        students[selectedIndex].editOnFirebase()
        tableOutlet.reloadData()
    }
    
}

