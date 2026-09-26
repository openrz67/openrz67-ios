import Observation

/// Mode, countdown and bulb state on top of ``Trigger``. Command bytes are listed in the
/// openrz67-trigger README.
@Observable
final class TriggerModel {
    enum Mode: String, CaseIterable {
        case direct = "Direct", countdown = "Countdown", bulb = "Bulb"
    }

    let trigger = Trigger()
    private(set) var mode = Mode.direct
    var countdownDuration = 10
    /// Seconds left while a countdown runs, otherwise nil.
    private(set) var countdownLeft: Int?
    /// Seconds the shutter has been open in bulb mode, otherwise nil.
    private(set) var bulbElapsed: Int?

    @ObservationIgnored private var timer: Task<Void, Never>?

    var isBusy: Bool { countdownLeft != nil || bulbElapsed != nil }

    func select(_ newMode: Mode) {
        guard newMode != mode else { return }
        if bulbElapsed != nil { trigger.send([20]) }
        if countdownLeft != nil { trigger.send([3, UInt8(countdownDuration), 0]) }
        stopTimer()
        mode = newMode
    }

    func shutter() {
        switch mode {
        case .direct:
            trigger.send([11])
        case .countdown:
            if countdownLeft != nil {
                stopTimer()
                trigger.send([3, UInt8(countdownDuration), 0])
            } else if trigger.send([3, UInt8(countdownDuration), 1]) {
                countdownLeft = countdownDuration
                tick { [self] in
                    countdownLeft! -= 1
                    if countdownLeft == 0 { countdownLeft = nil }
                    return countdownLeft != nil
                }
            }
        case .bulb:
            if bulbElapsed != nil {
                if trigger.send([20]) { stopTimer() }
            } else if trigger.send([21]) {
                bulbElapsed = 0
                tick { [self] in
                    bulbElapsed! += 1
                    return true
                }
            }
        }
    }

    /// Calls `step` once a second until it returns false or the timer is stopped.
    private func tick(_ step: @escaping () -> Bool) {
        timer?.cancel()
        timer = Task {
            repeat {
                try? await Task.sleep(for: .seconds(1))
            } while !Task.isCancelled && step()
        }
    }

    private func stopTimer() {
        timer?.cancel()
        countdownLeft = nil
        bulbElapsed = nil
    }
}
