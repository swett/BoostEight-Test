//
//  OnboardingViewModel.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 02.03.2026.
//

import Foundation



@MainActor
final class OnboardingViewModel: ObservableObject {
    
    // MARK: - Published UI state
    @Published var step: Int = 0
    var items: [OnboardingItem] = [
        OnboardingItem(image: "on1", title: "Clean your Storage", description: "Pick the best & delete the rest"),
        OnboardingItem(image: "on2", title: "Detect Similar Photos", description: "Clean similar photos & videos, save your storage space on your phone."),
        OnboardingItem(image: "on3", title: "Video Compressor", description: "Find large videos or media files and compress them to free up storage space")
    ]
    
    // MARK: - Dependencies
    private let coordinator: Routing?
    
    init(coordinator: Routing? = nil) {
        self.coordinator = coordinator
    }
    
    // MARK: - Step actions
    
    func nextStep() {
        if step < items.count - 1 {
            step += 1
        }
    }
    
    func backStep() {
        if step > 0 {
            step -= 1
        }
    }
    
    func finish() {
        coordinator?.goTo(.main)
    }
}
