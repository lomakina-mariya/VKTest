import Foundation

/// Класс для загрузки отзывов.
final class ReviewsProvider {

    private let bundle: Bundle
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

}

// MARK: - Internal

extension ReviewsProvider {
    
    typealias GetReviewsResult = Result<Data, GetReviewsError>
    
    enum GetReviewsError: Error {
        
        case badURL
        case badData(Error)
        
    }
    
    func getReviews(offset: Int = 0, completion: @escaping (GetReviewsResult) -> Void) {
        let operation = BlockOperation { [weak self] in
            guard let self = self else { return }
            
            guard let url = self.bundle.url(forResource: "getReviews.response", withExtension: "json") else {
                DispatchQueue.main.async {
                    completion(.failure(.badURL))
                }
                return
            }
            
            // Симулируем сетевой запрос - не менять
            usleep(.random(in: 100_000...1_000_000))
            
            do {
                let data = try Data(contentsOf: url)
                DispatchQueue.main.async {
                    completion(.success(data))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.badData(error)))
                }
            }
        }
        operationQueue.addOperation(operation)
    }
}
