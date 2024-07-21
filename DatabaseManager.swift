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
    var decks: [DeckData] = []
    var nonLanguages: [String] = []
    
    var AllCards: [Card] = []
    
    init(){
        
        self.database = Firestore.firestore()
        getLanguages()
        getDeckData()
        
        
        
        
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
    func getDeckData(){
        
        
        
        guard let userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func getLanguages()")
            
            return
        }
        database.collection("Users").document(userID).collection("DeckDatas")
        
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(String(describing: error))")
                    return
                }
                
                var deckDatas: [DeckData] = []
                
                for document in documents {
                    let data = document.data()
                    
                    if let name = data["name"] as? String,
                       let count = data["count"] as? Int {
                        
                        
                        let deck = DeckData(name: name, count: count)
                        deckDatas.append(deck)
                    }
                }
                
                self.decks = deckDatas
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
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Translation not found"]))
                return
            }
            
            let card: [String: Any] = cardToDic(front: "This is an example card", back: translation, dueDate: nil, id: "new")
            
            guard let cardID = card["id"] as? String else {
                print("Card has no ID")
                completion(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Card has no ID"]))
                return
            }
        
  
      
        self.database.collection("Users").document(userID).collection("Decks").document(language).collection("Cards").document(cardID).setData(card) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Document added with ID: \(card["front"] ?? "not found")")
            }
            completion(error)
        }
        
        let deckDataDict = deckToDic(deck: DeckData(name: language, count: 1))
        
        
        self.database.collection("Users").document(userID).collection("DeckDatas").document(language).setData(deckDataDict) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("Document added with ID: \(deckDataDict["count"] ?? 0)")
            }
            completion(error)
        }
    }
    
    private func increaseDeckCount(language: String, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user id found inside createDeck")
            completion(NSError(domain: "", code: 401, userInfo: ["error": "No user id found"]))
            return
        }
        guard var currentDeck = self.decks.first(where: { $0.name == language }) as? DeckData else{
            return
        }
        currentDeck.count = currentDeck.count + 1
        let deckDataDict = deckToDic(deck: currentDeck)
        self.database.collection("Users").document(userID).collection("DeckDatas").document(language).setData(deckDataDict) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("count changed to: \(deckDataDict["count"] ?? 0)")
            }
            completion(error)
        }
        getDeckData()
        
    }
    
    private func decreaseDeckCount(language: String, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user id found inside createDeck")
            completion(NSError(domain: "", code: 401, userInfo: ["error": "No user id found"]))
            return
        }
        guard var currentDeck = self.decks.first(where: { $0.name == language }) as? DeckData else{
            return
        }
        currentDeck.count = max(currentDeck.count - 1, 0)
        let deckDataDict = deckToDic(deck: currentDeck)
        self.database.collection("Users").document(userID).collection("DeckDatas").document(language).setData(deckDataDict) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("count changed to: \(deckDataDict["count"] ?? 0)")
            }
            completion(error)
        }
        
    }
    
    
    
    
    private func cardToDic(front: String, back: String, dueDate: Date?, id: String) -> [String: Any]{
        var cardId = id
        var cardDueDate = dueDate
        if id == "new"{
            cardId = UUID().uuidString
            cardDueDate = Date()
        }
        
        guard let cardDueDate = cardDueDate else{
            print("☎️ error. About to save card with no due date attached ☎️")
            return ["front": front, "back":back, "dueDate": Date(), "id": cardId]
        }
        
        return ["front": front, "back":back, "dueDate": cardDueDate, "id": cardId]
        
        
    }
    
    private func deckToDic(deck: DeckData) -> [String : Any]{
        let name = deck.name
        let count = deck.count
        return ["name": name, "count": count]
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
        guard let userID = Auth.auth().currentUser?.uid else {
            print("no user id found")
            
            return
        }
        
        let card = cardToDic(front: card.front, back: card.back, dueDate: card.dueDate, id: card.id)
        
        
        guard let cardID = card["id"] as? String else{
            print("card has no id")
            return
        }
        
        self.database.collection("Users").document(userID).collection("Decks").document(deckName).collection("Cards").document(cardID).setData(card) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("card added with name: \(card["front"] ?? "not found")")
                self.increaseDeckCount(language: deckName) { error in
                    if let error = error {
                        
                        print("Error: \(error.localizedDescription)")
                    } else {
                        
                        print("Deck count increased successfully.")
                    }
                }
                
            }
            completion(error)
        }
        
    }
    
    func getAllCardsInDeck(deckName: String){
        guard let userID = Auth.auth().currentUser?.uid else {
            print("no user id found inside func getLanguages()")
            
            return
        }
        
        print("running get all cards in deck жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж")
        database.collection("Users").document(userID).collection("Decks").document(deckName).collection("Cards")
        
            .addSnapshotListener { querySnapshot, error in
                
                
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(String(describing: error))")
                    return
                }
                var cards: [Card] = []
                for document in documents {
                    let data = document.data()
                    print(data)
                    print(type(of:data["front"]))
                    print(type(of:data["dueDate"]))
                    if let front = data["front"] as? String,
                       let back = data["back"] as? String,
                       let id = data["id"] as? String,
                       let date = self.asDate(data["dueDate"]) {
                        
                        print("Front: \(front)")
                        print("Back: \(back)")
                        print("ID: \(id)")
                        print("Due Date: \(date)")
                        
                        let card = Card(front: front, back: back, dueDate: date, id: id)
                                            print(card)
                                            cards.append(card)
                    } else {
                        print("Failed to parse some data")
                    }
                        

                    }
                
                
                self.AllCards = cards
                
            }
    }
    
    private func asDate(_ value: Any?) -> Date? {
        if let timestamp = value as? Timestamp {
            return timestamp.dateValue()
        } else if let dateString = value as? String {
            let dateFormatter = ISO8601DateFormatter()
            return dateFormatter.date(from: dateString)
        }
        return nil
    }
    
    func editCardInDeck(deckName: String, editedCard:Card, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("no user id found")
            
            return
        }
        
        let card = cardToDic(front: editedCard.front, back: editedCard.back, dueDate: editedCard.dueDate, id: editedCard.id)
        
        
        guard let cardID = card["id"] as? String else{
            print("card has no id")
            return
        }
        
        self.database.collection("Users").document(userID).collection("Decks").document(deckName).collection("Cards").document(cardID).setData(card) { error in
            if let error = error {
                print("Error adding document: \(error.localizedDescription)")
            } else {
                print("card edited with name: \(card["front"] ?? "not found")")
                
                
            }
            completion(error)
        }
        
    }
    
    
    func deleteCard(deckName: String, deleteCard:Card, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("no user id found")
            
            return
        }
        print("")
        print("😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈Running delete card😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈😈")
        print("")
        let cardID = deleteCard.id
        
        self.database.collection("Users").document(userID).collection("Decks").document(deckName).collection("Cards").document(cardID).delete { error in
            if let error = error {
                print("Error deleting document: \(error.localizedDescription)")
            } else {
                print("Card deleted with front: \(deleteCard.front)")
                print("card id " + deleteCard.id)
                self.decreaseDeckCount(language: deckName) { error in
                    if let error = error {
                        
                        print("Error: \(error.localizedDescription)")
                    } else {
                        
                        print("Deck count decreased successfully.")
                    }
                }
                
            }
            completion(error)
        }
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
        
        self.database.collection("Users").document(userID).collection("DeckDatas").document(language)
            .delete { error in
                if let error = error {
                    print("Error removing deck data from Firestore:", error.localizedDescription)
                    completion(error)
                } else {
                    print("Deck Data removed from Firestore successfully")
                    completion(nil)
                }
            }
        
        
        deleteAllCards(deckName: language) { error in
            if let error = error {
                print("Error deleting all cards: \(error.localizedDescription)")
            } else {
                print("All cards deleted successfully.")
            }
        }
        
        self.database.collection("Users").document(userID).collection("Decks").document(language)
            .delete { error in
                if let error = error {
                    print("Error removing WHOLE deck from Firestore:", error.localizedDescription)
                    completion(error)
                } else {
                    print("WHOLE Deck removed from Firestore successfully")
                    completion(nil)
                }
            }
        
        getDeckData()
    }
    
    
    
    
    
    func deleteAllDocumentsInCollection(collectionPath: String, batchSize: Int = 100, completion: @escaping (Error?) -> Void) {
        let collectionRef = self.database.collection(collectionPath)
        
        func deleteBatch(query: Query, completion: @escaping (Error?) -> Void) {
            query.getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else {
                    completion(error)
                    return
                }
                
                guard !snapshot.isEmpty else {
                    
                    completion(nil)
                    return
                }
                
                let batch = self.database.batch()
                snapshot.documents.forEach { batch.deleteDocument($0.reference) }
                
                batch.commit { batchError in
                    if let batchError = batchError {
                        completion(batchError)
                        return
                    }
                    
                    
                    deleteBatch(query: query, completion: completion)
                }
            }
        }
        
        let initialQuery = collectionRef.limit(to: batchSize)
        deleteBatch(query: initialQuery, completion: completion)
    }
    

    func deleteAllCards(deckName: String, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user ID found")
            
            return
        }
        
        let collectionPath = "Users/\(userID)/Decks/\(deckName)/Cards"
        
        deleteAllDocumentsInCollection(collectionPath: collectionPath) { error in
            if let error = error {
                print("Error deleting all cards: \(error.localizedDescription)")
            } else {
                print("All cards deleted successfully.")
            }
            completion(error)
        }
    }
}





// I decided to make this struct not contain cards since it is going to be fetched so often and it would be too expensive to fetch all the cards every time we just want to get the number
struct DeckData: Equatable, Hashable {

    

    

    
    var name: String

    
    var emoji: String
    var count: Int
    init(name: String, count: Int){
        self.name = name
        
        self.count = count
 
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
struct Card: Equatable, Hashable, Codable{
    var front: String
    var back: String
    var dueDate: Date
    var id: String
    init(front: String, back: String, dueDate: Date, id: String?){
        self.front = front
        self.back = back
        self.dueDate = dueDate
        if id == nil {
            print(" 📒 no past card id found. generating new one 📒 ")
            self.id = UUID().uuidString
            
        }
        else{
            self.id = id!
        }
    }
}
