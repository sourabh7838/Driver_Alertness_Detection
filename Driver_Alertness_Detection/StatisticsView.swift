import SwiftUI

struct StatisticsView: View {
    @ObservedObject var alertnessDetector: AlertnessDetector
    @State private var selectedTimeFrame: TimeFrame = .today
    
    enum TimeFrame: String, CaseIterable {
        case today = "Today"
        case week = "This Week"
        case month = "This Month"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Time Frame Selector
                    TimeFrameSelector(selectedTimeFrame: $selectedTimeFrame)
                    
                    // Key Metrics Cards
                    KeyMetricsSection(dailyStats: alertnessDetector.dailyStats)
                    
                    // Fatigue Trend Chart
                    FatigueTrendChart(alertnessDetector: alertnessDetector)
                    
                    // Safety Score Card
                    SafetyScoreCard(tripHistory: alertnessDetector.tripHistory)
                    
                    // Detailed Analytics
                    DetailedAnalyticsSection(alertnessDetector: alertnessDetector)
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Analytics")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Time Frame Selector
struct TimeFrameSelector: View {
    @Binding var selectedTimeFrame: StatisticsView.TimeFrame
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(StatisticsView.TimeFrame.allCases, id: \.self) { timeFrame in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTimeFrame = timeFrame
                    }
                }) {
                    Text(timeFrame.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(selectedTimeFrame == timeFrame ? .black : .white)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(selectedTimeFrame == timeFrame ? .white : .clear)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 29)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 29)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Key Metrics Section
struct KeyMetricsSection: View {
    let dailyStats: DailyStats
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Today's Performance")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                MetricCard(
                    title: "Driving Time",
                    value: formatDuration(dailyStats.totalDrivingTime),
                    icon: "clock.fill",
                    color: .blue
                )
                
                MetricCard(
                    title: "Safety Score",
                    value: String(format: "%.0f%%", calculateSafetyScore()),
                    icon: "shield.checkered",
                    color: safetyScoreColor()
                )
                
                MetricCard(
                    title: "Warnings",
                    value: "\(dailyStats.totalWarnings)",
                    icon: "exclamationmark.triangle.fill",
                    color: .orange
                )
                
                MetricCard(
                    title: "Trips",
                    value: "\(dailyStats.tripsCompleted)",
                    icon: "car.fill",
                    color: .green
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func calculateSafetyScore() -> Double {
        guard dailyStats.tripsCompleted > 0 else { return 100.0 }
        
        let warningPenalty = Double(dailyStats.totalWarnings) * 2.0
        let dangerPenalty = Double(dailyStats.totalDangerAlerts) * 5.0
        let fatiguePenalty = dailyStats.averageFatigueScore * 20.0
        
        let totalPenalty = (warningPenalty + dangerPenalty + fatiguePenalty) / Double(dailyStats.tripsCompleted)
        return max(0, 100.0 - totalPenalty)
    }
    
    private func safetyScoreColor() -> Color {
        let score = calculateSafetyScore()
        switch score {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Metric Card
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Fatigue Trend Chart
struct FatigueTrendChart: View {
    @ObservedObject var alertnessDetector: AlertnessDetector
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Fatigue Trend")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Last 7 Days")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            VStack(spacing: 10) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Current")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(Int(alertnessDetector.fatigueScore * 100))%")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Average")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(Int(alertnessDetector.dailyStats.averageFatigueScore * 100))%")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
                
                VStack(spacing: 8) {
                    ForEach(0..<7) { day in
                        HStack {
                            Text("Day \(7-day)")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                                .frame(width: 40, alignment: .leading)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(.white.opacity(0.1))
                                        .frame(height: 8)
                                        .cornerRadius(4)
                                    
                                    Rectangle()
                                        .fill(fatigueColor(for: mockFatigueData[day]))
                                        .frame(width: geometry.size.width * CGFloat(mockFatigueData[day]), height: 8)
                                        .cornerRadius(4)
                                }
                            }
                            .frame(height: 8)
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    private let mockFatigueData: [Double] = [0.2, 0.15, 0.35, 0.25, 0.1, 0.45, 0.3]
    
    private func fatigueColor(for value: Double) -> Color {
        switch value {
        case 0.0..<0.3: return .green
        case 0.3..<0.6: return .orange
        default: return .red
        }
    }
}

// MARK: - Safety Score Card
struct SafetyScoreCard: View {
    let tripHistory: [TripRecord]
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Safety Analysis")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                    .foregroundColor(.green)
            }
            
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(.white.opacity(0.2), lineWidth: 8)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(averageSafetyScore / 100))
                            .stroke(safetyScoreColor, lineWidth: 8)
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(Int(averageSafetyScore))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Text("Safety Score")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 12) {
                    SafetyMetric(
                        label: "Recent Trips",
                        value: "\(tripHistory.count)",
                        color: .blue
                    )
                    
                    SafetyMetric(
                        label: "Best Score",
                        value: "\(Int(bestSafetyScore))%",
                        color: .green
                    )
                    
                    SafetyMetric(
                        label: "Improvement",
                        value: "+\(Int(improvementRate))%",
                        color: .cyan
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var averageSafetyScore: Double {
        guard !tripHistory.isEmpty else { return 100.0 }
        return tripHistory.map { $0.safetyRating }.reduce(0, +) / Double(tripHistory.count)
    }
    
    private var bestSafetyScore: Double {
        tripHistory.map { $0.safetyRating }.max() ?? 100.0
    }
    
    private var improvementRate: Double {
        guard tripHistory.count >= 2 else { return 0.0 }
        let recent = tripHistory.suffix(3).map { $0.safetyRating }.reduce(0, +) / 3.0
        let older = tripHistory.prefix(3).map { $0.safetyRating }.reduce(0, +) / 3.0
        return recent - older
    }
    
    private var safetyScoreColor: Color {
        switch averageSafetyScore {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }
}

// MARK: - Safety Metric
struct SafetyMetric: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

// MARK: - Detailed Analytics Section
struct DetailedAnalyticsSection: View {
    @ObservedObject var alertnessDetector: AlertnessDetector
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Detailed Analytics")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("View All") {
                    // Action for viewing all analytics
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                AnalyticsRow(
                    title: "Total Blinks",
                    value: "\(alertnessDetector.totalBlinks)",
                    subtitle: "Blink rate monitoring",
                    icon: "eye.fill",
                    color: .blue
                )
                
                AnalyticsRow(
                    title: "Total Yawns",
                    value: "\(alertnessDetector.totalYawns)",
                    subtitle: "Drowsiness detection",
                    icon: "mouth.fill",
                    color: .orange
                )
                
                AnalyticsRow(
                    title: "Avg. Reaction Time",
                    value: String(format: "%.1fs", alertnessDetector.averageReactionTime),
                    subtitle: "Response monitoring",
                    icon: "timer",
                    color: .green
                )
                
                AnalyticsRow(
                    title: "Current Session",
                    value: formatDuration(alertnessDetector.currentTripDuration),
                    subtitle: "Active monitoring time",
                    icon: "clock.arrow.circlepath",
                    color: .purple
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Analytics Row
struct AnalyticsRow: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(.vertical, 8)
    }
} 