//
//  DatabaseManager.swift
//  Kartochki
//
//  Created by Darian Lee on 6/5/24.
//
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import FirebaseCore
import SwiftUI

@Observable
class DatabaseManager {
    let database: Firestore
    var languages: [String] = []
    var name: String = ""
    var decks: [Deck] = []
    var nonLanguages: [String] = []
    
    
    
    init(){
        
        self.database = Firestore.firestore()
        getLanguages()
        getDecks()
        
        
        
        
    }
    
    func getWelcomeMessage(language: String) -> String{
        let languageTranslationsWelcome: [String: String] = [
            "Japanese": "ようこそ",
            "Spanish": "Bienvenido",
            "Chinese": "欢迎",
            "Arabic": "أهلا بك",
            "Russian": "Добро пожаловать",
            "Korean": "환영합니다",
            "German": "Willkommen",
            "French": "Bienvenue",
            "Turkish": "Hoş geldiniz",
            "Italian": "Benvenuto",
            "Hindi": "स्वागत है",
            "Urdu": "خوش آمدید",
            "Vietnamese": "Chào mừng",
            "Polish": "Witamy",
            "Persian": "خوش آمدید",
            "Ukrainian": "Ласкаво просимо",
            "Portuguese": "Bem-vindo"
        ]

        let languageTranslationsGoodToSeeYou: [String: String] = [
            "Japanese": "お会いできて嬉しいです",
            "Spanish": "Me alegra verlo",
            "Chinese": "见到您很高兴",
            "Arabic": "سعدت برؤيتك",
            "Russian": "Рад вас видеть",
            "Korean": "반갑습니다",
            "German": "Schön Sie zu sehen",
            "French": "Content de vous voir",
            "Turkish": "Sizi görmek güzel",
            "Italian": "Felice di vederla",
            "Hindi": "आपसे मिलकर अच्छा लगा",
            "Urdu": "آپ سے مل کر خوشی ہوئی",
            "Vietnamese": "Rất vui được gặp bạn",
            "Polish": "Miło Pana/Panią widzieć",
            "Persian": "از دیدنتان خوشبختم",
            "Ukrainian": "Радий вас бачити",
            "Portuguese": "Bom vê-lo"
        ]
        
        guard let messageType = [languageTranslationsGoodToSeeYou, languageTranslationsWelcome].randomElement() else{
            return "Welcome"
        }
        
        guard let message = messageType[language] else{
            print("no message found")
            return "Welcome"
        }
        print("🕉️🕉️🕉️ this is the message 🕉️🕉️🕉️", message)
        return message
    }
    
    
    
    func getLanguages(){
        let allLanguages = ["Arabic", "Chinese", "French", "German", "Hindi", "Italian", "Japanese", "Korean", "Persian", "Polish", "Portuguese", "Russian", "Spanish", "Turkish", "Ukrainian", "Urdu", "Vietnamese"]
        
        print("running get languages")
        guard let userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func getLanguages()")
            
            return
        }
        print("userID")
        database.collection("Users").document(userID).collection("Languages")
        
            .addSnapshotListener { querySnapshot, error in
                
                
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(String(describing: error))")
                    return
                }
                var languages: [String] = []
                for document in documents {
                    let data = document.data()
                    if let language = data["language"] as? String{
                        print("we found this language: ")
                        print(language)
                        languages.append(language)
                    }
                }
                
                self.languages = languages
                self.nonLanguages = allLanguages.filter { !languages.contains($0) }            }
        
        database.collection("Users").document(userID).collection("PersonalInfo")
        
            .addSnapshotListener { querySnapshot, error in
                
                
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(String(describing: error))")
                    return
                }
                
                for document in documents {
                    let data = document.data()
                    if let name = data["name"] as? String{
                        print("we found this name: ")
                        print(name)
                        self.name = name
                    }
                }
                
                
                
            }
    }
    func getDecks(){
        
        
        
        guard let userID = Auth.auth().currentUser?.uid else {
        print("no user id found inside func getLanguages()")
        
        return
    }
    database.collection("Users").document(userID).collection("Decks")
    
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(String(describing: error))")
                    return
                }
                
                var decks: [Deck] = []
                
                for document in documents {
                    let data = document.data()
                    
                    if let name = data["name"] as? String,
                       let cardsData = data["cards"] as? [[String: Any]] {
                        
                        var cards: [Card] = []
                        
                        for cardData in cardsData {
                            if let front = cardData["front"] as? String,
                               let back = cardData["back"] as? String,
                               let dueDateTimestamp = cardData["dueDate"] as? Timestamp {
                                
                                let dueDate = dueDateTimestamp.dateValue()
                                let card = Card(front: front, back: back, dueDate: dueDate)
                                cards.append(card)
                            }
                        }
                        
                        let deck = Deck(name: name, cards: cards)
                        decks.append(deck)
                    }
                }
                
                self.decks = decks
            }
    
    database.collection("Users").document(userID).collection("PersonalInfo")
    
        .addSnapshotListener { querySnapshot, error in
            
            
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            
            for document in documents {
                let data = document.data()
                if let name = data["name"] as? String{
                    self.name = name
                }
            }
            
            
            
        }
}
    
    func setLanguages(languages: [String], completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func setLanguages")
            
            return
        }
        print("auth.auth!", userID)
        //var languageDict: [[String:String]] = []
        for language in languages{
            let tempDict = ["language": language]
            self.database.collection("Users").document(userID).collection("Languages").document(language).setData(tempDict) { error in
                print(error?.localizedDescription)
                completion(error)
            }
            
        }
        
        getLanguages()
    }
    func createDeck(language: String, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user id found inside createDeck")
            completion(NSError(domain: "", code: 401, userInfo: ["error": "No user id found"]))
            return
        }
        
 
        let translations: [String: String] = [
            "Japanese": "これは例のカードです。",
            "Spanish": "Esta es una tarjeta de ejemplo.",
            "Chinese": "这是一张示例卡片。",
            "Arabic": "هذه بطاقة مثال.",
            "Russian": "Это примерная карта.",
            "Korean": "이것은 예제 카드입니다.",
            "German": "Dies ist eine Beispielkarte.",
            "French": "Ceci est une carte d'exemple.",
            "Turkish": "Bu bir örnek karttır.",
            "Italian": "Questa è una carta di esempio.",
            "Hindi": "यह एक उदाहरण कार्ड है।",
            "Urdu": "یہ ایک مثال کارڈ ہے۔",
            "Vietnamese": "Đây là một thẻ ví dụ.",
            "Polish": "To jest przykładowa karta.",
            "Persian": "این یک کارت نمونه است.",
            "Ukrainian": "Це приклад картки.",
            "Portuguese": "Este é um cartão de exemplo."
    
        ]
        
        guard let translation = translations[language] else {
            print("Translation not found for language: \(language)")
            completion(NSError(domain: "", code: 404, userInfo: ["error": "Translation not found"]))
            return
        }
        
        let cards: [Card] = [
            Card(front: "This is an example card", back: translation, dueDate: Date())
            
        ]
        
        let deck = Deck(name: language, cards: cards)
        
      
        let deckData: [String: Any] = [
            "name": deck.name,
            "cards": deck.cards.map { ["front": $0.front, "back": $0.back, "dueDate": $0.dueDate] }
        ]
        
        self.database.collection("Users").document(userID).collection("Decks").document(language).setData(deckData) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Document added with ID: \(language)")
            }
            completion(error)
        }
    }
    
    
    
    func initializeNewUser(languages: [String], name: String, completion: @escaping (Error?) -> Void){
        guard let userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func initializeNewUser")
            
            return
        }
        self.database.collection("Users").document(userID).collection("PersonalInfo").document("name").setData(["name": name]) { error in
            print(error?.localizedDescription)
            completion(error)
        }
        
        self.setLanguages(languages: languages) { error in
            if let error = error {
                print("Error adding room: \(error.localizedDescription)")
            }
        }
        for language in languages{
            self.createDeck(language: language){ error in
                if let error = error {
                    print("Error adding room: \(error.localizedDescription)")
                }
            }
            
        }
    }
    
    
    func addCardToDeck(deckName: String, card:Card, completion: @escaping (Error?) -> Void) {
        var currentCards = getCardsInDeck(deckName: deckName)
        currentCards.append(card)
        let currentDeck = Deck(name: deckName, cards: currentCards)
        
        
    }
    
    
    
    
    
    func getCardsInDeck(deckName: String) -> [Card] {
        return self.decks.first { $0.name == deckName }?.cards ?? []
    }
    
    
    
    
    func deleteLanguageAndDeck(language: String, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func setLanguages")
            
            return
        }
        print("auth.auth!", userID)
        
        database.collection("Users").document(userID).collection("Languages").document(language)
            .delete { error in
                if let error = error {
                    print("Error removing language from Firestore:", error.localizedDescription)
                    completion(error)
                } else {
                    print("Language removed from Firestore successfully")
                    completion(nil)
                }
            }
        
        database.collection("Users").document(userID).collection("Decks").document(language)
            .delete { error in
                if let error = error {
                    print("Error removing deck from Firestore:", error.localizedDescription)
                    completion(error)
                } else {
                    print("Deck removed from Firestore successfully")
                    completion(nil)
                }
            }
        
        getDecks()
    }
    
}

struct Deck: Equatable, Hashable {

    static func == (lhs: Deck, rhs: Deck) -> Bool {
            return lhs.cards == rhs.cards &&
                   lhs.name == rhs.name &&
                   lhs.emoji == rhs.emoji &&
                   lhs.count == rhs.count
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(cards)
            hasher.combine(emoji)
            hasher.combine(count)
        }

    
    var name: String

    var cards: [Card]
    var emoji: String
    var count: Int
    init(name: String, cards: [Card] = []){
        self.name = name
        self.cards = cards
        self.count = cards.count
 
        let languagesWithCulturalAndFlagEmojis: [String: String] = [
            "Japanese": "🍣",
            "Spanish": "💃",
            "Chinese": "🐉",
            "Arabic": "🕌",
            "Russian": "🪆",
            "Korean": "🥢",
            "German": "🍺",
            "French": "🥖",
            "Turkish": "☕️",
            "Italian": "🍕",
            "Hindi": "🪷",
            "Urdu": "🏏",
            "Vietnamese": "🍜",
            "Polish": "🕍",
            "Persian": "🐆",
            "Ukrainian": "🥟",
            "Portuguese": "🏖️"
        ]
        guard let emoji = languagesWithCulturalAndFlagEmojis[name] else { 
            self.emoji = ""
        return }
        self.emoji = emoji
            
        
    }
}
struct Card: Equatable, Hashable{
    var front: String
    var back: String
    var dueDate: Date
}

