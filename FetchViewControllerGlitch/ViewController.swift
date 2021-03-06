import CoreData
import UIKit

class ViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = MyTableView()
    let resultController = ViewController.createResultController()
    var inserts = [IndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial cells
        for i in 0...40 {
            let x = SomeEntity(context: CoreDataContext.persistentContainer.viewContext)
            
            x.something = randomString(length: i + 1)
            x.date = Date()
            x.height = Float.random(in: 50...100)
        }
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (_) in
            let x = SomeEntity(context: CoreDataContext.persistentContainer.viewContext)
            
            x.something = self.randomString(length: Int.random(in: 10...50))
            x.date = Date()
            x.height = Float.random(in: 50...100)
        }
        
        resultController.delegate = self
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 75
        
        try! resultController.performFetch()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            inserts.append(newIndexPath!)
        default:
            fatalError()
        }
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let currentSize = tableView.contentSize.height

        UIView.performWithoutAnimation {
            tableView.performBatchUpdates({
                tableView.insertRows(at: inserts, with: .automatic)
            })
            
            inserts.removeAll()
            self.view.layoutIfNeeded()
            let newSize = tableView.contentSize.height
            let correctedY = tableView.contentOffset.y + newSize - currentSize

            print("Will apply an corrected Y value of: \(correctedY)")
            tableView.setContentOffset(CGPoint(x: 0,
                                               y: correctedY),
                                       animated: false)
            print("Corrected to: \(correctedY)")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("Scrolled to: \(scrollView.contentOffset.y)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(resultController.object(at: indexPath).height)
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
