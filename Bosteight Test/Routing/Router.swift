//
//  Router.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 02.03.2026.
//

import Foundation

enum AppFlow: Hashable {
    case launch
    case onboarding
    case main
}

enum FlowDestination: Hashable {
    case showMedia
    case showVideoCompressor
    
}
// MARK: 2. Define protocol
@MainActor protocol Routing: AnyObject {
    func goTo(_ flow: AppFlow)
    func push(_ destination: FlowDestination)
    func popLast()
    func popToRoot()
}
// MARK: 3. Create AppRouter
@MainActor final class AppRouter: ObservableObject, Routing {
    @Published var currentFlow: AppFlow = .launch
    @Published var flowPath: [FlowDestination] = []
    
    func goTo(_ flow: AppFlow) {
        currentFlow = flow
        flowPath = []
    }
    
    func push(_ destination: FlowDestination) {
        flowPath.append(destination)
    }
    func popLast() {
        if !flowPath.isEmpty {
            flowPath.removeLast()
        }
    }
    func popToRoot() {
        flowPath = []
    }
}
