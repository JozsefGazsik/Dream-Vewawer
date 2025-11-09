//
//  SyncStatusView.swift
//  Dream Vewawer
//
//  Real-time sync status between iPhone and Apple Watch
//

import SwiftUI

struct SyncStatusView: View {
    @ObservedObject var connectivityManager: WatchConnectivityManager
    let isTracking: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Connection Status Badge
            HStack(spacing: 8) {
                Image(systemName: statusIcon)
                    .foregroundStyle(statusColor)
                    .font(.caption)
                
                Text(statusText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusBackground)
            .clipShape(Capsule())
            
            // Detailed sync info during tracking
            if isTracking && connectivityManager.isWatchConnected {
                VStack(spacing: 6) {
                    // Last heart rate received
                    if connectivityManager.latestHeartRate > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.red)
                                .font(.caption2)
                            Text("Last: \(Int(connectivityManager.latestHeartRate)) bpm")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    
                    // Sync indicator
                    HStack(spacing: 4) {
                        Circle()
                            .fill(.green)
                            .frame(width: 6, height: 6)
                        Text("Live sync active")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            // Setup instructions if not connected
            if !connectivityManager.isWatchAppInstalled {
                VStack(spacing: 6) {
                    Text("Apple Watch App Not Installed")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.orange)
                    
                    Text("Install DreamWeaver on your paired Apple Watch")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else if !connectivityManager.isWatchConnected {
                VStack(spacing: 6) {
                    Text("Watch Not Reachable")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.orange)
                    
                    Text("Keep devices close and Bluetooth enabled")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    private var statusIcon: String {
        if !connectivityManager.isWatchAppInstalled {
            return "applewatch.slash"
        } else if connectivityManager.isWatchConnected {
            return "applewatch.radiowaves.left.and.right"
        } else {
            return "applewatch.slash"
        }
    }
    
    private var statusText: String {
        if !connectivityManager.isWatchAppInstalled {
            return "Watch App Not Installed"
        } else if connectivityManager.isWatchConnected {
            return "Watch Connected & Synced"
        } else {
            return "Watch Not Reachable"
        }
    }
    
    private var statusColor: Color {
        if !connectivityManager.isWatchAppInstalled {
            return .gray
        } else if connectivityManager.isWatchConnected {
            return .green
        } else {
            return .orange
        }
    }
    
    private var statusBackground: some View {
        Group {
            if connectivityManager.isWatchConnected {
                Capsule().fill(.green.opacity(0.2))
            } else {
                Capsule().fill(.gray.opacity(0.2))
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 30) {
            // Connected state
            SyncStatusView(
                connectivityManager: {
                    let manager = WatchConnectivityManager.shared
                    manager.isWatchConnected = true
                    manager.isWatchAppInstalled = true
                    manager.latestHeartRate = 65
                    return manager
                }(),
                isTracking: true
            )
            
            // Not connected state
            SyncStatusView(
                connectivityManager: {
                    let manager = WatchConnectivityManager.shared
                    manager.isWatchConnected = false
                    manager.isWatchAppInstalled = true
                    return manager
                }(),
                isTracking: false
            )
            
            // Not installed state
            SyncStatusView(
                connectivityManager: {
                    let manager = WatchConnectivityManager.shared
                    manager.isWatchConnected = false
                    manager.isWatchAppInstalled = false
                    return manager
                }(),
                isTracking: false
            )
        }
        .padding()
    }
}
