//
//  MemoriesVC.swift
//  DemoMemoryBook
//
//  Created by Denis Senichkin on 5/28/17.
//

class MemoriesVC: RootMenuVC, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var books: [BookEntity] = []
    var pushLast = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        books = kDataModel.getAllBooks()
        tableView.reloadData()
    }
 
    //MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoriesBookCell", for: indexPath) as! MemoriesBookCell
        
        if indexPath.row < books.count {
            let book = books[indexPath.row]
            cell.book = book
            cell.customInit()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }


    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, indexPath.row < books.count {
            
            let index = indexPath.row
            let bookEntity = books[index]
            
            books.remove(at: index)
            kDataModel.deleteBook(deletedBook: bookEntity)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < books.count {
            let newBook = books[indexPath.row]
            let bookViewerSB = UIStoryboard(name: "BookViewer", bundle: nil)
            let bookPreviewVC = bookViewerSB.instantiateViewController(withIdentifier: "BookPreviewVC") as! BookPreviewVC
            bookPreviewVC.currentBook = newBook
            self.navigationController?.pushViewController(bookPreviewVC, animated: true)
        }
    }
}

class MemoriesBookCell: UITableViewCell {
    
    var book: BookEntity?
    @IBOutlet weak var imBookCover: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    
    func customInit() {
        reset()
        if let book = book {
            imBookCover.image = book.getCoverImage(isThumb: true)
            lbTitle.text = book.title
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm"
            dateFormatter.locale = Locale(identifier: "en_US")
            
            if let creationDate = book.creationDate as Date? {
                let dateStr = dateFormatter.string(from: creationDate)
                lbDate.text = dateStr
            }
            
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    func reset() {
        imBookCover.image = nil
        lbTitle.text = nil
        lbDate.text = nil
    }
    
}
