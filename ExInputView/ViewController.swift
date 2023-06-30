//
//  ViewController.swift
//  ExInputView
//
//  Created by 김종권 on 2023/07/01.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxGesture

class ViewController: UIViewController, KeyboardWrapperable {
    private enum Policy {
        static let countOfText = 700
    }
    private enum Metric {
        static let textViewHeight = UIScreen.main.bounds.height * 0.5
        static let stackViewSpacing = 10.0
        static let spacing = 30.0
    }
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = Metric.stackViewSpacing
    }
    private let textView = UITextView().then {
        $0.backgroundColor = .lightGray.withAlphaComponent(0.1)
        $0.layer.borderWidth = 1.0
        $0.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.7).cgColor
        $0.textContainerInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        $0.font = .systemFont(ofSize: 18)
        $0.textColor = .lightGray
    }
    fileprivate let button = UIButton(type: .system).then {
        $0.backgroundColor = .green.withAlphaComponent(0.3)
        $0.setTitle("완료", for: .normal)
        $0.setTitleColor(.blue, for: .normal)
        $0.setTitleColor(.systemBlue, for: [.normal, .highlighted])
    }
    
    fileprivate let textViewPlaceHolder = "텍스트를 입력하세요"
    let disposeBag = DisposeBag()
    
    var keyboardWrapperView = PassThroughView()
    var keyboardSafeAreaView = PassThroughView()
    var didChangeKeyboardHeight: ((CGFloat) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setupKeybaordWrapper()
        setupUI()
    }
    
    private func setupUI() {
        textView.text = textViewPlaceHolder
        textView.delegate = self
        
        keyboardSafeAreaView.addSubview(scrollView)
        keyboardSafeAreaView.addSubview(button)
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(textView)
        
        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(30)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().priority(.medium)
            $0.leading.trailing.width.equalToSuperview()
            $0.bottom.equalToSuperview().priority(.high)
            $0.bottom.lessThanOrEqualTo(button.snp.top).offset(-30).priority(.medium)
        }
        textView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(Metric.textViewHeight)
        }
        button.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        didChangeKeyboardHeight = { [weak self] height in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                print(self?.stackView.frame.origin)
                self?.scrollView.contentInset.bottom = -height
            })
        }
    }
    
    private func bind() {
//        view.rx.tapGesture()
//            .when(.ended)
//            .bind(with: self) { ss, _ in
//                ss.view.endEditing(true)
//            }
//            .disposed(by: disposeBag)
    }
}

extension ViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .lightGray
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let inputString = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let oldString = textView.text, let newRange = Range(range, in: oldString) else { return true }
        let newString = oldString.replacingCharacters(in: newRange, with: inputString).trimmingCharacters(in: .whitespacesAndNewlines)

        let characterCount = newString.count
        guard characterCount <= Policy.countOfText else { return false }
        return true
    }
}
