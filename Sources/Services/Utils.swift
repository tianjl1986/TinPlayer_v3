import Foundation

func formatDuration(_ seconds: Double) -> String {
    let minutes = Int(seconds) / 60
    let remainingSeconds = Int(seconds) % 60
    return String(format: "%d:%02d", minutes, remainingSeconds)
}

func formatDuration(_ duration: String) -> String {
    // If it's already a formatted string, return as is
    if duration.contains(":") {
        return duration
    }
    // If it's a number string, convert and format
    if let seconds = Double(duration) {
        return formatDuration(seconds)
    }
    return duration
}
