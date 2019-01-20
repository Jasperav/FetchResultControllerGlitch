import CoreData
import UIKit

class ViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource {
    
    let tableView = MyTableView()
    let resultController = ViewController.createResultController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial cells
        for i in 0...40 {
            let x = SomeEntity(context: CoreDataContext.persistentContainer.viewContext)
            
            x.something = randomString(length: i + 1)
            x.date = Date()
        }
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
            let x = SomeEntity(context: CoreDataContext.persistentContainer.viewContext)
            
            x.something = self.randomString(length: Int.random(in: 10...50))
            x.date = Date()
        }
        
        resultController.delegate = self
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = 50
        
        try! resultController.performFetch()
    }
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyTableViewCell
        
        cell.textLabel?.text = resultController.object(at: indexPath).something
        
        return cell
    }

    
    private static func createResultController() -> NSFetchedResultsController<SomeEntity> {
        let fetchRequest: NSFetchRequest<SomeEntity> = SomeEntity.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataContext.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }
}

class MyTableView: UITableView {
    init() {
        super.init(frame: .zero, style: .plain)
        
        register(MyTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MyTableViewCell: UITableViewCell {
    
}

class CoreDataContext {
    static let persistentContainer: NSPersistentContainer =  {
        let container = NSPersistentContainer(name: "FetchViewControllerGlitch")
        
        container.loadPersistentStores(completionHandler: { (nsPersistentStoreDescription, error) in
            guard let error = error else {
                return
            }
            fatalError(error.localizedDescription)
        })
        
        return container
    }()
}
