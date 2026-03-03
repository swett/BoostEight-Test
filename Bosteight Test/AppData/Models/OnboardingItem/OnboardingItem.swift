//
//  OnboardingItem.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 02.03.2026.
//

import Foundation


struct OnboardingItem: Identifiable, Hashable {
    let id: UUID = UUID()
    let image: String
    let title: String
    let description: String
}
