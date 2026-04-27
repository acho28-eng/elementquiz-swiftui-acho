// ElementQuiz.swift
// A single-file SwiftUI migration of the ElementQuiz Storyboard project.
// Sections: App Entry Point → Model → ViewModel → View

import SwiftUI

// MARK: - App Entry Point
// Replaces AppDelegate + SceneDelegate + the "Initial View Controller" storyboard setting.

@main
struct ElementQuizApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Model
// Replaces raw arrays scattered inside ViewController.
// A typed struct makes the data easy to read, extend, and test.

struct Element {
    let name: String
    /// Asset catalog image name, e.g. "element_6"
    let imageName: String
}

let allElements: [Element] = [
    Element(name: "Hydrogen", imageName: "element_1"),
    Element(name: "Helium",   imageName: "element_2"),
    Element(name: "Lithium",  imageName: "element_3"),
    Element(name: "Carbon",   imageName: "element_6"),
    Element(name: "Oxygen",   imageName: "element_8"),
    Element(name: "Neon",     imageName: "element_10"),
    Element(name: "Gold",     imageName: "element_79"),
    // Add more elements here following the same pattern
]

// MARK: - ViewModel
// Replaces the logic half of ViewController.
// @Published properties replace IBOutlets — SwiftUI re-renders automatically on change.
// Plain functions replace @IBAction methods — no sender parameter needed.

@MainActor
final class QuizViewModel: ObservableObject {

    @Published private(set) var currentElement: Element
    /// `nil` = answer hidden; set to the element name after "Show Answer" is tapped.
    @Published private(set) var answerText: String?

    private let elements: [Element]
    private var currentIndex = 0

    init(elements: [Element] = allElements) {
        precondition(!elements.isEmpty, "Element list must not be empty.")
        self.elements = elements
        self.currentElement = elements[0]
    }

    /// Replaces the `showAnswer:` IBAction — reveals the current element's name.
    func showAnswer() {
        answerText = currentElement.name
    }

    /// Replaces the `next:` IBAction — advances to the next element and hides the answer.
    func nextElement() {
        currentIndex = (currentIndex + 1) % elements.count
        currentElement = elements[currentIndex]
        answerText = nil
    }
}

// MARK: - View
// Replaces both Main.storyboard and the layout half of ViewController.
//
// Storyboard → SwiftUI translations:
//   UIImageView  (scaleAspectFit, 140×140)   →  Image + .scaledToFit() + .frame(140×140)
//   UILabel      (bold 24 pt, centred)        →  Text + .font(.system(size:24,weight:.bold))
//   UIButton "Show Answer"                    →  Button { vm.showAnswer() }
//   UIButton "Next Element"                   →  Button { vm.nextElement() }
//   fixedFrame + autoresizingMask             →  VStack + Spacers (adapts to any screen size)
//   systemBackgroundColor resource            →  Color(uiColor: .systemBackground)

struct ContentView: View {

    @StateObject private var viewModel = QuizViewModel()

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Element image — equivalent to the storyboard's 140×140 scaleAspectFit UIImageView
            Image(viewModel.currentElement.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .animation(.easeInOut(duration: 0.25), value: viewModel.currentElement.imageName)

            Spacer()

            // Answer label — equivalent to the storyboard's bold-24pt centred UILabel
            // A non-breaking space keeps the row's height reserved while the answer is hidden.
            Text(viewModel.answerText ?? " ")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .animation(.easeIn(duration: 0.2), value: viewModel.answerText)

            Spacer()

            // Action buttons — equivalent to the two system UIButtons in the storyboard
            HStack(spacing: 20) {
                Button("Show Answer") { viewModel.showAnswer() }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.blue)

                Button("Next Element") { viewModel.nextElement() }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.blue)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview {
    ContentView()
}
