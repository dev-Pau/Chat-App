//
//  Answers.swift
//  ChatApp
//
//  Created by Pau Fernández Solà on 19/5/23.
//

import Foundation

struct Answers {
    
    static let shared = Answers()
    
    private let randomAnswers: [String] = [
        "My favorite color is blue.",
        "In my free time, I enjoy reading books and playing guitar.",
        "I absolutely love the movie 'The Shawshank Redemption'.",
        "Yes, I have a cute little dog named Max.",
        "I can never resist a delicious slice of pizza.",
        "I've always dreamed of visiting the beautiful beaches of Bora Bora.",
        "One of my all-time favorite books is 'To Kill a Mockingbird' by Harper Lee.",
        "I enjoy going for a jog in the mornings and practicing yoga in the evenings.",
        "I love the cozy atmosphere of autumn with its colorful leaves and cool weather.",
        "I'm a big fan of rock music, especially classic rock bands like Led Zeppelin and Queen.",
        "I enjoy painting and expressing my creativity through art.",
        "My favorite hobby is playing basketball and being part of a local league.",
        "I find cooking to be a therapeutic activity, and I love trying out new recipes.",
        "I'm a fan of science fiction movies, especially the 'Star Wars' franchise.",
        "I have a cat named Luna who is my constant companion.",
        "I love traveling and exploring different cultures and cuisines.",
        "I enjoy gardening and spending time taking care of my plants.",
        "I'm a fan of puzzle games like Sudoku and crosswords.",
        "I'm passionate about photography and capturing beautiful moments.",
        "I find meditation and mindfulness practices to be beneficial for my well-being.",
        "I enjoy volunteering and giving back to the community.",
        "I'm a fan of comedy shows and stand-up performances.",
        "I find hiking in nature to be a great way to unwind and recharge.",
        "I love watching documentaries and learning about various topics.",
        "I'm a fan of classic literature, and Jane Austen is one of my favorite authors.",
        "I enjoy playing board games and having game nights with friends.",
        "I'm passionate about environmental sustainability and reducing my carbon footprint.",
        "I find listening to podcasts to be a great way to learn and stay informed.",
        "I enjoy DIY projects and working on home improvement tasks.",
        "I'm a fan of team sports like soccer and basketball.",
        "I find astronomy and stargazing fascinating."
    ]
    
    func getAnswer() -> String {
        let value = Int.random(in: 0 ..< randomAnswers.count)
        return randomAnswers[value]
    }
}
