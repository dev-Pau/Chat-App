//
//  ConversationsViewController.swift
//  ChatApp
//
//  Created by Pau Fernández Solà on 12/5/23.
//

import UIKit
import CoreData

private let emptyConversationReuseIdentifier = "EmptyConversationCellReuseIdentifier"
private let conversationCellReuseIdentifier = "ConversationCellReuseIdentifier"

class ConversationViewController: UIViewController {
    
    // MARK: - Properties
    
    private var collectionView: UICollectionView!
    private var conversations = [Conversation]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNavigationBar()
        loadConversations()
    }

    //MARK: - Helpers

     private func conversationLayout() -> UICollectionViewCompositionalLayout {
         let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
             if self.conversations.isEmpty {
                 let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(400)))
                 let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(80)), subitems: [item])
                 let section = NSCollectionLayoutSection(group: group)
                 return section
             } else {
                 let section = NSCollectionLayoutSection.list(using: self.createListConfiguration(), layoutEnvironment: env)
                 return section
             }
         }
         return layout
     }
    
    private func createListConfiguration() -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.showsSeparators = false
        configuration.trailingSwipeActionsConfigurationProvider = { indexPath in
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] action, view, completion in
                
                let alert = UIAlertController(title: AppStrings.ConversationAlert.delete,
                                              message: AppStrings.ConversationAlert.deleteAlert,
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: AppStrings.Global.cancel, style: UIAlertAction.Style.cancel, handler: { _ in
                    completion(true)
                }))
                
                alert.addAction(UIAlertAction(title: AppStrings.Global.delete, style: UIAlertAction.Style.destructive, handler: { _ in
                    self?.deleteConversation(at: indexPath)
                    completion(true)
                }))
                self?.present(alert, animated: true, completion: nil)
            }
            deleteAction.image = self.swipeLayout(icon: AppStrings.Icons.trash, text: AppStrings.Global.delete, size: 16)
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        
        configuration.leadingSwipeActionsConfigurationProvider = { indexPath in
            let pinAction = UIContextualAction(style: .normal, title: nil) { [weak self] action, view, completion in
                
                completion(true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.togglePinConversation(at: indexPath)
                }
            }
            pinAction.image = self.swipeLayout(icon: AppStrings.Icons.fillPin, text: self.conversations[indexPath.item].isPinned ? AppStrings.Actions.unpin : AppStrings.Actions.pin, size: 16)
            return UISwipeActionsConfiguration(actions: [pinAction])
        }
        return configuration
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: conversationLayout())
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ConversationCell.self, forCellWithReuseIdentifier: conversationCellReuseIdentifier)
        collectionView.register(EmptyConversationCell.self, forCellWithReuseIdentifier: emptyConversationReuseIdentifier)
        view.addSubview(collectionView)
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Title.conversation
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.Global.add, style: .plain, target: self, action: #selector(handleAddConversations))
    }
    
    private func loadConversations() {
        conversations = DataGateway.shared.getConversations()
    }
    
    private func sortConversations() {
        conversations.sort { (conversation1, conversation2) -> Bool in
            if conversation1.isPinned && !conversation2.isPinned {
                return true
            }

            if !conversation1.isPinned && conversation2.isPinned {
                return false
            }
            
            return conversation1.latestMessage.sentDate > conversation2.latestMessage.sentDate
        }
    }
    
    private func deleteConversation(at indexPath: IndexPath) {
        let conversation = conversations[indexPath.row]
        DataGateway.shared.delete(conversation: conversation)
        collectionView.performBatchUpdates {
            self.conversations.remove(at: indexPath.row)
            collectionView.deleteItems(at: [indexPath])
        }
    }
    
    private func togglePinConversation(at indexPath: IndexPath) {
        self.conversations[indexPath.row].togglePin()
        let conversationToUpdate = self.conversations[indexPath.row]
        DataGateway.shared.edit(conversation: conversationToUpdate, set: conversationToUpdate.isPinned, forKey: "isPinned")
        
        let unorderedConversations = self.conversations
        self.sortConversations()
        let sortMap = unorderedConversations.map { conversations.firstIndex(of: $0)!}
        
        collectionView.performBatchUpdates {
            for index in 0 ..< sortMap.count {
                if index != sortMap[index] {
                    self.collectionView.moveItem(at: IndexPath(item: index, section: 0), to: IndexPath(item: sortMap[index], section: 0))
                }
            }
        } completion: { _ in
            self.collectionView.reloadData()
        }
    }

    //MARK: - Actions
    
    @objc func handleAddConversations() {
        
        let uuid = UUID()
        let url = FileGateway.shared.saveImage(UIImage(named: "user.profile")!, userId: uuid)
        
        let latestMessage = Message(text: "Welcome to ChatApp 💭", sentDate: Date(), messageId: UUID(), isRead: false, isSender: false, kind: .text)
        let conversation = Conversation(name: "ChatApp User \(conversations.count + 1)", image: url?.absoluteString ?? nil, userId: uuid, unreadMessages: 1, isPinned: false, latestMessage: latestMessage)
        
        DataGateway.shared.save(conversation: conversation, latestMessage: latestMessage)
        
        self.conversations.insert(conversation, at: 0)
        self.sortConversations()
        
        if let conversationIndex = conversations.firstIndex(of: conversation) {
            collectionView.performBatchUpdates {
                self.collectionView.insertItems(at: [IndexPath(item: conversationIndex, section: 0)])
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource

extension ConversationViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return conversations.isEmpty ? 1 : conversations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if conversations.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emptyConversationReuseIdentifier, for: indexPath) as! EmptyConversationCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: conversationCellReuseIdentifier, for: indexPath) as! ConversationCell
            cell.viewModel = ConversationViewModel(conversation: conversations[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !conversations.isEmpty else { return }
        let conversation = conversations[indexPath.row]
        let controller = MessageViewController(conversation: conversation)
        controller.messageDelegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard !indexPaths.isEmpty, !conversations.isEmpty else { return nil }
        let previewViewController = UINavigationController(rootViewController: MessageViewController(conversation: conversations[indexPaths[0].item], preview: true))
        let previewProvider: () -> UINavigationController? = { previewViewController }
       
        return UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider) { _ in
            let deleteAction = UIAction(title: AppStrings.ConversationAlert.delete, image: UIImage(systemName: AppStrings.Icons.trash), attributes: .destructive) { action in
                let alert = UIAlertController(title: AppStrings.ConversationAlert.delete,
                                              message: AppStrings.ConversationAlert.deleteAlert,
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: AppStrings.Global.cancel, style: UIAlertAction.Style.cancel, handler: { _ in }))
                alert.addAction(UIAlertAction(title: AppStrings.Global.delete, style: UIAlertAction.Style.destructive, handler: { _ in
                    self.deleteConversation(at: indexPaths[0])
                }))
                self.present(alert, animated: true, completion: nil)
            }
            return UIMenu(children: [deleteAction])
        }
    }
}

// MARK: - MessageViewControllerDelegate

extension ConversationViewController: MessageViewControllerDelegate {
    func didReadAllMessages(for conversation: Conversation) {
        if let conversationIndex = conversations.firstIndex(where: { $0.userId == conversation.userId }) {
            conversations[conversationIndex].markMessagesAsRead()
            collectionView.reloadItems(at: [IndexPath(item: conversationIndex, section: 0)])
        }
    }
    
    func didSendMessage(for conversation: Conversation, message: Message) {
        if let conversationIndex = conversations.firstIndex(where: { $0.userId == conversation.userId }) {
            conversations[conversationIndex].changeLatestMessage(to: message)
            sortConversations()
            collectionView.reloadData()
        }
    }
    
    private func swipeLayout(icon: String, text: String, size: CGFloat) -> UIImage {
        let config = UIImage.SymbolConfiguration(pointSize: size, weight: .regular, scale: .large)
        let img = UIImage(systemName: icon, withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        label.text = text
        
        let tempView = UIStackView(frame: .init(x: 0, y: 0, width: 50, height: 50))
        let imageView = UIImageView(frame: .init(x: 0, y: 0, width: img!.size.width, height: img!.size.height))
        imageView.contentMode = .scaleAspectFit
        tempView.axis = .vertical
        tempView.alignment = .center
        tempView.spacing = 2
        imageView.image = img
        tempView.addArrangedSubview(imageView)
        tempView.addArrangedSubview(label)
        
        let renderer = UIGraphicsImageRenderer(bounds: tempView.bounds)
        let image = renderer.image { rendererContext in
            tempView.layer.render(in: rendererContext.cgContext)
        }
        return image
    }
}


