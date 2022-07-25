//
//  ViewController.swift
//  Carrot
//
//  Created by ebamboo on 2021/11/26.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let titles = ["FlowImageView", "Browser Swift", "Browser OC"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Carrot"
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "Cell")
        }
        cell?.textLabel?.text = titles[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row == 0 {
            navigationController?.pushViewController(FlowImageViewController(), animated: true)
            return
        }
        if indexPath.row == 1 {
            navigationController?.pushViewController(BrowserTestSwiftViewController(), animated: true)
            return
        }
        if indexPath.row == 2 {
            navigationController?.pushViewController(BrowserTestOCViewController(), animated: true)
            return
        }
    }
    
}
