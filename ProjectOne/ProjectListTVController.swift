//
//  ProjectListTVController.swift
//  ProjectOne
//
//  Created by Robert Whitehead on 9/27/17.
//  Copyright © 2017 Robert Whitehead. All rights reserved.
//



import UIKit
import Firebase

class ProjectListTVController: UITableViewController {

    var imageNumberGraphics: [UIImage] = []
    var listofImages: [UIImage] = []
    var listofTitles: [String] = []
    var listofStatus: [String] = []
    var listofSummary: [String] = []
    var listofImagePointers: [Int] = []
    var listofCompleted: [Bool] = []
    
    var items: [ToDoItem] = []
    var user: User!
    var userBarButton: UIBarButtonItem!

    let ref = Database.database().reference(withPath: "todo-items")
    let usersRef = Database.database().reference(withPath: "online")
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        initListofProjects()
        
        self.view.backgroundColor = UIColor.black
        userBarButton = UIBarButtonItem(title: "user:1",
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(userCountButtonDidTouch))
        userBarButton.tintColor = UIColor.white

        navigationItem.rightBarButtonItem = userBarButton

        
        // Fetches the project data for the data source layout.
//        cell.listSummaryProtoText.text = listofSummary[indexPath.row]

        ref.observe(.value, with: { snapshot in
//            var newItems: [ToDoItem] = []
//            for item in snapshot.children {
//                let todoItem = ToDoItem(snapshot: item as! DataSnapshot)
//                newItems.append(todoItem)
//            }
//            self.items = newItems
//            self.tableView.reloadData()
//        })

            self.ref.queryOrdered(byChild: "title").observe(.value, with: { snapshot in
                var newItems: [ToDoItem] = []
         
                for item in snapshot.children {
                    let todoItem = ToDoItem(snapshot: item as! DataSnapshot)
                    newItems.append(todoItem)
                }
         
                self.items = newItems
                self.tableView.reloadData()
            })
        })
        usersRef.observe(.value, with: { snapshot in
            if snapshot.exists() {
                self.userBarButton?.title = "Users:" + snapshot.childrenCount.description
            } else {
                self.userBarButton?.title = "Users:0"
            }
        })
        usersRef.observe(.childRemoved, with: { snap in
            guard let emailToFind = snap.value as? String else { return }
            if snap.exists() {
                self.userBarButton?.title = "Users:" + snap.childrenCount.description
            } else {
                self.userBarButton?.title = "Users:0"
            }
        })
        
        Auth.auth().addStateDidChangeListener ({ auth, user in
            guard let user = user else { return }
            self.user = User(uid: user.uid, email: user.email!)
            //      self.user = User(authData: user)
            let currentUserRef = self.usersRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()
            
        })
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
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 //       let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
     // Table view cells are reused and should be dequeued using a cell identifier.
     let cellIdentifier = "ListofProjectsTVCell"
     
     guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SingleLineProjectCell  else {
     fatalError("The dequeued cell is not an instance of SingleLineProjectCell.")
     }

     // Fetches the project data for the data source layout.

        let fbIndex = indexPath.row
        let todoItem = items[fbIndex]
        let imagePtr = todoItem.imagePtr % 10
        cell.listProjectProtoImage.image = UIImage(named: "num" + String(imagePtr))
        cell.listTitleProtoText.text = todoItem.title
        cell.listStatusProtoText.text = "Status: " + todoItem.status
        cell.listSummaryProtoText.text = todoItem.summary
        cell.accessoryType = .none
        if todoItem.completed {
            cell.accessoryType = .checkmark
        }
        if fbIndex < listofTitles.count {
            listofImages[fbIndex] = cell.listProjectProtoImage.image!
            listofTitles[fbIndex] = todoItem.title
            listofStatus[fbIndex] = todoItem.status
            listofSummary[fbIndex] = todoItem.summary
            listofImagePointers[fbIndex] = todoItem.imagePtr
            listofCompleted[fbIndex] = todoItem.completed
        } else  {
            listofImages.append(cell.listProjectProtoImage.image!)
            listofStatus.append(todoItem.status)
            listofSummary.append(todoItem.summary)
            listofImagePointers.append(todoItem.imagePtr)
            listofCompleted.append(todoItem.completed)
            listofTitles.append(todoItem.title)
        }
     
        return cell
    }
     



    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


// add row action
//
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let iRow = editActionsForRowAt.row
//
//        var iNew = -1 //set to Negative on no move up/down
//        let movedown = UITableViewRowAction(style: .normal, title: "Move Down") { action, index in
//
//            // move down
//            iNew = (iRow + 1) % self.listofTitles.count
//            self.switchRows(iRow,iNew)
//        }
//        movedown.backgroundColor = .lightGray
//
//        let moveup = UITableViewRowAction(style: .normal, title: "Move Up") { action, index in
//            // move up
//            iNew = (iRow + self.listofTitles.count - 1) % self.listofTitles.count
//            self.switchRows(iRow,iNew)
//        }
//        moveup.backgroundColor = .blue
//
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            // Delete the row from the data source
            let delAlert = UIAlertController.self(title: "Project Delete", message: "Are you sure you want to delete this project?", preferredStyle: .alert)
            delAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
//                print("..........Delete..........")
                let iRowTemp = iRow
                let todoItem = self.items[iRowTemp]
                todoItem.ref?.removeValue()
//                tableView.deleteRows(at: [editActionsForRowAt], with: .fade)
//                self.listofTitles.remove(at: iRowTemp)
//                self.listofStatus.remove(at: iRowTemp)
//                self.listofSummary.remove(at: iRowTemp)
//                self.listofImages.remove(at: iRowTemp)
                self.tableView.reloadData()

            }))
            delAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            self.present(delAlert, animated: true, completion: nil)

        }
        delete.backgroundColor = .red
        
//        return [delete, moveup, movedown]
        return [delete]
    }
    


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            // Delete the row from the data source
            let todoItem = items[indexPath.row]
            todoItem.ref?.removeValue()
//            listofTitles.remove(at: indexPath.row)
//            listofStatus.remove(at: indexPath.row)
//            listofSummary.remove(at: indexPath.row)
//            listofImages.remove(at: indexPath.row)
            tableView.reloadData()
//            tableView.deleteRows(at: [indexPath], with: .fade)
//            print ("****other delete*****")
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }


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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UsersSegue" {
            return
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
 //       print("???\(segue.identifier ?? "No")")
     
    /*
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
     if segue.identifier == "toRestaurant"{
     let navigationController = segue.destinationViewController as UINavigationController
     let vc = navigationController.topViewController as RestaurantViewController
     vc.data = currentResponse[i] as NSArray
     }
     }
 */
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     
        // Create reference and pass it
        // Get the row from the cell click in the table
//     if segue.identifier == "rowSequeProjectList"{
        var tTitle = ""
        var tStatus = ""
        var tSummary = ""
        var tPtr = -1
        var tIndex = 9
        
        let detailViewController = segue.destination as! DetailTableViewController
        if segue.identifier == "rowSequeProjectList" {
     let cellThatWasClicked = sender as! UITableViewCell
     let indexPath = self.tableView.indexPath(for: cellThatWasClicked)

     // Get the relevant data from the array
     let yourVarToPass = indexPath?.row

     // Create reference and pass it

        
            tTitle = listofTitles[yourVarToPass!]
            tStatus = listofStatus[yourVarToPass!]
            tSummary = listofSummary[yourVarToPass!]
            tPtr = yourVarToPass!
            tIndex = listofImagePointers[yourVarToPass!]
        
     }
            detailViewController.projectEditedTitle = tTitle
            detailViewController.projectEditedStatus = tStatus
            detailViewController.projectEditedSummary = tSummary
            detailViewController.imagePtr = tIndex
            detailViewController.projectEditedTablePtr = tPtr
            detailViewController.projectUserEmail = user.email
        tableView.beginUpdates()

        tableView.reloadData()
        
        tableView.endUpdates()
        
    }
    

    private func initListofProjects () {
        var getImageName = ""
        for i in 0...9 {
            getImageName = "num" + String(i)
            imageNumberGraphics.append(UIImage(named: getImageName)!)
        }
        listofImagePointers.append(0)
        listofImages.append(imageNumberGraphics[0])
        listofTitles.append("Project 0(Zero)")
        listofCompleted.append(true)
        listofStatus.append("Completed")
        listofSummary.append("•✓ Display a login screen with two text fields, login.\n•✓ The home screen should include:\n•✓ Your name\n•✓ A photo of you\n•✓ A button on the right end of the Navigation Bar should say My Bio.\n•✓ Buttons for each subsection listed below, View Controller for each):\n•✓ \"My Goal\"s.\n•✓ \"My Resume\"\n•✓ \"My Favorites\"\n•✓ Bonus: Create another version , iPad!\n")

        listofImagePointers.append(1)
        listofImages.append(imageNumberGraphics[1])
        listofTitles.append("Project 1, To-Do-List")
        listofCompleted.append(true)
        listofStatus.append("Finished + Firebase")
        listofSummary.append("•✓ Implement the prototype you created\n•✓ View a collection of to-do lists\n•✓ View items on a to-do list\n•✓ Allow the user to create a new to-do list\n•✓ Add items to each to-do list\n•✓ Display correctly in both landscape and portrait orientations\n•✓ Use Storyboard to layout all the Scenes and connect them\n•✓ Use template TableViews\n•✓ Implement OOP\n•✓ Create the model for the ToDo item\n•✓ Bonus: Show an error message if invalid input is given\n•✓ Bonus: Allow the user to check off and remove completed items\n•✓ Bonus: Add an item detail screen that allows the user to give an optional description for each item\n")
        

        listofImagePointers.append(2)
        listofImages.append(imageNumberGraphics[2])
        listofTitles.append("Project 2, Feedr Reader")
        listofCompleted.append(true)
        listofStatus.append("Completed")
        listofSummary.append("•✓ Include at least 1 prototypes\n•✓ Hit at least one news-based API\n•✓ Allow the user to browse through news articles using an interface that is photo-based, rather than text-based, i.e. Flipboard.\n•✓ Allow the user to click on a photo and read the article to which the photo relates\n•✓ Provide the user with some mechanism by which to filter stories based on one or more of the following:\n•✓ Keywords\n•✓ Tags\n•✓ Topics\n•✓ Location\n•✓ Integrate with the Twitter and/or Facebook\'s APIs\n•✓ Allow the user to share individual photos and stories via social media\n•✓ Look great in both landscape and portrait modes and reflect Material Design principles\n•✓ Not crash or hang and should handle for when networking/internet is slow or unavailable\n•✓ Include at least one Notifications feature (e.g. reminder, alarm)\n•✓ Use Auto Layout\n•✓ Use a tableview pattern\n•✓ Use custom tableviews with custom tableview cell classes\n•✓ Have smooth transitions and fade in/fade out animation\n•✓ Run on your own device\n•✓ Bonus: Integrate additional APIs\n•✓ Bonus: Allow the user to download photos, manipulate them by adding text, etc. (image manipulation libraries will probably be helpful here...) and then share their manipulated image via social media\n•✓ Bonus: Create multiple prototype cells to use in your app\n\n")

        listofImagePointers.append(3)
        listofImages.append(imageNumberGraphics[3])
        listofTitles.append("Project 3, E-Commerce Replica")
        listofCompleted.append(false)
        listofStatus.append("Class, protos & login")
        listofSummary.append("•✓ Store shopping cart and favorite data locally\n•✓ Have multiple roles:\n•✓ A consumer that can “purchase” products\n•✓ A vendor that can set up a “shop” and products to their shop\n•✓ Each role should have multiple UI elements\n•✓ Allow vendors to add products to a “shop”\n•✓ Have a shopping cart that persists data\n•✓ Do not sync the favorites and the shopping cart items\n•✓ Have a checkout process\n•✓ Allow consumers to add products to the cart\n•✓ Allow vendors to have multiple photos for a particular product using the photo library or the camera\n•✓ Allow consumers to consume products with these tags\n•✓ Allow consumers to see vendor reviews and product reviews\n•✓ Implement OOP\n•✓ The “product” object should have attributes and functions that the consumer does not have access to\n•✓ Use Firebase to persist data\n•✓ Have a tab bar that allows users to:\n•✓ Visit the home page\n•✓ Login and logout\n•✓ Visit favorites\n•✓ Get to the checkout cart\n•✓ Allow the user to search by at least three different product-related criteria\n•✓ Examples: name, price, availability, size, description, etc.\n•✓ Allows users to favorite products and come back to them\n•✓ Implement an OAuth system (via Twitter or Facebook?)\n•✓ Allow vendors to:\n•✓ See a list of their customers and customer reviews\n•✓ Create product “categories” or “tags” to “tag” products with\n•✓ Use CocoaPods to manage your third party dependencies (use at least 1 third party UI library)\n•✓ Use the seed data to populate the database\n•✓ Unit tests that pass\n•✓ Upload the app to TestFlight\n•✓ Bonus: Notify “consumers” when new products have been added to the store using a push notification or a favorite item comes back in stock\n•✓ Bonus: Integrate payment functionality with Stripe (using development mode)\n•✓ Bonus: Use 3D touch to “push and hold” (only if you have a 6S)\n•✓ Bonus: Make the app render on both iPhone and iPad layouts\n\n")

        listofImagePointers.append(4)
        listofImages.append(imageNumberGraphics[4])
        listofTitles.append("Project 4, Final App")
        listofCompleted.append(false)
        listofStatus.append("Not Started")
        listofSummary.append("•✓ Have an impressive design and user experience that follows Human Interface Guidelines and can impress future clients and employers\n•✓ Use at least one API or SDK\n•✓ Implement thoughtful user stories that are significant enough to help you know which features to build and which to scrap\n•✓ Be object oriented\n•✓ Be robust and handle cases of failure well (e.g., failed network calls)\n•✓ Work on, and is optimized for, an iPhone or iPad\n•✓ Save data to a local database or cloud-based service\n•✓ Have a polished UI\n•✓ Use at least one hardware component or at least one Apple-specific technology\n•✓ Have clean code with consistent formatting, comments, and naming conventions\n•✓ Be available on the TestFlight, so it is publicly available\n•✓ Bonus: Implement ApplePay\n•✓ Bonus: Be available on the AppStore\n\n")


    }

    func switchRows (_ iRow: Int, _ iNew: Int) {
        // iNew is set on move up/down
        if iNew < 0 || iNew == iRow {
            return //no switch on neg. flag/iNew
        }
            let tTitles = self.listofTitles[iRow]
            let tStatus = self.listofStatus[iRow]
            let tSummary = self.listofSummary[iRow]
            let tImages = self.listofImages[iRow]
            let tPtr = self.listofImagePointers[iRow]

        if (iNew == 0 && iRow == (self.listofTitles.count - 1)) || (iRow == 0 && iNew == (self.listofTitles.count - 1)) {
            self.listofTitles.remove(at: iRow)
            self.listofStatus.remove(at: iRow)
            self.listofSummary.remove(at: iRow)
            self.listofImages.remove(at: iRow)
            self.listofImagePointers.remove(at: iRow)
            if iNew == 0 {
                // move down off bottom
                self.listofTitles.insert(tTitles, at: iNew)
                self.listofStatus.insert(tStatus, at: iNew)
                self.listofSummary.insert(tSummary, at: iNew)
                self.listofImages.insert(tImages, at: iNew)
                self.listofImagePointers.insert(tPtr, at: iNew)
            } else {
                // move up off top
                self.listofTitles.append(tTitles)
                self.listofStatus.append(tStatus)
                self.listofSummary.append(tSummary)
                self.listofImages.append(tImages)
                self.listofImagePointers.append(tPtr)
            }
        } else {
            // normal swap/move
            self.listofTitles[iRow] = self.listofTitles[iNew]
            self.listofTitles[iNew] = tTitles
            self.listofStatus[iRow] = self.listofStatus[iNew]
            self.listofStatus[iNew] = tStatus
            self.listofSummary[iRow] = self.listofSummary[iNew]
            self.listofSummary[iNew] = tSummary
            self.listofImages[iRow] = self.listofImages[iNew]
            self.listofImages[iNew] = tImages
            self.listofImagePointers[iRow] = self.listofImagePointers[iNew]
            self.listofImagePointers[iNew] = tPtr
        }

            tableView.beginUpdates()
            tableView.reloadData()
            tableView.endUpdates()
    }
    
    @objc func userCountButtonDidTouch() {
        performSegue(withIdentifier: "UsersSegue", sender: nil)
    }
    
}
// MARK: - UITableViewDelegate
extension ProjectListTVController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        
    }
}
