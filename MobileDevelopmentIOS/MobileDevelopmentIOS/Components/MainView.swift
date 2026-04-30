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
                VStack{
                    Group {
                        switch selectedTab {
                        case .home:
                            HomeView(selectedTab: $selectedTab)
                        case .detector:
                            DetectorView()
                        case .game:
                            GameView()
                        case .history:
                            HistoryView()
                        case .profile:
                            ProfileView()
                        }
                        
                    }
                }.frame(height:.infinity)

                .frame(maxWidth: .infinity)
                TabBar(selectedTab: $selectedTab)
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(ActiveUserManager())
}

