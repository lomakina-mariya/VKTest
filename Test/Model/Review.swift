/// Модель отзыва.
struct Review: Decodable {

    let avatarImageURL: String?
    let firstName: String
    let lastName: String
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    let rating: Int

}
