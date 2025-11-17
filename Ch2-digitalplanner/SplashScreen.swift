//
//  SplashScreen.swift
//  Ch2-digitalplanner
//
//  Created by AbadUrRehman on 14/11/25.
//

import SwiftUI

struct SplashScreen: View {
    @State private var scale = 0.8
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing:30) {
                // App Icon
                Image(systemName: "calendar.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                    .scaleEffect(scale)
                
                // App Name
                VStack(spacing: 10) {
                    Text("Daily Planner")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Organize Your Day")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                scale = 1.0
            }
            
            withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
                opacity = 1.0
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
