# Belu
Bluetooth Library For Native Swift

[![forthebadge](https://forthebadge.com/images/badges/made-with-swift.svg)](https://forthebadge.com)

## Installation:
- you can clone this repo, build the project and add the xcode project to your ios application for using this library or you can directly download it via swift package manager.

## Usage:
- import Belu module into your swift project
```swift
import Belu
```
- a sample belu library usage is given below.

## Docs:
```swift
import Belu

extension Communicable {
    public var serviceUUID: CBUUID {
        return CBUUID(string: "UUID")
    }
}

// get 
struct GetUserIDItem: Communicable {
    public var method: RequestMethod {
        return .get(isNotified: false)
    }

    public var characteristicUUID: CBUUID {
        return CBUUID(string: "UUID")
    }
}

// post
struct PostUserIDItem: Communicable {
    public var method: RequestMethod {
        return .post
    }

    public var characteristicUUID: CBUUID {
        return CBUUID(string: "UUId")
    }
}

```

## Get
- Server
```swift
Belu.addReceiver(Receiver(GetUserID(), get: { [weak self] (manager, request) in
    guard let text: String = self?.textField.text else {
        manager.respond(to: request, withResult: .attributeNotFound)
        return
    }
    request.value = text.data(using: .utf8)
    manager.respond(to: request, withResult: .success)
}))

Belu.startAdvertising()
```

- client
```swift 
let request: Request = Request(communication: GetUserID()) { [weak self] (peripheral, characteristic, error) in
    if let error = error {
        debugPrint(error)
        return
    }
    
    let data: Data = characteristic.value!
    let text: String = String(data: data, encoding: .utf8)!
    
    self?.centralTextField.text = text
}

// send
Belu.send([request]) { completedRequests, error in
    if let error = error {
        print("timeout")
    }
}
```

## Post
- server
```swift

Belu.addReceiver(Receiver(PostUserID(), post: { (manager, request) in
    let data: Data = request.value!
    let text: String = String(data: data, encoding: .utf8)!
    print(text)
    manager.respond(to: request, withResult: .success)
}))

Belu.startAdvertising()
```

- Client
```swift
let data: Data = "Sample".data(using: .utf8)!
let request: Request = Request(communication: PostUserID()) { (peripheral, characteristic, error) in
    if let error = error {
        debugPrint(error)
        return
    }
    
    print("success")
}
request.value = data
Belu.send([request]) { completedRequests, error in
    if let error = error {
        print("timeout")
    }
}
```

## Author:
- Belu is created by [krishpranav](https://github.com/krishpranav)

## License:
- Belu is licensed under MIT.
