import SwiftUI

class HistoryDetailViewModel: ObservableObject {
    @Published var historyDetails: [HistoryDetail] = []
    @Published var isLoading = false
    private var currentPage = 1
    private var lastPage = 1 // Akan diupdate berdasarkan response
    private let perPage = 10
    private var canLoadMore = true

    func fetchHistoryDetails() {
        guard !isLoading && canLoadMore else { return }
        isLoading = true

        guard let url = URL(string: "https://example.com/api/history-details?page=\(currentPage)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let data = data {
                    do {
                        let decodedResponse = try JSONDecoder().decode(HistoryDetailResponse.self, from: data)
                        self.historyDetails.append(contentsOf: decodedResponse.data)
                        self.currentPage += 1
                        self.lastPage = decodedResponse.meta.lastPage
                        self.canLoadMore = self.currentPage <= self.lastPage
                    } catch {
                        print("Decoding error:", error)
                    }
                }
            }
        }.resume()
    }
}
