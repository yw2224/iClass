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

class IndexViewController: UIViewController {
    
    var _index = 0
}

extension IndexViewController: IndexObject {
    var index : Int {
        get {
            return _index
        }
        set {
            _index = newValue
        }
    }
}

class IndexTableViewController: UITableViewController {
    var _index = 0
}

extension IndexTableViewController: IndexObject {
    var index : Int {
        get {
            return _index
        }
        set {
            _index = newValue
        }
    }
}

class IndexCollectionViewController: UICollectionViewController {
    var _index = 0
}

extension IndexCollectionViewController: IndexObject {
    var index: Int {
        get {
            return _index
        }
        set {
            _index = newValue
        }
    }
}