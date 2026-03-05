//
//  VideoCompressionState.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 05.03.2026.
//

import Foundation
enum VideoCompressionState {

    case idle

    case preparing

    case compressing(progress: Double)

    case finished(result: VideoCompressionResult)

    case failed(Error)

    case cancelled
}
