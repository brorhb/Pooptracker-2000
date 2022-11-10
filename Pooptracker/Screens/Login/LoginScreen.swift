//
//  LoginScreen.swift
//  Pooptracker
//
//  Created by Bror2 on 08/11/2022.
//

import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        HStack {
            Spacer()
            SignInWithAppleButton()
                .onTapGesture {
                    authManager.startSignInWithAppleFlow()
                }
                .frame(height: 50)
            Spacer()
        }
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
