//
//  ActivityIndicatorView.swift
//  landmarknotes
//
//  Created by Roger Lee on 6/11/20.
//  Copyright © 2020 JR Lee. All rights reserved.
//

import SwiftUI

struct ActivityIndicatorView: UIViewRepresentable {
    
    typealias UIView = UIActivityIndicatorView
    var isAnimating: Bool
    var configuration = { (indicator: UIView) in }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView { UIView() }
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        configuration(uiView)
    }
}

extension View where Self == ActivityIndicatorView {
    func configure(_ configuration: @escaping (Self.UIView)->Void) -> Self {
        Self.init(isAnimating: self.isAnimating, configuration: configuration)
    }
}


struct ActivityIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ActivityIndicatorView(isAnimating: true)
            ActivityIndicatorView(isAnimating: false)
            ActivityIndicatorView(isAnimating: true).configure { $0.color = .red }
            ActivityIndicatorView(isAnimating: true).configure { $0.color = .blue }
        }.previewLayout(.fixed(width: 300, height: 60))
    }
}
