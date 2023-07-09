//
//  Communicable.swift
//  Belu
//
//  Created by krisna pranav on 09/07/23.
//

import Foundation
import CoreBluetooth

public enum RequestMethod {
    case get(isNotified: Bool)
    case post
    case broadcast(isNotified: Bool)
    
    var properties: CBCharacteristicProperties {
        switch self {
        case .get(let isNotifiy):
            if isNotifiy {
                return [.read, .notify]
            }
            return .read
        case .post:
            return .write
        case .broadcast(let isNotify):
            if isNotify {
                return [.notify, .broadcast]
            }
            return [.broadcast]
        }
    }
}


public protocol Communicable: Hashable {
    var serviceUUID: CBUUID { get }
    var method: RequestMethod { get }
    var value: Data? { get }
    var characteristicUUID: CBUUID? { get }
    var charactertic: CBMutableCharacteristic { get }
}


extension Communicable {
    public var method: RequestMethod {
        return .get(isNotified: false)
    }
    
    public var value: Data? {
        return nil
    }
    
    public var hashValue: Int {
        guard let charactersicitcUUID: CBUUID = self.characteristicUUID else {
            fatalError("ERRO")
        }
        return charactersicitcUUID.hash
    }
}

public func == <T: Communicable>(lhs: T, rhs:T) -> Bool {
    return lhs.characteristicUUID == rhs.charactertic
}
