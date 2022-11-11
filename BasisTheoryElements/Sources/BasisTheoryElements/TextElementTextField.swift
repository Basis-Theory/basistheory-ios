//
//  TextElementTextField.swift
//  
//
//  Created by Brian Gonzalez on 10/26/22.
//

import SwiftUI
import Combine
import Foundation

struct TextElementView: UIViewRepresentable, InternalElementProtocol, ElementProtocol {
    var validation: ((String?) -> Bool)?
    
    public var subject = PassthroughSubject<ElementEvent, Error>()
    typealias UIViewType = TextElementUITextField

    func makeUIView(context: Context) -> TextElementUITextField {
        let input = TextElementUITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 50))

        return input
    }

    func updateUIView(_ uiView: TextElementUITextField, context: Context) { }
    
    func getValue() -> String? {
        ""
    }
}
