import UIKit

protocol ViewControllerProtocol: class {
    
}

class ViewController: UIViewController {
    private let cellId = "i\\d"
    //Логотип Яндекса
    private let yandexLogo = UIImageView()
    //TableView с введенным и переведенным текстом
    private let tableView = UITableView()
    //Нижнее View с вводом текста для перевода
    private var bottomView = BottomView()
    //Используем для поднятия View с вводом при подъеме клавиатуры
    private var bottomBottomViewConstraint: NSLayoutConstraint!
    var presenter: ViewPresenterProtocol!
    
    private let INDENT_DISTANCE: CGFloat = 16
    private let BOTTOM_VIEW_HEIGHT: CGFloat = 44
    private let YANDEX_LOGO_HEIGHT: CGFloat = 20.9
    private let YABDEX_LOGO_TOP_CONSTANT: CGFloat = 18
    private let BOTTOM_VIEW_EDGE_INDENT: CGFloat = 4
    private let YANDEX_LOGO_MULTIPLIER: CGFloat = 6.83
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomView.presenter = presenter.getBottomViewPresenter(for: bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomView)
        bottomView.heightAnchor.constraint(equalToConstant: BOTTOM_VIEW_HEIGHT).isActive = true
        bottomView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: BOTTOM_VIEW_EDGE_INDENT).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -BOTTOM_VIEW_EDGE_INDENT).isActive = true
        bottomBottomViewConstraint = bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -INDENT_DISTANCE)
        bottomBottomViewConstraint.isActive = true
        
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorStyle = .none
        tableView.transform = CGAffineTransform(rotationAngle: -(.pi));
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant: -INDENT_DISTANCE).isActive = true
        
        yandexLogo.image = UIImage(named: "yandexLogo")
        yandexLogo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(yandexLogo)
        yandexLogo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: YABDEX_LOGO_TOP_CONSTANT).isActive = true
        yandexLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        yandexLogo.heightAnchor.constraint(equalToConstant: YANDEX_LOGO_HEIGHT).isActive = true
        yandexLogo.widthAnchor.constraint(equalTo: yandexLogo.heightAnchor, multiplier: YANDEX_LOGO_MULTIPLIER).isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.delegate = self
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
    }
    
    @objc func keyboardWillShow(n: NSNotification) {
        if let keyboardHeight = (n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            bottomBottomViewConstraint.constant = -keyboardHeight - INDENT_DISTANCE
            view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(n: NSNotification) {
        bottomBottomViewConstraint.constant = -INDENT_DISTANCE
        view.layoutIfNeeded()
    }

    @objc func handleTap() {
        presenter.tapOnView()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getRowCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatMessageCell
        cell.chatMessage = presenter.getMessage(for: indexPath.row)
        return cell
    }
}

extension ViewController: ViewControllerProtocol {
    
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let view = gestureRecognizer.view else { return false }
        let tappedView = view.hitTest(gestureRecognizer.location(in: view), with: nil)
        return tappedView != nil && tappedView != bottomView
    }
}
