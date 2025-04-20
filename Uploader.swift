import Photos

struct Uploader {
    private let boundary = UUID().uuidString
    private let serverURL = URL(string: "https://twoj‑serwer.pl/upload")!
    
    func upload(asset: PHAsset, completion: @escaping (Bool) -> Void) {
        let resources = PHAssetResource.assetResources(for: asset)
        guard let resource = resources.first else { return completion(false) }
        
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".jpg")
        
        PHAssetResourceManager.default().writeData(for: resource,
                                                   toFile: tempURL,
                                                   options: options) { error in
            if let error { print(error); return completion(false) }
            
            var request = URLRequest(url: serverURL)
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)",
                             forHTTPHeaderField: "Content-Type")
            
            // body
            var body = Data()
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(tempURL.lastPathComponent)\"\r\n")
            body.append("Content-Type: image/jpeg\r\n\r\n")
            body.append(try! Data(contentsOf: tempURL))
            body.append("\r\n--\(boundary)--\r\n")
            
            let config = URLSessionConfiguration.background(withIdentifier: UUID().uuidString)
            config.isDiscretionary = true
            let session = URLSession(configuration: config)
            
            let task = session.uploadTask(with: request, from: body) { _, response, error in
                let ok = (response as? HTTPURLResponse)?.statusCode == 200 && error == nil
                completion(ok)
            }
            task.resume()
        }
    }
}
