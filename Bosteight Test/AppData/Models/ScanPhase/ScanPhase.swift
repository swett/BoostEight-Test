//
//  ScanPhase.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 02.03.2026.
//

import Foundation

enum ScanPhase {
    case metadata
    case duplicates
    case similar
    case finished
}

struct ScanProgress {
    let phase: ScanPhase
    let progress: Double   // 0...1
}
