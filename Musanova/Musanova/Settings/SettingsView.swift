//
//  SettingsView.swift
//  Musadora
//
//  Created by Rudrank Riyam on 17/03/23.
//

import SwiftUI

struct SettingsView: View {
  @State private var developerToken: String = ""
  @State private var showTokenSavedAlert = false

  var body: some View {
    NavigationStack {
      List {
        Section("Developer Token") {
          VStack(alignment: .leading, spacing: 8) {
            Text("Enter your Apple Music developer token to access private APIs like pins and lyrics.")
              .font(.subheadline)
              .foregroundColor(.secondary)

            TextField("Developer Token", text: $developerToken)
              .textFieldStyle(.roundedBorder)
              .autocorrectionDisabled()

            Button("Save Token") {
              UserDefaults.standard.set(developerToken, forKey: "developerToken")
              showTokenSavedAlert = true
            }
            .buttonStyle(.borderedProminent)
            .disabled(developerToken.isEmpty)
          }
          .padding(.vertical, 8)
        }

        Section("About") {
          Text("Made for [MusadoraKit](https://github.com/rryam/MusadoraKit). Go ⭐️ it!")
          Text("Made by [Rudrank Riyam](https://twitter.com/rudrankriyam). Go follow him!")
        }
      }
      .navigationTitle("Settings")
      .alert("Token Saved", isPresented: $showTokenSavedAlert) {
        Button("OK", role: .cancel) { }
      } message: {
        Text("Your developer token has been saved securely.")
      }
    }
    .tint(Color.indigo)
    .onAppear {
      developerToken = UserDefaults.standard.string(forKey: "developerToken") ?? ""
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}
