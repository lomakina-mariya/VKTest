import UIKit

/// Класс, описывающий бизнес-логику экрана отзывов.
final class ReviewsViewModel: NSObject {

    /// Замыкание, вызываемое при изменении `state`.
    var onStateChange: ((State) -> Void)?

    private var state: State
    private let reviewsProvider: ReviewsProvider
    private let ratingRenderer: RatingRenderer
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    init(
        state: State = State(),
        reviewsProvider: ReviewsProvider = ReviewsProvider(),
        ratingRenderer: RatingRenderer = RatingRenderer()
    ) {
        self.state = state
        self.reviewsProvider = reviewsProvider
        self.ratingRenderer = ratingRenderer
    }
}

// MARK: - Internal

extension ReviewsViewModel {

    typealias State = ReviewsViewModelState

    /// Метод получения отзывов.
    func getReviews() {
        guard state.shouldLoad else { return }
        state.shouldLoad = false
        reviewsProvider.getReviews(offset: state.offset) { [weak self] result in
            self?.gotReviews(result)
        }
    }
}

// MARK: - Private

private extension ReviewsViewModel {

    /// Метод обработки получения отзывов.
    func gotReviews(_ result: ReviewsProvider.GetReviewsResult) {
        do {
            let data = try result.get()
            let reviews = try decoder.decode(Reviews.self, from: data)
            var newItems: [ReviewCellConfig] = []
            let dispatchGroup = DispatchGroup()
            
            for review in reviews.items.prefix(min(state.limit, reviews.count - state.offset)) {
                dispatchGroup.enter()
                makeReviewItem(review) { item in
                    newItems.append(item)
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                self.state.items += newItems
                self.clearHeightCache()
                self.state.offset += self.state.limit
                self.state.shouldLoad = self.state.offset < reviews.count
                self.onStateChange?(self.state)
            }
        } catch {
            state.shouldLoad = true
        }
    }

    /// Метод, вызываемый при нажатии на кнопку "Показать полностью...".
    /// Снимает ограничение на количество строк текста отзыва (раскрывает текст).
    func showMoreReview(with id: UUID) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        item.maxLines = .zero
        state.items[index] = item
        onStateChange?(state)
    }
    
    func clearHeightCache() {
        state.items = state.items.map { item in
            if var cachableItem = item as? HeightCaching {
                cachableItem.setHeight(nil)
                if let reviewItem = cachableItem as? ReviewCellConfig {
                    return reviewItem
                }
            }
            return item
        }
    }
}

// MARK: - Items

private extension ReviewsViewModel {

    typealias ReviewItem = ReviewCellConfig

    func makeReviewItem(_ review: Review, completion: @escaping (ReviewCellConfig) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let avatarUrl = review.avatarURL
            let username = ("\(review.firstName) \(review.lastName)").attributed(font: .username)
            let reviewText = review.text.attributed(font: .text)
            let created = review.created.attributed(font: .created, color: .created)
            let item = ReviewItem(
                reviewText: reviewText,
                created: created,
                avatarUrl: avatarUrl,
                username: username,
                rating: review.rating,
                onTapShowMore: { [weak self] id in
                    self?.showMoreReview(with: id)
                }
            )
            DispatchQueue.main.async {
                completion(item)
            }
        }
    }
    
    func makeSummaryConfig(totalReviews: Int) -> ReviewSummaryCellConfig {
        let text = NSAttributedString(
            string: "\(totalReviews) отзывов",
            attributes: [
                .font: UIFont.reviewCount,
                .foregroundColor: UIColor.reviewCount
            ]
        )
        return ReviewSummaryCellConfig(text: text)
    }

}

// MARK: - UITableViewDataSource

extension ReviewsViewModel: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state.items.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < state.items.count {
            let config = state.items[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: config.reuseId, for: indexPath)
            config.update(cell: cell)
            return cell
        } else {
            let config = makeSummaryConfig(totalReviews: state.items.count)
            let cell = tableView.dequeueReusableCell(withIdentifier: ReviewSummaryCellConfig.reuseId, for: indexPath)
            config.update(cell: cell)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension ReviewsViewModel: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == state.items.count {
            return 44.0
        }
        
        guard let config = state.items[indexPath.row] as? ReviewCellConfig else {
            return UITableView.automaticDimension
        }
    
        if let cachedHeight = config.getCachedHeight() {
            return cachedHeight
        }
        
        let width = tableView.bounds.size.width
        let height = config.height(with: CGSize(width: width, height: .greatestFiniteMagnitude))
        
        var updatedConfig = config
        updatedConfig.setHeight(height)
        
        var updatedItems = state.items
        updatedItems[indexPath.row] = updatedConfig
        state.items = updatedItems
        
        return height
    }

    /// Метод дозапрашивает отзывы, если до конца списка отзывов осталось два с половиной экрана по высоте.
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
            getReviews()
        }
    }

    private func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double = 2.5
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }

}
