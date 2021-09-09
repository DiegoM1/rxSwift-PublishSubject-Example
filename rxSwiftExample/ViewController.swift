//
//  ViewController.swift
//  rxSwiftExample
//
//  Created by Diego Sebastian Monteagudo Diaz on 9/09/21.
//

import UIKit
import RxSwift
import RxCocoa

struct Product {
    let imageName: String
    let title: String
}

class ProductViewModel {
    
    var items = PublishSubject<[Product]>()
    
    let products = [
        Product(imageName: "gamecontroller", title: "Game controller"),
        Product(imageName: "keyboard", title: "Keyboard"),
        Product(imageName: "scanner", title: "Scanner"),
        Product(imageName: "iphone", title: "Iphone"),
        Product(imageName: "ipod", title: "Ipod"),
        Product(imageName: "applewatch", title: "Applewatch")
    ]
    
    var  reactiveProducts: [Product] = []
    
    func fetchItems() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
            if let element = self.products.randomElement() {
                self.reactiveProducts.append(element)
                items.onNext(reactiveProducts)
            }
            if reactiveProducts.count == 15 {
                timer.invalidate()
                
            }
            
            
        }
    }
    
}

class ViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

    public var viewModel = ProductViewModel()
    
    private var bag = DisposeBag()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        bindTableData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(redoData))
    }
    
    private func bindTableData() {
        tableView.dataSource = nil
        viewModel.items.bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { row, model, cell in
            cell.textLabel?.text = model.title
            cell.imageView?.image = UIImage(systemName: model.imageName)
        }.disposed(by: bag)
        
        viewModel.fetchItems()
    
    }
    
    @objc func redoData() {
        viewModel.reactiveProducts = []
        bindTableData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        viewModel.items.onCompleted()
    }
    
}

