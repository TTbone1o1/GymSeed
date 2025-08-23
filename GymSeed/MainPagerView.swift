//
//  MainPagerView.swift
//  GymSeed
//
//  Created by Abraham may on 8/6/25.
//

//  MainPagerView.swift
import SwiftUI

struct MainPagerView: View {
    var body: some View {
        TabView {
            ContentView()
            ProfilePage()
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(Color.clear)  // ← no white backing
        .ignoresSafeArea(.container, edges: [.top, .bottom])
    }
}

#Preview {
    MainPagerView()
}
