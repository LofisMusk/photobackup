
import SwiftUI
import Photos

struct ContentView: View {
    @StateObject private var backup = PhotoBackupManager()

    var body: some View {
        VStack(spacing: 32) {
            if backup.authorized {
                ProgressView(value: backup.progress)
                    .padding()
                Button(backup.isRunning ? "Przerwij" : "Rozpocznij kopię") {
                    backup.toggleBackup()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Poproś o dostęp do Zdjęć") {
                    PHPhotoLibrary.requestAuthorization { _ in
                        Task { await backup.checkAuthorization() }
                    }
                }
            }
            Text(backup.statusText)
                .font(.footnote)
                .multilineTextAlignment(.center)
        }
        .padding()
        .task { await backup.scheduleBackgroundTaskIfNeeded() }
    }
}
