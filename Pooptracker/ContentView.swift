//
//  ContentView.swift
//  Pooptracker
//
//  Created by Bror2 on 08/11/2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var childManager: ChildManager
    @EnvironmentObject var authManager: AuthManager
    @State private var newChildName = ""
    
    var body: some View {
        switch childManager.loading {
        case true:
            ProgressView()
        case false:
            NavigationView {
                if childManager.children.count == 0 {
                    Form {
                        Section(header: Text("Legg til nytt barn")) {
                            VStack {
                                Text("Hva vil du kalle barnet?")
                                TextField("Barnets navn", text: $newChildName)
                            }
                            Button(action: {
                                childManager.addChild(name: newChildName)
                            }) {
                                Text("Legg til barn")
                            }
                        }
                        Section(header: Text("Eller del for å bli forsørger")) {
                            VStack(alignment: .leading) {
                                Text("Hvis du har noen i livet ditt som allerede bruker appen, og du vil være forsørger. Del koden under med personen, så kan du bli lagt til som forsørger.")
                                Text(authManager.userInSession?.uid ?? "")
                                    .padding(.vertical)
                                    .bold()
                                Button(action: {
                                    guard let user = self.authManager.userInSession else {return}
                                    UIPasteboard.general.string = user.uid
                                }) {
                                    Text("Kopier koden")
                                        .foregroundColor(Color.blue)
                                }
                            }
                        }
                    }.navigationTitle("Velkommen!")
                } else {
                    if childManager.children.count > 1 {
                        List(childManager.children, id: \.id) { child in
                            NavigationLink(child.name) {
                                ChildDetail(child: child)
                            }
                        }.navigationTitle("Barna dine")
                    } else {
                        ChildDetail(child: childManager.children.first!)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
