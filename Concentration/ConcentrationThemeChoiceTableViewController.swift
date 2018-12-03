//
//  ConcentrationThemeChoiceTableViewController.swift
//  Concentration
//
//  Created by Zachery Miller on 12/2/18.
//  Copyright © 2018 Zachery Miller. All rights reserved.
//

import UIKit

class ConcentrationThemeChoiceTableViewController: UITableViewController {

    private var lastSeguedViewController : ViewController?
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ViewController.Emoji.emojiThemeNames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let themeName = ViewController.Emoji.emojiThemeNames[indexPath.row]
        cell.textLabel?.text = themeName
        cell.textLabel?.textAlignment = .center
        
        return cell
    }

    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let vc = lastSeguedViewController {
            vc.chosenEmojiTheme = ViewController.Emoji.emojiThemes[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            self.performSegue(withIdentifier: "ChooseTheme", sender: indexPath)
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let chosenThemeIndexPath = sender as? IndexPath {
            let theme = ViewController.Emoji.emojiThemes[chosenThemeIndexPath.row]

            if let viewController = segue.destination as? ViewController {
                viewController.chosenEmojiTheme = theme
                lastSeguedViewController = viewController
            }
        }
    }
}
