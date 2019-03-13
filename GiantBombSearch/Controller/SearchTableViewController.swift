//
//  ViewController.swift
//  GiantBombSearch
//
//  Created by Jordan Jackson on 3/12/19.
//  Copyright © 2019 Perium. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController {
    
    
    var games = [Game]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var filteredGames = [Game]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var searchActive = false
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
    }
    
    func setupSearchController() {
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        self.navigationController?.navigationItem.searchController = searchController
        let leftNavBarButton = UIBarButtonItem(customView: searchController.searchBar)
        self.navigationItem.leftBarButtonItem = leftNavBarButton
        definesPresentationContext = true
        
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.autocapitalizationType = .none
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.isSearchResultsButtonSelected = false
        searchController.searchBar.enablesReturnKeyAutomatically = true
        searchController.searchBar.placeholder = "Search Games"
    }
    

    
    func searchForGames(_ searchText: String) {
        if !Reachability.connectedToNetwork() {
            errorAlert(title: "Error Connecting to the Wifi!", message: "Unable to complete search, check your network preferences.", view: self)
            return
        }
        Networking.shared.searchGames(searchInput: searchText) { (results) in
            switch results {
            case .failure(let error):
                print("Error", error.localizedDescription)
            case .success(let games):
                //                loadingAnimation(secondsTillHidden: 5.0)
                self.games = games
                
                print(games.count)
            }
        }
    }
    
    func removeSpaces(search: String) -> String {
        let clearSearch = search.replacingOccurrences(of: " ", with: "%20")
        return clearSearch
    }
    
}

// MARK: - Table view data source
extension SearchTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (self.games.count == 0) && (self.filteredGames.count == 0) {
            // If there are no games avaliable, return a view describing 0 results found
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No Results Found."
            noDataLabel.textColor = .lightGray
            noDataLabel.textAlignment = .center
            self.tableView.backgroundView  = noDataLabel
            self.tableView.backgroundColor = .white
            self.tableView.separatorStyle  = .none
            return 1
        } else {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
            return 1
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredGames.count
        } else {
            return games.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as? SearchTableViewCell else {
            return UITableViewCell()
        }
        
        if isFiltering() {
            cell.game = filteredGames[indexPath.row]
        } else {
            cell.game = games[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isFiltering() { return }
        
        let game = games[indexPath.row]
        // present the activity view when the user clicks on a game and let them share it with friends on twitter, imessage, email etc
        let activityVC = UIActivityViewController(activityItems: [game.name, game.giantBombURL], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.05 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
        })
    }
}

// MARK: - Search Methods

extension SearchTableViewController: UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
//        guard let text = searchController.searchBar.text else { return }
//        filterContentForSearchText(text)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // When a user clicks search we clear any spaces from the text and end the activity to see the updating content.
        
        print("Search Button clicked")
        searchActive = true
        guard let searchText = searchBar.text, searchText.count > 1 else {
            print("No results from an empty search")
            return
        }
        let search = removeSpaces(search: searchText)
        
        
        searchForGames(search)
        
        self.searchController.isActive = false
        self.searchController.searchBar.text = searchText
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        if let text = searchController.searchBar.text, text.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        // Filtering through the games already searched for and returning a filtered list based on the search text
        if searchText != "" {
            searchActive = true
            filteredGames = games.filter({( game: Game) -> Bool in
                return game.name.lowercased().contains(searchText.lowercased())
            })
            
            self.tableView.reloadData()
        } else {
            searchActive = false
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.text = ""
    }
    
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchActive = true
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        searchActive = false
        searchController.searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("End editing")
        searchBar.resignFirstResponder()
    }
}
