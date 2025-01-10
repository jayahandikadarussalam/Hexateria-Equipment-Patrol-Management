//
//  HomeTabView.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 31/12/24.
//

import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var cameraViewModel: CameraViewModel
    @State private var navigateToActivity = false
    let user: User?
    
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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // MARK: Want to patrol?
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Text("\(departmentName) Patrol Transactions")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                        }
                        
                        Text("3")
                            .font(.custom("SF Pro Display", size: 34, relativeTo: .title))
                            .fontWeight(.semibold)
                    }
                    
                    // MARK: Flow Statistics
                    HStack {
                        Button {
                            cameraViewModel.showCamera()
                        } label: {
                            Text("NO")
                                .padding()
                                .foregroundColor(.pink)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, maxHeight: 40)
                                .background(
                                    RoundedRectangle(
                                        cornerRadius: 8,
                                        style: .continuous
                                    )
                                    .fill(Color.pink.opacity(0.2))
                                )
                        }
                        .sheet(isPresented: $cameraViewModel.isShowingCamera) {
                            ImagePicker(viewModel: cameraViewModel)
                        }
                        
                        Spacer()
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 1, height: 30)
                        
                        Button {
                            navigateToActivity = true
                        } label: {
                            Text("YES")
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
                        
//                        Spacer()
                        
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 24)
                .background(Color(UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark ? UIColor.systemGray6 : UIColor.white }))
                .cornerRadius(16)
                
                // MARK: Recent Transactions
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Recent transaction")
                            .font(.system(size: 16, weight: .medium))
                        Spacer()
                        Text("see all")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    }
                    
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
                .padding(16)
                .background(Color(UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark ? UIColor.systemGray6 : UIColor.white }))
                .cornerRadius(16)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .background(Color(UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.systemGray6 }))
            .navigationDestination(isPresented: $navigateToActivity) {
                if user?.role == "Operator" {
                    ActivityView(viewModel: viewModel, user: user)
                        .navigationBarBackButtonHidden(true) // Hilangkan tombol kembali untuk operator
                } else {
                    ActivityView(viewModel: viewModel, user: user) // Role lain tetap bisa kembali
                }
            }
        }
    }
}

struct TransactionItem: View {
    let name: String
    let date: String
    let amount: String
    let type: String
    let isOutgoing: Bool
    let progress: Double
    var progressPercentage: String {
        String(format: "%.0f%%", progress * 100) // Konversi ke persen
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
            return .gray // Untuk nilai di luar rentang, meskipun seharusnya tidak terjadi
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
//                .fill(isOutgoing ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                .fill(progressColor.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: isOutgoing ? "arrow.up" : "arrow.down")
                        .foregroundColor(progressColor)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 16))
                Text(date)
                    .font(.system(size: 14))
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
                    .font(.system(size: 16))
                Text(type)
                    .font(.system(size: 14))
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
