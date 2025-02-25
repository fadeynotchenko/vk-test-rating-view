/// Модель отзыва.
struct Review: Decodable {

    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    /// Имя.
    let firstName: String
    /// Фамилия.
    let lastName: String
    /// Рейтинг (от 1 до 5).
    let rating: UInt8
    /// URL аватарки
    let avatarUrl: String?
    
}

/// Enum для маппинга
extension Review {
    
    enum CodingKeys: String, CodingKey {
        case text
        case created
        case firstName = "first_name"
        case lastName = "last_name"
        case rating
        case avatarUrl
    }
    
}
