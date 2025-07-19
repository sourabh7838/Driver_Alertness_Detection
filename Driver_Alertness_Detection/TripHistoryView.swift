import SwiftUI

struct TripHistoryView: View {
    @StateObject private var alertnessDetector = AlertnessDetector()
    @State private var selectedTrip: TripRecord?
    @State private var showingTripDetail = false
    @State private var sortOption: SortOption = .recent
    @Environment(\.dismiss) private var dismiss
    
    enum SortOption: String, CaseIterable {
        case recent = "Recent"
        case duration = "Duration"
        case safety = "Safety Score"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        TripSummaryHeader(tripHistory: alertnessDetector.tripHistory)
                        
                        SortSelector(selectedSort: $sortOption)
                        
                        if alertnessDetector.tripHistory.isEmpty {
                            EmptyTripsView()
                        } else {
                            LazyVStack(spacing: 15) {
                                ForEach(sortedTrips) { trip in
                                    TripCard(trip: trip) {
                                        selectedTrip = trip
                                        showingTripDetail = true
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Trip History")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showingTripDetail) {
                if let trip = selectedTrip {
                    TripDetailView(trip: trip)
                }
            }
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                #endif
            }
        }
    }
    
    private var sortedTrips: [TripRecord] {
        switch sortOption {
        case .recent:
            return alertnessDetector.tripHistory.sorted { $0.startTime > $1.startTime }
        case .duration:
            return alertnessDetector.tripHistory.sorted { $0.duration > $1.duration }
        case .safety:
            return alertnessDetector.tripHistory.sorted { $0.safetyRating > $1.safetyRating }
        }
    }
}

// MARK: - Trip Summary Header
struct TripSummaryHeader: View {
    let tripHistory: [TripRecord]
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Trip Overview")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "car.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            HStack(spacing: 20) {
                SummaryMetric(
                    title: "Total Trips",
                    value: "\(tripHistory.count)",
                    color: .blue
                )
                
                SummaryMetric(
                    title: "Total Time",
                    value: formatTotalDuration(),
                    color: .green
                )
                
                SummaryMetric(
                    title: "Avg. Safety",
                    value: "\(Int(averageSafetyScore))%",
                    color: averageSafetyColor
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
    
    private func formatTotalDuration() -> String {
        let totalSeconds = tripHistory.map { $0.duration }.reduce(0, +)
        let hours = Int(totalSeconds) / 3600
        let minutes = Int(totalSeconds) % 3600 / 60
        
        return "\(hours)h \(minutes)m"
    }
    
    private var averageSafetyScore: Double {
        guard !tripHistory.isEmpty else { return 100.0 }
        return tripHistory.map { $0.safetyRating }.reduce(0, +) / Double(tripHistory.count)
    }
    
    private var averageSafetyColor: Color {
        switch averageSafetyScore {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }
}

// MARK: - Summary Metric
struct SummaryMetric: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Sort Selector
struct SortSelector: View {
    @Binding var selectedSort: TripHistoryView.SortOption
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(TripHistoryView.SortOption.allCases, id: \.self) { option in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedSort = option
                        }
                    }) {
                        Text(option.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedSort == option ? .black : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedSort == option ? .white : .white.opacity(0.1))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Trip Card
struct TripCard: View {
    let trip: TripRecord
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 15) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formatDate(trip.startTime))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("\(formatTime(trip.startTime)) - \(formatTime(trip.endTime))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    SafetyBadge(score: trip.safetyRating)
                }
                
                HStack(spacing: 20) {
                    TripMetric(
                        icon: "clock.fill",
                        value: formatDuration(trip.duration),
                        label: "Duration",
                        color: .blue
                    )
                    
                    TripMetric(
                        icon: "exclamationmark.triangle.fill",
                        value: "\(trip.warningCount)",
                        label: "Warnings",
                        color: .orange
                    )
                    
                    TripMetric(
                        icon: "xmark.octagon.fill",
                        value: "\(trip.dangerCount)",
                        label: "Dangers",
                        color: .red
                    )
                    
                    TripMetric(
                        icon: "gauge.medium",
                        value: "\(Int(trip.maxFatigueScore * 100))%",
                        label: "Max Fatigue",
                        color: fatigueColor(trip.maxFatigueScore)
                    )
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
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
    
    private func fatigueColor(_ score: Double) -> Color {
        switch score {
        case 0.0..<0.3: return .green
        case 0.3..<0.6: return .orange
        default: return .red
        }
    }
}

// MARK: - Trip Metric
struct TripMetric: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Safety Badge
struct SafetyBadge: View {
    let score: Double
    
    var body: some View {
        Text("\(Int(score))%")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(badgeColor)
            )
    }
    
    private var badgeColor: Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }
}

// MARK: - Empty Trips View
struct EmptyTripsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "car.circle")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.3))
            
            VStack(spacing: 10) {
                Text("No Trips Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Start your first trip to see detailed analytics and safety metrics here.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            Button("Start Monitoring") {
                // Action to start monitoring
            }
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.blue)
            )
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Trip Detail View
struct TripDetailView: View {
    let trip: TripRecord
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    TripDetailHeader(trip: trip)
                    
                    TripDetailMetrics(trip: trip)
                    
                    Spacer(minLength: 50)
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
            .navigationTitle("Trip Details")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .preferredColorScheme(.dark)
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                #endif
            }
        }
    }

// MARK: - Trip Detail Header
struct TripDetailHeader: View {
    let trip: TripRecord
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 5) {
                Text(formatFullDate(trip.startTime))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("\(formatTime(trip.startTime)) - \(formatTime(trip.endTime))")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.2), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: CGFloat(trip.safetyRating / 100))
                    .stroke(safetyScoreColor(trip.safetyRating), lineWidth: 8)
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 5) {
                    Text("\(Int(trip.safetyRating))")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Safety Score")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func safetyScoreColor(_ score: Double) -> Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }
}

// MARK: - Trip Detail Metrics
struct TripDetailMetrics: View {
    let trip: TripRecord
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Trip Metrics")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                DetailMetricCard(
                    title: "Duration",
                    value: formatDuration(trip.duration),
                    icon: "clock.fill",
                    color: .blue
                )
                
                DetailMetricCard(
                    title: "Warnings",
                    value: "\(trip.warningCount)",
                    icon: "exclamationmark.triangle.fill",
                    color: .orange
                )
                
                DetailMetricCard(
                    title: "Danger Alerts",
                    value: "\(trip.dangerCount)",
                    icon: "xmark.octagon.fill",
                    color: .red
                )
                
                DetailMetricCard(
                    title: "Max Fatigue",
                    value: "\(Int(trip.maxFatigueScore * 100))%",
                    icon: "gauge.medium",
                    color: fatigueColor(trip.maxFatigueScore)
                )
            }
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
    
    private func fatigueColor(_ score: Double) -> Color {
        switch score {
        case 0.0..<0.3: return .green
        case 0.3..<0.6: return .orange
        default: return .red
        }
    }
}

// MARK: - Detail Metric Card
struct DetailMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
} }
