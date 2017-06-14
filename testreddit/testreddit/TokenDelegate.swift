//
//  TokenDelegate.swift
//  testreddit
//
//  Created by Alexander on 6/14/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

public protocol TokenDelegate {
    
    func onNewTokenReceived(newToken token:Token)
}
