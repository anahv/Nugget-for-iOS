//
//  ViewController.swift
//  Nugget
//
//  Created by Ana Hidalgo de la Vega on 11/06/2020.
//  Copyright © 2020 ana. All rights reserved.
//

// ADD VOICE RECORDINGS
// ADD SHAKE TO UNDO
// ADD SHARING
// ADD SAVE THE PHOTO
// ADD DELETE THE PHOTO
// add RANDOM and 2 years?


import UIKit
import CoreData
import ChameleonFramework

class NuggetViewController: UITableViewController {
    
    var nuggetsArray = [Nugget]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let notifications = Notifications()
    let dateToString = DateToString()
    let saveNugget = SaveNugget()
    
    override func viewWillAppear(_ animated: Bool) {
        loadNuggets()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Pacifico-Regular", size: 20)!]
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Pacifico-Regular", size: 34)!]
        
        notifications.notificationCenter.delegate = notifications
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 60.0
        tableView.separatorStyle = .none
        
        self.searchBar.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    
    // MARK: - TableView Data Source Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        nuggetsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NuggetCell", for: indexPath)
        cell.textLabel?.text = nuggetsArray[indexPath.row].body ?? "No nuggets yet!"
        
        let convertedDate = dateToString.dateToString(date: nuggetsArray[indexPath.row].date!)
        cell.detailTextLabel?.text = convertedDate
        
        cell.backgroundColor = UIColor(hexString: nuggetsArray[indexPath.row].colour ?? "1D9BF6")
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        cell.tintColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        cell.detailTextLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        
        return cell
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    // MARK: - Segues into New Nugget and Edit Nugget
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewNuggetSegue",
            let destination = segue.destination as? NewNuggetViewController {
            let newNugget = Nugget(context: self.context)
            //            newNugget.body = "Placeholder"
            newNugget.date = NSDate() as Date
            newNugget.id = UUID()
            newNugget.colour = UIColor.init(randomColorIn: [FlatRed(), FlatOrange(), FlatYellow(), FlatSkyBlue(), FlatGreen(), FlatMint(), FlatPurple(), FlatWatermelon(), FlatPink(), FlatPowderBlue(), FlatBlue()])?.hexValue()
            self.nuggetsArray.append(newNugget)
            destination.newNugget = newNugget
        }
        
        if segue.identifier == "EditNuggetSegue",
            let destination = segue.destination as? NewNuggetViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            destination.newNugget = nuggetsArray[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: - TableView Data Source Methods
    
    func loadNuggets(with request: NSFetchRequest<Nugget> = Nugget.fetchRequest()) {
        
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            nuggetsArray = try context.fetch(request)
        }
        catch {
            print("Error fetching data, \(error)")
        }
        tableView.reloadData()
    }
    
    // MARK: - Delete with Swipe
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.notifications.removePendingNotifications(id: nuggetsArray[indexPath.row].id!)
            context.delete(self.nuggetsArray[indexPath.row])
            nuggetsArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveNugget.saveNugget()
            tableView.reloadData()
        }
    }
}

// MARK: - Search Bar

extension NuggetViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let request: NSFetchRequest<Nugget> = Nugget.fetchRequest()
        request.predicate = NSPredicate(format: "body CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "body", ascending: true)]
        loadNuggets(with: request)
        if searchBar.text?.count == 0 {
            loadNuggets()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}




//extension NuggetViewController: UISearchResultsUpdating {
//
//  func updateSearchResults(for searchController: UISearchController) {
//
////    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//
//        let request: NSFetchRequest<Nugget> = Nugget.fetchRequest()
//        request.predicate = NSPredicate(format: "body CONTAINS[cd] %@", searchBar.text!)
//        request.sortDescriptors = [NSSortDescriptor(key: "body", ascending: true)]
//        loadNuggets(with: request)
//        if searchBar.text?.count == 0 {
//            loadNuggets()
//            DispatchQueue.main.async {
//                self.searchBar.resignFirstResponder()
//            }
//        }
//    }
//
//}

//        navigationController?.navigationBar.prefersLargeTitles = true
//        let searchController = UISearchController(searchResultsController: nil)
//        navigationItem.searchController = searchController
//        searchController.searchResultsUpdater = self
//        searchController.searchBar.placeholder = "Search for Nuggets"



//        navigationController!.navigationBar.backgroundColor = UIColor(hexString: "D8E1F5")
//        self.view.backgroundColor = UIColor(hexString: "D8E1F5")
//        searchBar.barTintColor = UIColor(hexString: "D8E1F5")


//        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.flatBlue()]


//        cell.backgroundColor = UIColor.flatPowderBlue().darken(byPercentage: CGFloat(indexPath.row) / CGFloat(nuggetsArray.count) / 4.0)
//        cell.backgroundColor = UIColor.init(randomColorIn: [FlatYellowDark(), FlatYellow(), FlatOrange(), FlatOrangeDark()])
//        cell.backgroundColor = UIColor.init(randomFlatColorExcludingColorsIn: [FlatBlack(), FlatForestGreen(), FlatBrown(), FlatMaroon(), FlatPlum(), FlatBlueDark(), FlatPlumDark(), FlatBrownDark(), FlatForestGreenDark(), FlatMaroonDark(), FlatBlackDark(), FlatTealDark()])
