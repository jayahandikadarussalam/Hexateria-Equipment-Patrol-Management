//
//  HistoryView.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 04/03/25.
//

import SwiftUI

struct Transaction: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let date: Date
    let status: String
    let imageUrl: String?
    let progress: Double
    let isIncoming: Bool
    
//    var dateAsDate: Date? {
//        return dateFormatter.date(from: date)  // Convert String to Date
//    }
}

struct HistoryView: View {
    @State private var searchText: String = ""
    @State private var selectedFilter: FilterOption = .all
    @Environment(\.colorScheme) var colorScheme

    enum FilterOption: String, CaseIterable {
        case all = "All"
        case finish = "Finish"
        case progress = "Progress"
        case cannotPatrol = "Cannot Patrol"
    }
    
    // Sample transactions data
    let transactions = [
        Transaction(name: "Aceng Kaivan",
                    location: "Scada Room",
//                    date: "2025-03-04 15:07:49",
                    date: Date(timeIntervalSinceNow: -6 * 3600),
                    status: "Finish",
                    imageUrl: nil,
                    progress: 1.0,
                    isIncoming: false),
        Transaction(name: "Clark",
                    location: "Scada Room",
                    date: Date(timeIntervalSinceNow: -6 * 3600),
//                    date: "2025-03-04 10:07:49",
                    status: "Progress",
                    imageUrl: nil,
                    progress: 0.7,
                    isIncoming: true),
        Transaction(name: "Monarch",
                    location: "Scada Room",
//                    date: "2025-03-04 07:07:49",
                    date: Date(timeIntervalSinceNow: -6 * 3600),
                    status: "Cannot Patrol",
                    imageUrl: "person1",
                    progress: 0.3,
                    isIncoming: false),
        Transaction(name: "Cat",
                    location: "Scada Room",
                    date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
//                    date: "2025-03-03 11:07:49",
                    status: "Cannot Patrol",
                    imageUrl: "person1",
                    progress: 0.3,
                    isIncoming: false)
    ]
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
                            Text(formatSectionDate(date))
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                            
                            ForEach(groupedTransactions[date] ?? []) { transaction in
                                TransactionRow(transaction: transaction)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .padding(.horizontal, 8)
                                    .padding(.bottom, 8)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Patrol history")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: {}) {
//                        Image(systemName: "chevron.left")
//                            .foregroundColor(.black)
//                    }
//                }
                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {}) {
//                        Image(systemName: "ellipsis")
//                            .foregroundColor(.black)
//                    }
//                }
            }
        }
    }
    
    var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: filteredTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
    
//    var groupedTransactions: [String: [Transaction]] {
//        Dictionary(grouping: filteredTransactions) { transaction in
//            guard let date = transaction.dateAsDate else { return "Invalid Date" }
//            return dateFormatter.string(from: date)
//        }
//    }
    
    var filteredTransactions: [Transaction] {
        transactions.filter { transaction in
            (searchText.isEmpty || transaction.name.localizedCaseInsensitiveContains(searchText)) &&
            (selectedFilter == .all || transaction.status == selectedFilter.rawValue)
        }
    }
    
    func formatSectionDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.string(from: date)
        }
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"  // Format for grouping (without time)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

struct TransactionRow: View {
    let transaction: Transaction
    @Environment(\.colorScheme) var colorScheme
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var toastColor: Color = .green
    
    private var rowBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray5) : Color.white
    }
    
    var progressPercentage: String {
        String(format: "%.0f%%", transaction.progress * 100)
    }
    
    private var progressColor: Color {
        switch transaction.progress {
        case 0..<0.5:
            return .red
        case 0.5..<0.8:
            return .orange
        case 0.8...1.0:
            return .green
        default:
            return .gray
        }
    }
    
    private func syncToBackend() {
        let success = Bool.random()
        
        toastMessage = success ? "Sync to backend successfully!" : "Failed to sync to backend!"
        toastColor = success ? .green : .red
        
        withAnimation(.easeInOut) {
            showToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
        }
    }
    
    var body: some View {
        HStack {
            Group {
                Image(systemName: "person.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
//                if let imageUrl = transaction.imageUrl {
//                    Image(imageUrl)
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 40, height: 40)
//                        .clipShape(Circle())
//                } else {
//                    Image(systemName: "person.fill")
//                        .font(.system(size: 20))
//                        .foregroundColor(.gray)
//                        .frame(width: 40, height: 40)
//                        .background(Color.gray.opacity(0.2))
//                        .clipShape(Circle())
//                }
            }
            
            VStack(alignment: .leading) {
                Text(transaction.name)
                    .font(.system(size: 14, weight: .medium))
                
                Text(formatTransactionDate(transaction.date))
//                Text(transaction.date)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                HStack {
                    ProgressView(value: transaction.progress)
                        .tint(progressColor)
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    
                    Text(progressPercentage)
                        .font(.system(size: 14))
                        .foregroundColor(progressColor)
                }
            }
            
            Spacer()
            

            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.location)
                    .font(.system(size: 14))
                Text(transaction.status)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(rowBackgroundColor)
    }
    
    func formatTransactionDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMM d • HH:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    HistoryView()
}
