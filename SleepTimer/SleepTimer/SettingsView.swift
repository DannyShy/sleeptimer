import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Appearance")
                    .font(.headline)
                
                Picker("Theme", selection: $appearanceManager.currentMode) {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            
            Spacer()
            
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(30)
        .frame(width: 350, height: 250)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppearanceManager())
}
