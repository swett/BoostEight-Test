//
//  ArrayExtension.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 02.03.2026.
//

import Foundation

extension Array {
    
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        
        var result: [[Element]] = []
        var index = 0
        
        while index < count {
            let end = Swift.min(index + size, count)
            result.append(Array(self[index..<end]))
            index += size
        }
        
        return result
    }
}
