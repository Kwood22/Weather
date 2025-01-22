import SwiftUI

struct ErrorView: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @State private var isNavigationBarHidden: Bool = true
    private let completionHandler: () -> Void
    private let headingText: String
    private let descriptionText: String
    private let buttonText: String

    init(
        heading: String,
        description: String,
        buttonText: String,
        completionHandler: @escaping () -> Void)
    {
        self.headingText = heading
        self.descriptionText = description
        self.buttonText = buttonText
        self.completionHandler = completionHandler
    }

    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .foregroundStyle(.red)
                .frame(width: 100.0, height: 100.0)

            VStack(spacing: 15) {
                title
                description
            }
            .padding(.bottom, 48)
            .padding(.top, 20)
            Button(buttonText) {
                dismiss()
                completionHandler()
            }.buttonStyle(PillButtonStyle(colors: [.blue.opacity(0.8)]))
        }
        .padding(.horizontal, 24)
        .navigationBarHidden(isNavigationBarHidden)
        .onAppear { isNavigationBarHidden = true }
        .onDisappear { isNavigationBarHidden = false }
    }

    // MARK: - View Components
    private var title: some View {
        Text(headingText)
            .font(.title2)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: false)
    }

    private var description: some View {
        Text(descriptionText)
            .font(.body)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: false)
    }
}

#Preview {
    ErrorView(heading: "Error", description: "Some Error", buttonText: "Retry", completionHandler: { print("Retried") })
}
