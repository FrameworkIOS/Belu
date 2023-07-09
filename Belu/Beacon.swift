//
//  Beacon.swift
//  Belu
//
//  Created by krisna pranav on 09/07/23.
//

import Foundation
import CoreBluetooth

public class Beacon: NSObject, CBPeripheralManagerDelegate {

    weak var delegate: BeluServerDelegate?

    static let ReceiveWritePeripheralKey: AnyHashable = "belu.beacon.receive.peripheral.key"

    static let ReceiveWriteDataKey: AnyHashable = "belu.beacon.receive.data.key"

    static let ReceiveWriteCBATTRequestKey: AnyHashable = "belu.beacon.receive.CBATTRequest.key"

    public var localName: String?

    public var serviceData: Data?

    public var isAdvertising: Bool {
        return self.peripheralManager.isAdvertising
    }

    public var authorizationStatus: CBPeripheralManagerAuthorizationStatus {
        return CBPeripheralManager.authorizationStatus()
    }

    public var state: CBManagerState {
        return self.peripheralManager.state
    }

    private let queue: DispatchQueue = DispatchQueue(label: "belu.beacon.queue", attributes: [], target: nil)

    private let restoreIdentifierKey: String = "belu.beacon.restore.key"

    private var advertisementData: [String: Any]?

    private var startAdvertisingBlock: (([String : Any]?) -> Void)?

    private lazy var peripheralManager: CBPeripheralManager = {
        let options: [String: Any] = [
            CBPeripheralManagerOptionRestoreIdentifierKey: self.restoreIdentifierKey,
            CBPeripheralManagerOptionShowPowerAlertKey: true]
        let peripheralManager: CBPeripheralManager = CBPeripheralManager(delegate: self,
                                                                         queue: self.queue,
                                                                         options: options)
        return peripheralManager
    }()

    override init() {
        super.init()
        _ = self.peripheralManager
    }

    private func setup() {
        queue.async { [unowned self] in
            guard let services: [CBMutableService] = self.delegate?.services else {
                return
            }
            self.services = services
        }
    }

    private var services: [CBMutableService]? {
        didSet {
            self.peripheralManager.removeAllServices()
            guard let services: [CBMutableService] = services else {
                return
            }
            for service: CBMutableService in services {
                self.peripheralManager.add(service)
            }
        }
    }

    public func startAdvertising() {
        self.setup()
        var advertisementData: [String: Any] = [:]

        guard let serviceUUIDs: [CBUUID] = self.delegate?.receivers.map({ return $0.serviceUUID }) else {
            return
        }
        advertisementData[CBAdvertisementDataServiceUUIDsKey] = serviceUUIDs

        if let localName: String = self.localName {
            advertisementData[CBAdvertisementDataLocalNameKey] = localName
        }
        
        if let serviceData: Data = self.serviceData {
            advertisementData[CBAdvertisementDataServiceDataKey] = serviceData
        }

        startAdvertising(advertisementData)
    }

    public func startAdvertising(_ advertisementData: [String : Any]?) {
        _startAdvertising(advertisementData)
    }

    private var canStartAdvertising: Bool = false

    private func _startAdvertising(_ advertisementData: [String : Any]?) {
        queue.async { [unowned self] in
            self.advertisementData = advertisementData
            self.startAdvertisingBlock = { [unowned self] (advertisementData) in
                if !self.isAdvertising {
                    self.peripheralManager.startAdvertising(advertisementData)
                    debugPrint("[Belu Beacon] Start advertising", advertisementData ?? [:])
                } else {
                    debugPrint("[Belu Beacon] Beacon has already advertising.")
                }
            }
            if self.canStartAdvertising {
                self.startAdvertisingBlock!(advertisementData)
            }
        }
    }

    public func stopAdvertising() {
        self.peripheralManager.stopAdvertising()
    }

    public func updateValue(_ value: Data, for characteristic: CBMutableCharacteristic, onSubscribedCentrals centrals: [CBCentral]?) -> Bool {
        return self.peripheralManager.updateValue(value, for: characteristic, onSubscribedCentrals: centrals)
    }

    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            debugPrint("[Belu Beacon] did update status POWERD ON")
            setup()
        case .poweredOff:
            debugPrint("[Belu Beacon] did update status POWERD OFF")
        case .resetting:
            debugPrint("[Belu Beacon] did update status RESETTING")
        case .unauthorized:
            debugPrint("[Belu Beacon] did update status UNAUTHORIZED")
        case .unknown:
            debugPrint("[Belu Beacon] did update status UNKNOWN")
        case .unsupported:
            debugPrint("[Belu Beacon] did update status UNSUPPORTED")
        }
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error: Error = error {
            debugPrint("[Belu Beacon] did add service error", error)
            return
        }
        debugPrint("[Belu Beacon] did add service service", service)
        self.canStartAdvertising = true
        self.startAdvertisingBlock?(self.advertisementData)
    }

    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error: Error = error {
            debugPrint("[Belu Beacon] did start advertising", error)
            return
        }
        debugPrint("[Belu Beacon] did start advertising", peripheral, peripheral)
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        debugPrint("[Belu Beacon] will restore state ", dict)
    }

    public func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        debugPrint("[Belu Beacon] is ready to update subscribers ", peripheral)
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        debugPrint("[Belu Beacon] did subscribe to ", peripheral, central, characteristic)
        self.delegate?.subscribe(peripheralManager: peripheral, central: central, characteristic: characteristic)
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        debugPrint("[Belu Beacon] did unsubscribe from ", peripheral, central, characteristic)
        self.delegate?.unsubscribe(peripheralManager: peripheral, central: central, characteristic: characteristic)
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        debugPrint("[Belu Beacon] did receive read ", peripheral, request)
        self.delegate?.get(peripheralManager: peripheral, request: request)
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        debugPrint("[Belu Beacon] did receive write", peripheral, requests)
        self.delegate?.post(peripheralManager: peripheral, requests: requests)
    }
}
