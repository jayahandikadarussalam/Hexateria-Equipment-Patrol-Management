//
//  HomeTabView.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 31/12/24.
//

import SwiftUI
import Combine
import Charts

struct HomeTabView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var cameraViewModel: CameraViewModel
    @StateObject private var locationViewModel = LocationViewModel()
    @State private var navigateToActivity = false
    @State private var currentDate = Date()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let user: User?
    let currentWeek: [StepCount] = [
        StepCount(day: "20220717", steps: 4200),
        StepCount(day: "20220718", steps: 15000),
        StepCount(day: "20220719", steps: 2800),
        StepCount(day: "20220720", steps: 10800),
        StepCount(day: "20220721", steps: 5300),
        StepCount(day: "20220722", steps: 10400),
        StepCount(day: "20220723", steps: 4000)
    ]
 
    var departmentName: String {
        switch user?.department {
        case "ELC":
            return "Electrical"
        case "INS":
            return "Instrument"
        case "MRT":
            return "Rotary"
        default:
            return user?.department ?? ""
        }
    }
    
    static func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd MMM yyyy HH:mm:ss"
        return formatter.string(from: date)
    }
    
    private var backgroundColorPatrolSection: Color {
        colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6)
    }
    
    private var backgroundColor: Color {
        (colorScheme == .dark ? Color(.systemGray6) : Color.white)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Location and date section
//                    VStack(spacing: 4) {
//                        HStack {
//                            Image(systemName: "location.fill")
//                                .foregroundColor(.blue)
//                            if locationViewModel.locationName == "Getting location..." {
//                                HStack(spacing: 4) {
//                                    Text("Getting location")
//                                        .font(.footnote)
//                                        .foregroundColor(.gray)
//                                    ProgressView()
//                                        .scaleEffect(0.7)
//                                }
//                            } else {
//                                Text(locationViewModel.locationName)
//                                    .font(.footnote)
//                                    .foregroundColor(.gray)
//                            }
//                        }
//                        
//                        if let lat = locationViewModel.latitude, let lon = locationViewModel.longitude {
//                            Text("Lon: \(lon), Lat: \(lat) ")
//                                .font(.footnote)
//                                .foregroundColor(.gray)
//                        }
//                    
//                        TimelineView(.periodic(from: Date(), by: 0.1)) { context in
//                            Text(Self.format(date: context.date))
//                                .font(.footnote)
//                                .foregroundStyle(Color.secondary)
//                        }
//                    }
//                    .padding(.top, 8)

                    // MARK: Patrol Transactions
//                    VStack(spacing: 24) {
//                        VStack(spacing: 8) {
//                            // Location and date section
//                            Section {
//                                HStack {
//                                    Text(user?.initials ?? "??")
//                                        .font(.title)
//                                        .fontWeight(.semibold)
//                                        .foregroundColor(.white)
//                                        .frame(width: 50, height: 50)
//                                        .background(Color(.systemGray3))
//                                        .clipShape(Circle(), style: FillStyle())
//                                    VStack(alignment: .leading, spacing: 4) {
//                                        Text(user?.name ?? "Shadow Monarch")
//                                            .fontWeight(.semibold)
//                                            .padding(.top, 4)
//                                        Text(user?.email ?? "monarch@gmail.com")
//                                            .font(.footnote)
//                                            .foregroundColor(.gray)
//                                    }
//                                }
//                            }
//                        }
//                        
//                        // MARK: Activity Buttons
//                        HStack {
//                            Button {
//                                cameraViewModel.showCamera()
//                            } label: {
//                                Text("NO")
//                                    .padding()
//                                    .foregroundColor(.primary)
//                                    .fontWeight(.semibold)
//                                    .frame(maxWidth: .infinity, maxHeight: 40)
//                                    .background(
//                                        RoundedRectangle(
//                                            cornerRadius: 8,
//                                            style: .continuous
//                                        )
//                                        .stroke(lineWidth: 2)
//                                        .fill(Color.gray.opacity(0.2))
//                                    )
//                            }
//                            
//                            Spacer()
//                            
//                            Rectangle()
//                                .fill(Color.gray.opacity(0.3))
//                                .frame(width: 1, height: 30)
//                            
//                            Button {
//                                navigateToActivity = true
//                            } label: {
//                                Text("YES")
//                                    .padding()
//                                    .foregroundColor(.white)
//                                    .fontWeight(.semibold)
//                                    .frame(maxWidth: .infinity, maxHeight: 40)
//                                    .background(
//                                        RoundedRectangle(
//                                            cornerRadius: 8,
//                                            style: .continuous
//                                        )
//                                        .fill(.green)
//                                    )
//                            }
//                        }
//                        .padding(.horizontal, 16)
//                    } //ends
//                    .padding(.vertical, 24)
//                    .background(
//                        (colorScheme == .dark ? Color(.systemGray6) : Color.white)
////                            .edgesIgnoringSafeArea(.all)
//                    )
//                    .cornerRadius(16)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            // Location and date section
                            VStack{
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "person.badge.shield.checkmark")
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(Color.green.gradient)
                                        .clipShape(Circle())
                                        .offset(y: 10)
                                    
                                    VStack(alignment: .leading) {
                                        Text("\(user?.department ?? "ITG") - \(user?.role ?? "Role") - \(user?.name ?? "Username")")
                                            .fontWeight(.semibold)
                                            .font(.subheadline)
                                        
                                        if locationViewModel.locationName == "Getting location..." {
                                            HStack(spacing: 4) {
                                                Text("Getting location")
                                                    .font(.footnote)
                                                    .foregroundColor(.secondary)
                                                ProgressView()
                                                    .scaleEffect(0.7)
                                            }
                                        } else {
                                            Text(locationViewModel.locationName)
                                                .font(.footnote)
                                                .foregroundColor(.secondary)
                                        }
                                        TimelineView(.periodic(from: Date(), by: 0.1)) { context in
                                            Text(Self.format(date: context.date))
                                                .font(.footnote)
                                                .foregroundStyle(Color.secondary)
                                        }
                                    }
                                }
                                .padding(12)
                            }
                            .frame(maxWidth: .infinity)
                            .background(backgroundColorPatrolSection)
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        HStack() {
                            Spacer()
                            Text("Can you do Patrol today?")
                                .foregroundColor(Color.primary)
                                .font(.title)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        
                        
                        // MARK: Activity Buttons
                        HStack {
                            Button {
                                cameraViewModel.showCamera()
                            } label: {
                                Text("No")
                                    .padding()
                                    .foregroundColor(.primary)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, maxHeight: 40)
                                    .background(
                                        RoundedRectangle(
                                            cornerRadius: 8,
                                            style: .continuous
                                        )
                                        .stroke(lineWidth: 2)
                                        .fill(Color.gray.opacity(0.2))
                                    )
                            }
                            
                            Spacer()
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 1, height: 30)
                            
                            Button {
                                navigateToActivity = true
                            } label: {
                                Text("Yes")
                                    .padding()
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, maxHeight: 40)
                                    .background(
                                        RoundedRectangle(
                                            cornerRadius: 8,
                                            style: .continuous
                                        )
                                        .fill(.green)
                                    )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 24)
                    .background(backgroundColor)
                    .cornerRadius(16)
                    
                    //MARK: Patrol Statistics
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(departmentName) Patrol Bar Chart")
                                .font(.system(size: 16, weight: .medium))
                                .padding()
                                Chart(currentWeek) {
                                    let stepThousands = Double($0.steps) / 1000.00
                                    BarMark(
                                        x: .value("Week Day", $0.weekday, unit: .day),
                                        y: .value("Step Count", $0.steps)
                                    )
                                    .foregroundStyle(Color.green.gradient)
                                    .cornerRadius(6)
                                    .annotation(position: .overlay, alignment: .topLeading, spacing: 3) {
                                        Text("\(stepThousands, specifier: "%.1F")")
                                            .font(.footnote)
                                            .foregroundColor(Color.black)
                                    }
                                }
                                .background(
                                    (colorScheme == .dark ? Color(.systemGray6) : Color.white)
//                                        .edgesIgnoringSafeArea(.all)
                                )
                                .chartYAxis(.hidden)
                                .chartXAxis {
                                    AxisMarks (values: .stride (by: .day)) { value in
                                        AxisValueLabel(format: .dateTime.weekday(),
                                                       centered: true)
                                    }
                                }
                            .frame(height: 180)
                            
                            Spacer()
                        }
                    }
                    .padding(.vertical, 24)
                    .background(backgroundColor)
                    .cornerRadius(16)
                    
                    // MARK: Recent Transactions
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Recent Patrol")
                                .font(.system(size: 16, weight: .medium))
                            Spacer()
                            Text("see all")
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                        }
                        
                        LazyVStack(spacing: 16) {
                            TransactionItem(
                                name: "Jajang Aldebaran",
                                date: "2024 Dec 31 • 14:21pm",
                                amount: "All Area",
                                type: "Finish",
                                isOutgoing: true,
                                progress: 1.0
                            )
                            
                            TransactionItem(
                                name: "Ujang Kenzo",
                                date: "2024 Dec 30 • 7:30am",
                                amount: "All Area",
                                type: "Finish",
                                isOutgoing: true,
                                progress: 1.0
                            )
                            
                            TransactionItem(
                                name: "Rey Saepudin",
                                date: "2024 Dec 30 • 9:01am",
                                amount: "All Area",
                                type: "Finish",
                                isOutgoing: true,
                                progress: 1.0
                            )
                            
                            TransactionItem(
                                name: "Asep Zavian",
                                date: "2024 Dec 31 • 8:45pm",
                                amount: "Area CA-2",
                                type: "Progress",
                                isOutgoing: false,
                                progress: 0.40
                            )
                            
                            TransactionItem(
                                name: "Aceng Kaivan",
                                date: "2024 Dec 31 • 22:01pm",
                                amount: "Area CA-1",
                                type: "Progress",
                                isOutgoing: false,
                                progress: 0.75
                            )
                        }
                    }
                    .padding(16)
                    .background(backgroundColor)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationDestination(isPresented: $navigateToActivity) {
                if user?.role == "Operator" {
                    ActivityView(viewModel: viewModel, user: user)
                        .navigationBarBackButtonHidden(true)
                } else {
                    ActivityView(viewModel: viewModel, user: user)
                }
            }
            .sheet(isPresented: $cameraViewModel.isShowingCamera) {
                ImagePicker(viewModel: cameraViewModel)
            }
        }
    }
}

struct StepCount: Identifiable {
    let id = UUID()
    let day: String
    let steps: Int
    
    var weekday: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.date(from: day) ?? Date()
    }
}

struct TransactionItem: View {
//    let id = UUID()
    let name: String
    let date: String
    let amount: String
    let type: String
    let isOutgoing: Bool
    let progress: Double
    var progressPercentage: String {
        String(format: "%.0f%%", progress * 100) // Konversi ke persen
    }
    
    init(name: String, date: String, amount: String, type: String, isOutgoing: Bool, progress: Double) {
        self.name = name
        self.date = date
        self.amount = amount
        self.type = type
        self.isOutgoing = isOutgoing
        self.progress = progress
        
//        print("Initialized TransactionItem: \(name), \(date), \(amount), \(type), \(isOutgoing), \(progress)")
    }
    
    var progressColor: Color {
        switch progress {
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
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(progressColor.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: isOutgoing ? "arrow.up" : "arrow.down")
                        .foregroundColor(progressColor)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 14))
                Text(date)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                HStack {
                    ProgressView(value: progress)
                        .tint(progressColor)
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    Text(progressPercentage)
                        .font(.system(size: 14))
                        .foregroundColor(progressColor)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(amount)
                    .font(.system(size: 14))
                Text(type)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
    }
} //End Transcation


#Preview {
    HomeTabView(user: nil)
        .environmentObject(AuthViewModel())
        .environmentObject(CameraViewModel())
}
