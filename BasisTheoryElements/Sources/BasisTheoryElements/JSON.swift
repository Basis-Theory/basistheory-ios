//
//  JSON.swift
//  
//
//  Created by Brian Gonzalez on 12/21/22.
//

import Foundation

@dynamicMemberLookup
public enum JSON {
    case elementValueReference(ElementValueReference)
    case arrayValue(Array<JSON>)
    case dictionaryValue(Dictionary<String, JSON>)
    
    public var elementValueReference: ElementValueReference? {
      if case .elementValueReference(let elementValueRef) = self {
         return elementValueRef
      }
      return nil
   }
    
    subscript(index: Int) -> JSON? {
        if case .arrayValue(let arr) = self {
            return index < arr.count ? arr[index] : nil
        }
        return nil
    }
    
    public subscript(key: String) -> JSON? {
        get {
            if case .dictionaryValue(let dict) = self {
                return dict[key]
            }
            return nil
        }
        
        mutating set {
            if case .dictionaryValue(var dict) = self {
                dict[key] = newValue
                self = JSON.dictionaryValue(dict)
            }
        }
    }
    
    public subscript(dynamicMember member: String) -> JSON? {
        if case .dictionaryValue(let dict) = self {
            return dict[member]
        }
        return nil
    }
}
