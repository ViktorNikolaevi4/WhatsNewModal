
import Foundation
import SwiftUI

struct PrimaryCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, 10)
            .padding(.horizontal, 22)
            .background(
                Capsule().fill(Color.accentColor.opacity(configuration.isPressed ? 0.75 : 1))
            )
            .foregroundColor(.white)
    }
}

