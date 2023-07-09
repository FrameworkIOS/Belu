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
        case .get(let isNotify):
            if isNotify {
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

    var permissions: CBAttributePermissions {
        switch self {
        case .get: return .readable
        case .post: return .writeable
        case .broadcast: return .readable
        }
    }
}

public protocol Communicable: Hashable {
    var serviceUUID: CBUUID { get }
    var method: RequestMethod { get }
    var value: Data? { get }
    var characteristicUUID: CBUUID? { get }
    var characteristic: CBMutableCharacteristic { get }
}

extension Communicable {

    public var method: RequestMethod {
        return .get(isNotified: false)
    }

    public var value: Data? {
        return nil
    }

    public var hashValue: Int {
        guard let characteristicUUID: CBUUID = self.characteristicUUID else {
            fatalError("*** LogError: characteristicUUID must be defined for Communicable. ***")
        }
        return characteristicUUID.hash
    }

    public var characteristic: CBMutableCharacteristic {
        return CBMutableCharacteristic(type: self.characteristicUUID!, properties: self.method.properties, value: nil, permissions: self.method.permissions)
    }
}

public func == <T: Communicable>(lhs: T, rhs: T) -> Bool {
    return lhs.characteristicUUID == rhs.characteristicUUID
}
