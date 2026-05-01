//
//  TabBar.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

//
//  TopBar.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//
import SwiftUI
enum FFTab {
    case home, detector , game , history, profile
}

struct TabBar : View {
    @Binding var selectedTab: FFTab
    var body: some View {
        VStack(spacing: 0){
            Rectangle()
                .fill(Color.ffBorder)
                .frame(height: 0.5)
            HStack(spacing: 0) {
                ForEach([FFTab.home, .detector, .game, .history, .profile], id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        VStack(spacing: 4) {
                            ZStack {
                                getIcon(for: tab)
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                            }.frame(width: 25, height: 25)
                            
                            Text(label(for: tab))
                                .font(.caption2)
                        }
                        .foregroundColor(selectedTab == tab ? .ffGold : .ffTextMuted)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color.ffBackground)
        }
        }
            
}

func label(for tab: FFTab) -> String {
    return "\(tab)".capitalized
}

func getIcon(for tab: FFTab) -> Image {
    switch tab {
        case .home: return Image(.home)
    case .detector: return Image(systemName: "camera.viewfinder")
    case .game: return Image(.play)
    case .history: return Image(systemName: "clock.arrow.circlepath")
        case .profile: return Image(.profile)
    }
}

#Preview {
    TabBar(selectedTab: .constant(.home) )
}
