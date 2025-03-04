import UIKit

final class ReviewsView: UIView {

    let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let newFrame = bounds.inset(by: safeAreaInsets)
        guard tableView.frame != newFrame else { return }
        tableView.frame = newFrame
    }
    
    func setLoading(_ isLoading: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if isLoading {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }
}

// MARK: - Private

private extension ReviewsView {

    func setupView() {
        backgroundColor = .systemBackground
        setupTableView()
        setupActivityIndicatorView()
    }

    func setupTableView() {
        addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCellConfig.reuseId)
        tableView.register(ReviewSummaryCell.self, forCellReuseIdentifier: ReviewSummaryCellConfig.reuseId)
    }
    
    func setupActivityIndicatorView() {
        addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
    }
}
