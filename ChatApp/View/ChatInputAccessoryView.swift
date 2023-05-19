//
//  ChatInputAccessoryView.swift
//  ChatApp
//
//  Created by Pau Fernández Solà on 12/5/23.
//

import UIKit

protocol ChatInputAccessoryViewDelegate: AnyObject {
    func didSendMessage(message: String)
    func didTapAddMedia()
}

class ChatInputAccessoryView: UIView {

    let commentTextView = ChatInputTextView()
    weak var inputDelegate: ChatInputAccessoryViewDelegate?
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.isEnabled = true
        button.configuration?.baseBackgroundColor = .systemBlue
        button.configuration?.image = UIImage(systemName: "arrow.up", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        button.addTarget(self, action: #selector(didTapPostButton), for: .touchUpInside)
        button.configuration?.cornerStyle = .capsule
        button.translatesAutoresizingMaskIntoConstraints = false
        button.sizeToFit()
        return button
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.isEnabled = true
        button.configuration?.baseBackgroundColor = .systemBlue
        button.configuration?.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withRenderingMode(.alwaysOriginal).withTintColor(.systemBlue)
        button.addTarget(self, action: #selector(handleAddMedia), for: .touchUpInside)
        button.configuration?.cornerStyle = .capsule
        button.translatesAutoresizingMaskIntoConstraints = false
        button.sizeToFit()
        return button
    }()
    
    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
    
    /// Initializes a new instance of the view with the specified frame.
    ///
    /// - Parameters:
    ///   - frame: The frame rectangle for the view, measured in points.
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        commentTextView.placeholder.text = "Text Message"
        commentTextView.font = UIFont.systemFont(ofSize: 17)
        commentTextView.isScrollEnabled = false
        commentTextView.clipsToBounds = true
        commentTextView.layer.cornerRadius = 16
        commentTextView.layer.borderColor = UIColor.systemGray3.cgColor
        commentTextView.layer.borderWidth = 0.4
        commentTextView.tintColor = .systemBlue
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        autoresizingMask = .flexibleHeight
        
        addSubviews(addButton, commentTextView, sendButton, topView)
        NSLayoutConstraint.activate([
            commentTextView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            commentTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            commentTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            commentTextView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -6),
            
            addButton.bottomAnchor.constraint(equalTo: commentTextView.bottomAnchor, constant: -5),
            addButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            addButton.heightAnchor.constraint(equalToConstant: 27),
            addButton.widthAnchor.constraint(equalToConstant: 27),
            
            sendButton.trailingAnchor.constraint(equalTo: commentTextView.trailingAnchor, constant: -5),
            sendButton.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: 27),
            sendButton.widthAnchor.constraint(equalToConstant: 27),
            
            topView.topAnchor.constraint(equalTo: topAnchor),
            topView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: 0.4)
        ])
    }
    
    @objc func didTapPostButton() {
        inputDelegate?.didSendMessage(message: commentTextView.text)
        commentTextView.text = String()
        commentTextView.text = nil
        commentTextView.placeholder.isHidden = false
        commentTextView.invalidateIntrinsicContentSize()
    }
    
    @objc func handleAddMedia() {
        inputDelegate?.didTapAddMedia()
    }
}
