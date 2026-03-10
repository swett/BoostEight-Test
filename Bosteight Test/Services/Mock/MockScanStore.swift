//
//  MockScanStore.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 04.03.2026.
//

import Foundation
import Photos

final class MockScanStore: ScanStore {

    init() {
        super.init(scanResult: MockDataFactory.makeScanResult())
    }

  
}
