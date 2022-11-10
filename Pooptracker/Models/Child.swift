//
//  Child.swift
//  Pooptracker
//
//  Created by Bror2 on 08/11/2022.
//

import Foundation
import Firebase

struct Child: Codable {
    var id: String
    var name: String
    var caregivers: [String]
    
    init(id: String, name: String, caregivers: [String]) {
        self.id = id
        self.name = name
        self.caregivers = caregivers
    }
    
    init(documentData: [String: Any]) throws {
        guard let id = documentData["id"] as? String else { throw "missing child Id" }
        guard let name = documentData["name"] as? String else { throw "missing child name" }
        guard let caregivers = documentData["caregivers"] as? [String] else { throw "missing child caregivers" }
        self.id = id
        self.name = name
        self.caregivers = caregivers
    }
}

struct Feeding: Codable {
    var id: String
    var duration: Int?
    var side: FeedingSide?
    var timestamp: String
    
    init(id: String, duration: Int?, side: FeedingSide?, timestamp: String) {
        self.id = id
        self.duration = duration
        self.side = side
        self.timestamp = timestamp
    }
    
    init(documentData: [String: Any]) throws {
        guard let id = documentData["id"] as? String else { throw "Missing feeding id" }
        guard let timestamp = documentData["timestamp"] as? String else { throw "Missing action timestamp" }
        let duration: Int? = documentData["duration"] as? Int ?? nil
        let sideString: String? = documentData["side"] as? String ?? nil
        var side: FeedingSide?
        if sideString != nil {
            side = FeedingSide(rawValue: sideString!)
        }
        self.id = id
        self.duration = duration
        self.side = side
        self.timestamp = timestamp
    }
}

struct Diaper: Codable {
    var id: String
    var type: DiaperType?
    var timestamp: String
    
    init(id: String, type: DiaperType?, timestamp: String) {
        self.type = type
        self.id = id
        self.timestamp = timestamp
    }
    
    init(documentData: [String: Any]) throws {
        guard let id = documentData["id"] as? String else { throw "Missing feeding id" }
        guard let timestamp = documentData["timestamp"] as? String else { throw "Missing action timestamp" }
        let typeString: String? = documentData["type"] as? String ?? nil
        var type: DiaperType?
        if typeString != nil {
            type = DiaperType(rawValue: typeString!)
        }
        self.id = id
        self.type = type
        self.timestamp = timestamp
    }
}

enum DiaperType: String, Codable {
    case poop = "poop", pee = "pee", both = "both"
}

enum FeedingSide: String, Codable {
    case left = "left", right = "right"
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
