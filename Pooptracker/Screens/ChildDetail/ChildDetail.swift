//
//  ChildDetail.swift
//  Pooptracker
//
//  Created by Bror2 on 08/11/2022.
//

import SwiftUI
import Charts

struct ActionsPerDay {
    var actions: Int
    var date: Date
}

enum ActionType: String {
    case feeding = "feeding", diaper = "diaper"
}

struct ChildDetail: View {
    let child: Child
    
    @EnvironmentObject var childManager: ChildManager
    
    @State private var showActionSheet = false
    @State private var selectedAction: ActionType = .feeding
    @State private var lastFedString = ""
    @State private var lastDiaperString = ""
    @State private var diaperTimerange = 7
    @State private var feedingTimerange = 7
    @State private var newCaregiverCode = ""
    
    var body: some View {
        List {
            Section(header: Text("Handlinger")) {
                Button(action: {
                    self.selectedAction = .diaper
                    self.showActionSheet = true
                }) {
                    HStack {
                        Text("Legg til bleie")
                        Spacer()
                        Text("💩")
                    }
                }
                Button(action: {
                    self.selectedAction = .feeding
                    self.showActionSheet = true
                }) {
                    HStack {
                        Text("Legg til mat")
                        Spacer()
                        Text("🍼")
                    }
                }
            }
            Section(header: Text("Oversikt")) {
                NavigationLink(destination: DiaperList()) {
                    HStack {
                        Text("Byttet sist bleie")
                        Spacer()
                        if (childManager.lastDiaper != nil) {
                            Text("\(childManager.lastDiaper!.timestamp.fromISO8601ToDate()!.getTime())")
                        } else {
                            Text("Ikke registert bleier ennå")
                                .font(.caption)
                        }
                    }
                }
                NavigationLink (destination: FeedingList()) {
                    HStack {
                        Text("Fikk sist mat")
                        Spacer()
                        if (childManager.lastFed != nil) {
                            Text("\(childManager.lastFed!.timestamp.fromISO8601ToDate()!.getTime())")
                        } else {
                            Text("Ikke registert mat ennå")
                                .font(.caption)
                        }
                    }
                }
                HStack {
                    Text("Fikk sist mat fra")
                    Spacer()
                    if (childManager.lastFed?.side != nil) {
                        Text("\(childManager.lastFed!.side == .left ? "Venstre" : "Høyre")")
                    } else {
                        Text("Ikke registert mat ennå")
                            .font(.caption)
                    }
                }
            }
            Section("Bleie statistikk") {
                VStack {
                    Picker(selection: $diaperTimerange, label: Text("")) {
                        Text("7 dager").tag(7)
                        Text("30 dager").tag(30)
                    }.pickerStyle(.segmented)
                    Chart {
                        ForEach(Array(childManager.diapersReduced.keys.prefix(diaperTimerange).sorted(by: { $0.compare($1) == .orderedDescending })), id: \.self) { item in
                            BarMark(
                                x: .value("Dag", item),
                                y: .value("Antall", childManager.diapersReduced[item]!.count)
                            )
                        }
                    }
                }.padding(.vertical)
            }
            Section("Mat statistikk") {
                VStack {
                    Picker(selection: $feedingTimerange, label: Text("")) {
                        Text("7 dager").tag(7)
                        Text("30 dager").tag(30)
                    }.pickerStyle(.segmented)
                    Chart {
                        ForEach(Array(childManager.feedingsReduced.keys.prefix(feedingTimerange).sorted(by: { $0.compare($1) == .orderedDescending })), id: \.self) { item in
                            BarMark(
                                x: .value("Dag", item),
                                y: .value("Antall", childManager.feedingsReduced[item]!.count)
                            )
                        }
                    }
                }.padding(.vertical)
            }
            Section("Legg til forsørger") {
                TextField("Forsørger kode", text: $newCaregiverCode)
                Button("Large") {
                    childManager.addParent(toChild: child, parentId: newCaregiverCode)
                }
            }
        }
        .sheet(isPresented: $showActionSheet) {
            SheetView(actionType: $selectedAction)
        }
        .navigationTitle(child.name)
        .onAppear {
            childManager.selectedChild = child
        }
    }
}
