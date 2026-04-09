//
//  ViewModelProtocol.swift
//  App
//
//  Created by esteban on 4/8/26.
//

import SwiftUI

protocol ViewModelProtocol: ObservableObject {
    var state: SwiftViewModel.State { get }
    func start()
    func refresh()
    func onSeen(id: String)
    func requestNextPage()
}

extension SwiftViewModel: ViewModelProtocol {}
