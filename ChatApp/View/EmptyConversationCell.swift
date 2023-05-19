//
//  EmptyConversationCell.swift
//  ChatApp
//
//  Created by Pau Fernández Solà on 18/5/23.
//

import UIKit

class EmptyConversationCell: UICollectionViewCell {

    private let emptyConversationImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .secondaryLabel
        iv.image = UIImage(named: "conversation.empty")
        return iv
    }()
    
    private let emptyConversationTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 23, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let emptyConversationSubtitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
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
        addSubviews(emptyConversationImage, emptyConversationTitle, emptyConversationSubtitle)
        
        NSLayoutConstraint.activate([
            emptyConversationImage.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            emptyConversationImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyConversationImage.heightAnchor.constraint(equalToConstant: 100),
            emptyConversationImage.widthAnchor.constraint(equalToConstant: 100),
            
            emptyConversationTitle.topAnchor.constraint(equalTo: emptyConversationImage.bottomAnchor, constant: 20),
            emptyConversationTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            emptyConversationTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            emptyConversationSubtitle.topAnchor.constraint(equalTo: emptyConversationTitle.bottomAnchor, constant: 10),
            emptyConversationSubtitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            emptyConversationSubtitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
        
        emptyConversationImage.layer.cornerRadius = (100) / 2
        
        let heighConstraint = heightAnchor.constraint(equalToConstant: 400)
        heighConstraint.priority = .defaultHigh
        heighConstraint.isActive = true
        
        configureWithConversation()
    }
    
    private func configureWithConversation() {
        emptyConversationTitle.text = AppStrings.Welcome.title
        emptyConversationSubtitle.text = AppStrings.Welcome.subtitle
    }
}
