//
//  HeaderView.swift
//  VibeExchange
//
//  Created by Alexander Lee on 6/20/25.
//

import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var viewModel: CurrencyViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Vibe Exchange")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    Task {
                        await viewModel.refreshRates()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .opacity(viewModel.isLoading ? 0.5 : 1.0)
                        .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                        .animation(
                            viewModel.isLoading ?
                            .linear(duration: 1.0).repeatForever(autoreverses: false) :
                            .default,
                            value: viewModel.isLoading
                        )
                }
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            if !viewModel.lastUpdatedString.isEmpty {
                HStack {
                    Text("Last updated: \(viewModel.lastUpdatedString)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

