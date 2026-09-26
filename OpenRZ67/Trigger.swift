import CoreBluetooth
import Observation

/// Owns the BLE connection to the openrz67-trigger. A pending `connect` on iOS never times out,
/// so after a disconnect the app simply connects again and iOS finishes it when the trigger is back.
@Observable
final class Trigger: NSObject {
    static let service = CBUUID(string: "c9239c9e-6fc9-4168-b3aa-53105eb990b0")
    static let command = CBUUID(string: "458d4dc9-349f-401d-b092-a2b1c55f5319")

    private(set) var status = "Not connected"
    private var characteristic: CBCharacteristic?
    var isConnected: Bool { characteristic != nil }
    /// A known trigger dropped out and iOS is waiting for it; the only case where rescanning helps.
    private(set) var connectionLost = false

    @ObservationIgnored private var central: CBCentralManager?
    @ObservationIgnored private var peripheral: CBPeripheral?

    /// Creating the central manager is what shows the Bluetooth permission prompt.
    func start() {
        if central == nil { central = CBCentralManager(delegate: self, queue: nil) }
    }

    /// Forgets the current trigger and scans again.
    func reconnect() {
        if let peripheral { central?.cancelPeripheralConnection(peripheral) }
        peripheral = nil
        characteristic = nil
        connectionLost = false
        if central?.state == .poweredOn { scan() } else { start() }
    }

    /// Returns false if there is no connection. Write Without Response gives no delivery report.
    @discardableResult
    func send(_ bytes: [UInt8]) -> Bool {
        guard let peripheral, let characteristic else { return false }
        peripheral.writeValue(Data(bytes), for: characteristic, type: .withoutResponse)
        return true
    }

    private func scan() {
        status = "Scanning for devices..."
        central?.scanForPeripherals(withServices: [Self.service])
    }

    private func connect(_ peripheral: CBPeripheral) {
        status = connectionLost ? "Waiting for trigger..." : "Connecting..."
        central?.connect(peripheral)
    }
}

extension Trigger: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            if let peripheral { connect(peripheral) } else { scan() }
        case .poweredOff:
            characteristic = nil
            status = "Bluetooth is off"
        case .unauthorized:
            status = "Bluetooth permission is required"
        case .unsupported:
            status = "Bluetooth LE is not supported"
        default:
            break
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        central.stopScan()
        self.peripheral = peripheral
        peripheral.delegate = self
        connect(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([Self.service])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connect(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        characteristic = nil
        guard peripheral == self.peripheral else { return }
        connectionLost = true
        connect(peripheral)
    }
}

extension Trigger: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let service = peripheral.services?.first(where: { $0.uuid == Self.service }) else { return }
        peripheral.discoverCharacteristics([Self.command], for: service)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        characteristic = service.characteristics?.first { $0.uuid == Self.command }
        if characteristic != nil {
            status = "Connected"
            connectionLost = false
        }
    }
}
