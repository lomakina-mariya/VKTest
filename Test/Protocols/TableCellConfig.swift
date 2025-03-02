import UIKit

/// Протокол, который описывает требования для конфигурации ячейки таблицы,
/// для того чтобы хранить разные по типу конфигурации ячеек в одном массиве.
protocol TableCellConfig {

    /// Идентификатор для переиспользования ячейки (по умолчанию тип конфигурации).
    var reuseId: String { get }

    /// Метод для обновления текстов, изображений и другого содержимого ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell)

    /// Метод возвращающий актуальную высоту ячейки.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat

}

// MARK: - Internal

extension TableCellConfig {

    static var reuseId: String {
        String(describing: Self.self)
    }

    var reuseId: String {
        Self.reuseId
    }

}
