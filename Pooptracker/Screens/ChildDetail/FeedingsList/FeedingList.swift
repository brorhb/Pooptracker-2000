//
//  FeedingList.swift
//  Pooptracker
//
//  Created by Bror2 on 10/11/2022.
//

import SwiftUI

struct FeedingList: View {
    @EnvironmentObject var childManager: ChildManager
    
    func sortedDates(dates: [Date]) -> [Date] {
        return dates.sorted(by: { $0.compare($1) == .orderedDescending })
    }
    
    var body: some View {
        List(sortedDates(dates: Array(childManager.feedingsReduced.keys)), id: \.self) { feedingDate in
            Section(header: Text(feedingDate.getDate())) {
                ForEach(childManager.feedingsReduced[feedingDate]!.sorted(by: { $0.timestamp.compare($1.timestamp) == .orderedDescending }), id: \.id) { feeding in
                    HStack {
                        if let side = feeding.side {
                            Text(side == .left ? "Venstre" : "Høyre")
                        } else {
                            Text("Side ikke registrert")
                        }
                        Spacer()
                        Text(feeding.timestamp.fromISO8601ToDate()!.getTime())
                            .bold()
                    }
                }
            }
        }.navigationTitle("Matinger")
    }
}

struct FeedingList_Previews: PreviewProvider {
    static var previews: some View {
        FeedingList()
    }
}
