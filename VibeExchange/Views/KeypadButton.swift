import SwiftUI

struct KeypadButton: View {
    let symbol: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(symbol)
                .font(.title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                .foregroundColor(.white)
        }
    }
} 