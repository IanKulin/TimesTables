//
//  ContentView.swift
//  TimesTables
//
//  Created by Ian Bailey on 19/9/2022.
//

import SwiftUI

enum HCS: String {
    case operand = "operand"
    case numQuestions = "numQuestions"
    case markerFeltWide = "Marker Felt Wide"
}

struct ContentView: View {
    
    @State private var tablesSelection =
     (UserDefaults.standard.integer(forKey: HCS.operand.rawValue) != 0) ? UserDefaults.standard.integer(forKey: HCS.operand.rawValue) : 5
    @State private var calculatorDisplay = " "
    @State private var questionText = ""
    @State private var answer = 0
    @State private var showingResponseText = false
    @State private var showingError = false
    @State private var titleAnimationAmount: CGFloat = 1
    
    @State private var showRoundResults = false
    @State private var roundResultsText1 = ""
    @State private var roundResultsText2 = ""
    
    @State private var numQuestionsToAsk =
    (UserDefaults.standard.integer(forKey: HCS.numQuestions.rawValue) != 0) ? UserDefaults.standard.integer(forKey: HCS.numQuestions.rawValue) : 5
    @State private var numCompletedQuestions = 0
    @State private var numCorrectQuestions = 0
    
    var body: some View {
        // TODO: deal with landscape
        ZStack {
            mainView()
            resultsView().opacity(showRoundResults ? 0.9 : 0.0)
        }
        .onAppear(perform: generateTable)
        // results view that's shown at the end of a round
    }
    
    fileprivate func mainView() -> some View {
        VStack {
            titleView()
            operandPickerView()
            HStack{
                Text("Questions:")
                Picker("Questions", selection: $numQuestionsToAsk) {
                    Text("5").tag(5)
                    Text("10").tag(10)
                    Text("20").tag(20)
                }
                .pickerStyle(.segmented)
            }
            .onChange(of: numQuestionsToAsk) { _ in
                UserDefaults.standard.set(self.numQuestionsToAsk,
                                          forKey: HCS.numQuestions.rawValue)
            }
            .padding(.horizontal)
            Spacer()
            Text(questionText).font(.largeTitle)
            Spacer()
            Text(calculatorDisplay)
                .font(.system(size: 40))
                .frame(width: 350, height: 80) //TODO: make scalable
                .background(Color.primary)
                .foregroundColor(showingError ? .red : .green)
            Spacer()
            numPadView()
        }
    }
    
    
    fileprivate func titleView() -> some View {
        Text("Times Tables!")
            .padding()
            .font(.custom(HCS.markerFeltWide.rawValue,
                          fixedSize: 36))
            .scaleEffect(titleAnimationAmount)
            .animation(
                .linear(duration: 3.0)
                .delay(0.2),
                value: titleAnimationAmount)
    }
    
    
    fileprivate func operandPickerView() -> some View {
        Picker("Operand", selection: $tablesSelection) {
            ForEach(2..<13) { i in
                Image(systemName: "\(i).circle").tag(i)
                    .rotationEffect(Angle(degrees:90))
            }
        }
        .pickerStyle(WheelPickerStyle())
        .scaleEffect(1.7)
        .rotationEffect(Angle(degrees: -90))
        .frame(maxHeight: 60.0)
        .clipped()
        .onChange(of: tablesSelection) { _ in
            UserDefaults.standard.set(self.tablesSelection,
                                      forKey: HCS.operand.rawValue)
            generateTable()
        }
    }
    
    
    fileprivate func numPadView() -> some View {
        VStack {
            HStack {
                Button("7️⃣"){buttonPressed("7️⃣")}
                Button("8️⃣"){buttonPressed("8️⃣")}
                Button("9️⃣"){buttonPressed("9️⃣")}
            }
            HStack {
                Button("4️⃣"){buttonPressed("4️⃣")}
                Button("5️⃣"){buttonPressed("5️⃣")}
                Button("6️⃣"){buttonPressed("6️⃣")}
            }
            HStack {
                Button("1️⃣"){buttonPressed("1️⃣")}
                Button("2️⃣"){buttonPressed("2️⃣")}
                Button("3️⃣"){buttonPressed("3️⃣")}
            }
            HStack {
                Button("0️⃣"){buttonPressed("0️⃣")}
                Button("🔙"){buttonPressed("🔙")}
                Button("↩️"){buttonPressed("↩️")}
            }
        }.font(.system(size: 80)) //TODO: make scalable
    }

    
    fileprivate func resultsView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40)
                .fill(.red)
                .padding(30)
                .frame(maxHeight: 400)
            VStack {
                // some cute animations
                // some text with the scores
                Spacer()
                Spacer()
                Section {
                    Text(roundResultsText1)
                    Text(roundResultsText2)
                }
                .font(.largeTitle)
                .foregroundColor(.white)
                
                Spacer()
                // a button to close it out
                Button("Close")
                {
                    showRoundResults = false
                    numCompletedQuestions = 0
                    numCorrectQuestions = 0
                    titleAnimationAmount = 1
                }
                .foregroundColor(.white)
                .buttonStyle(.borderedProminent)
                .font(.largeTitle)
                Spacer()
                Spacer()
            }
        }
    }
    
    
    fileprivate func generateTable() {
        var tablesQuestion = createTablesQuestion(for: tablesSelection)
        while tablesQuestion.question == questionText {
            tablesQuestion = createTablesQuestion(for: tablesSelection)
        }
        questionText = tablesQuestion.question
        answer = tablesQuestion.answer
    }
    
    
    fileprivate func prepareResultsView() {
        let percentCorrect = Double(numCorrectQuestions) / Double(numCompletedQuestions) * 100
        if percentCorrect > 75 {
            roundResultsText1 = "Well done!"
        } else if percentCorrect > 50 {
            roundResultsText1 = "Not bad"
        } else {
            roundResultsText1 = "You can do better"
        }
        roundResultsText2 = "\(numCorrectQuestions) correct out of \(numCompletedQuestions)"
    }
    
    
    fileprivate func buttonPressed(_ button: String) {
        // remove previous response test
        if showingResponseText {
            calculatorDisplay = ""
            showingResponseText = false
            // if they hit enter when showing a response don't process it
            if button == "↩️" { return }
        }
        showingError = false
        // delete any leading space
        if calculatorDisplay == " " {calculatorDisplay = ""}
        switch button {
        case "0️⃣": calculatorDisplay += "0"
        case "1️⃣": calculatorDisplay += "1"
        case "2️⃣": calculatorDisplay += "2"
        case "3️⃣": calculatorDisplay += "3"
        case "4️⃣": calculatorDisplay += "4"
        case "5️⃣": calculatorDisplay += "5"
        case "6️⃣": calculatorDisplay += "6"
        case "7️⃣": calculatorDisplay += "7"
        case "8️⃣": calculatorDisplay += "8"
        case "9️⃣": calculatorDisplay += "9"
        case "🔙":
            calculatorDisplay = String(calculatorDisplay.dropLast(1))
            if calculatorDisplay == "" {calculatorDisplay = " "}
        case "↩️":
            numCompletedQuestions += 1
            let userAnswer = Int(calculatorDisplay) ?? 0
            if userAnswer == answer {
                numCorrectQuestions += 1
                calculatorDisplay = "Correct!"
                showingResponseText = true
                showingError = false
                notifySuccess()
            }
            else
            {
                calculatorDisplay = "No,  \(questionText)\(answer)"
                showingResponseText = true
                showingError = true
                notifyFailure()
            }
            withAnimation{
                generateTable()
            }
            if numCompletedQuestions == numQuestionsToAsk {
                prepareResultsView()
                showRoundResults = true
            }
        default:
            fatalError("Unexpected button")
        }
    }
    
    
    fileprivate func notifySuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        if titleAnimationAmount < 2.0 {
            titleAnimationAmount *= 1.1
        }
    }
    
    
    fileprivate func notifyFailure() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        if titleAnimationAmount > 0.1 {
            titleAnimationAmount *= 0.9
        }
    }
    
    
}
    
    
fileprivate func createTablesQuestion(for operand: Int) -> (answer: Int, question: String) {
    let operandInFirstPlace = Bool.random()
    let otherOperand = Int.random(in: 2...12)
    return (operand*otherOperand,
            operandInFirstPlace ? "\(operand) x \(otherOperand) = " : "\(otherOperand) x \(operand) = ")
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
