//
//  AttackPatternGenerator.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2015-01-27.
//  Copyright (c) 2015 Benjamin Pierce. All rights reserved.
//

import Foundation

open class AttackPatternGenerator {
    fileprivate var chickenatorAttackPercentage = 0.0
    fileprivate var bowlingBallAttackPercentage = 0.0
    fileprivate var pieAttackPercentage = 0.0
    fileprivate var maxWeaponsAllowedInAttack = 0
    
    public init(maxWeaponsAllowedInAttack: Int, chickenatorAttackPercentage: Double, bowlingBallAttackPercentage : Double, pieAttackPercentage: Double) {

        self.chickenatorAttackPercentage = chickenatorAttackPercentage
        self.bowlingBallAttackPercentage = bowlingBallAttackPercentage
        self.pieAttackPercentage = pieAttackPercentage
        self.maxWeaponsAllowedInAttack = maxWeaponsAllowedInAttack
    }

    open func GenerateAttackPattern(_ canThrowChickenator: Bool) -> [CRIMINAL_WEAPON] {
        let numberOfAttacks = Int.random(1...maxWeaponsAllowedInAttack)
        let pattern = Int.random(1...27)
        var result: [CRIMINAL_WEAPON]
    
        // Attacks are mostly pattern based.
        //
        // Normal Patterns
        // Pattern 1 = All the same weapons in a row.
        // Pattern 2 = Pie, Bowling Ball, repeated (random sequence ordering though).
        // Pattern 3 = Chickenator high, chickenator low, chickenator high, chickenator low.
        // Pattern 4 = All 3 repeated (random sequence ordering though).
        // Pattern 5 = Bowling Ball, Chickenator High (repeated).
        // Pattern 6 = Bowling Ball, Chickenator Low (repeated).
        // Pattern 7 = Pie, Chickenator High (repeated).
        // Pattern 8 = Pie, Chickenator Low (repeated).
        // Pattern 9 = 1 random item.
        // Pattern 10 = Completely random.
    
        // Hard Patterns
        // Pattern 11 = Low chickenators (at least 3, or the min), and a high chickenator.
        // Pattern 12 = High chickenators (at least 3, or the min), and a low chickenator.
        // Pattern 13 = Pie, Pie, Bowling Ball, Chickenator High, Chickenator High, Chickenator Low.
        // Pattern 14 = Chickenator High, Chickenator High, Chickenator Low, Chickenator High
        // Pattern 15 = Chickenator Low, Chickenator Low, Chickenator High, Chickenator Low.
        // Pattern 16 = Chickenator High, Chickenator High, Chickenator Low, Chickenator Low repeated.
        // Pattern 19 = Bowling Ball, Chickenator High, Bowling Ball, Chickenator High... Chickenator Low, Chickenator High
        // Pattern 20 = Pie, Chickenator Low, Pie, Chickenator Low ... Chickenator High, Chickenator Low

        switch(pattern) {
        case 1:
            result = QueuePattern1(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        case 2:
            result = QueuePattern2(numberOfAttacks)
        case 3:
            result = QueuePattern3(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        case 4:
            result = QueuePattern4(numberOfAttacks)
        case 5:
            result = QueuePattern5(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        case 6:
            result = QueuePattern6(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        case 7:
			result = QueuePattern7(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        case 8:
			result = QueuePattern8(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        case 9:
			result = QueuePattern9(canThrowChickenator)
        case 10:
			result = QueuePattern10(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        case 11:
			result = QueuePattern11(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        case 12:
			result = QueuePattern12(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        case 13:
			result = QueuePattern13(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        case 14:
			result = QueuePattern14(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        case 15:
			result = QueuePattern15(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        case 16:
			result = QueuePattern16(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        case 17:
			result = QueuePattern10(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        case 18:
			result = QueuePattern10(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        case 19:
            result = QueuePattern19(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        case 20:
            result = QueuePattern20(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        default:
            result = QueuePattern10(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        }
        
        return result;
    }
    
    // Pattern 1 = All the same weapons in a row.
    fileprivate func QueuePattern1(_ numberOfAttacks: Int, canThrowChickenator: Bool) -> [CRIMINAL_WEAPON]{
        var attackNum = 0
        var weapon = 0
        var queue : [CRIMINAL_WEAPON] = []
        
        if ( canThrowChickenator ) {
            weapon = Int.random(1...3)  // Chickenator allowed.
        } else {
            weapon = Int.random(2...3)  // Chickenator not allowed.
        }
    
        while(attackNum < numberOfAttacks) {
            if( weapon == 1 ) {
				let position = Int.random(1...2)
				
				if( position == 1 ) {
                    queue.append(CRIMINAL_WEAPON.chickenator_HIGH)
				}
                else {
                    queue.append(CRIMINAL_WEAPON.chickenator_LOW)
				}
            } else if (weapon == 2) {
                queue.append(CRIMINAL_WEAPON.bowling_BALL)
            } else {
                queue.append(CRIMINAL_WEAPON.pie)
            }
    
            attackNum = attackNum + 1
        }
    
        return queue
    }
    
    // Alternate Pie, Bowling Ball, repeated (random sequence ordering though).
    fileprivate func QueuePattern2(_ numberOfAttacks: Int) -> [CRIMINAL_WEAPON] {
        var attackNum = 0
        var weapon = Int.random(1...2)
        var queue : [CRIMINAL_WEAPON] = []
    
        while(attackNum < numberOfAttacks) {
            if( weapon == 1 ) {
                queue.append(CRIMINAL_WEAPON.bowling_BALL)
				weapon = 2
            } else {
				queue.append(CRIMINAL_WEAPON.pie)
				weapon = 1
            }
    
            attackNum = attackNum + 1
        }
    
        return queue
    }
    
    // Pattern 3 = Chickenator high, chickenator low, chickenator high, chickenator low.
    fileprivate func QueuePattern3(_ numberOfAttacks: Int, canThrowChickenator: Bool) -> [CRIMINAL_WEAPON]{
        var attackNum = 0
        var weapon = Int.random(1...2)
        var queue : [CRIMINAL_WEAPON] = []
    
        if ( canThrowChickenator ) {
            while(attackNum < numberOfAttacks) {
				if( weapon == 1 ) {
                    queue.append(CRIMINAL_WEAPON.chickenator_HIGH)
                    weapon = 2
				} else {
                    queue.append(CRIMINAL_WEAPON.chickenator_LOW)
                    weapon = 1
				}
    
				attackNum = attackNum + 1
            }
        } else {
            // Can't throw chickenators, so we'll fallback to bowling balls and pies.
            queue = QueuePattern2(numberOfAttacks)
        }
    
        return queue;
    }
    
    // Pattern 4 = All 3 repeated (random sequence ordering though).
    fileprivate func QueuePattern4(_ numberOfAttacks: Int) -> [CRIMINAL_WEAPON] {
        var attackNum = 0
        var queue : [CRIMINAL_WEAPON] = []
    
        var weapon = Int.random(1...3)
    
        while(attackNum < numberOfAttacks) {
            if(weapon == 1) {
				let position = Int.random(1...2)
                
				if(position == 1) {
                    queue.append(CRIMINAL_WEAPON.chickenator_HIGH)
				} else {
                    queue.append(CRIMINAL_WEAPON.chickenator_LOW)
				}
    
				weapon = 2
            } else if(weapon == 2) {
                queue.append(CRIMINAL_WEAPON.bowling_BALL)
				weapon = 3
            } else {
                queue.append(CRIMINAL_WEAPON.pie)
				weapon = 1
            }
    
            attackNum = attackNum + 1
        }
    
        return queue
    }
    
    // Pattern 5 = Bowling Ball, Chickenator High (repeated).
    fileprivate func QueuePattern5(_ numberOfAttacks: Int, canThrowChickenator: Bool) -> [CRIMINAL_WEAPON] {
        var weapon = Int.random(1...2)
        var attackNum = 0
        var queue : [CRIMINAL_WEAPON] = []
    
        if(canThrowChickenator) {
            while(attackNum < numberOfAttacks) {
				if(weapon == 1) {
                    queue.append(CRIMINAL_WEAPON.chickenator_HIGH)
                    weapon = 2
				} else {
                    queue.append(CRIMINAL_WEAPON.bowling_BALL)
                    weapon = 1
				}
    
				attackNum = attackNum + 1
            }
        } else {
            queue = QueuePattern10(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        }
    
        return queue;
    }
    
    // Pattern 6 = Bowling Ball, Chickenator Low (repeated).
    fileprivate func QueuePattern6(_ numberOfAttacks: Int, canThrowChickenator: Bool) -> [CRIMINAL_WEAPON] {
        var weapon = Int.random(1...2)
        var attackNum = 0
        var queue : [CRIMINAL_WEAPON] = []
    
        if(canThrowChickenator) {
            while(attackNum < numberOfAttacks) {
				if(weapon == 1) {
                    queue.append(CRIMINAL_WEAPON.chickenator_LOW)
                    weapon = 2
				} else {
                    queue.append(CRIMINAL_WEAPON.bowling_BALL)
                    weapon = 1
				}
    
				attackNum = attackNum + 1
            }
        } else {
            queue = QueuePattern10(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        }
    
        return queue
    }
    
    // Pattern 7 = Pie, Chickenator High (repeated).
    fileprivate func QueuePattern7(_ numberOfAttacks: Int, canThrowChickenator: Bool) -> [CRIMINAL_WEAPON] {
        var weapon = Int.random(1...2)
        var attackNum = 0
        var queue : [CRIMINAL_WEAPON] = []
    
        if(canThrowChickenator) {
            while(attackNum < numberOfAttacks) {
				if(weapon == 1) {
                    queue.append(CRIMINAL_WEAPON.chickenator_HIGH)
                    weapon = 2
				} else {
                    queue.append(CRIMINAL_WEAPON.pie)
                    weapon = 1
				}
    
				attackNum = attackNum + 1
            }
        } else {
            queue = QueuePattern10(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        }
    
        return queue
    }
    
    // Pattern 8 = Pie, Chickenator Low (repeated).
    fileprivate func QueuePattern8(_ numberOfAttacks: Int, canThrowChickenator: Bool) -> [CRIMINAL_WEAPON] {
        var weapon = Int.random(1...2)
        var attackNum = 0
        var queue : [CRIMINAL_WEAPON] = []
    
        if(canThrowChickenator) {
            while(attackNum < numberOfAttacks) {
				if(weapon == 1) {
                    queue.append(CRIMINAL_WEAPON.chickenator_LOW)
                    weapon = 2
				} else {
                    queue.append(CRIMINAL_WEAPON.pie)
                    weapon = 1
				}
    
				attackNum = attackNum + 1
            }
        } else {
            queue = QueuePattern10(numberOfAttacks, canThrowChickenator: canThrowChickenator);
        }
    
        return queue
    }
    
    // Pattern 9: 1 Random Item only.
    fileprivate func QueuePattern9(_ canThrowChickenator: Bool) -> [CRIMINAL_WEAPON] {
        return QueuePattern10(1, canThrowChickenator: canThrowChickenator)
    }
    
    // Pattern 10: Completely Random.
    fileprivate func QueuePattern10(_ numberOfAttacks: Int, canThrowChickenator: Bool) -> [CRIMINAL_WEAPON] {
        var attackNum = 0
        var attackPercentage : Double
        let chickenatorAttackPercentage = self.chickenatorAttackPercentage + 0.001 // Adding a small number so we never accidentally hit the chickenator if it's disabled.
        var queue : [CRIMINAL_WEAPON] = []
    
        while(attackNum < numberOfAttacks) {
            if(canThrowChickenator) {
                attackPercentage =  Double.random(0, max: 1)
            } else {
                attackPercentage = Double.random(chickenatorAttackPercentage, max: 1)
            }
            
            if(attackPercentage <= self.chickenatorAttackPercentage) {
				let position = Int.random(1...2)
                if(position == 1) {
                    queue.append(CRIMINAL_WEAPON.chickenator_HIGH)
				} else {
                    queue.append(CRIMINAL_WEAPON.chickenator_LOW)
				}
            } else if (attackPercentage > self.chickenatorAttackPercentage && attackPercentage <= self.chickenatorAttackPercentage + self.bowlingBallAttackPercentage) {
                queue.append(CRIMINAL_WEAPON.bowling_BALL)
            } else {
                queue.append(CRIMINAL_WEAPON.pie)
            }
    
            attackNum = attackNum + 1
        }
    
        return queue
    }
    
    // Pattern 11 = Low chickenators, a high chickenator, and a low chickenator.
    fileprivate func QueuePattern11(_ numberOfAttacks: Int, canThrowChickenator: Bool) -> [CRIMINAL_WEAPON] {
        var attackNum = 0
        var queue : [CRIMINAL_WEAPON] = []
    
        if(numberOfAttacks == 1) {
            return QueuePattern9(canThrowChickenator);
        } else if (!canThrowChickenator) {
            return QueuePattern10(numberOfAttacks, canThrowChickenator: canThrowChickenator);
        } else {
            while(attackNum < numberOfAttacks) {
				if(attackNum == 1) {		// Second Last one.
                    queue.append(CRIMINAL_WEAPON.chickenator_HIGH)
				} else {
                    queue.append(CRIMINAL_WEAPON.chickenator_LOW)
				}
    
				attackNum = attackNum + 1
            }
        }
				
        return queue
    }
    
    // Pattern 12 High chickenators (at least 3, or the min), and a low chickenator.
    fileprivate func QueuePattern12(_ numberOfAttacks: Int, canThrowChickenator: Bool) -> [CRIMINAL_WEAPON] {
        var attackNum = 0
        var queue : [CRIMINAL_WEAPON] = []
    
        if(numberOfAttacks == 1) {
            return QueuePattern9(canThrowChickenator);
        } else if (!canThrowChickenator) {
            return QueuePattern10(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        } else {
            while(attackNum < numberOfAttacks) {
				if(attackNum == 1) {		// Second Last one.
                    queue.append(CRIMINAL_WEAPON.chickenator_LOW)
				} else {
                    queue.append(CRIMINAL_WEAPON.chickenator_HIGH)
				}
    
				attackNum = attackNum + 1
            }
        }
				
        return queue
    }
    
    // Pattern 13 = Pie, Pie, Bowling Ball, Chickenator High, Chickenator High, Chickenator Low.
    fileprivate func QueuePattern13(_ numberOfAttacks: Int, canThrowChickenator: Bool) -> [CRIMINAL_WEAPON] {
        var attackNum = 0
        var numAttacks = numberOfAttacks
    
        if(numAttacks > 6) {
            numAttacks = 6
        }
        var queue : [CRIMINAL_WEAPON] = []
    
        if(numAttacks == 1) {
            return QueuePattern9(canThrowChickenator);
        } else {
            while(attackNum < numAttacks) {
				switch(attackNum) {
                    case 0:
                        queue.append(canThrowChickenator ? CRIMINAL_WEAPON.chickenator_LOW : CRIMINAL_WEAPON.bowling_BALL)
                    case 1:
                        queue.append(canThrowChickenator ? CRIMINAL_WEAPON.chickenator_HIGH : CRIMINAL_WEAPON.pie)
                    case 2:
                        queue.append(CRIMINAL_WEAPON.chickenator_HIGH)
                    case 3:
                        queue.append(CRIMINAL_WEAPON.bowling_BALL)
                    case 4:
                        queue.append(CRIMINAL_WEAPON.pie)
                    case 5:
                        queue.append(CRIMINAL_WEAPON.pie)
                    default:
                        queue.append(CRIMINAL_WEAPON.pie)
				}
    
				attackNum = attackNum + 1
            }
        }
				
        return queue
    }
    
    // Pattern 14 = Chickenator High, Chickenator High, Chickenator Low, Chickenator High
    fileprivate func QueuePattern14(_ numberOfAttacks: Int, canThrowChickenator: Bool) -> [CRIMINAL_WEAPON] {
        var attackNum = 0
        var numAttacks = numberOfAttacks
        
        if(numAttacks > 4) {
            numAttacks = 4
        }
        var queue: [CRIMINAL_WEAPON] = []
    
        if(numAttacks == 1) {
            return QueuePattern9(canThrowChickenator);
        } else {
            while(attackNum < numAttacks) {
				switch(attackNum) {
                case 0:
                    queue.append(canThrowChickenator ? CRIMINAL_WEAPON.chickenator_HIGH : CRIMINAL_WEAPON.pie)
                case 1:
                    queue.append(canThrowChickenator ? CRIMINAL_WEAPON.chickenator_LOW : CRIMINAL_WEAPON.bowling_BALL)
                case 2:
                    queue.append(canThrowChickenator ? CRIMINAL_WEAPON.chickenator_HIGH : CRIMINAL_WEAPON.pie)
                case 3:
                    queue.append(canThrowChickenator ? CRIMINAL_WEAPON.chickenator_HIGH: CRIMINAL_WEAPON.pie)
                default:
                    queue.append(CRIMINAL_WEAPON.pie)
				}
    
				attackNum = attackNum + 1
            }
        }
				
        return queue;
    }
    
    // Pattern 15 = Chickenator Low, Chickenator Low, Chickenator High, Chickenator Low.
    fileprivate func QueuePattern15(_ numberOfAttacks: Int, canThrowChickenator: Bool) -> [CRIMINAL_WEAPON] {
        var attackNum = 0
        var numAttacks = numberOfAttacks
        
        if(numAttacks > 4) {
            numAttacks = 4
        }
        var queue : [CRIMINAL_WEAPON] = []
    
        if(numberOfAttacks == 1) {
            return QueuePattern9(canThrowChickenator)
        } else {
            while(attackNum < numAttacks) {
				switch(attackNum) {
                case 0:
                    queue.append(canThrowChickenator ? CRIMINAL_WEAPON.chickenator_LOW : CRIMINAL_WEAPON.bowling_BALL)
                case 1:
                    queue.append(canThrowChickenator ? CRIMINAL_WEAPON.chickenator_HIGH : CRIMINAL_WEAPON.pie)
                case 2:
                    queue.append(canThrowChickenator ? CRIMINAL_WEAPON.chickenator_LOW : CRIMINAL_WEAPON.bowling_BALL)
                case 3:
                    queue.append(canThrowChickenator ? CRIMINAL_WEAPON.chickenator_LOW: CRIMINAL_WEAPON.bowling_BALL)
                default:
                    queue.append(canThrowChickenator ? CRIMINAL_WEAPON.chickenator_LOW: CRIMINAL_WEAPON.bowling_BALL)
                }
    
				attackNum = attackNum + 1
            }
        }
				
        return queue
    }
    
    // Pattern 16 = Chickenator High, Chickenator High, Chickenator Low, Chickenator Low repeated.
    fileprivate func QueuePattern16(_ numberOfAttacks: Int, canThrowChickenator: Bool) -> [CRIMINAL_WEAPON] {
        var attackNum = 0
        var queue : [CRIMINAL_WEAPON] = []
    
        if(numberOfAttacks == 1) {
            return QueuePattern9(canThrowChickenator)
        } else {
            while(attackNum < numberOfAttacks) {
				switch(attackNum % 4) {
                case 0:
                    queue.append(canThrowChickenator ? CRIMINAL_WEAPON.chickenator_LOW : CRIMINAL_WEAPON.bowling_BALL)
                case 1:
                    queue.append(canThrowChickenator ? CRIMINAL_WEAPON.chickenator_LOW : CRIMINAL_WEAPON.bowling_BALL)
                case 2:
                    queue.append(canThrowChickenator ? CRIMINAL_WEAPON.chickenator_HIGH : CRIMINAL_WEAPON.pie)
                case 3:
                    queue.append(canThrowChickenator ? CRIMINAL_WEAPON.chickenator_HIGH: CRIMINAL_WEAPON.pie)
                default:
                    queue.append(CRIMINAL_WEAPON.pie)
                }
    
				attackNum = attackNum + 1
            }
        }
				
        return queue
    }
    
    // Pattern 19 = Bowling Ball, Chickenator High, Bowling Ball, Chickenator High... Chickenator Low, Chickenator High
    fileprivate func QueuePattern19(_ numberOfAttacks: Int, canThrowChickenator: Bool) -> [CRIMINAL_WEAPON] {
        var attackNum = 0
        var numAttacks = numberOfAttacks
        
        if(numAttacks <= 5) {
            numAttacks = 6
        }
        var queue: [CRIMINAL_WEAPON] = []
    
        if(numAttacks == 1) {
            return QueuePattern9(canThrowChickenator);
        } else if (!canThrowChickenator) {
            return QueuePattern10(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        } else {
            while(attackNum < numAttacks) {
                if (attackNum == 0) {
                    queue.append(CRIMINAL_WEAPON.chickenator_HIGH)
                } else if(attackNum == 1) {		// Second Last one.
                    queue.append(CRIMINAL_WEAPON.chickenator_LOW)
				} else {
                    if ( (attackNum + 1) % 2 == 1) {
                        queue.append(CRIMINAL_WEAPON.chickenator_HIGH)
                    } else {
                        queue.append(CRIMINAL_WEAPON.bowling_BALL)
                    }
				}
    
				attackNum = attackNum + 1
            }
        }
				
        return queue;
    }

    // Pattern 20 = Pie, Chickenator High, Pie, Chickenator High ... Chickenator Low, Chickenator High
    fileprivate func QueuePattern20(_ numberOfAttacks: Int, canThrowChickenator: Bool) -> [CRIMINAL_WEAPON] {
        var attackNum = 0
        var numAttacks = numberOfAttacks
        
        if(numAttacks <= 5) {
            numAttacks = 6
        }
        var queue: [CRIMINAL_WEAPON] = []
        
        if(numAttacks == 1) {
            return QueuePattern9(canThrowChickenator);
        } else if (!canThrowChickenator) {
            return QueuePattern10(numberOfAttacks, canThrowChickenator: canThrowChickenator)
        } else {
            while(attackNum < numAttacks) {
                if (attackNum == 0) {
                    queue.append(CRIMINAL_WEAPON.chickenator_LOW)
                } else if(attackNum == 1) {		// Second Last one.
                    queue.append(CRIMINAL_WEAPON.chickenator_HIGH)
                } else {
                    if ( (attackNum + 1) % 2 == 1) {
                        queue.append(CRIMINAL_WEAPON.chickenator_LOW)
                    } else {
                        queue.append(CRIMINAL_WEAPON.pie)
                    }
                }
                
                attackNum = attackNum + 1
            }
        }
        
        return queue;
    }

    fileprivate func PrintPattern(_ queue: [CRIMINAL_WEAPON]) {
        let count = queue.count - 1
        for i in 0 ... count {
            let item = queue[i]
            switch(item) {
            case CRIMINAL_WEAPON.bowling_BALL:
                print("Weapon \(i) is Bowling Ball")
            case CRIMINAL_WEAPON.pie:
                print("Weapon \(i) is Pie")
            case CRIMINAL_WEAPON.chickenator_HIGH:
                print("Weapon \(i) is Chickenator High")
            case CRIMINAL_WEAPON.chickenator_LOW:
                print("Weapon \(i) is Chickenator Low")
            }
        }
    }

}
