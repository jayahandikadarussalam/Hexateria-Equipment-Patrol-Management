struct HistoryDetailResponse: Decodable {
    let message: String
    let data: [HistoryDetail]
    let meta: PaginationMeta
}

struct HistoryDetail: Identifiable, Decodable {
    let id: Int
    let name: String
    let username: String
    let department: String
    let role: String
    let date: String
    let status: String
    let reasons: [HistoryReason] // Tambahan array reasons
}

struct HistoryReason: Identifiable, Decodable {
    let id: Int
    let userId: String
    let status: String
    let date: String
    let reason: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case status
        case date
        case reason
    }
}

struct PaginationMeta: Decodable {
    let currentPage: Int
    let from: Int
    let lastPage: Int
    let perPage: Int
    let to: Int
    let total: Int

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case perPage = "per_page"
        case to
        case total
    }
}
