//
//  SelectableAsset.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 04.03.2026.
//

import Foundation

struct SelectableAsset: Identifiable, Hashable {
    let id: String           // localIdentifier
    let size: Int64
    var isSelected: Bool
    var isBest: Bool
}
