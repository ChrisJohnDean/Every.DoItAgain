//
//  MasterViewController.swift
//  Every.DoItAgain
//
//  Created by Chris Dean on 2018-03-21.
//  Copyright © 2018 Chris Dean. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil

    var _fetchedResultsController: NSFetchedResultsController<ToDo>? = nil // Stored property below
    
    var currentTheme: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem
        let themeButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(chooseTheme(_:)))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItems = [themeButton, addButton]
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        if let path = Bundle.main.path(forResource: "Themes", ofType: "plist") {
            let dictRoot = NSDictionary(contentsOfFile: path)
            if let dict = dictRoot {
                currentTheme = dict["Selected theme"] as! String
                if currentTheme == "light" {
                    view.backgroundColor = UIColor.lightGray
                } else {
                    view.backgroundColor = UIColor.darkGray
                }
            }
        }
        
        
        createDefaultToDoTask()
    }
    
    // Chooses theme from plist (needs to be refactored duhhh)
    @objc func chooseTheme(_ sender: Any) {
        var themeArray: Array<String>!
        
        if let path = Bundle.main.path(forResource: "Themes", ofType: "plist") {
            let dictRoot = NSDictionary(contentsOfFile: path)
            if let dict = dictRoot {
                themeArray = dict["Themes"] as! Array<String>
            }
        }
        
        if themeArray[0] == currentTheme {
            currentTheme = themeArray[1]
            view.backgroundColor = UIColor.darkGray
        } else {
            currentTheme = themeArray[0]
            view.backgroundColor = UIColor.lightGray
        }
        
        if let path = Bundle.main.path(forResource: "Themes", ofType: "plist") {
            let dictRoot = NSMutableDictionary(contentsOfFile: path)
            if let dict = dictRoot {
                dict.setValue(currentTheme, forKey: "Selected theme")
                dict.write(toFile: path, atomically: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}

// MARK: - UITableViewDatasource methods
extension MasterViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let toDo = fetchedResultsController.object(at: indexPath)
        
        if toDo.isCompleted {
            cell.backgroundColor = UIColor.green
        } else {
            cell.backgroundColor = UIColor.clear
        }
        
        configureCell(cell, withToDo: toDo)
        return cell
    }
}
    
// MARK: - UITableViewDelegate methods
extension MasterViewController {
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withToDo toDo: ToDo) {
        cell.textLabel!.text = toDo.title!
        cell.detailTextLabel?.text = String(toDo.priorityNumber) + " " + toDo.todoDescription!
    }

}



// MARK: - NSFetchedResultsControllerDelegate Methods
extension MasterViewController {
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<ToDo> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)!, withToDo: anObject as! ToDo)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)!, withToDo: anObject as! ToDo)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
     // In the simplest, most efficient, case, reload the table view.
     tableView.reloadData()
     }
     */
    
    
}

// MARK: - UserDefault methods
extension MasterViewController {
    
    private func createDefaultToDoTask() {
        UserDefaults.standard.set("Lots to do", forKey: "title")
        UserDefaults.standard.set("Gimme the deets", forKey: "todoDescription")
        UserDefaults.standard.set(0, forKey: "priorityNumber")
        UserDefaults.standard.set(false, forKey: "isComleted")
    }
    
    private func loadUserDefaults(titleTextField: UITextField, toDoDescriptionTextField: UITextField) {
        titleTextField.text = UserDefaults.standard.string(forKey: "title")
        toDoDescriptionTextField.text = UserDefaults.standard.string(forKey: "todoDescription")
    }
}


// MARK: - Private methods
extension MasterViewController {
    
    @objc
    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        
        let alert = UIAlertController(title: "Add a ToDo item!", message: nil, preferredStyle: .alert)
        
        var titleTextField: UITextField!
        var toDoDescriptionTextField: UITextField!
        
        alert.addTextField { (textField: UITextField) in
            titleTextField = textField
            titleTextField.clearsOnBeginEditing = false
        }
        alert.addTextField { (textField: UITextField) in
            toDoDescriptionTextField = textField
            toDoDescriptionTextField.clearsOnBeginEditing = false
        }
        
        
        loadUserDefaults(titleTextField: titleTextField, toDoDescriptionTextField: toDoDescriptionTextField)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
            print("ToDo title is \(String(describing: titleTextField.text))")
            print("ToDo Description is \(String(describing: toDoDescriptionTextField.text))")
            
            let newToDo = ToDo(context: context)
            newToDo.title = titleTextField.text
            if let toDoDescription = toDoDescriptionTextField.text {
                newToDo.todoDescription = toDoDescription
            }
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
            // Do nothing
        }))
        
        present(alert, animated: true, completion: nil)
        
        // Save the context.
        
    }

}


















