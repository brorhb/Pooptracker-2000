//
//  SignInWithAppleButton.swift
//  Pooptracker
//
//  Created by Bror2 on 08/11/2022.
//


import SwiftUI
import AuthenticationServices

// 1
struct SignInWithAppleButton: UIViewRepresentable {
  // 2
  func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
    // 3
    return ASAuthorizationAppleIDButton()
  }
  
  // 4
  func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
  }
}
