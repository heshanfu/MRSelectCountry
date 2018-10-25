//
//  MRSelectCountryTableViewController.swift
//  MRSelectCountry
//
//  Created by Muhammad Raza on 09/08/2017.
//  Copyright © 2017 Muhammad Raza. All rights reserved.
//

import UIKit

public class MRSelectCountryTableViewController: UITableViewController, UISearchBarDelegate {
    
    // MARK :- IBOutlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK :- Properties
    
    private var countries: [MRCountry] = []
    private var filteredCountries: [MRCountry] = []
    private var isFiltering = false
    public var delegate: MRSelectCountryDelegate?
    
    // MARK: - UIViewController Lifecycle methods
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get Countries
        countries = getCountries()
        
        // Remove extra seperator lines
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    // MARK: - Supporting functions
    
    private func getCountries() -> [MRCountry] {
        var countries = [MRCountry]()
        let bundle = Bundle(identifier: "org.cocoapods.MRSelectCountry")
        if let path = bundle?.url(forResource: "countries", withExtension: "json") {
            
            do {
                let jsonData = try Data(contentsOf: path, options: .mappedIfSafe)
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? NSArray {
                        for arrData in jsonResult {
                            let country = MRCountry(json: arrData as! [String: Any])
                            countries.append(country)
                        }
                    }
                } catch let error as NSError {
                    print("Error: \(error)")
                }
            } catch let error as NSError {
                print("Error: \(error)")
            }
        }
        return countries
    }
    
    // MARK: - IBActions
    
    
    // MARK: - Table view data source

    override public func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isFiltering {
            return filteredCountries.count
        }
        return countries.count
    }

    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MRSelectCountryTableViewCell
        
        // Configure the cell...
        var country: MRCountry
        if isFiltering {
            country = filteredCountries[indexPath.row]
        }else{
            country = countries[indexPath.row]
        }
        
        cell.countryNameLabel.text = country.name
        cell.codeLabel.text = country.dialCode
        cell.countryCodeLabel.text = country.code
        cell.countryLocaleLabel.text = country.locale
        
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedCountry: MRCountry!
        if isFiltering {
            selectedCountry = filteredCountries[indexPath.row]
        }else{
            selectedCountry = countries[indexPath.row]
        }
        
        self.delegate?.didSelectCountry(controller: self, country: selectedCountry)
    }
    
    // MARK :- UISearchBar Delegate
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil && self.searchBar.text != "" {
            isFiltering = true
            filterCountry(text: searchBar.text!)
        }else{
            isFiltering = false
            tableView.reloadData()
        }
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text! != "" {
            isFiltering = true
            filterCountry(text: searchBar.text!)
        }else{
            isFiltering = false
            tableView.reloadData()
        }
    }
    
    private func filterCountry(text: String) {
        filteredCountries = self.countries.filter({ (country) -> Bool in
            return country.name.lowercased().contains(text.lowercased()) || country.code.lowercased().contains(text.lowercased()) || country.dialCode.lowercased().contains(text.lowercased())
        })
        tableView.reloadData()
    }

}
