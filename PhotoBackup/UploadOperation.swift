
import Photos

final class UploadOperation: Operation {
    private let asset: PHAsset
    private let uploader: Uploader
    private let completion: (Bool) -> Void

    init(asset: PHAsset, uploader: Uploader, completion: @escaping (Bool) -> Void) {
        self.asset = asset
        self.uploader = uploader
        self.completion = completion
    }

    override func main() {
        let semaphore = DispatchSemaphore(value: 0)
        uploader.upload(asset: asset) { ok in
            self.completion(ok)
            semaphore.signal()
        }
        semaphore.wait()
    }
}
