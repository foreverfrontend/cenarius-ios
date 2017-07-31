//
//  ModuleViewController.swift
//  CenariusExample
//
//  Created by Devin on 2017/7/31.
//  Copyright © 2017年 M. All rights reserved.
//

import UIKit

class ModuleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {


    private var arrayM = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let mainTableView = UITableView(frame: view.bounds, style: .plain)
        mainTableView.tableFooterView = UIView()
        mainTableView.separatorStyle = .none
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(mainTableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayM.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = arrayM[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        return cell
    }

}
