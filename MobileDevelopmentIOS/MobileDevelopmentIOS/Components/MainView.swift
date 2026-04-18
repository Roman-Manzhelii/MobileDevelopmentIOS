//
//  File.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 17/04/2026.
//
import SwiftUI
struct MainView: View {
    @State private var selectedTab: FFTab = .home
    
    var body: some View {
        ZStack {
            Color.ffBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TopBar()
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .detector:
                        DetectorView()
                    case .game:
                        Text("Game View")
                    case .history:
                        HistoryView()
                    case .profile:
                        Text("Profile View")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                TabBar(selectedTab: $selectedTab)
            }
        }
    }
}

#Preview {
    MainView()
}

