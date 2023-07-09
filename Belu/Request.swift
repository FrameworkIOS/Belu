//
//  Request.swift
//  Belu
//
//  Created by krisna pranav on 09/07/23.
//

import Foundation
import CoreBluetooth

public class Request: Communicable {
    public typealias ResponseHandler = ((CBPeripheral, CBCharacteristic, Error?) -> Void)
    public let serviceUUID: CBUUID
    public let method: RequestMethod
    public let characteristicUUID: CBUUID?
    public let characteristic: CBMutableCharacteristic
    public let options: [String, Any]
    public var value: Data?
    public var response: ResponseHandler?
    
    init(serviceUUID: serviceUUID, method: method, characteristic: characteristic) {
        self.serviceUUID = serviceUUID
        self.method = method
        self.characteristic = characteristic
    }
}
