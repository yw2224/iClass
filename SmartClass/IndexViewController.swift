//
//  ViewControllerWithIndex.swift
//  SmartClass
//
//  Created by PengZhao on 15/4/16.
//  Copyright (c) 2015年 PKU netlab. All rights reserved.
//

protocol IndexObject : class {
    var index: Int {get set}
}

class IndexViewController: UIViewController, IndexObject {
    var index = 0
}

class IndexTableViewController: UITableViewController, IndexObject {
    var index = 0
}

class IndexCollectionViewController: UICollectionViewController, IndexObject {
    var index = 0
}