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
                Image("Burger")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 16)
                Spacer()
                Image("FakeFinder").resizable().scaledToFit().frame(height:22)
                    .padding(.trailing, 32)
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
