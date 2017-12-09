//
//  DetailTableViewController.swift
//  ProjectOne
//
//  Created by Robert Whitehead on 9/28/17.
//  Copyright © 2017 Robert Whitehead. All rights reserved.
//


 //MARK: - IBActions
extension ProjectListTVController {
    
    @IBAction func cancelToPlayersViewController(_ segue: UIStoryboardSegue) {
    }

    @IBAction func savePlayerDetail(_ segue: UIStoryboardSegue) {

        guard let playerDetailsViewController = segue.source as? DetailTableViewController else {
                return
        }
        
        // fix bullets and /n in Summary
        playerDetailsViewController.summaryofProjectText.text = includeBullets(playerDetailsViewController.summaryofProjectText.text!)

        // add the new player to the players array
        
        var newI = playerDetailsViewController.projectEditedTablePtr
        if playerDetailsViewController.projectEditedTablePtr >= 0 && playerDetailsViewController.originalTitle == playerDetailsViewController.titleofProjectText.text! {
            listofTitles[playerDetailsViewController.projectEditedTablePtr] = playerDetailsViewController.titleofProjectText.text!
            listofImages[playerDetailsViewController.projectEditedTablePtr] = playerDetailsViewController.imageofProjectImage.image!
            listofImagePointers[playerDetailsViewController.projectEditedTablePtr] = playerDetailsViewController.imagePtr
            listofStatus[playerDetailsViewController.projectEditedTablePtr] = playerDetailsViewController.statusofProjectText.text!
            listofSummary[playerDetailsViewController.projectEditedTablePtr] = playerDetailsViewController.summaryofProjectText.text!
            var cflag = false
            if listofStatus[newI].lowercased().contains("complete") || listofStatus[newI].lowercased().contains("finish") {
                cflag = true
            }
            listofCompleted[playerDetailsViewController.projectEditedTablePtr] = cflag
            updateCloud(newI, playerDetailsViewController.projectUserEmail)
            
        } else {
        listofTitles.append(playerDetailsViewController.titleofProjectText.text ?? "")
        listofImages.append(playerDetailsViewController.imageofProjectImage.image ?? UIImage(named: "num9")!)
        listofImagePointers.append(playerDetailsViewController.imagePtr)
        listofStatus.append(playerDetailsViewController.statusofProjectText.text ?? "")
        listofSummary.append(playerDetailsViewController.summaryofProjectText.text ?? "")
            newI = listofTitles.count - 1
            var cflag = false
            if listofStatus[newI].lowercased().contains("complete") || listofStatus[newI].lowercased().contains("finish") {
                cflag = true
            }
        listofCompleted.append(cflag)
            updateCloud(newI, playerDetailsViewController.projectUserEmail)
        
        // update the tableView
//        let indexPath = IndexPath(row: listofTitles.count - 1, section: 0)
//        tableView.insertRows(at: [indexPath], with: .automatic)
        }
        tableView.beginUpdates()
        
        tableView.reloadData()
        
        tableView.endUpdates()

    }
    
    func updateCloud(_ newI: Int, _ email: String) {
        let todoItem = ToDoItem(title: listofTitles[newI], status: listofStatus[newI], summary: listofSummary[newI], imagePtr: listofImagePointers[newI], addedByUser: email,
                                completed: listofCompleted[newI])
        let todoItemRef = self.ref.child(listofTitles[newI].lowercased())
        todoItemRef.setValue(todoItem.toAnyObject())
    }
    
    func includeBullets(_ inputText: String) -> String {
        var inText = inputText
        if inText.isEmpty {
            return inText
        }
        var lastC = "\n".first
        var sIndex = inText.startIndex
        for i in inText.characters {
            if i == "•" && (lastC != "\n") {
                inText.insert("\n", at: sIndex)
                sIndex = inText.characters.index(after: sIndex)
            } else {
                if lastC == "\n" && i != "•" {
                    inText.insert("•", at: sIndex)
                    sIndex = inText.characters.index(after: sIndex)
                    lastC = "•".first
                    if inText.characters[sIndex] != " " && inText.characters[sIndex] != "✓" {
                        inText.insert(" ", at: sIndex)
                        sIndex = inText.characters.index(after: sIndex)
                        lastC = " ".first
                    }
                } else {
                    if lastC == "•" && !(i == " " || i == "✓") {
                        inText.insert(" ", at: sIndex)
                        sIndex = inText.characters.index(after: sIndex)
                        lastC = " ".first
                    }
                }
            }
            sIndex = inText.characters.index(after: sIndex)
            lastC = i
        }
        if (inText.last == "•") {
            inText.append(" \n")
        } else {
            if inText.last != "\n" {
                inText.append("\n")
            }
        }
        return inText
    }

}
/*
 class SomeViewController: UIViewController, UITextFieldDelegate {
 let someTextField = UITextField()
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 someTextField.delegate = self
 }
 
 func textFieldShouldReturn(textField: UITextField) -> Bool {
 textField.resignFirstResponder() // Dismiss the keyboard
 // Execute additional code
 return true
 }
 }
 */

import UIKit


class DetailTableViewController: UITableViewController {

    @IBOutlet weak var titleofProjectText: UITextField!
    @IBOutlet weak var statusofProjectText: UITextField!
    @IBOutlet weak var summaryofProjectText: UITextView!
    @IBOutlet weak var imageofProjectImage: UIImageView!

    // MARK: - Properties

        var projectEditedTitle = ""
        var projectEditedStatus = ""
        var projectEditedSummary = ""
        var projectEditedTablePtr = 0
        var projectUserEmail = ""
        var imagePtr = 9
        var originalTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let tableViewHeader = UIView(frame: CGRect(x:0, y:0, width: 100, height: 50))
        tableViewHeader.backgroundColor = UIColor.green
//        self.tableView(DetailTableViewController, viewForHeaderInSection: 2) = tableViewHeader
        imageofProjectImage.image = UIImage(named: "num" + String(imagePtr))
        titleofProjectText.text = projectEditedTitle
        statusofProjectText.text = projectEditedStatus
        summaryofProjectText.text = projectEditedSummary
        originalTitle = projectEditedTitle
        
    }

    
    @IBAction func changeImageButton(_ sender: UIButton) {
        imagePtr = (imagePtr + 1) % 10

        imageofProjectImage.image = UIImage(named: "num" + String(imagePtr))        
    }
    
    /*
     
     // alert on save to new record
     if playerDetailsViewController.originalTitle != playerDetailsViewController.titleofProjectText.text! && playerDetailsViewController.originalTitle != "" {
     let infoAlert = UIAlertController.self(title: "New Project", message: "FYI, you have created/added a new project (made changes to the title). The old project has not been deleted.", preferredStyle: .alert)
     infoAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
     }))
     
     self.present(infoAlert, animated: true, completion: nil)
     }
     
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
*/
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
}

// MARK: - UITableViewDelegate
extension DetailTableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            titleofProjectText.becomeFirstResponder()
        }
        if indexPath.section == 1 {
            statusofProjectText.becomeFirstResponder()
        }
        if indexPath.section == 3 {
            summaryofProjectText.becomeFirstResponder()
        }

   }
}

