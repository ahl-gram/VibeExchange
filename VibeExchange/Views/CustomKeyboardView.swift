import SwiftUI

struct CustomKeyboardView: View {
    @Binding var text: String
    var decimalSeparator: String
    @Binding var shouldClearOnNextInput: Bool
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        VStack(spacing: 8) {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(1...9, id: \.self) { number in
                    KeypadButton(symbol: "\(number)") {
                        handleTap(symbol: "\(number)")
                    }
                }
                
                KeypadButton(symbol: decimalSeparator) {
                    handleTap(symbol: decimalSeparator)
                }
                
                KeypadButton(symbol: "0") {
                    handleTap(symbol: "0")
                }
                
                KeypadButton(symbol: "􀎠") { // SF Symbol for backspace
                    handleTap(symbol: "􀎠")
                }
            }
        }
        .padding(8)
        .background(Color.black)
    }
    
    private func handleTap(symbol: String) {
        if symbol == "􀎠" { // backspace
            if !text.isEmpty {
                text.removeLast()
            }
            return
        }

        if shouldClearOnNextInput {
            text = ""
            shouldClearOnNextInput = false
        }

        if symbol == decimalSeparator {
            if !text.contains(decimalSeparator) {
                if text.isEmpty {
                    text = "0"
                }
                text += decimalSeparator
            }
        } else { // It's a number
            if text == "0" {
                text = symbol
            } else {
                text += symbol
            }
        }
    }
} 