//
//  DiaperList.swift
//  Pooptracker
//
//  Created by Bror2 on 10/11/2022.
//

import SwiftUI

struct DiaperList: View {
    @EnvironmentObject var childManager: ChildManager
    
    func sortedDates(dates: [Date]) -> [Date] {
        return dates.sorted(by: { $0.compare($1) == .orderedDescending })
    }
    
    var body: some View {
        List(sortedDates(dates: Array(childManager.diapersReduced.keys)), id: \.self) { diaperDate in
            Section(header: Text(diaperDate.getDate())) {
                ForEach(childManager.diapersReduced[diaperDate]!.sorted(by: { $0.timestamp.compare($1.timestamp) == .orderedDescending }), id: \.id) { diaper in
                    HStack {
                        if let type = diaper.type {
                            switch (type) {
                            case .both:
                                Text("Begge")
                            case .poop:
                                Text("Bæsj 💩")
                            case .pee:
                                Text("Tiss")
                            }
                        } else {
                            Text("Bleie innhold ikke registrert")
                        }
                        Spacer()
                        Text(diaper.timestamp.fromISO8601ToDate()!.getTime())
                            .bold()
                    }
                }
            }
        }.navigationTitle("Bleier")
    }
}

struct DiaperList_Previews: PreviewProvider {
    static var previews: some View {
        DiaperList()
    }
}
