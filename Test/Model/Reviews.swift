/// Модель отзывов.
struct Reviews: Decodable {

    /// Модели отзывов.
    let items: [Review]
    /// Общее количество отзывов.
    let count: Int

}
