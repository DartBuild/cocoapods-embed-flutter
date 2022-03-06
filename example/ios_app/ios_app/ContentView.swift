//
//  ContentView.swift
//  ios_app
//
//  Created by Soumya Ranjan Mahunt on 06/03/22.
//

import SwiftUI
import Flutter
import FlutterPluginRegistrant

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Hello, world!")
                    .padding()
                NavigationLink("Go to Flutter", destination: FlutterView())
            }
        }
    }
}


struct FlutterView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> FlutterViewController {
        let flutterViewController = FlutterViewController(project: nil, nibName: nil, bundle: nil)
        return flutterViewController
    }

    func updateUIViewController(_ uiViewController: FlutterViewController, context: Context) {
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
