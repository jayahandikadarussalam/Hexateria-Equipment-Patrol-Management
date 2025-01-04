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
        VStack(spacing: 16) {
            //MARK: Want to patrol?
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
//                        Text("\(user?.department ?? "") Patrol Transactions")
                        Text("\(departmentName) Patrol Transactions")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                    }
                    
                    Text("3")
                        .font(.custom("SF Pro Display", size: 34, relativeTo: .title))
                        .fontWeight(.semibold)
                }
                
                
                //MARK: Flow Statistics
                HStack {
                    // Inflow
//                    HStack(spacing: 8) {
//                        Circle()
//                            .fill(Color.green.opacity(0.1))
//                            .frame(width: 20, height: 20)
//                            .overlay(
//                                Image(systemName: "arrow.down")
//                                    .foregroundColor(.green)
//                                    .font(.system(size: 14))
//                            )
//                        VStack(alignment: .leading) {
//                            Text("Inflow")
//                                .font(.system(size: 14))
//                                .foregroundColor(.gray)
//                            Text("$ 110,667.60")
//                                .font(.system(size: 16, weight: .medium))
//                        }
//                    }
                    
                    Button {
                            
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

                    Spacer()
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1, height: 30)
                    
                    Spacer()
                    
                    // Outflow
//                    HStack(spacing: 8) {
//                        Circle()
//                            .fill(Color.red.opacity(0.1))
//                            .frame(width: 20, height: 20)
//                            .overlay(
//                                Image(systemName: "arrow.up")
//                                    .foregroundColor(.red)
//                                    .font(.system(size: 14))
//                            )
//                        VStack{
//                            Text("Outflow")
//                                .font(.system(size: 14))
//                                .foregroundColor(.gray)
//                            
//                            Text("$ 3,900.00")
//                                .font(.system(size: 14))
//                        }
//                    }
                    
                    Button {
                        cameraViewModel.showCamera()
                        } label: {
                            Text("NO")
                                .padding()
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, maxHeight: 40)
                                .background(
                                    RoundedRectangle(
                                        cornerRadius: 8,
                                        style: .continuous
                                    )
//                                        .fill(.pink)
                                        .fill(Color.pink.opacity(0.4))
                                )
                        }
                        .sheet(isPresented: $cameraViewModel.isShowingCamera) {
                            ImagePicker(viewModel: cameraViewModel)
                        }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 24)
            .background(Color(UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? UIColor.systemGray6 : UIColor.white }))
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            
            
            //MARK: Recent Transactions
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
                    date: "Dec 31 • 14:21pm",
                    amount: "All Area",
                    type: "Finish",
                    isOutgoing: true,
                    progress: 1.0
                )
                
                TransactionItem(
                    name: "Ujang Kenzo",
                    date: "Dec 30 • 7:30am",
                    amount: "All Area",
                    type: "Finish",
                    isOutgoing: true,
                    progress: 1.0
                )
                
                TransactionItem(
                    name: "Rey Saepudin",
                    date: "Dec 30 • 9:01am",
                    amount: "All Area",
                    type: "Finish",
                    isOutgoing: true,
                    progress: 1.0
                )
                
                TransactionItem(
                    name: "Asep Zavian",
                    date: "Dec 31 • 8:45pm",
                    amount: "Area CA-2",
                    type: "Progress",
                    isOutgoing: false,
                    progress: 0.40
                )
                
                TransactionItem(
                    name: "Aceng Kaivan",
                    date: "Dec 31 • 22:01pm",
                    amount: "Area CA-1",
                    type: "Progress",
                    isOutgoing: false,
                    progress: 0.75
                )
            }
            .padding(16)
            .background(Color(UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? UIColor.systemGray6 : UIColor.white }))
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .background(Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.systemGray6 }))
        .background(Color(UIColor.systemBackground))
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color(uiColor: .systemGray6))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(.black)
                        .font(.system(size: 20))
                )
            Text(title)
                .font(.system(size: 14))
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
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(isOutgoing ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: isOutgoing ? "arrow.up" : "arrow.down")
                        .foregroundColor(isOutgoing ? .green : .red)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 16))
                Text(date)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
//                ProgressView(value: progress)
//                   .tint(isOutgoing ? .green : .red)
//                   .scaleEffect(x: 1, y: 1.5, anchor: .center)
                HStack {
                    ProgressView(value: progress)
                        .tint(isOutgoing ? .green : .red)
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    
                    Text(progressPercentage)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
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
}

#Preview {
    HomeTabView(user: nil)
        .environmentObject(AuthViewModel())
        .environmentObject(CameraViewModel())
}
