//
//  TopBar.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//
import SwiftUI

struct TopBar : View {
    var body : some View {
        VStack(spacing:20){
            HStack {
                Spacer()
                Image("FakeFinder").resizable().scaledToFit().frame(height:22)
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color.ffBackground)
    }
}

#Preview {
    TopBar()
}
