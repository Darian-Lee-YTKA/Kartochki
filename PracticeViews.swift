//
//  PracticeViews.swift
//  Kartochki
//
//  Created by Darian Lee on 7/23/24.
//

import SwiftUI


struct PopupView: View {
    let emoji: String
    let direction: CardContentView.SwipeDirection
    @State private var swipeOffset: CGFloat = 0
    var body: some View {
        VStack {
            Text("Please swipe")
                .font(.headline)
                .foregroundColor(.white)
            Text(emoji)
                .font(.system(size: 50))
                .transition(transitionForDirection(direction))
                .offset(x: swipeOffset)
                                    .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true))
        }
        .onAppear {
            if direction == .left{
                swipeOffset = -50
            }
            else {
                swipeOffset = 50
            }
        }
        .frame(width: 250, height: 100)
                .background(Color.black.opacity(0.8))
                .cornerRadius(10)
                .foregroundColor(.white)
                .shadow(radius: 10)
    }
        
    
    private func transitionForDirection(_ direction: CardContentView.SwipeDirection) -> AnyTransition {
        switch direction {
        case .left:
            return .move(edge: .trailing)
        case .right:
            return .move(edge: .leading)
        }
    }
}




struct CardContentView: View {
    let card: Card
    @Binding var userAnswer: String
    @Binding var isShowingAnswer: Bool
    @Binding var attributedAnswers: (AttributedString, AttributedString)
    @State private var showPlainAnswer: Bool = false
    @State private var showSwipeReminder = false
    @State private var swipeDirection: SwipeDirection? = nil
    @State private var noUserAnswer: Bool =  false
  
    enum SwipeDirection {
        case left, right
    }
    
    var body: some View {
        VStack {
            ScrollView {
                HStack(spacing: 0) {
                    Image("kartochkiWhite")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 100)
                        .clipped()
                        .padding(15)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                
                VStack {
                    Text(card.front)
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                        .bold()
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                TextField("Type answer", text: $userAnswer, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .foregroundStyle(.black)
                    .padding()
                
                Button(action: {
                    if userAnswer == "" {
                        showPlainAnswer.toggle()
                        isShowingAnswer.toggle()
                        noUserAnswer = true
                    }
                    else{
                        noUserAnswer = false
                        attributedAnswers = colorAnswer(correct: card.back.lowercased(), userAnswer: userAnswer.lowercased())
                        isShowingAnswer.toggle()
                    }
                    
                }) {
                    Text("Show answer")
                        .foregroundColor(.white)
                        .padding()
                }
                
                if isShowingAnswer {
                    if showPlainAnswer {
                        HStack {
                            Text(card.back)
                                .foregroundColor(.white)
                            
                            if noUserAnswer == false{
                                Button(action: {
                                    showPlainAnswer.toggle()
                                }) {
                                    
                                    Image(systemName: "questionmark.circle")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    } else {
                        VStack(alignment: .leading) {
                            Text(attributedAnswers.0)
                                .padding(.vertical, 5)

                            HStack {
                                Text(attributedAnswers.1)
                                Button(action: {
                                    showPlainAnswer.toggle()
                                }) {
                                    Image(systemName: "questionmark.circle")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            HStack {
                HStack {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                    Text("incorrect")
                        .foregroundColor(.white)
                }
                .onLongPressGesture(minimumDuration: 0.1) {
                    swipeDirection = .left
                    showSwipeReminder.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSwipeReminder = false
                    }
                }
                .overlay(
                    Group {
                        if showSwipeReminder, swipeDirection == .left {
                            PopupView(emoji: "👈", direction: .left)
                                .transition(.opacity)
                                .animation(.easeInOut, value: showSwipeReminder)
                        }
                    }
                )
                
                Spacer()
                
                HStack {
                    Text("correct")
                        .foregroundColor(.white)
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white)
                }
                .onLongPressGesture(minimumDuration: 0.1) {
                    swipeDirection = .right
                    showSwipeReminder.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSwipeReminder = false
                    }
                }
                .overlay(
                    Group {
                        if showSwipeReminder, swipeDirection == .right {
                            PopupView(emoji: "👉", direction: .right)
                                .transition(.opacity)
                                .animation(.easeInOut, value: showSwipeReminder)
                        }
                    }
                )
            }
            .padding()
        }
    }

    
    
    private func colorAnswer(correct: String, userAnswer: String) -> (AttributedString, AttributedString) {
        var attributedString1 = AttributedString()
        var attributedString2 = AttributedString()
        
        let lightGreen = Color(red: 0.6, green: 0.85, blue: 0.6)
        let lightRed = UIColor(red: 255/255, green: 153/255, blue: 153/255, alpha: 1.0)
        let blackBackground = UIColor.black
        let whiteForeground = UIColor.white

        
//        if userAnswer == ""{
//           attributedString2 =  AttributedString(correct)
//            attributedString2.foregroundColor = whiteForeground
//            attributedString2.backgroundColor = blackBackground
//            attributedString2.underlineStyle = .single
//            
//            
//
//            attributedString1 = AttributedString("")
//            
//            return (attributedString1, attributedString2)
//        }
        
        
        
        let correctArray = Array(correct)
        let userAnswerArray = Array(userAnswer)
        
        
        var dp = Array(repeating: Array(repeating: 0, count: userAnswerArray.count + 1), count: correctArray.count + 1)
        
        for i in 0..<correctArray.count {
            for j in 0..<userAnswerArray.count {
                if correctArray[i] == userAnswerArray[j] {
                    dp[i + 1][j + 1] = dp[i][j] + 1
                } else {
                    dp[i + 1][j + 1] = max(dp[i + 1][j], dp[i][j + 1])
                }
            }
        }
        print("☎️")
        print(dp)
        print(dp[correctArray.count - 1][userAnswerArray.count - 1])
        var i = correctArray.count
        var j = userAnswerArray.count
        print(correctArray)
        while i > 0 && j > 0 {
            print("\nstarting new loop")
            print(attributedString1)
            print(attributedString2)
            if correctArray[i - 1] == userAnswerArray[j - 1] {
                print("Match found at indices i:\(i - 1) and j:\(j - 1)")
                
                
                var attributedChar = AttributedString(String(correctArray[i - 1]))
                attributedChar.foregroundColor = lightGreen
                attributedChar.backgroundColor = blackBackground
                
                attributedString1.insert(attributedChar, at: attributedString1.startIndex)
                attributedString2.insert(attributedChar, at: attributedString2.startIndex)
                i -= 1
                j -= 1
            } else if dp[i - 1][j] >= dp[i][j - 1] {
                print("Mismatch or deletion case at indices i:\(i - 1) and j:\(j)")
               
                
//                var attributedChar1 = AttributedString(String(userAnswerArray[j - 1]))
//                attributedChar1.foregroundColor = lightRed
//                attributedChar1.backgroundColor = blackBackground
//                attributedString1.insert(attributedChar1, at: attributedString1.startIndex)
                
                
                var attributedChar2 = AttributedString(String(correctArray[i - 1]))
                attributedChar2.foregroundColor = whiteForeground
                attributedChar2.backgroundColor = blackBackground
                attributedChar2.underlineStyle = .single
                
                attributedString2.insert(attributedChar2, at: attributedString2.startIndex)
                
            
                //j -= 1
                i -= 1
            } else {
                print("Substitution or insertion case at indices i:\(i) and j:\(j - 1)")
               
                
                var attributedChar1 = AttributedString(String(userAnswerArray[j - 1]))
                attributedChar1.foregroundColor = lightRed
                attributedChar1.backgroundColor = blackBackground
                
//                var attributedChar2 = AttributedString("-")
//                attributedChar2.foregroundColor = whiteForeground
//                attributedChar2.backgroundColor = blackBackground
                //attributedChar2.underlineStyle = .single
                
                attributedString1.insert(attributedChar1, at: attributedString1.startIndex)
                //attributedString2.insert(attributedChar2, at: attributedString2.startIndex)
               
                j -= 1
            }
        }
        
        
        print("this is what the correct array looks like before we handle extra characters")
        print(correctArray)
        print(i)
        while i > 0 {
            print("☎️☎️☎️☎️☎️it happened")
            print(i)
            print(correctArray[i - 1])
            
            var attributedChar = AttributedString(String(correctArray[i - 1]))
            attributedChar.foregroundColor = whiteForeground
            attributedChar.backgroundColor = blackBackground
            attributedChar.underlineStyle = .single
            
            attributedString2.insert(attributedChar, at: attributedString2.startIndex)
            i -= 1
        }
        
     
        while j > 0 {
            print("☎️☎️☎️☎️☎️it happened")
            var attributedChar = AttributedString(String(userAnswerArray[j - 1]))
            attributedChar.foregroundColor = lightRed
            attributedChar.backgroundColor = blackBackground
            
            attributedString1.insert(attributedChar, at: attributedString1.startIndex)
            j -= 1
        }
        
        return (attributedString1, attributedString2)
    }
}
    


struct FlashCard: View {
    @State var doShowAlert = false
    @State private var alertMessage = ""
    private let swipeThreshold: Double = 100
    @State private var offset: CGSize = .zero
    @State var userAnswer: String = ""
    @State var attributedAnswers: (AttributedString, AttributedString) = (AttributedString(), AttributedString())
    @State var isShowingAnswer: Bool = false
    @State private var showing: Bool = true
    @State var databaseManager: DatabaseManager = DatabaseManager()
    @Binding var cardsTilReset: Int
    var deckName: String
    var card: Card
    let cardColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if showing {
                    RoundedRectangle(cornerRadius: 25.0)
                        .fill(offset.width < 0 ? .red : .green)
                    
                    RoundedRectangle(cornerRadius: 25.0)
                        .fill(cardColor)
                        .shadow(color: .black, radius: 4, x: -0.5, y: 0.5)
                        .opacity(1 - abs(offset.width) / swipeThreshold)
                    
                    CardContentView(
                        card: card,
                        userAnswer: $userAnswer,
                        isShowingAnswer: $isShowingAnswer,
                        attributedAnswers: $attributedAnswers
                    )
                }
            }
            .offset(offset)
            .gesture(DragGesture()
                .onChanged { gesture in
                    let translation = gesture.translation
                    print(translation)
                    offset = translation
                }
                .onEnded { gesture in
                    if gesture.translation.width > swipeThreshold {
                        print("👉 Swiped right")
                        
                        cardsTilReset = cardsTilReset + 1
                        print("new cardstilreset: ", cardsTilReset)
                        showing = false
                        print("⏰ old int: ", String(card.oldInterval))
                        let newInfoDic = databaseManager.increaseInterval(oldInterval: card.oldInterval, oldDate: card.dueDate)
                        
                        guard let newDate = newInfoDic["Date"] as? Date else{ doShowAlert.toggle()
                            alertMessage = "unable to set new date"
                            return
                        }
                        guard let newOldInt = newInfoDic["Int"] as? Int else{ doShowAlert.toggle()
                            alertMessage = "unable to set old interval"
                            return
                        }
                        print("⏰ new int: ", String(newOldInt))
                        var cardCopy = card
                        cardCopy.dueDate = newDate
                        cardCopy.oldInterval = newOldInt
                        databaseManager.editCardInDeck(deckName: deckName, editedCard: cardCopy) { error in
                            if let error = error{
                                print(error.localizedDescription)
                                doShowAlert = true
                                alertMessage = error.localizedDescription
                            }
                            
                            else{
                                print("success")
                                
                                if newOldInt == 420 {
                                    alertMessage = "Card marked as correct. This card will be shown again in 7 minutes"
                                }
                                else{
                                    alertMessage = "Card marked as correct. This card will be shown again in \(newOldInt / 60 / 60 / 24) days"
                                }
                                doShowAlert = true
                               
                            }
                        }
                                    
                       
                        
                        
                        
                    } else if gesture.translation.width < -swipeThreshold {
                        print("👈 Swiped left")
                        showing = false
                        doShowAlert = true
                        alertMessage = "Card marked as incorrect. This card will be shown again in 2 minutes"
                        cardsTilReset = cardsTilReset + 1
                    } else {
                        print("🚫 Swipe canceled")
                        withAnimation(.bouncy) {
                            offset = .zero
                        }
                    }
                }
            )
            .opacity(3 - abs(offset.width) / swipeThreshold * 3)
            .rotationEffect(.degrees(offset.width / 20.0))
            .offset(CGSize(width: offset.width, height: 0))
            .alert(isPresented: $doShowAlert) {
                Alert(
                    title: Text(alertMessage),
                    primaryButton: .default(Text("OK"), action: {
                        // Actions to be performed when "OK" is pressed
                        // For example:
                        // performAction() or any other code you want to run
                    }),
                    secondaryButton: .cancel(Text("Undo"), action: {
                        showing = true
                        offset = .zero
                    })
                )
            }
            .frame(width: 355, height: 650)
            .padding(.horizontal)
        }
    }
}

//#Preview {
//    FlashCard(deckName: "Russian", card: Card(front: "hey", back: "family", dueDate: Date(), id: "123", oldInterval: 0), cardColor: Color(red: 47/255, green: 79/255, blue: 79/255))
//}

struct PracticeViews: View {
    
    @StateObject private var timerManager = TimerManager()
    @State private var score: Int = 0
    @State var cardsLearned: String = "0"
    @State var goToEditGoalScreen: Bool = false
    @Binding var cardsTilReset: Int
    @State var addCard: Bool = false
    @State var deckView: Bool = false
    @State var databaseManager: DatabaseManager = DatabaseManager()
    let language: String
    var resetVal = 0
    @State var showingAlert: Bool = false

  
    @State private var showBlackScreen: Bool = false
    @State private var transitionTimer: Timer?
    
    
    init(language: String, cardsTilReset: Binding<Int>) {
            self.language = language
            self._cardsTilReset = cardsTilReset
            print("cardsTilReset 💤📣")
            print(cardsTilReset.wrappedValue)
        
        }
                
           
            
                
            
        
    let colorList: [Color] = [
        
        
        
 
        Color(red: 47/255, green: 79/255, blue: 79/255),
        Color(red: 40/255, green: 45/255, blue: 45/255),
        Color(red: 69/255, green: 69/255, blue: 69/255),
        Color(red: 153/255, green: 61/255, blue: 108/255)

    ]
    var body: some View {
        ZStack {
            
            Color.black.ignoresSafeArea()
            
            
            
            VStack {
                VStack{
                    
                    HStack{
                        Button(action: {deckView.toggle()}) {
                            
                            Text("<-")
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Text(timeString(from: timerManager.counter))
                            .font(.system(size: 30, weight: .bold))
                        
                        Button(action: {
                            goToEditGoalScreen.toggle()}
                        ){
                            Text("Edit goal")
                                .foregroundColor(Color(red: 213/255, green: 121/255, blue: 168/255))
                        }
                        Spacer()
                        Button(action: {addCard.toggle()}) {
                            
                            Text("+")
                                .foregroundColor(.white)
                        }
                        
                    }
                    
                    Text("Cards learned " + cardsLearned)}
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 30)
                
                
                ZStack{
                    Button(action: {
                        
                        
                        
                            databaseManager.fetchDueCards(limit: 2, language: language)
                        
                        print("Ⓜ️", databaseManager.currentBatch.count)
                        print(databaseManager.currentBatch)
                    }) {
                        Text("😄 Great work! You finished another 10 cards. Click here to fetch 10 more")
                            .foregroundStyle(.white)
                            .frame(maxWidth: 300, alignment: .leading)
                            .lineLimit(nil)
                    }
                    
                        ForEach(databaseManager.currentBatch.indices, id: \.self) { index in
                            FlashCard(cardsTilReset: $cardsTilReset, deckName: language, card: databaseManager.currentBatch[index], cardColor: colorList[index % colorList.count])
                            //.rotationEffect(.degrees(Double(cards.count - 1 - index) * -0.5))
                            
                                .offset(x: CGFloat(3 * -(index % 6)), y: CGFloat(4 * index % 4))
                            
                            
                        }
                    
                    
                    
                    Spacer()
                }
                .onAppear {
                    print("appeared to have appeared \n :)")
                    databaseManager.fetchDueCards(limit: 1, language: language)
                }
                .onChange(of: databaseManager.currentBatch) { newBatch in
                    
                    print("Ⓜ️Ⓜ️ currentBatch updated, re-rendering view Ⓜ️Ⓜ️")
                    print("Ⓜ️Ⓜ️", databaseManager.currentBatch.count)
                        
                            if cardsTilReset % 1 == 0 && cardsTilReset > 0 {
                                print("showing black screen")
                                showBlackScreen = true
                                
                            }
                        
                }
                .onReceive(timerManager.$counter) { newCounter in
                    if newCounter == 0 {
                        
                        //print("\n\n\n\n THIS SHOULDNT HAPPEN VERY OFTEN.WE ARE UPDATING GET OVERDUE CARDS")
                        //databaseManager.getOverdueCards(deckName: language)
                        
                    }
                }
                .fullScreenCover(isPresented: $goToEditGoalScreen) {
                    
                    EditGoalScreen(language: language)
                        .environment(AuthManager())
                }
                .fullScreenCover(isPresented: $addCard) {
                    
                    CardCreateView(translationLanguage: language, deck: language, inputLanguage: nil, front: nil)
                        .environment(AuthManager())
                }
                .fullScreenCover(isPresented: $deckView) {
                    
                    DecksView()
                        .environment(AuthManager())
                }
                .fullScreenCover(isPresented: $showBlackScreen) {
                    BlackScreenView(language: language)
                }
                
                //            .alert(isPresented: $showingAlert) {
                //                Alert(title: Text("Time is up"), message: Text("Congrats"), dismissButton: .default(Text("OK")))
                // }
            }
        }
    }
   
        private func timeString(from seconds: Int) -> String {
            let minutes = seconds / 60
            let seconds = seconds % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
        
        
    
}

import SwiftUI

struct BlackScreenView: View {
    @State private var showPractice: Bool = false
    @State private var currentImageIndex: Int = 0
    @State private var timer: Timer? = nil
    
    var language: String
    
    private let imageSequence: [String] = [
        "smilingkar1", "smilingkar2", "smilingkar3", "smilingkar2", "smilingkar1",
        "smilingkar4", "smilingkar5", "smilingkar4"
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("Congrats! You earned 5 more points")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
                
                Image(imageSequence[currentImageIndex])
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    
                
                Spacer()
                
                Button(action: {
                    showPractice = true
                }) {
                    Text("Back to Practice")
                        .font(.title2)
                        .bold()
                        .padding()
                        .background(Color.pink)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .fullScreenCover(isPresented: $showPractice) {
                    ParentView(language: language)
                }
                
                Spacer()
            }
        }
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startAnimation() {
        var index = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            currentImageIndex = index
            index = (index + 1) % imageSequence.count
        }
    }
}

struct ParentView: View {
    @State private var cardsTilReset: Int = 0
    var language: String
    var body: some View {
        PracticeViews(language: language, cardsTilReset: $cardsTilReset)
    }
}

extension String {
    subscript(_ range: Range<Int>) -> Substring {
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return self[start..<end]
    }

    subscript(_ range: ClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return self[start...end]
    }
}

