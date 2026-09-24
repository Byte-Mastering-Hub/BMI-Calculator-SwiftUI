//
//  ContentView.swift
//  Body Mass Index
//
//  Created by Sumit on 02/01/26.
//

import SwiftUI

// MARK: - ENUMS
enum Gender: String {
    case male = "Male"
    case female = "Female"
}

enum WeightUnit {
    case kg, lb
}

enum HeightUnit {
    case cm, ft
}

// MARK: - THEME
struct AppTheme {
    static let background = LinearGradient(
        colors: [
            Color(red: 0.06, green: 0.09, blue: 0.14),
            Color(red: 0.12, green: 0.18, blue: 0.26)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let card = Color.white.opacity(0.10)
    static let accent = Color.cyan
    static let label = Color.white.opacity(0.7)
    static let inputBg = Color.white.opacity(0.14)
}

// MARK: - SEGMENTED STYLE
struct SegmentedStyle {
    static let background = Color.white.opacity(0.15)
    static let selected = AppTheme.accent
    static let textSelected = Color.black
    static let textNormal = Color.white.opacity(0.95)
}

// MARK: - CUSTOM SEGMENTED CONTROL
struct CustomSegmentedPicker<SelectionValue: Hashable>: View {
    let title1: String
    let title2: String
    @Binding var selection: SelectionValue
    let value1: SelectionValue
    let value2: SelectionValue

    var body: some View {
        HStack(spacing: 0) {
            segment(title: title1, value: value1)
            segment(title: title2, value: value2)
        }
        .padding(4)
        .background(SegmentedStyle.background)
        .cornerRadius(14)
    }

    private func segment(title: String, value: SelectionValue) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selection = value
            }
        } label: {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundColor(selection == value
                                 ? SegmentedStyle.textSelected
                                 : SegmentedStyle.textNormal)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(selection == value
                              ? SegmentedStyle.selected
                              : Color.clear)
                )
        }
    }
}

// MARK: - INPUT FIELD
struct InputField: View {
    let title: String
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .decimalPad

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundColor(AppTheme.label)

            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.5)))
                .keyboardType(keyboard)
                .padding()
                .background(AppTheme.inputBg)
                .foregroundColor(.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.accent.opacity(0.4), lineWidth: 1)
                )
        }
    }
}

// MARK: - MAIN VIEW
struct ContentView: View {

    // Inputs
    @State private var gender: Gender = .male
    @State private var weight = ""
    @State private var height = ""
    @State private var inches = ""

    @State private var weightUnit: WeightUnit = .kg
    @State private var heightUnit: HeightUnit = .cm

    // Result
    @State private var bmi: Double = 0
    @State private var category = ""
    @State private var advice = ""
    @State private var showResult = false

    // Alert
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 24) {

                        headerView
                        genderSelector
                        weightCard
                        heightCard
                        calculateButton

                        if showResult {
                            resultCard
                                .id("RESULT")
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding()
                }
                .onChange(of: showResult) { oldValue, newValue in
                    withAnimation {
                        proxy.scrollTo("RESULT", anchor: .top)
                    }
                }
            }
        }
    }

    // MARK: - HEADER
    var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "figure.mind.and.body")
                .font(.system(size: 44))
                .foregroundColor(AppTheme.accent)

            Text("BMI Calculator")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            Text("Check your body health")
                .foregroundColor(AppTheme.label)
        }
    }

    // MARK: - GENDER
    var genderSelector: some View {
        HStack(spacing: 16) {
            genderCard(.male, icon: "figure.stand")
            genderCard(.female, icon: "figure.stand.dress")
        }
    }

    func genderCard(_ value: Gender, icon: String) -> some View {
        Button {
            gender = value
        } label: {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 36))

                Text(value.rawValue)
                    .font(.headline)
            }
            .foregroundColor(gender == value ? .black : .white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(gender == value ? AppTheme.accent : AppTheme.card)
            )
        }
    }

    // MARK: - WEIGHT
    var weightCard: some View {
        glassCard {
            VStack(alignment: .leading, spacing: 16) {

                Text("Weight")
                    .font(.headline)
                    .foregroundColor(.white)

                InputField(
                    title: "Body Weight",
                    icon: "scalemass",
                    placeholder: "Enter weight",
                    text: $weight
                )

                CustomSegmentedPicker(
                    title1: "KG",
                    title2: "LB",
                    selection: $weightUnit,
                    value1: .kg,
                    value2: .lb
                )
            }
        }
    }

    // MARK: - HEIGHT
    var heightCard: some View {
        glassCard {
            VStack(alignment: .leading, spacing: 16) {

                Text("Height")
                    .font(.headline)
                    .foregroundColor(.white)

                if heightUnit == .cm {
                    InputField(
                        title: "Height (cm)",
                        icon: "ruler",
                        placeholder: "Enter height",
                        text: $height
                    )
                } else {
                    HStack {
                        InputField(
                            title: "Feet",
                            icon: "arrow.up.and.down",
                            placeholder: "ft",
                            text: $height,
                            keyboard: .numberPad
                        )

                        InputField(
                            title: "Inches",
                            icon: "arrow.up.and.down",
                            placeholder: "in",
                            text: $inches,
                            keyboard: .numberPad
                        )
                    }
                }

                CustomSegmentedPicker(
                    title1: "CM",
                    title2: "FT",
                    selection: $heightUnit,
                    value1: .cm,
                    value2: .ft
                )
            }
        }
    }

    // MARK: - BUTTON WITH ALERT
    var calculateButton: some View {
        Button {
            validateAndCalculate()
        } label: {
            HStack {
                Image(systemName: "function")
                Text("Calculate BMI")
            }
            .font(.headline)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.accent)
            .cornerRadius(20)
        }
        .alert("Invalid Input", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - RESULT
    var resultCard: some View {
        glassCard {
            VStack(spacing: 12) {

                Text("Your BMI")
                    .foregroundColor(AppTheme.label)

                Text(String(format: "%.1f", bmi))
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(categoryColor)

                Text(category)
                    .font(.title2.bold())
                    .foregroundColor(categoryColor)

                Text(advice)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppTheme.label)
            }
        }
    }

    // MARK: - VALIDATION + LOGIC
    func validateAndCalculate() {

        guard let w = Double(weight), w > 0 else {
            alertMessage = "Please enter a valid weight."
            showAlert = true
            return
        }

        if heightUnit == .cm {
            guard let h = Double(height), h > 0 else {
                alertMessage = "Please enter a valid height in cm."
                showAlert = true
                return
            }
        } else {
            guard let ft = Double(height), ft > 0 else {
                alertMessage = "Please enter height in feet."
                showAlert = true
                return
            }

            guard let _ = Double(inches) else {
                alertMessage = "Please enter inches (0 if none)."
                showAlert = true
                return
            }
        }

        calculateBMI()
        showResult = true
    }

    func calculateBMI() {
        let w = Double(weight)!
        let h = Double(height)!

        let weightKg = weightUnit == .kg ? w : w * 0.453592

        let heightM: Double = {
            if heightUnit == .cm {
                return h / 100
            } else {
                let inch = Double(inches) ?? 0
                return ((h * 12) + inch) * 0.0254
            }
        }()

        bmi = weightKg / (heightM * heightM)
        category = bmiCategory(bmi)
        advice = healthAdvice(bmi)
    }

    func bmiCategory(_ bmi: Double) -> String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }

    func healthAdvice(_ bmi: Double) -> String {
        switch bmi {
        case ..<18.5:
            return "Increase calories and do strength training."
        case 18.5..<25:
            return "Great! Maintain your healthy routine."
        case 25..<30:
            return "Exercise regularly and eat balanced food."
        default:
            return "Consult a doctor and focus on healthy habits."
        }
    }

    var categoryColor: Color {
        switch category {
        case "Normal": return .green
        case "Overweight": return .orange
        case "Obese": return .red
        default: return .blue
        }
    }
}

// MARK: - GLASS CARD
func glassCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    content()
        .padding()
        .background(AppTheme.card)
        .cornerRadius(24)
}

// MARK: - PREVIEW
#Preview {
    ContentView()
}
