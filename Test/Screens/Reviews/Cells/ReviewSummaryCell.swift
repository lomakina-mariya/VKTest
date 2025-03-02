
import UIKit

struct ReviewSummaryCellConfig: TableCellConfig {
    
    let text: NSAttributedString
    
    static let reuseId = String(describing: ReviewSummaryCellConfig.self)

    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewSummaryCell else { return }
        cell.titleLabel.attributedText = text
    }

    func height(with size: CGSize) -> CGFloat {
        return 44.0
    }
}

final class ReviewSummaryCell: UITableViewCell {

    fileprivate let titleLabel = UILabel()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = contentView.bounds
    }

    private func setupCell() {
        contentView.addSubview(titleLabel)
        titleLabel.textAlignment = .center
    }
}
