//: Playground - noun: a place where people can play

import UIKit

//https://codelle.com/blog/2016/5/an-easy-way-to-convert-swift-structs-to-json/
//http://www.sthoughts.com/2016/06/30/swift-3-serializing-swift-structs-to-json/

import Foundation


//: ### Defining the protocols
protocol JSONRepresentable {
    var JSONRepresentation: Any { get }
}

protocol JSONSerializable: JSONRepresentable {}

//: ### Implementing the functionality through protocol extensions
extension JSONSerializable {
    var JSONRepresentation: Any {
        var representation = [String: Any]()
        
        for case let (label?, value) in Mirror(reflecting: self).children {
            
            switch value {
                
            case let value as Dictionary<String, Any>:
                representation[label] = value as AnyObject
                
            case let value as Array<Any>:
                if let val = value as? [JSONSerializable] {
                    representation[label] = val.map({ $0.JSONRepresentation as AnyObject }) as AnyObject
                } else {
                    representation[label] = value as AnyObject
                }
                
            case let value:
                representation[label] = value as AnyObject
                //  break
                
                //            default:
                //                // Ignore any unserializable properties
                //                break
            }
        }
        return representation as Any
    }
}

extension JSONSerializable {
    func toJSON() -> String? {
        let representation = JSONRepresentation
        
        guard JSONSerialization.isValidJSONObject(representation) else {
            print("Invalid JSON Representation")
            return nil
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: representation, options: [])
            
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}


//: ### Define the Structures
//: Notice how they are conforming to the `JSONSerializable` protocol
struct Author: JSONSerializable {
    var name: String
}

struct Book: JSONSerializable {
    var title: String
    var isbn: String
    var pages: Int
    
    var authors:[JSONSerializable]
    var extra:[String: Any]
}

//: ### Create a sample object for serialization
let book = Book(title: "Book", isbn: "1234", pages: 2, authors: [Author(name: "Clive Cussler"),Author(name:"Jack Du Brul")], extra: ["foo": "bar", "baz": 142.226])

//: ### Use the protocols to convert the data to JSON
if let json = book.toJSON() {
    print(json)
}

