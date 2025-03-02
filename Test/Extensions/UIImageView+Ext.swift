
import UIKit

extension UIImageView {
    func loadImage(from url: URL?, placeholder: UIImage? = nil, completion: (() -> Void)? = nil) {
        self.image = placeholder
        
        guard let url = url else {
            completion?()
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = image
                        completion?()
                    }
                }
            } catch {
                print("Failed to load image: \(error)")
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }
    }
}
