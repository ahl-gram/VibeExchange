import SwiftUI

struct KeypadButton: View {
    let symbol: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if symbol.count > 1 {
                Image(systemName: symbol)
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.regularMaterial)
                    .cornerRadius(12)
                    .foregroundColor(.primary)
            } else {
                Text(symbol)
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.regularMaterial)
                    .cornerRadius(12)
                    .foregroundColor(.primary)
            }
        }
    }
} 