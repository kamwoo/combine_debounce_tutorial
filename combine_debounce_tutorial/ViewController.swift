//
//  ViewController.swift
//  combine_debounce_tutorial
//
//  Created by wooyeong kam on 2021/06/06.
//

// 입력이 완료된 다음 사용하기 위해 사용
// 예를들어 api를 호출할 때 매 글자마다 호출하지 않고 단어가 완성되면 api를 호출되게 할 수 있다.

import UIKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet weak var myLabel: UILabel!
    
    private lazy var searchController : UISearchController  = {
        let searchController = UISearchController()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = .black
        searchController.searchBar.searchTextField.accessibilityIdentifier = "mySearchBarTextField"
        return searchController
    }()
    
    var mySubscription = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationItem.searchController = searchController
        searchController.isActive = true
        
        searchController.searchBar.searchTextField
            .myDebounceSearchPublisher
            .sink{ [weak self] (receiveValue) in
                guard let self = self else { return }
                
                print("\(receiveValue)")
                self.myLabel.text = receiveValue
            }.store(in: &mySubscription)
    }


}

extension UISearchTextField {
    var myDebounceSearchPublisher : AnyPublisher<String, Never> {
        // UISearchTextField.text가 변할때 마다 보내는 주파수의 이름이 UISearchTextField.textDidChangeNotification
        NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification, object: self)
            .compactMap{ $0.object as? UISearchTextField}
            .map{ $0.text ?? ""}
            .debounce(for: .milliseconds(1000), scheduler: RunLoop.main)
            .filter{ $0.count > 0 }
            .print()
            // 리턴값 자료형을 AnyPublisher로 퉁 치는 것
            .eraseToAnyPublisher()
    }
}

