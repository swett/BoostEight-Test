//
//  AssetGroup.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 04.03.2026.
//

import Foundation

struct AssetGroup: Identifiable, Hashable {
    let id: UUID
    var assets: [SelectableAsset]
}
