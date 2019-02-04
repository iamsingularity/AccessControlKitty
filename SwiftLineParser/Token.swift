//
//  Token.swift
//  Temporary
//
//  Created by Zoe Smith on 4/20/18.`while` 'repeat`
//  Copyright © 2018 Hot Beverage. All rights reserved.
//

import Foundation

enum Token: Equatable {
    case attribute(String)
    case keyword(Keyword)
    case singleCharacter(SingleCharacter)
    case identifier(String)
}

enum SingleCharacter: String, CaseIterable {
    case bracketOpen = "{", bracketClose = "}"
    case colon = ":"
    case equals = "="
}

enum Keyword: String, CaseIterable {
    case `protocol`, `extension`, `struct`, `class`, `let`, `var`,
    `public`, `private`, `open`, `fileprivate`, `internal`,
    `override`, `func`,
    `final`, `enum`, `case`,
    _init = "init",
    `static`, `typealias`, `required`,
    `mutating`, `nonmutating`,
    `for`, `while`, `repeat`,
    `unowned`, unownedsafe = "unowned(safe)", unownedunsafe = "unowned(unsafe)",
    `convenience`, `do`, `catch`, `defer`, `subscript`,
    `prefix`, `postfix`, `infix`,
    `lazy`, `weak`
}

extension Token {
    init?(_ singleCharacter: SingleCharacter?) {
        guard singleCharacter != nil else { return nil }
        self = .singleCharacter(singleCharacter!)
    }
    
    init?(_ keyword: Keyword?) {
        guard keyword != nil else { return nil }
        self = .keyword(keyword!)
    }
}




