import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct CountCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: CountCellConfig.self)

    /// Кол-во комментариев
    let count: NSAttributedString

    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = Layout()
    
}

// MARK: - TableCellConfig

extension CountCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? CountCell else { return }
        
        cell.countTextLabel.attributedText = count
        cell.config = self
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }
}

// MARK: - Cell

final class CountCell: UITableViewCell {

    fileprivate var config: Config?

    fileprivate let countTextLabel = UILabel()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        
        countTextLabel.frame = layout.countTextLabelFrame
    }

}

// MARK: - Private

private extension CountCell {

    func setupCell() {
        contentView.addSubview(countTextLabel)
    }
}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class CountCellLayout {
    
    // MARK: - Фреймы

    private(set) var countTextLabelFrame = CGRect.zero

    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let width = maxWidth - insets.left - insets.right
        let textSize = config.count.boundingRect(width: width).size
        
        countTextLabelFrame = CGRect(
            origin: CGPoint(x: (maxWidth - textSize.width) / 2, y: insets.top),
            size: textSize
        )

        return countTextLabelFrame.maxY + insets.bottom
    }

}

// MARK: - Typealias

fileprivate typealias Config = CountCellConfig
fileprivate typealias Layout = CountCellLayout
