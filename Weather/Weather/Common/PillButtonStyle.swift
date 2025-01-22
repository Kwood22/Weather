import SwiftUI

struct PillButtonStyle: ButtonStyle {
    let colors: [Color]

    init(colors: [Color] = [.blue, .purple]) {
        self.colors = colors
    }

    func makeBody(configuration: Configuration) -> some View {
        Group {
            configuration.label
                .frame(maxWidth: .infinity, minHeight: 40)
        }
        .font(.callout)
        .foregroundStyle(Color.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(
                    colors: colors,
                    startPoint: .leading, endPoint: .trailing
                ))
        )
    }
}

#Preview {
    VStack {
        Button("Pill Button", action: {})
            .buttonStyle(PillButtonStyle())
    }
}
