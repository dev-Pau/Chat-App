//
//  ViewController.swift
//  ChatApp
//
//  Created by Pau Fernández Solà on 12/5/23.
//

import UIKit
import CoreData
import PhotosUI

private let messageTextCellReuseIdentifier = "MessageTextCellReuseIdentifier"
private let messageImageCellReuseIdentifier = "MessageImageCellReuseIdentifier"

protocol MessageViewControllerDelegate: AnyObject {
    func didReadAllMessages(for conversation: Conversation)
    func didSendMessage(for conversation: Conversation, message: Message)
}

class MessageViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    weak var messageDelegate: MessageViewControllerDelegate?

    private let chatInputAccessoryView = ChatInputAccessoryView()
    private let conversation: Conversation
    private var messages = [Message]()
    private var scrolledToBottom: Bool = false
    private var fetchBatchSize = 40
    private var preview: Bool = false
    private var initialLoad = true
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGreen
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.isScrollEnabled = true
        configure()
        getData()
    }
    
    /// Initializes a new instance of the MessageViewController with a conversation and a preview flag.
    ///
    /// - Parameters:
    ///   - conversation: The conversation to display.
    ///   - preview: A flag indicating wether the view controller is in preview mode.
    init(conversation: Conversation, preview: Bool? = false) {
        self.conversation = conversation
        
        if let preview {
            self.preview = preview
        }
        
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 10, bottom: 10, trailing: 10)
        let layout = UICollectionViewCompositionalLayout(section: section)
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func getData() {
        messages = DataGateway.shared.getMessages(for: conversation)
        print(messages)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            let lastIndexPath = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: false)
            if self.preview == false {
                DataGateway.shared.readMessages(conversation: self.conversation)
                self.messageDelegate?.didReadAllMessages(for: self.conversation)
            }
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return preview ? false : true
    }
    
    private func configure() {
        title = conversation.name
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MessageTextCell.self, forCellWithReuseIdentifier: messageTextCellReuseIdentifier)
        collectionView.register(MessagePhotoCell.self, forCellWithReuseIdentifier: messageImageCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        chatInputAccessoryView.inputDelegate = self
        guard preview == false else { return }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.Global.receive, style: .done, target: self, action: #selector(sendUserMessage))
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.bounds.height {
            scrolledToBottom = true
        }
        guard scrolledToBottom else { return }
        
        if initialLoad {
            initialLoad = false
            return
        }
        
        if scrollView.contentOffset.y < scrollView.contentSize.height / 3 {
            fetchMoreMessages()
        }
    }
    
    private func fetchMoreMessages() {
        guard let newestMessage = messages.first else { return }
        
        let newMessages = DataGateway.shared.getMoreMessages(for: conversation, from: newestMessage.sentDate)
        messages.insert(contentsOf: newMessages, at: 0)

        var newIndexPaths = [IndexPath]()
        newMessages.enumerated().forEach { index, post in
            newIndexPaths.append(IndexPath(item: index, section: 0))
            if newIndexPaths.count == newMessages.count {
                collectionView.isScrollEnabled = false
                collectionView.showsVerticalScrollIndicator = false
                
                collectionView.performBatchUpdates {
                    collectionView.isScrollEnabled = false
                    collectionView.insertItems(at: newIndexPaths)
                    collectionView.layoutIfNeeded()
                    
                    var totalHeight: CGFloat = 0.0
                    for indexPath in newIndexPaths {
                        if let layoutAttributes = collectionView.layoutAttributesForItem(at: indexPath) {
                            totalHeight += layoutAttributes.frame.height
                        }
                    }
                    let contentHeight = collectionView.contentSize.height + totalHeight
                    collectionView.contentSize.height = contentHeight
                } completion: { _ in
                    self.collectionView.showsVerticalScrollIndicator = true
                }
                
                DispatchQueue.main.async {
                    self.collectionView.isScrollEnabled = true
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func sendUserMessage() {
        let answer = Answers.shared.getAnswer()
        let newMessage = Message(text: answer, sentDate: Date.now, messageId: UUID(), isRead: false, isSender: false, kind: .text)
        
        DataGateway.shared.save(message: newMessage, to: conversation)
        
        messages.append(newMessage)
        messageDelegate?.didSendMessage(for: conversation, message: newMessage)
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: [IndexPath(item: messages.count - 1, section: 0)])
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.collectionView.scrollToItem(at: IndexPath(item: self.messages.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    func firstMessageOfTheDay(indexOfMessage: IndexPath) -> Bool {
        let messageDate = messages[indexOfMessage.item].sentDate
        guard indexOfMessage.item > 0 else { return true }
        let previouseMessageDate = messages[indexOfMessage.item - 1].sentDate
        
        let day = Calendar.current.component(.day, from: messageDate)
        let previouseDay = Calendar.current.component(.day, from: previouseMessageDate)
        if day == previouseDay {
            return false
        } else {
            return true
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages[indexPath.item]
        switch message.kind {
            
        case .text:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messageTextCellReuseIdentifier, for: indexPath) as! MessageTextCell
            cell.viewModel = MessageViewModel(message: messages[indexPath.row])
            cell.displayTimestamp(firstMessageOfTheDay(indexOfMessage: indexPath))
            return cell
        case .photo:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messageImageCellReuseIdentifier, for: indexPath) as! MessagePhotoCell
            cell.viewModel = MessageViewModel(message: messages[indexPath.row])
            cell.displayTimestamp(firstMessageOfTheDay(indexOfMessage: indexPath))
            return cell
        }
    }
}

// MARK: - ChatInputAccessoryViewDelegate, PHPickerViewControllerDelegate

extension MessageViewController: ChatInputAccessoryViewDelegate, PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if results.count == 0 { return }
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                guard let self = self else { return }
                guard let image = reading as? UIImage, error == nil else { return }
                DispatchQueue.main.async {
                    picker.dismiss(animated: true)
                    self.sendMessageWithImage(image: image)
                }
            }
        }
    }
    
    func didTapAddMedia() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        let controller = PHPickerViewController(configuration: config)
        controller.delegate = self
        present(controller, animated: true)
    }
    
    func didSendMessage(message: String) {
        let newMessage = Message(text: message, sentDate: Date.now, messageId: UUID(), isRead: true, isSender: true, kind: .text)
        
        DataGateway.shared.save(message: newMessage, to: conversation)
        
        messages.append(newMessage)
        messageDelegate?.didSendMessage(for: conversation, message: newMessage)
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: [IndexPath(item: messages.count - 1, section: 0)])
        } completion: { _ in
            self.collectionView.scrollToItem(at: IndexPath(item: self.messages.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    func sendMessageWithImage(image: UIImage) {
        let uuid = UUID()
        if let url = FileGateway.shared.saveImage(image, userId: uuid) {
            
            let newMessage = Message(text: "Image", sentDate: Date.now, messageId: uuid, isRead: true, isSender: true, image: url.absoluteString, kind: .photo)
            
            DataGateway.shared.save(message: newMessage, to: conversation)
            
            messages.append(newMessage)
            messageDelegate?.didSendMessage(for: conversation, message: newMessage)
            collectionView.performBatchUpdates {
                collectionView.insertItems(at: [IndexPath(item: messages.count - 1, section: 0)])
            } completion: { _ in
                self.collectionView.scrollToItem(at: IndexPath(item: self.messages.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
}
