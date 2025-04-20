
import Photos
import BackgroundTasks

@MainActor
final class PhotoBackupManager: ObservableObject {
    @Published var authorized = false
    @Published var isRunning = false
    @Published var progress: Double = 0
    @Published var statusText = "Czekam…"

    private let store = BackupStore()
    private let uploader = Uploader()
    private let queue = OperationQueue()

    init() { Task { await checkAuthorization() } }

    func checkAuthorization() async {
        authorized = PHPhotoLibrary.authorizationStatus(for: .readOnly) == .authorized
    }

    func toggleBackup() {
        isRunning ? queue.cancelAllOperations() : startBackup()
        isRunning.toggle()
    }

    private func startBackup() {
        Task.detached { [weak self] in
            guard let self else { return }
            statusText = "Odczytuję zdjęcia…"

            let assets = PHAsset.fetchAssets(
                with: .image,
                options: self.assetsOptions(since: self.store.lastBackedUpDate)
            )

            let group = DispatchGroup()
            var done = 0

            assets.enumerateObjects { asset, _, _ in
                group.enter()
                let op = UploadOperation(asset: asset, uploader: self.uploader) { success in
                    if success { self.store.updateLastDate(asset.creationDate) }
                    done += 1
                    Task { @MainActor in
                        self.progress = Double(done) / Double(assets.count)
                    }
                    group.leave()
                }
                self.queue.addOperation(op)
            }

            group.wait()
            Task { @MainActor in
                self.statusText = "Kopia ukończona ✅"
                self.isRunning = false
                self.progress = 1.0
            }
        }
    }

    func scheduleBackgroundTaskIfNeeded() async {
        let identifier = "pl.twoja_firma.photoBackup"
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: identifier,
            using: nil
        ) { task in
            self.startBackup()
            task.setTaskCompleted(success: true)
            self.scheduleNextTask(id: identifier)
        }
        scheduleNextTask(id: identifier)
    }

    private func scheduleNextTask(id: String) {
        let request = BGProcessingTaskRequest(identifier: id)
        request.requiresNetworkConnectivity = true
        request.earliestBeginDate = Date(timeIntervalSinceNow: 6 * 60 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }

    private func assetsOptions(since date: Date?) -> PHFetchOptions {
        let opts = PHFetchOptions()
        if let d = date {
            opts.predicate = NSPredicate(format: "creationDate > %@", d as NSDate)
        }
        opts.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return opts
    }
}
