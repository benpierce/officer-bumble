//
//  PhysicsHandler.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2015-01-03.
//  Copyright (c) 2015 Benjamin Pierce. All rights reserved.
//

import Foundation
import SpriteKit

public protocol PhysicsHandler {
    var BodyType: BODY_TYPE { get }
    func SetPhysics(_ physicsManager: PhysicsManager)
    func RemovePhysics()
}
