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


func userDefaultInt( _ key: String ) -> Int {
    UserDefaults.standard.integer(forKey: key)
}


struct ContentView: View {

    @State private var tablesSelection =
        (userDefaultInt(HCS.operand.rawValue) != 0) ? userDefaultInt(HCS.operand.rawValue) : 5
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
        (userDefaultInt(HCS.numQuestions.rawValue) != 0) ? userDefaultInt(HCS.numQuestions.rawValue) : 5
    @State private var numCompletedQuestions = 0
    @State private var numCorrectQuestions = 0


    var body: some View {
        ZStack {

            mainView()
                .background(Gradient(colors: [.white, Color(red: 0.92, green: 0.97, blue: 1.00)]))
            resultsView().opacity(showRoundResults ? 0.9 : 0.0)
        }
        .onAppear(perform: generateTable)
        // results view that's shown at the end of a round
    }


    func mainView() -> some View {
        VStack {
            titleView()
            complicatedView()
            Spacer()

            Spacer()
            numPadView()
        }
    }


    // swiftlint:disable closure_body_length
    // after all, it's complicated
    func complicatedView() -> some View {
        Group {
            VStack {
                Text("Questions:")
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color(red: 0.89, green: 0.96, blue: 1.0))
                        .padding(.horizontal)
                    VStack {
                        Picker("Questions", selection: $numQuestionsToAsk) {
                            Text("5").tag(5)
                            Text("10").tag(10)
                            Text("20").tag(20)
                        }
                        .onChange(of: numQuestionsToAsk) { _ in
                            UserDefaults.standard.set(self.numQuestionsToAsk, forKey: HCS.numQuestions.rawValue)
                        }
                            operandPickerView()
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white)
                                .padding(.horizontal)
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.black, lineWidth: 2)
                                .padding(.horizontal)
                            HStack {
                                Text(questionText)
                                    .font(.title)
                                    .fontWeight(.heavy)
                                Text(calculatorDisplay)
                                    .font(.title)
                                    .fontWeight(.heavy)
                                    .foregroundColor(.blue)
                            }
                        }
                        .frame(maxWidth: 350)
                        .offset(y: 15)
                    }
                }
            }

        }
    }
    // swiftlint:enable closure_body_length


    func titleView() -> some View {
        Text("Times Tables!")
            .padding()
            .font(.custom(HCS.markerFeltWide.rawValue, fixedSize: 36))
            .scaleEffect(titleAnimationAmount)
            .animation(
                .linear(duration: 3.0)
                .delay(0.2),
                value: titleAnimationAmount)
    }


    func operandPickerView() -> some View {
        ZStack {
            let corner = CGSize(width: 8, height: 0)
            /*RoundedRectangle(cornerRadius: 10)
                .fill(.white)
                .padding(.horizontal)*/
            Picker("Operand", selection: $tablesSelection) {
                ForEach(2..<13) { index in
                    Text("\(index)")
                        .tag(index)
                        .font(.system(size: 10, weight: .heavy))
                        .rotationEffect(Angle(degrees: 90))
                }
            }
            .pickerStyle(WheelPickerStyle())
            .scaleEffect(1.7)
            .rotationEffect(Angle(degrees: -90))
            .frame(maxWidth: 320, maxHeight: 60.0)
            .clipped()
            .background(.white)
            .clipShape(RoundedRectangle(cornerSize: corner))
            .onChange(of: tablesSelection) { _ in
                UserDefaults.standard.set(
                    self.tablesSelection, forKey: HCS.operand.rawValue
                )
                generateTable()
            }
        }
    }


    func numPadView() -> some View {
        VStack {
            Spacer()
            Spacer()
            threeNumberView(7, 8, 9)
            threeNumberView(4, 5, 6)
            threeNumberView(1, 2, 3)
            HStack {
                Spacer()
                deleteButtonView().onTapGesture { buttonPressed("🔙") }
                Spacer()
                numberButtonView(0).onTapGesture { buttonPressed("0") }
                Spacer()
                returnButtonView().onTapGesture { buttonPressed("↩️") }
                Spacer()
            }
        }
        .font(.system(size: 80))
    }


    func threeNumberView(_ num1: Int, _ num2: Int, _ num3: Int) -> some View {
        // a horizontal row of number buttons
        HStack {
            Spacer()
            numberButtonView(num1).onTapGesture { buttonPressed("\(num1)") }
            Spacer()
            numberButtonView(num2).onTapGesture { buttonPressed("\(num2)") }
            Spacer()
            numberButtonView(num3).onTapGesture { buttonPressed("\(num3)") }
            Spacer()
        }
    }


    func resultsView() -> some View {
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
                Button("Close") {
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


    func generateTable() {
        var tablesQuestion = createTablesQuestion(for: tablesSelection)
        while tablesQuestion.question == questionText {
            tablesQuestion = createTablesQuestion(for: tablesSelection)
        }
        questionText = tablesQuestion.question
        answer = tablesQuestion.answer
    }


    func prepareResultsView() {
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


    func buttonPressed(_ button: String) {
        // remove previous response test
        if showingResponseText {
            calculatorDisplay = ""
            showingResponseText = false
            // if they hit enter when showing a response don't process it
            if button == "↩️" {
                return
            }
        }
        showingError = false
        // delete any leading space
        if calculatorDisplay == " " {calculatorDisplay = ""}
        switch button {
        case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
            calculatorDisplay += button
        case "🔙":
            calculatorDisplay = String(calculatorDisplay.dropLast(1))
            if calculatorDisplay.isEmpty {calculatorDisplay = " "}
        case "↩️":
            numCompletedQuestions += 1
            let userAnswer = Int(calculatorDisplay) ?? 0
            if userAnswer == answer {
                numCorrectQuestions += 1
                calculatorDisplay = "Correct!"
                showingResponseText = true
                showingError = false
                notifySuccess()
            } else {
                calculatorDisplay = "No,  \(questionText)\(answer)"
                showingResponseText = true
                showingError = true
                notifyFailure()
            }
            withAnimation {
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

    func notifySuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        if titleAnimationAmount < 2.0 {
            titleAnimationAmount *= 1.1
        }
    }

    func notifyFailure() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        if titleAnimationAmount > 0.1 {
            titleAnimationAmount *= 0.9
        }
    }

}


func numberButtonView(_ number: Int) -> some View {
    ZStack {
        let circleSize = 90.0
        buttonCircleView(circleSize)
        Text("\(number)")
            .font(.system(size: circleSize / 2.8))
            .fontWeight(.heavy)
    }
}


func deleteButtonView() -> some View {
    ZStack {
        Circle()
            .strokeBorder(.blue, lineWidth: 3)
            .frame(width: 88, height: 88)
    Image(systemName: "delete.left")
        .scaleEffect(0.42)
    }
}


func returnButtonView() -> some View {
    ZStack {
        Circle()
            .fill(Color(red: 0.93, green: 0.64, blue: 0.27))
            .frame(width: 88, height: 88)

        Circle()
            .strokeBorder(Color(red: 0.93, green: 0.64, blue: 0.27), lineWidth: 2)
            .frame(width: 108, height: 108)

        // and bold number
        Image(systemName: "arrowshape.turn.up.left.fill")
            .scaleEffect(0.4)
            .foregroundColor(Color(.white))
    }
}


func buttonCircleView(_ size: CGFloat) -> some View {
    ZStack {
        // light blue circle
        Circle()
            .fill(Color(red: 0.80, green: 0.92, blue: 1.0))
        // with black border
        Circle()
            .strokeBorder(.black, lineWidth: 2)
    }
    .frame(width: size, height: size)
}


func createTablesQuestion(for operand: Int) -> (answer: Int, question: String) {
    let operandInFirstPlace = Bool.random()
    let otherOperand = Int.random(in: 2...12)
    return (operand * otherOperand,
        operandInFirstPlace ? "\(operand) x \(otherOperand) = " : "\(otherOperand) x \(operand) = ")
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
