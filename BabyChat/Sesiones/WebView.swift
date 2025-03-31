//
//  WebView.swift
//  BabyChat
//
//  Created by eduardo caballero on 28/03/25.
//

// --- Necesario para SignUpView.swift ---

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
