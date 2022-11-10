//
//  ChildManager.swift
//  Pooptracker
//
//  Created by Bror2 on 08/11/2022.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore

class ChildManager: ObservableObject {
    @Published var children = [Child]()
    @Published var loading = true
    @Published var selectedChild: Child? {
        didSet {
            self.listenToDiapers()
            self.listenToFeedings()
        }
    }
    @Published var feedings = [Feeding]() {
        didSet {
            feedingsReduced = reduceFeedings(feedings: feedings)
            guard let lastFeeding = self.calculateLatestFeeding(actions: feedings) else { return }
            self.lastFed = lastFeeding
        }
    }
    @Published var diaperChanges = [Diaper]() {
        didSet {
            diapersReduced = reduceDiapers(diapers: diaperChanges)
            guard let lastDiaper = self.calculateLatestDiaper(actions: diaperChanges) else { return }
            self.lastDiaper = lastDiaper
        }
    }
    @Published var lastDiaper: Diaper?
    @Published var lastFed: Feeding?
    @Published var feedingsReduced = [Date: [Feeding]]()
    @Published var diapersReduced = [Date: [Diaper]]()
    
    private var db: Firestore!
    private var user: User? {
        didSet {
            self.listenToChildren()
        }
    }
    
    init() {
        db = Firestore.firestore()
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.user = user
            } else {
                self.user = nil
            }
        }
    }
    
    private func listenToDiapers() {
        guard let selectedChild = selectedChild else { return }
        db.collection("poopers").document(selectedChild.id).collection("diapers").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                var actions = [Diaper]()
                for document in querySnapshot!.documents {
                    if let action = try? Diaper.init(documentData: document.data()) {
                        actions.append(action)
                    }
                }
                self.diaperChanges = actions
            }
        }
    }
    
    private func listenToFeedings() {
        guard let selectedChild = selectedChild else { return }
        db.collection("poopers").document(selectedChild.id).collection("feedings").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                var actions = [Feeding]()
                for document in querySnapshot!.documents {
                    if let action = try? Feeding.init(documentData: document.data()) {
                        actions.append(action)
                    }
                }
                self.feedings = actions
            }
        }
    }
    
    private func listenToChildren() {
        guard let user = user else { return }
        db.collection("poopers").whereField("caregivers", arrayContains: user.uid).addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                var children = [Child]()
                for document in querySnapshot!.documents {
                    if let child = try? Child.init(documentData: document.data()) {
                        children.append(child)
                    }
                }
                self.children = children
            }
            self.loading = false
        }
    }
    
    private func reduceDiapers(diapers: [Diaper]) -> [Date: [Diaper]] {
        let formatter = ISO8601DateFormatter()
        var count = [Date: [Diaper]]()
        for diaper in diapers {
            if let date = formatter.date(from: diaper.timestamp) {
                let adjustedDate: Date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .second, value: 0, to: date)!)
                if count[adjustedDate] != nil {
                    count[adjustedDate]!.append(diaper)
                } else {
                    count[adjustedDate] = [diaper]
                }
            }
        }
        return count
    }
    
    private func reduceFeedings(feedings: [Feeding]) -> [Date: [Feeding]] {
        let formatter = ISO8601DateFormatter()
        var count = [Date: [Feeding]]()
        for feeding in feedings {
            if let date = formatter.date(from: feeding.timestamp) {
                let adjustedDate: Date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .second, value: 0, to: date)!)
                if count[adjustedDate] != nil {
                    count[adjustedDate]!.append(feeding)
                } else {
                    count[adjustedDate] = [feeding]
                }
            }
        }
        return count
    }
    
    private func calculateLatestDiaper(actions: [Diaper]) -> Diaper? {
        let sortedActions = actions.sorted(by: { $0.timestamp.compare($1.timestamp) == .orderedDescending })
        guard let firstAction = sortedActions.first else { return nil }
        return firstAction
    }
    
    private func calculateLatestFeeding(actions: [Feeding]) -> Feeding? {
        let sortedActions = actions.sorted(by: { $0.timestamp.compare($1.timestamp) == .orderedDescending })
        guard let firstAction = sortedActions.first else { return nil }
        return firstAction
    }
    
    func addChild(name: String) {
        guard let user = user else { return }
        let id = UUID().uuidString
        let child = Child(id: id, name: name, caregivers: [user.uid])
        db.collection("poopers").document(id).setData([
            "id": child.id,
            "name": child.name,
            "caregivers": child.caregivers
        ])
    }
    
    func addParent(toChild child: Child, parentId: String) {
        var caregivers = child.caregivers
        caregivers.append(parentId)
        db.collection("poopers").document(child.id).setData([
            "id": child.id,
            "name": child.name,
            "caregivers": caregivers
        ])
    }
    
    func addDiaper(date: Date, type: DiaperType) {
        guard let selectedChild = selectedChild else { return }
        let id = UUID().uuidString
        let diaper = Diaper(
            id: id,
            type: type,
            timestamp: date.ISO8601Format(.iso8601)
        )
        db.collection("poopers").document(selectedChild.id).collection("diapers").document(diaper.id).setData([
            "id": diaper.id,
            "type": diaper.type!.rawValue,
            "timestamp": diaper.timestamp
        ])
    }
    
    func addFeeding(date: Date, duration: Int?, side: FeedingSide) {
        guard let selectedChild = selectedChild else { return }
        let id = UUID().uuidString
        let feeding = Feeding(
            id: id,
            duration: duration,
            side: side,
            timestamp: date.ISO8601Format(.iso8601)
        )
        db.collection("poopers").document(selectedChild.id).collection("feedings").document(feeding.id).setData([
            "id": feeding.id,
            "duration": feeding.duration as Any,
            "side": feeding.side!.rawValue as Any,
            "timestamp": feeding.timestamp
        ])
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func getTime() -> String {
        let hour = Calendar.current.component(.hour, from: self)
        let minute = Calendar.current.component(.minute, from: self)
        let hourString = hour < 10 ? "0\(hour)" : "\(hour)"
        let minuteString = minute < 10 ? "0\(minute)" : "\(minute)"
        return "\(hourString):\(minuteString)"
    }
    
    func getDate() -> String {
        let date = Calendar.current.component(.day, from: self)
        let month = Calendar.current.component(.month, from: self)
        return "\(date)/\(month)"
    }
}

extension String {
    func fromISO8601ToDate() -> Date? {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: self) else { return nil }
        return date
    }
}

