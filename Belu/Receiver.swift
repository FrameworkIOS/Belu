//
//  Receiver.swift
//  Belu
//
//  Created by krisna pranav on 09/07/23.
//

import Foundation
import CoreBluetooth

public class Receiver: Communicable {
    
    public typealias ReceiveGetHandler = ((CBPeripheralManager, CBATTRequest) -> Void)
    
    public typealias ReceivePostHandler = ((CBPeripheralManager, CBATTRequest) -> Void)
    
    public typealias ReceiveNotifyHandler = ((CBPeripheralManager, CBCentral, CBCharacteristic) -> Void)
    
    public let serviceUUID: CBUUID
    
    public let method: RequestMethod
    
    public let characteristicUUID: CBUUID?
    
    public let characteristic: CBMutableCharacteristic
    
    public var get: ReceiveGetHandler?
    
    public var post: ReceivePostHandler?
    
    public var subscribe: ReceiveNotifyHandler?
    
    public var unsubscribe: ReceiveNotifyHandler?

    public init<T: Communicable>(communication: T,
                get: ReceiveGetHandler? = nil,
                post: ReceivePostHandler? = nil,
                subscribe: ReceiveNotifyHandler? = nil,
                unsubscribe: ReceiveNotifyHandler? = nil) {
        self.serviceUUID = communication.serviceUUID
        self.method = communication.method
        self.characteristicUUID = communication.characteristicUUID
        self.get = get
        self.post = post
        self.subscribe = subscribe
        self.unsubscribe = unsubscribe
        self.characteristic = CBMutableCharacteristic(type: communication.characteristicUUID!,
                                                      properties: method.properties,
                                                      value: nil,
                                                      permissions: method.permissions)
    }
}
