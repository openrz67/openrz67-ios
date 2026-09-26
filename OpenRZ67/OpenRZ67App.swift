import SwiftUI

@main
struct OpenRZ67App: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

private let durations = [2, 5, 10, 15, 30, 60, 120, 180, 240]

struct ContentView: View {
    @State private var model = TriggerModel()
    @State private var taps = 0

    private var connected: Bool { model.trigger.isConnected }

    var body: some View {
        VStack(spacing: 0) {
            header
            stage
            controls
        }
        .padding(.horizontal, 20)
        .background(Color.cream.ignoresSafeArea())
        .tint(.deepTeal)
        .onAppear { model.trigger.start() }
        .onChange(of: model.isBusy) { _, busy in UIApplication.shared.isIdleTimerDisabled = busy }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("OpenRZ67").font(.title.weight(.semibold)).foregroundStyle(Color.ink)
                HStack(spacing: 8) {
                    Circle().fill(connected ? Color.deepTeal : .burntOrange).frame(width: 8, height: 8)
                    Text(model.trigger.status).font(.subheadline).foregroundStyle(Color.muted)
                }
            }
            Spacer()
            if model.trigger.connectionLost {
                Button("Reconnect", systemImage: "arrow.clockwise", action: model.trigger.reconnect)
            }
        }
        .padding(.top, 16)
    }

    private var readout: String? {
        if let left = model.countdownLeft { return "\(left)" }
        if let s = model.bulbElapsed { return String(format: "%d:%02d", s / 60, s % 60) }
        return nil
    }

    private var stage: some View {
        Image("Background")
            .resizable()
            .scaledToFit()
            .clipShape(.rect(cornerRadius: 24))
            .opacity(readout == nil ? 1 : 0.15)
            .overlay {
                if let readout {
                    Text(readout)
                        .font(.system(size: 120, weight: .bold))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .foregroundStyle(Color.ink)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 16)
    }

    private var hint: String? {
        switch model.mode {
        case .direct: "Press the shutter to take a picture"
        case .countdown: model.countdownLeft == nil ? nil : "Shutter fires when the count reaches zero"
        case .bulb: model.bulbElapsed == nil
            ? "Set the camera to B (bulb) first. Otherwise it just takes one normal picture."
            : "Shutter is open"
        }
    }

    private var shutterLabel: String {
        switch model.mode {
        case .direct: "Shutter"
        case .countdown: model.countdownLeft == nil ? "Start" : "Stop"
        case .bulb: model.bulbElapsed == nil ? "Open" : "Close"
        }
    }

    private var controls: some View {
        VStack {
            Picker("Mode", selection: Binding(get: { model.mode }, set: model.select)) {
                ForEach(TriggerModel.Mode.allCases, id: \.self) { Text($0.rawValue) }
            }
            .pickerStyle(.segmented)
            .disabled(!connected)

            Group {
                if let hint {
                    Text(hint).multilineTextAlignment(.center).foregroundStyle(Color.muted)
                } else {
                    HStack(spacing: 12) {
                        Text("Delay").foregroundStyle(Color.muted)
                        Picker("Delay", selection: $model.countdownDuration) {
                            ForEach(durations, id: \.self) { Text(durationLabel($0)).tag($0) }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .frame(height: 72)

            let color = !connected ? Color.muted.opacity(0.4) : model.isBusy ? .burntOrange : .deepTeal
            Button {
                taps += 1
                model.shutter()
            } label: {
                ZStack {
                    Circle().strokeBorder(color, lineWidth: 3)
                    Circle().fill(color).padding(10)
                }
                .frame(width: 96, height: 96)
            }
            .buttonStyle(.plain)
            .disabled(!connected)
            .accessibilityLabel(shutterLabel)
            .sensoryFeedback(.impact, trigger: taps)

            Text(shutterLabel).font(.callout.weight(.medium)).foregroundStyle(Color.muted)
        }
        .padding(.bottom, 24)
    }

    private func durationLabel(_ seconds: Int) -> String {
        seconds % 60 == 0 ? "\(seconds / 60)m" : "\(seconds)s"
    }
}

/// Palette from the Android app's theme.
private extension Color {
    static let deepTeal = Color(light: 0x2A5555, dark: 0x6FB3B3)
    static let burntOrange = Color(light: 0xB8660A, dark: 0xE8963A)
    static let cream = Color(light: 0xFBE7C9, dark: 0x1B140E)
    static let ink = Color(light: 0x3D2914, dark: 0xF1E3CC)
    static let muted = Color(light: 0x5C4630, dark: 0xCBB79A)

    init(light: UInt32, dark: UInt32) {
        self.init(UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255,
                           blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
        })
    }
}
