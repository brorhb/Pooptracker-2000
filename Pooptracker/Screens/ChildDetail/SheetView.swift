//
//  SheetView.swift
//  Pooptracker
//
//  Created by Bror2 on 08/11/2022.
//

import SwiftUI

struct SheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var childManager: ChildManager
    @Binding var actionType: ActionType
    @State private var selectedDate = Date()
    @State private var duration = ""
    @State private var side: Int = 0
    @State private var diaperType: Int = 2
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tidspunkt")) {
                    HStack {
                        DatePicker(selection: $selectedDate) {
                            Text("Tidspunkt")
                        }
                    }
                }
                if actionType == .diaper {
                    Section(header: Text("Tilleggs info")) {
                        Picker(selection: $diaperType, label: Text("Hvilke side?")) {
                            Text("Tiss").tag(0)
                            Text("Bæsj").tag(1)
                            Text("Begge").tag(2)
                        }.pickerStyle(.segmented)
                    }
                }
                if actionType == .feeding {
                    Section(header: Text("Tileggs info")) {
                        VStack {
                            Text("Hvor lenge (minutter)")
                            TextField("Hvor lenge (minutter)", text: $duration)
                                .keyboardType(.numberPad)
                        }
                        Picker(selection: $side, label: Text("Hvilke side?")) {
                            Text("Venstre").tag(1)
                            Text("Høyre").tag(0)
                        }.pickerStyle(.segmented)
                    }
                }
            }
            .navigationTitle("Registrer \(actionType == .feeding ? "mating" : "bleie")")
            .toolbar {
                Button(action: {
                    if actionType == .feeding {
                        let sideAsEnum: FeedingSide = side == 1 ? .left : .right
                        childManager.addFeeding(date: selectedDate, duration: Int(duration), side: sideAsEnum)
                    } else {
                        var diaperAsEnum: DiaperType = .both
                        switch (diaperType) {
                        case 0:
                            diaperAsEnum = .pee
                        case 1:
                            diaperAsEnum = .poop
                        case 2:
                            diaperAsEnum = .both
                        default:
                            diaperAsEnum = .both
                        }
                        childManager.addDiaper(date: selectedDate, type: diaperAsEnum)
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Lagre")
                }
            }
        }
    }
}
