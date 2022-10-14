//
//  File.swift
//  iostest
//
//  Created by Brian Gonzalez on 10/13/22.
//

import Foundation
import Combine
import SwiftUI
import UIKit
import OpenAPIClient
import AnyCodable

final public class BasisTheoryElements {
    public static var apiKey: String = ""

    public static func tokenize(body: TextElementUITextField, apiKey: String, completion: @escaping ((_ data: AnyCodable?, _ error: Error?) -> Void)) -> Void {
        let payload = AnyCodable(body.values)
        let apiKeyForTokenize = !BasisTheoryElements.apiKey.isEmpty ? BasisTheoryElements.apiKey : apiKey
        TokenizeAPI.tokenizeWithRequestBuilder(body: payload).addHeader(name: "BT-API-KEY", value: apiKeyForTokenize).execute { result in
            do {
                let app = try result.get()

                completion(app.body, nil)
            } catch {
                print(error)
            }
        }
    }
}

public struct ElementEventErrors {
    public var type: String
}

public struct ElementEvent {
    public var type: String
    public var complete: Bool
    public var empty: Bool
    public var errors: [ElementEventErrors]
}

public protocol TextElementProtocol {
    var subject: PassthroughSubject<ElementEvent, Error> {get set}
}

internal protocol InternalTextElementProtocol {
    var values: [String: String] { get set }
}

extension InternalTextElementProtocol {
    internal func getValues() {
        print("value")
    }
}

// SwiftUI
struct TextElementView: UIViewRepresentable, InternalTextElementProtocol, TextElementProtocol {
    public var subject = PassthroughSubject<ElementEvent, Error>()
    internal var values: [String: String]
    typealias UIViewType = TextElementUITextField

    func makeUIView(context: Context) -> TextElementUITextField {
        let input = TextElementUITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 50))

        return input
    }

    func updateUIView(_ uiView: TextElementUITextField, context: Context) {
        print("updateUIView")
    }
}

// UIKit
final public class TextElementUITextField: UITextField, InternalTextElementProtocol, TextElementProtocol {
    public var subject = PassthroughSubject<ElementEvent, Error>()
    internal var values: [String : String] = ["textValue" : ""]

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        subject.send(ElementEvent(type: "ready", complete: true, empty: true, errors: []))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        subject.send(ElementEvent(type: "ready", complete: true, empty: true, errors: []))
    }
    
    deinit {
        subject.send(completion: .finished)
    }
    
    public override var text: String? {
        set { values["textValue"] = newValue }
        get { return "" }
    }
    
    @objc private func textFieldDidChange() {
        let currentTextValue = super.text
        values["textValue"] = currentTextValue

        subject.send(ElementEvent(type: "textChange", complete: true, empty: currentTextValue?.isEmpty ?? true, errors: []))
    }
}
