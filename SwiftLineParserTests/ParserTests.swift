//
//  ParserTests.swift
//  SwiftLineParserTests
//
//  Created by Zoe Smith on 4/21/18.
//  Copyright © 2018-9 Zoë Smith. Distributed under the MIT License.
//

import XCTest
@testable import SwiftLineParser

class ParserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        continueAfterFailure = true
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStructure() {
        let test =
        """
        final class ViewController: NSViewController {
        @IBOutlet var textView: NSTextView!
        override func viewDidLoad() {
        super.viewDidLoad()
        let strings: [Highlight<NSAttributedString>] = markdown()
        let result = strings.map { $0.rendered }.join(separator: " ")
        textView.textStorage!.setAttributedString(result)
        }
        }
        """
        let expected =
        """
        public final class ViewController: NSViewController {
        @IBOutlet public var textView: NSTextView!
        public override func viewDidLoad() {
        super.viewDidLoad()
        let strings: [Highlight<NSAttributedString>] = markdown()
        let result = strings.map { $0.rendered }.join(separator: " ")
        textView.textStorage!.setAttributedString(result)
        }
        }
        """
        multilineTest(test: test, expected: expected)
        
    }
    
    func testEnum() {
        let test =
        """
        enum Kind: Int {
        case keyword
        case string
        case other

        init?(sourceKitType type: String) {
        switch type {
        case source.lang.swift.syntaxtype.keyword: self = .keyword
        case source.lang.swift.syntaxtype.string: self = .string
        default: self = .other
        }
        }
        }
        """
        let expected =
        """
        public enum Kind: Int {
        case keyword
        case string
        case other

        public init?(sourceKitType type: String) {
        switch type {
        case source.lang.swift.syntaxtype.keyword: self = .keyword
        case source.lang.swift.syntaxtype.string: self = .string
        default: self = .other
        }
        }
        }
        """
        multilineTest(test: test, expected: expected)
    }
    
    func testFunc() {
        let test =
        """
        func highlightSyntax(code: String) throws -> [(Range<String.Index>, Kind)] {
        let tempDir = NSURL(fileURLWithPath: NSTemporaryDirectory())
        let tmpFile = tempDir.appendingPathComponent(UUID().uuidString + \".swift\")!
        try! code.write(to: tmpFile, atomically: true, encoding: .utf8)]
        return (range, Kind(sourceKitType: dict[\"type\"] as! String)!)
        """
        let expected =
        """
        public func highlightSyntax(code: String) throws -> [(Range<String.Index>, Kind)] {
        let tempDir = NSURL(fileURLWithPath: NSTemporaryDirectory())
        let tmpFile = tempDir.appendingPathComponent(UUID().uuidString + \".swift\")!
        try! code.write(to: tmpFile, atomically: true, encoding: .utf8)]
        return (range, Kind(sourceKitType: dict[\"type\"] as! String)!)
        """
        multilineTest(test: test, expected: expected)
    }

    
    func testPrePostSubstitutionFixing() {
        let test =
                    """
                    public let strings: [Highlight<NSAttributedString>] = markdown()
                    final class ViewController: NSViewController {
                    @IBOutlet var textView: NSTextView!
                    func highlightSyntax(code: String) throws -> [(Range<String.Index>, Kind)] {
                    """
        let expected =
                    """
                    public let strings: [Highlight<NSAttributedString>] = markdown()
                    public final class ViewController: NSViewController {
                    @IBOutlet public var textView: NSTextView!
                    public func highlightSyntax(code: String) throws -> [(Range<String.Index>, Kind)] {
                    """
        multilineTest(test: test, expected: expected)
    }
    
    func testPrePostSubstitutionFixingVars() {
        let test =
                    """
                    public var strings: [Highlight<NSAttributedString>] = markdown()
                    final class ViewController: NSViewController {
                    @IBOutlet var textView: NSTextView!
                    func highlightSyntax(code: String) throws -> [(Range<String.Index>, Kind)] {
                    """
        
        let expected =
                    """
                    public var strings: [Highlight<NSAttributedString>] = markdown()
                    public final class ViewController: NSViewController {
                    @IBOutlet public var textView: NSTextView!
                    public func highlightSyntax(code: String) throws -> [(Range<String.Index>, Kind)] {
                    """
        multilineTest(test: test, expected: expected)
    }
    
    func testPropertiesInsideStruct() {
        let test =
        """
        struct Highlight<Result> where Result: Block & HighlightedCode {
        let rendered: Result
        """
        
        let expected =
        """
        public struct Highlight<Result> where Result: Block & HighlightedCode {
        public let rendered: Result
        """
        multilineTest(test: test, expected: expected)
    }
    
    func testPropertiesMethodsInsideProtocol() {
        let test =
        """
        protocol HighlightedCode {
        static func highlight(text: String, tokens: [(Range<String.Index>, Kind)]) -> Self
        var whatever { get }
        var another { get set }
        """
        let expected =
        """
        public protocol HighlightedCode {
        static func highlight(text: String, tokens: [(Range<String.Index>, Kind)]) -> Self
        var whatever { get }
        var another { get set }
        """
        multilineTest(test: test, expected: expected)
    }
    
    func testPropertiesMethodsInsideProtocolWithClosingBrace() {
        let test =
            """
            protocol HighlightedCode {
            static func highlight(text: String, tokens: [(Range<String.Index>, Kind)]) -> Self
            var whatever { get }
            var whatever { get }
            var whatever { get }
            var another { get set }
            }
            """
        let expected =
        """
            public protocol HighlightedCode {
            static func highlight(text: String, tokens: [(Range<String.Index>, Kind)]) -> Self
            var whatever { get }
            var whatever { get }
            var whatever { get }
            var another { get set }
            }
            """
        multilineTest(test: test, expected: expected)
    }
    
    func testExtensionWithConformance() {
        let test =
            """
        extension NSAttributedString: Block {
        static func paragraph(text: String) -> Self {
        return .init(string: text)
        }
        """
        let expected =
        """
        extension NSAttributedString: Block {
        static public func paragraph(text: String) -> Self {
        return .init(string: text)
        }
        """
        multilineTest(test: test, expected: expected)
    }
    
    func testInitAsMethodNotRecognized() {
        let test =
        """
        extension NSAttributedString: HighlightedCode {
        static func highlight(text: String, tokens: [(Range<String.Index>, Kind)]) -> Self {
        let result = NSMutableAttributedString(string: text)
        for highlight in tokens {
        let range = NSRange(highlight.0, in: text)
        let color = highlight.1.color
        result.addAttribute(.foregroundColor, value: color, range: range)
        }
        return .init(attributedString: result)
        }
        }

        extension NSAttributedString: Block {
        static func paragraph(text: String) -> Self {
        return .init(string: text)
        }

        static func codeBlock(text: String, language: String?) -> Self {
        return .init(string: text)
        }
        }
        """
        let expected =
        """
        extension NSAttributedString: HighlightedCode {
        static public func highlight(text: String, tokens: [(Range<String.Index>, Kind)]) -> Self {
        let result = NSMutableAttributedString(string: text)
        for highlight in tokens {
        let range = NSRange(highlight.0, in: text)
        let color = highlight.1.color
        result.addAttribute(.foregroundColor, value: color, range: range)
        }
        return .init(attributedString: result)
        }
        }

        extension NSAttributedString: Block {
        static public func paragraph(text: String) -> Self {
        return .init(string: text)
        }

        static public func codeBlock(text: String, language: String?) -> Self {
        return .init(string: text)
        }
        }
        """
        multilineTest(test: test, expected: expected)
    }
    
    func testDoubleAttributeMarking() {
        let test = "@IBOutlet private var Thing : UISwitch"
        let expected = "@IBOutlet public var Thing : UISwitch"
        multilineTest(test: test, expected: expected)
    }
    
    func testRemoval() {
        let lines = ["public let strings: [Highlight<NSAttributedString>] = markdown()",
                                "public final class ViewController: NSViewController {",
                                "@IBOutlet public var textView: NSTextView!",
                                "public func highlightSyntax(code: String) throws -> [(Range<String.Index>, Kind)] {"]
        let expectedNewLines = ["let strings: [Highlight<NSAttributedString>] = markdown()",
                                                               "final class ViewController: NSViewController {",
                                                               "@IBOutlet var textView: NSTextView!",
                                                               "func highlightSyntax(code: String) throws -> [(Range<String.Index>, Kind)] {"]
        let parser = Parser(lines: lines)
        let newLines = parser.newLines(at: [0, 1, 2, 3], accessChange: .singleLevel(.remove))
        for (index, expectedline) in expectedNewLines.enumerated() {
            XCTAssertEqual(newLines[index], expectedline, "Line no.: \(index) \(lines[index]) was incorrectly parsed")
        }
    }
    
    func testRequiredInitKeyword() {
        let lines = [
         "required init?(coder aDecoder: NSCoder) {",
         "super.init(style: .grouped)",
        " }"]
        let expectedNewLines = [
            "required public init?(coder aDecoder: NSCoder) {", nil, nil]
        let parser = Parser(lines: lines)
        let newLines = parser.newLines(at: [0, 1, 2], accessChange: .singleLevel(.public))
        for (index, expectedline) in expectedNewLines.enumerated() {
            XCTAssertEqual(newLines[index], expectedline, "Line no.: \(index) \(lines[index]) was incorrectly parsed")
        }
    }
    
    func testTypeAliasDecoration() {
        let lines = [
         "typealias WriteToState<State> = ((inout State) -> ()) -> ()"
         ]
        let expectedNewLines  = [
            "public typealias WriteToState<State> = ((inout State) -> ()) -> ()"
        ]
        let parser = Parser(lines: lines)
        let newLines = parser.newLines(at: [0], accessChange: .singleLevel(.public))
        for (index, expectedline) in expectedNewLines.enumerated() {
            XCTAssertEqual(newLines[index], expectedline, "Line no.: \(index) \(lines[index]) was incorrectly parsed")
        }
    }
    
    func testMutatingDecoration() {
    let lines = ["mutating func nest<X>(_ element: FormElement<X, State>) {",
                 "strongReferences.append(contentsOf: element.strongReferences)"]
    let expectedNewLines = ["public mutating func nest<X>(_ element: FormElement<X, State>) {", nil]
        let parser = Parser(lines: lines)
        let newLines = parser.newLines(at: [0], accessChange: .singleLevel(.public))
        for (index, expectedline) in expectedNewLines.enumerated() {
            XCTAssertEqual(newLines[index], expectedline, "Line no.: \(index) \(lines[index]) was incorrectly parsed")
        }
    }
    
    func testLastLineOfStructWithoutParens() {
        let test =
        """
@testable import Parser

struct CloudKitIdentifiers {
let container: String
let placesZone : String
let databaseSubscriptionID: String
let placesZoneSubscriptionID  : String
"""
        let expected =
        """
@testable import Parser

public struct CloudKitIdentifiers {
public let container: String
public let placesZone : String
public let databaseSubscriptionID: String
public let placesZoneSubscriptionID  : String
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testEnumCases() {
        
        let test =
            """
            enum Reps {
            case count(Int)
             case range(ClosedRange<Int>)
             case amrap
             case dropset(count: Int)
             case rpe(Int)
             case max(Int)
             case time(Int)
             case ladder([Int])
            }
            """
        let expected =
        """
            public enum Reps {
            case count(Int)
             case range(ClosedRange<Int>)
             case amrap
             case dropset(count: Int)
             case rpe(Int)
             case max(Int)
             case time(Int)
             case ladder([Int])
            }
            """
        multilineTest(test: test, expected: expected)
    }

    
    func testComputedVariables() {
        let test = """
var oneOrMore: Parser<[A]> {
// prepend the single result + remainder many result
let transform: (A, [A]) -> [A] = { single, array in return [single] + array }
let curried = curry(transform)
let intermediate = curried <^> self  // Parser<([A]) -> [A]>
let final = intermediate <*> self.many // Parser<[A]>
return final
}
"""
        let expected = """
public var oneOrMore: Parser<[A]> {
// prepend the single result + remainder many result
let transform: (A, [A]) -> [A] = { single, array in return [single] + array }
let curried = curry(transform)
let intermediate = curried <^> self  // Parser<([A]) -> [A]>
let final = intermediate <*> self.many // Parser<[A]>
return final
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testComplexAssignmentsWithCurlyBraces() {
        let test = """
private let wales = countries[0].regions.first { $0.name == "Wales" }!
private let england = countries[0].regions.first { $0.name == "England" }!
private let english = england.languages.first { $0.name == "English" }!

"""
        let expected = """
public let wales = countries[0].regions.first { $0.name == "Wales" }!
public let england = countries[0].regions.first { $0.name == "England" }!
public let english = england.languages.first { $0.name == "English" }!

"""
    multilineTest(test: test, expected: expected)
    }
    
    func testComplexAssignmentListWithFancyOperators() {
        let test = """
let range = curry({ from, _, to in return RepStyle.range(from...to) }) <^> digits <*> hyphen <*> digits //8-12
let dropset = curry({ _, _, count in return RepStyle.dropset(count: count) }) <^> string("dropset") <*> hyphen <*> digits //dropset-4
let count = { RepStyle.count($0) } <^> digits <* character { $0 == "x" } //15
let amrap = { _ in RepStyle.amrap } <^> string("AMRAP")
let time = { RepStyle.time($0) } <^> digits <* character { $0 == "s" } //30s
let rpe = { RepStyle.rpe($0) } <^> (string("rpe") *> digits)  //rpe8
let ladder = { RepStyle.ladder($0) } <^> (digits <* character { $0 == "," }).oneOrMore // 12,10,8,6,8,10,12
let max = { RepStyle.max($0) } <^> digits <* character { $0 == "%" } //30%
let repStyle = ladder <|> dropset <|> range <|> time <|> rpe <|> amrap <|> max <|> count
"""
        let expected = """
public let range = curry({ from, _, to in return RepStyle.range(from...to) }) <^> digits <*> hyphen <*> digits //8-12
public let dropset = curry({ _, _, count in return RepStyle.dropset(count: count) }) <^> string("dropset") <*> hyphen <*> digits //dropset-4
public let count = { RepStyle.count($0) } <^> digits <* character { $0 == "x" } //15
public let amrap = { _ in RepStyle.amrap } <^> string("AMRAP")
public let time = { RepStyle.time($0) } <^> digits <* character { $0 == "s" } //30s
public let rpe = { RepStyle.rpe($0) } <^> (string("rpe") *> digits)  //rpe8
public let ladder = { RepStyle.ladder($0) } <^> (digits <* character { $0 == "," }).oneOrMore // 12,10,8,6,8,10,12
public let max = { RepStyle.max($0) } <^> digits <* character { $0 == "%" } //30%
public let repStyle = ladder <|> dropset <|> range <|> time <|> rpe <|> amrap <|> max <|> count
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testIncompleteBraceSelection() {
        let test = """
struct CloudKitIdentifiers {
let container: String
let placesZone : String
let databaseSubscriptionID: String
let placesZoneSubscriptionID : String
"""
         let expected = """
public struct CloudKitIdentifiers {
public let container: String
public let placesZone : String
public let databaseSubscriptionID: String
public let placesZoneSubscriptionID : String
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testVariablesDefinedWithLocalScopeInVarDontGetAccessNotation() {
        let test = """
var patchMark: String {
let fstMark = "yo"
let sndMark = "beef"
return "@@@@"
}
"""
        let expected = """
public var patchMark: String {
let fstMark = "yo"
let sndMark = "beef"
return "@@@@"
}
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testComplexAssignmentsVarsWithCurlyBraces() {
        let test = """
private var wales = countries[0].regions.first { $0.name == "Wales" }!
private var england = countries[0].regions.first { $0.name == "England" }!
private var english = england.languages.first { $0.name == "English" }!

"""
        let expected = """
public var wales = countries[0].regions.first { $0.name == "Wales" }!
public var england = countries[0].regions.first { $0.name == "England" }!
public var english = england.languages.first { $0.name == "English" }!

"""
        multilineTest(test: test, expected: expected)
    }

    func testVariablesDefinedWithLocalScopeInLetDontGetAccessNotation() {
        let test = """
let patchMark: String {
let fstMark = "yo"
let sndMark = "beef"
return "@@@@"
}()
"""
        let expected = """
public let patchMark: String {
let fstMark = "yo"
let sndMark = "beef"
return "@@@@"
}()
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testAccessModifierAfterStaticKeywordIsRecognized() {
        let test = """
static private func == (lhs: Index, rhs: Index) -> Bool {
switch (lhs, rhs) {
case (.array(let left), .array(let right)):
return left == right
case (.dictionary(let left), .dictionary(let right)):
return left == right
case (.null, .null): return true
default:
return false
}
}
"""
        
        let expected = """
static public func == (lhs: Index, rhs: Index) -> Bool {
switch (lhs, rhs) {
case (.array(let left), .array(let right)):
return left == right
case (.dictionary(let left), .dictionary(let right)):
return left == right
case (.null, .null): return true
default:
return false
}
}
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testStaticKeywordRecognizedCorrectly() {
        let test = """
        static var playing: [PlayerCore] {
        return playerCores.filter { !$0.info.isIdle }
        }
        
        static var playerCores: [PlayerCore] = []
        static private var playerCoreCounter = 0
        
        static private func findIdlePlayerCore() -> PlayerCore? {
        return playerCores.first { $0.info.isIdle && !$0.info.fileLoading }
        }
        
        static private func createPlayerCore() -> PlayerCore {
        let pc = PlayerCore()
        playerCores.append(pc)
        pc.startMPV()
        playerCoreCounter += 1
        return pc
        }
        
        static func activeOrNewForMenuAction(isAlternative: Bool) -> PlayerCore {
        let useNew = Preference.bool(for: .alwaysOpenInNewWindow) != isAlternative
        return useNew ? newPlayerCore : active
        }
"""
        let expected = """
        static public var playing: [PlayerCore] {
        return playerCores.filter { !$0.info.isIdle }
        }
        
        static public var playerCores: [PlayerCore] = []
        static public var playerCoreCounter = 0
        
        static public func findIdlePlayerCore() -> PlayerCore? {
        return playerCores.first { $0.info.isIdle && !$0.info.fileLoading }
        }
        
        static public func createPlayerCore() -> PlayerCore {
        let pc = PlayerCore()
        playerCores.append(pc)
        pc.startMPV()
        playerCoreCounter += 1
        return pc
        }
        
        static public func activeOrNewForMenuAction(isAlternative: Bool) -> PlayerCore {
        let useNew = Preference.bool(for: .alwaysOpenInNewWindow) != isAlternative
        return useNew ? newPlayerCore : active
        }
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testIgnoreAvailableModifier() {
        let test = """
/// The static null JSON
@available(*, unavailable, renamed:"null")
private static var nullJSON: JSON { return null }
private static var null: JSON { return JSON(NSNull()) }
"""
        let expected = """
/// The static null JSON
@available(*, unavailable, renamed:"null")
public static var nullJSON: JSON { return null }
public static var null: JSON { return JSON(NSNull()) }
"""
        multilineTest(test: test, expected: expected)
    }

    func testObjcModifierIgnored() {
        let test = """
  @objc
  private func droppedText(_ pboard: NSPasteboard, userData:String, error: NSErrorPointer) {
    if let url = pboard.string(forType: .string) {
      openFileCalled = true
      PlayerCore.active.openURLString(url)
    }
  }
"""
        let expected = """
  @objc
  public func droppedText(_ pboard: NSPasteboard, userData:String, error: NSErrorPointer) {
    if let url = pboard.string(forType: .string) {
      openFileCalled = true
      PlayerCore.active.openURLString(url)
    }
  }
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testUnownedKeyword() {
        let test = """
unowned let player: PlayerCore
unowned(safe) let safeplayer: PlayerCore
unowned(unsafe) let unsafeplayer: PlayerCore
"""
        let expected = """
unowned public let player: PlayerCore
unowned(safe) public let safeplayer: PlayerCore
unowned(unsafe) public let unsafeplayer: PlayerCore
"""
        multilineTest(test: test, expected: expected)
    }

    func testMakeAPI() {
        let test = """
struct TestStruct {
    private let privateProperty = "Ooh la la"
    fileprivate let fileprivateProperty = "Not so secret"
    let property = "A bit hush hush"
    internal let property = "Exactly the same amount of hush"
    public let property "Open secret"
}
"""
        let expected = """
public struct TestStruct {
    private let privateProperty = "Ooh la la"
    fileprivate let fileprivateProperty = "Not so secret"
    public let property = "A bit hush hush"
    public let property = "Exactly the same amount of hush"
    public let property "Open secret"
}
"""
        multilineTest(test: test, expected: expected, accessChange: .makeAPI)
    }

    func testRemoveAPI() {
        let test = """
struct TestStruct {
    private let privateProperty = "Ooh la la"
    fileprivate let fileprivateProperty = "Not so secret"
    let property = "A bit hush hush"
    internal let property = "Exactly the same amount of hush"
    public let property "Open secret"
}
"""
        let expected = """
struct TestStruct {
    private let privateProperty = "Ooh la la"
    fileprivate let fileprivateProperty = "Not so secret"
    let property = "A bit hush hush"
    internal let property = "Exactly the same amount of hush"
    let property "Open secret"
}
"""
        multilineTest(test: test, expected: expected, accessChange: .removeAPI)
    }
    
    func testIncreaseAccess() {
        let test = """
struct TestStruct {
    private let privateProperty = "Ooh la la"
    fileprivate let fileprivateProperty = "Not so secret"
    let property = "A bit hush hush"
    internal let property = "Exactly the same amount of hush"
    public let property "Open secret"
}
"""
        let expected = """
public struct TestStruct {
    let privateProperty = "Ooh la la"
    let fileprivateProperty = "Not so secret"
    public let property = "A bit hush hush"
    public let property = "Exactly the same amount of hush"
    public let property "Open secret"
}
"""
        multilineTest(test: test, expected: expected, accessChange: .increaseAccess)
    }
    
    func testDecreaseAccess() {
        let test = """
struct TestStruct {
    private let privateProperty = "Ooh la la"
    fileprivate let fileprivateProperty = "Not so secret"
    let property = "A bit hush hush"
    internal let property = "Exactly the same amount of hush"
    public let property "Open secret"
}
"""
        let expected = """
private struct TestStruct {
    private let privateProperty = "Ooh la la"
    private let fileprivateProperty = "Not so secret"
    private let property = "A bit hush hush"
    private let property = "Exactly the same amount of hush"
    let property "Open secret"
}
"""
        multilineTest(test: test, expected: expected, accessChange: .decreaseAccess)
    }
    
    func testMakeAPIWithSpaces() {
        let test = """
    class ViewController: NSViewController {
    
    struct ThisShouldHaveBeenPublic {

        internal var foo: String?

    }
    
    
    
    
    }
"""
        let expected = """
    public class ViewController: NSViewController {
    
    public struct ThisShouldHaveBeenPublic {

        public var foo: String?

    }
    
    
    
    
    }
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testLocalScope() {
        
        let test = """
protocol TopLevelProtocol {
    func functionOne()
    var propertyOne: String { get set }
}

extension TopLevelProtocol {
    func newFunction() {
    }
    var extensionDefinedVariable: String {
        let hello = "hello"
        return hello
    }
}

struct TopLevelStruct {
    class ViewController: NSViewController {
        let topLevel = "Top level"
        struct InternalStruct {
            let internalProperty: String = {
                let localScope = "Internal"
                return localScope
            }()
            struct NestedStruct {
                let nested: String = {
                    let localScope = "Nested"
                    return localScope
                }()
                struct DoublyNestedStruct {
                    let double = "Double"
                }
            }
        }
    }
}

extension TopLevelStruct: Equatable {
    var extraProperty: String {
        let thing = "thing"
        return thing
    }
}

class ViewController: NSViewController {
    let topLevel = "Top level"
    struct InternalStruct {
        let internalProperty = "Internal"
        struct NestedStruct {
            let nested = "Nested"
            struct DoublyNestedStruct {
                let double = "Double"
            }
        }
    }
}

"""
        let expected = """
public protocol TopLevelProtocol {
    func functionOne()
    var propertyOne: String { get set }
}

public extension TopLevelProtocol {
    public func newFunction() {
    }
    public var extensionDefinedVariable: String {
        let hello = "hello"
        return hello
    }
}

public struct TopLevelStruct {
    public class ViewController: NSViewController {
        public let topLevel = "Top level"
        public struct InternalStruct {
            public let internalProperty: String = {
                let localScope = "Internal"
                return localScope
            }()
            public struct NestedStruct {
                public let nested: String = {
                    let localScope = "Nested"
                    return localScope
                }()
                public struct DoublyNestedStruct {
                    public let double = "Double"
                }
            }
        }
    }
}

extension TopLevelStruct: Equatable {
    public var extraProperty: String {
        let thing = "thing"
        return thing
    }
}

public class ViewController: NSViewController {
    public let topLevel = "Top level"
    public struct InternalStruct {
        public let internalProperty = "Internal"
        public struct NestedStruct {
            public let nested = "Nested"
            public struct DoublyNestedStruct {
                public let double = "Double"
            }
        }
    }
}

"""
        multilineTest(test: test, expected: expected, accessChange: .makeAPI)
    }
    
    func testForLoop() {
        let test = """
        for option in info {
            switch option {
            case .targetCache(let value): targetCache = value
"""
        let expected = """
        for option in info {
            switch option {
            case .targetCache(let value): targetCache = value
"""
        multilineTest(test: test, expected: expected)
    }
    
    
    
    func testFunctionAfterDiscardableResult() {
        let test = """
   @discardableResult
    func setImage(
        with resource: Resource?,
        for state: UIControl.State,
        placeholder: UIImage? = nil,
        options: KingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) -> DownloadTask?
    {
        return setImage(
            with: resource.map { Source.network($0) },
            for: state,
            placeholder: placeholder,
            options: options,
            progressBlock: progressBlock,
            completionHandler: completionHandler)
    }
"""
        let expected = """
   @discardableResult
    public func setImage(
        with resource: Resource?,
        for state: UIControl.State,
        placeholder: UIImage? = nil,
        options: KingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) -> DownloadTask?
    {
        return setImage(
            with: resource.map { Source.network($0) },
            for: state,
            placeholder: placeholder,
            options: options,
            progressBlock: progressBlock,
            completionHandler: completionHandler)
    }
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testConvenienceInit() {
        let test = """
extension NSBezierPath {
    convenience init(roundedRect rect: NSRect, topLeftRadius: CGFloat, topRightRadius: CGFloat,
                     bottomLeftRadius: CGFloat, bottomRightRadius: CGFloat)
    {
        self.init()
        
        let maxCorner = min(rect.width, rect.height) / 2
        
        let radiusTopLeft = min(maxCorner, max(0, topLeftRadius))
        let radiusTopRight = min(maxCorner, max(0, topRightRadius))
        let radiusBottomLeft = min(maxCorner, max(0, bottomLeftRadius))
        let radiusBottomRight = min(maxCorner, max(0, bottomRightRadius))
        
        guard !rect.isEmpty else {
            return
        }
        
        let topLeft = NSPoint(x: rect.minX, y: rect.maxY)
        let topRight = NSPoint(x: rect.maxX, y: rect.maxY)
        let bottomRight = NSPoint(x: rect.maxX, y: rect.minY)
        
        move(to: NSPoint(x: rect.midX, y: rect.maxY))
        appendArc(from: topLeft, to: rect.origin, radius: radiusTopLeft)
        appendArc(from: rect.origin, to: bottomRight, radius: radiusBottomLeft)
        appendArc(from: bottomRight, to: topRight, radius: radiusBottomRight)
        appendArc(from: topRight, to: topLeft, radius: radiusTopRight)
        close()
    }
"""
        let expected = """
public extension NSBezierPath {
    convenience public init(roundedRect rect: NSRect, topLeftRadius: CGFloat, topRightRadius: CGFloat,
                     bottomLeftRadius: CGFloat, bottomRightRadius: CGFloat)
    {
        self.init()
        
        let maxCorner = min(rect.width, rect.height) / 2
        
        let radiusTopLeft = min(maxCorner, max(0, topLeftRadius))
        let radiusTopRight = min(maxCorner, max(0, topRightRadius))
        let radiusBottomLeft = min(maxCorner, max(0, bottomLeftRadius))
        let radiusBottomRight = min(maxCorner, max(0, bottomRightRadius))
        
        guard !rect.isEmpty else {
            return
        }
        
        let topLeft = NSPoint(x: rect.minX, y: rect.maxY)
        let topRight = NSPoint(x: rect.maxX, y: rect.maxY)
        let bottomRight = NSPoint(x: rect.maxX, y: rect.minY)
        
        move(to: NSPoint(x: rect.midX, y: rect.maxY))
        appendArc(from: topLeft, to: rect.origin, radius: radiusTopLeft)
        appendArc(from: rect.origin, to: bottomRight, radius: radiusBottomLeft)
        appendArc(from: bottomRight, to: topRight, radius: radiusBottomRight)
        appendArc(from: topRight, to: topLeft, radius: radiusTopRight)
        close()
    }
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testConvenienceInitRecognizedAsAccessModifiable() {
        let test = """
private extension NSImage {
    // macOS does not support scale. This is just for code compatibility across platforms.
    private convenience init?(data: Data, scale: CGFloat) {
        self.init(data: data)
    }
}
"""
        let expected = """
public extension NSImage {
    // macOS does not support scale. This is just for code compatibility across platforms.
    public convenience init?(data: Data, scale: CGFloat) {
        self.init(data: data)
    }
}
"""
        multilineTest(test: test, expected: expected)
    }

    func testControlFlowStructures() {
        let test = """
while things.isEmpty {
            var forLocalProperty: String = "hello"
            func forLocalFunc() {
                var forEvenMoreLocalVar: String = "ooh ah mrs"
            }
        }
for thing in things {
            var forLocalProperty: String = "hello"
            func forLocalFunc() {
                var forEvenMoreLocalVar: String = "ooh ah mrs"
            }
        }
        
        repeat {
            var forLocalProperty: String = "hello"
            func forLocalFunc() {
                var forEvenMoreLocalVar: String = "ooh ah mrs"
            }
        } while things.isEmpty
        
        while things.isEmpty {
            var forLocalProperty: String = "hello"
            func forLocalFunc() {
                var forEvenMoreLocalVar: String = "ooh ah mrs"
            }
        }
"""
        let expected = """
while things.isEmpty {
            var forLocalProperty: String = "hello"
            func forLocalFunc() {
                var forEvenMoreLocalVar: String = "ooh ah mrs"
            }
        }
for thing in things {
            var forLocalProperty: String = "hello"
            func forLocalFunc() {
                var forEvenMoreLocalVar: String = "ooh ah mrs"
            }
        }
        
        repeat {
            var forLocalProperty: String = "hello"
            func forLocalFunc() {
                var forEvenMoreLocalVar: String = "ooh ah mrs"
            }
        } while things.isEmpty
        
        while things.isEmpty {
            var forLocalProperty: String = "hello"
            func forLocalFunc() {
                var forEvenMoreLocalVar: String = "ooh ah mrs"
            }
        }
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testTryAndErrorHandling() {
        let test = """
        try! doThis()
        try? doThat()
        do {
            try Int.init("1234")
            let localScope = "Local scope"
        } catch SpecificError
            return
        } catch {
            let localScope = "Local scope"
            fatalError()
        }
        throw
"""
        let expected = """
        try! doThis()
        try? doThat()
        do {
            try Int.init("1234")
            let localScope = "Local scope"
        } catch SpecificError
            return
        } catch {
            let localScope = "Local scope"
            fatalError()
        }
        throw
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testControlFlowKeywords() {
        let test = """
break
return
continue
fallthrough
"""
        let expected = """
break
return
continue
fallthrough
"""
        multilineTest(test: test, expected: expected)
    }

    func testDeferBlock() {
        let test = """
defer {
let localProperty = "local string"
}
"""
        let expected = """
defer {
let localProperty = "local string"
}
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testCompilerControlStatements() {
        let test = """
#if something
let localPropertyA = "Local"

#elseif somethingelse
let localPropertyB = "Local"

#else somethingelseentirely
let localPropertyC = "Local"

#endif

struct Thingie {
    
    init() {
        if #available(*, *) {
           let localPropertyD = "Local"
        } else {
           let localPropertyE = "Local"
        }
    }
    
}

"""
        let expected = """
#if something
public let localPropertyA = "Local"

#elseif somethingelse
public let localPropertyB = "Local"

#else somethingelseentirely
public let localPropertyC = "Local"

#endif

public struct Thingie {
    
    public init() {
        if #available(*, *) {
           let localPropertyD = "Local"
        } else {
           let localPropertyE = "Local"
        }
    }
    
}
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testSubscriptDefinition() {
        let test = """
subscript (Int) -> String {
    get {
        let localPropertyA = "Local"
    }
    set {
        let localPropertyB = "Local"
    }
}
"""
        let expected = """
public subscript (Int) -> String {
    get {
        let localPropertyA = "Local"
    }
    set {
        let localPropertyB = "Local"
    }
}
"""
        multilineTest(test: test, expected: expected)
    }

    func testOperatorDefinition() {
        let test = """
prefix operator NotAnEmojiPlease
postfix operator NotAnEmojiPlease
infix operator NotAnEmojiPlease: DefaultPrecendence
"""
        let expected = """
prefix operator NotAnEmojiPlease
postfix operator NotAnEmojiPlease
infix operator NotAnEmojiPlease: DefaultPrecendence
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testPrefixForOperatorFunctionDefinitions() {
        let test = """
prefix operator ^
prefix func ^ <Root, Value>(_ kp: KeyPath<Root, Value>) -> (Root) -> Value {
    return get(kp)
}
"""

        let expected = """
prefix operator ^
public prefix func ^ <Root, Value>(_ kp: KeyPath<Root, Value>) -> (Root) -> Value {
    return get(kp)
}
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testPrecedenceGroupDefinition() {
        let test = """
precedencegroup SpecialPrecedence {
    higherThan: TernaryPrecedence
    lowerThan: DefaultPrecedence
    associativity: right
    assignment: true
}
"""
        let expected = """
precedencegroup SpecialPrecedence {
    higherThan: TernaryPrecedence
    lowerThan: DefaultPrecedence
    associativity: right
    assignment: true
}
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testMoreModifiers() {
        let test = """
class ViewController: NSViewController {
@objc dynamic let things: [String] = []
final class MyFinalClass {
let internalProperty: String = "Hello world!"
}
lazy var internalLazyThing: String = "Hello"
weak var internalWeakLazyThing: NSNumber? = NSNumber(value: 50)
override func viewDidLoad() {
super.viewDidLoad()
}
}
"""
        let expected = """
public class ViewController: NSViewController {
@objc public dynamic let things: [String] = []
public final class MyFinalClass {
public let internalProperty: String = "Hello world!"
}
public lazy var internalLazyThing: String = "Hello"
public weak var internalWeakLazyThing: NSNumber? = NSNumber(value: 50)
public override func viewDidLoad() {
super.viewDidLoad()
}
}
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testOpenToPublic() {
        let test = """
open class ViewController: NSViewController {
    
    @objc open dynamic let things: [String] = []
    
    open class MyFinalClass {
        let internalProperty: String = "Hello world!"
    }
    
    open lazy var internalLazyThing: String = "Hello"
    
    open weak var internalWeakLazyThing: NSNumber? = NSNumber(value: 50)
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
}
"""
        let expected = """
public class ViewController: NSViewController {
    
    @objc public dynamic let things: [String] = []
    
    public class MyFinalClass {
        public let internalProperty: String = "Hello world!"
    }
    
    public lazy var internalLazyThing: String = "Hello"
    
    public weak var internalWeakLazyThing: NSNumber? = NSNumber(value: 50)
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
}
"""
        multilineTest(test: test, expected: expected)
    }
    
    func testMakeAPIInEntityWithLowerThanInternalAccessShouldFail() {
        let test = """
private extension Human {
    func callForServiceA() {
        // tbd
    }
}
fileprivate extension Human {
    func callForServiceB() {
        // tbd
    }
}
extension Human {
    func callForServiceC() {
        // tbd
    }
}
public extension Human {
    func callForServiceD() {
        // tbd
    }
}
"""
        let expected = """
private extension Human {
    func callForServiceA() {
        // tbd
    }
}
fileprivate extension Human {
    func callForServiceB() {
        // tbd
    }
}
public extension Human {
    public func callForServiceC() {
        // tbd
    }
}
public extension Human {
    public func callForServiceD() {
        // tbd
    }
}
"""
        multilineTest(test: test, expected: expected, accessChange: .makeAPI)
    }
    
    func testRemoveAPIInEntityWithLowerThanInternalAccessShouldFail() {
        let test = """
private extension Human {
    func callForServiceA() {
        // tbd
    }
}
fileprivate extension Human {
    func callForServiceB() {
        // tbd
    }
}
extension Human {
    public func callForServiceC() {
        // tbd
    }
}
public extension Human {
    func callForServiceD() {
        // tbd
    }
}
public extension Human {
    public func callForServiceD() {
        // tbd
    }
}
"""
        let expected = """
private extension Human {
    func callForServiceA() {
        // tbd
    }
}
fileprivate extension Human {
    func callForServiceB() {
        // tbd
    }
}
extension Human {
    func callForServiceC() {
        // tbd
    }
}
extension Human {
    func callForServiceD() {
        // tbd
    }
}
extension Human {
    func callForServiceD() {
        // tbd
    }
}
"""
        multilineTest(test: test, expected: expected, accessChange: .removeAPI)
    }
    
func testIncrementInEntityWithLowerThanInternalImplicitAccessShouldFail() {
        let test = """
private extension Human {
    func implicitPrivate() {
        // tbd
    }
}
fileprivate extension Human {
    func implicitFilePrivate() {
        // tbd
    }
}
extension Human {
    func callForServiceC() {
        // tbd
    }
}
public extension Human {
    func implicitPublic() {
        // tbd
    }
}
"""
        let expected = """
extension Human {
    func implicitPrivate() {
        // tbd
    }
}
extension Human {
    func implicitFilePrivate() {
        // tbd
    }
}
public extension Human {
    public func callForServiceC() {
        // tbd
    }
}
public extension Human {
    public func implicitPublic() {
        // tbd
    }
}
"""
        multilineTest(test: test, expected: expected, accessChange: .increaseAccess)
    }
    
    
    func testSubscriptSetterIncrement() {
        
        // Increments underlying property; leaves setter alone
        
        let test = """
private(set) subscript (Int) -> String {
    get {
        let localPropertyA = "Local"
    }
    set {
        let localPropertyB = "Local"
    }
}
"""
        let expected = """
private(set) public subscript (Int) -> String {
    get {
        let localPropertyA = "Local"
    }
    set {
        let localPropertyB = "Local"
    }
}
"""
        multilineTest(test: test, expected: expected, accessChange: .increaseAccess)
    }
    
    // Decrements underlying property
    // coalesces with setter if appropriate
    // otherwise leaves as is: 
    
    func testSubscriptSetterDecrement() {
        let test = """
internal(set) public subscript (Int) -> String {
    get {
        let localPropertyA = "Local"
    }
    set {
        let localPropertyB = "Local"
    }
}
"""
        let expected = """
subscript (Int) -> String {
    get {
        let localPropertyA = "Local"
    }
    set {
        let localPropertyB = "Local"
    }
}
"""
        multilineTest(test: test, expected: expected, accessChange: .decreaseAccess)
    }

    func testSubscriptSetterMakeAPI() {
        let test = """
internal(set) subscript (Int) -> String {
    get {
        let localPropertyA = "Local"
    }
    set {
        let localPropertyB = "Local"
    }
}
private(set) internal subscript (Int) -> String {
    get {
        let localPropertyA = "Local"
    }
    set {
        let localPropertyB = "Local"
    }
}
"""
        let expected = """
internal(set) public subscript (Int) -> String {
    get {
        let localPropertyA = "Local"
    }
    set {
        let localPropertyB = "Local"
    }
}
private(set) public subscript (Int) -> String {
    get {
        let localPropertyA = "Local"
    }
    set {
        let localPropertyB = "Local"
    }
}
"""
        multilineTest(test: test, expected: expected, accessChange: .makeAPI)
    }
    
    func testSubscriptSetterRemoveAPI() {
        let test = """
internal(set) public subscript (Int) -> String {
    get {
        let localPropertyA = "Local"
    }
    set {
        let localPropertyB = "Local"
    }
}
"""
        let expected = """
subscript (Int) -> String {
    get {
        let localPropertyA = "Local"
    }
    set {
        let localPropertyB = "Local"
    }
}
"""
        multilineTest(test: test, expected: expected, accessChange: .removeAPI)
    }
    
    func testSubscriptSetterSetAllToPublic() {
        let test = """
private(set) internal subscript (Int) -> String {
    get {
        let localPropertyA = "Local"
    }
    set {
        let localPropertyB = "Local"
    }
}
"""
        let expected = """
public subscript (Int) -> String {
    get {
        let localPropertyA = "Local"
    }
    set {
        let localPropertyB = "Local"
    }
}
"""
        multilineTest(test: test, expected: expected, accessChange: .singleLevel(.public))
    }
  
    
    // Incrementing access :
    
    // increment the underlying property
    // leave the setter alone
    
    
    func testVarSetterIncrement() {
        let test = """
private(set) var example: String {
get {
return "An example"
}
set {
example = newValue
}

}
private(set) fileprivate var exampleA: String = "A"
private(set) internal var exampleB: String = "B"
private(set) var exampleC: String = "C"
private(set) public var exampleD: String = "D"

fileprivate(set) var exampleE: String = "E"
fileprivate(set) internal var exampleF: String = "F"
fileprivate(set) public var exampleG: String = "G"

internal(set) public var exampleH: String = "H"
"""
        let expected = """
private(set) public var example: String {
get {
return "An example"
}
set {
example = newValue
}

}
private(set) var exampleA: String = "A"
private(set) public var exampleB: String = "B"
private(set) public var exampleC: String = "C"
private(set) public var exampleD: String = "D"

fileprivate(set) public var exampleE: String = "E"
fileprivate(set) public var exampleF: String = "F"
fileprivate(set) public var exampleG: String = "G"

internal(set) public var exampleH: String = "H"
"""
        multilineTest(test: test, expected: expected, accessChange: .increaseAccess)
    }
    
    // Decrementing access :
    
    // Decrease the underlying property
    // Coalesce the setter if the setter and property end up the same
    // Otherwise leave as is

    func testVarSetterDecrement() {
        let test = """
private(set) var example: String {
get {
return "An example"
}
set {
example = newValue
}

}
private(set) fileprivate var exampleA: String = "A"
private(set) internal var exampleB: String = "B"
private(set) var exampleC: String = "C"
private(set) public var exampleD: String = "D"

fileprivate(set) var exampleE: String = "E"
fileprivate(set) internal var exampleF: String = "F"
fileprivate(set) public var exampleG: String = "G"

internal(set) public var exampleH: String = "H"
"""
        let expected = """
private var example: String {
get {
return "An example"
}
set {
example = newValue
}

}
private var exampleA: String = "A"
private var exampleB: String = "B"
private var exampleC: String = "C"
private(set) var exampleD: String = "D"

private var exampleE: String = "E"
private var exampleF: String = "F"
fileprivate(set) var exampleG: String = "G"

var exampleH: String = "H"
"""
        multilineTest(test: test, expected: expected, accessChange: .decreaseAccess)
    }

    func testVarSetterMakeAPI() {
        let test = """
private(set) var example: String {
    return "An example"
}
private(set) fileprivate var example: String = "A"
private(set) internal var example: String = "B"
private(set) var example: String = "C"
private(set) public var example: String = "D"

fileprivate(set) var example: String = "E"
fileprivate(set) internal var example: String = "F"
fileprivate(set) public var example: String = "G"

internal(set) public var example: String = "A"
"""
        let expected = """
private(set) public var example: String {
    return "An example"
}
private(set) fileprivate var example: String = "A"
private(set) public var example: String = "B"
private(set) public var example: String = "C"
private(set) public var example: String = "D"

fileprivate(set) public var example: String = "E"
fileprivate(set) public var example: String = "F"
fileprivate(set) public var example: String = "G"

internal(set) public var example: String = "A"
"""
        multilineTest(test: test, expected: expected, accessChange: .makeAPI)
    }
 
    func testVarSetterRemoveAPI() {
        let test = """
private(set) var example: String {
    return "An example"
}
private(set) fileprivate var example: String = "A"
private(set) internal var example: String = "B"
private(set) var example: String = "C"
private(set) public var example: String = "D"

fileprivate(set) var example: String = "E"
fileprivate(set) internal var example: String = "F"
fileprivate(set) public var example: String = "G"

internal(set) public var example: String = "A"
"""
        let expected = """
private(set) var example: String {
    return "An example"
}
private(set) fileprivate var example: String = "A"
private(set) internal var example: String = "B"
private(set) var example: String = "C"
private(set) var example: String = "D"

fileprivate(set) var example: String = "E"
fileprivate(set) internal var example: String = "F"
fileprivate(set) var example: String = "G"

var example: String = "A"
"""
        multilineTest(test: test, expected: expected, accessChange: .removeAPI)
    }

    func testVarSetterAllPrivate() {
        let test = """
private(set) var example: String {
    return "An example"
}
private(set) fileprivate var example: String = "A"
private(set) internal var example: String = "B"
private(set) var example: String = "C"
private(set) public var example: String = "D"

fileprivate(set) var example: String = "E"
fileprivate(set) internal var example: String = "F"
fileprivate(set) public var example: String = "G"

internal(set) public var example: String = "A"
"""
        let expected = """
private var example: String {
    return "An example"
}
private var example: String = "A"
private var example: String = "B"
private var example: String = "C"
private var example: String = "D"

private var example: String = "E"
private var example: String = "F"
private var example: String = "G"

private var example: String = "A"
"""
        multilineTest(test: test, expected: expected, accessChange: .singleLevel(.private))
    }
    
    func testStaticVariableInheritanceInPublicExtension() {
        let test = """
// Base type is public
public struct MyStruct {}

// Here, the extension is declared public, so each top level member
// "inherits" that access level.
public extension MyStruct {
    // This is public even if it is not annotated
    static var firstValue: String { return "public" }
    
    // This is also public but the compiler will warn.
    public static var secondValue: String { return "public but warned" }
    
    // This class is also public via "inheritance"
    class PublicSubclass {
        // However, its members must be annotated. This is public
        public static let publicValue = "public"
        // This defaults to internal
        static let internalValue = "internal"
    }
}
"""
        let expected = """
// Base type is public
struct MyStruct {}

// Here, the extension is declared public, so each top level member
// "inherits" that access level.
extension MyStruct {
    // This is public even if it is not annotated
    static var firstValue: String { return "public" }
    
    // This is also public but the compiler will warn.
    static var secondValue: String { return "public but warned" }
    
    // This class is also public via "inheritance"
    class PublicSubclass {
        // However, its members must be annotated. This is public
        static let publicValue = "public"
        // This defaults to internal
        static let internalValue = "internal"
    }
}
"""
        multilineTest(test: test, expected: expected, accessChange: .decreaseAccess)
    }
    
    func testPublicExtensionInheritance() {
  
// MAKE LINES 2 && 5 PUBLIC

let test =
"""
public struct PublicStruct {}
public extension PublicStruct {
static var first: String { return "Implicit public" }
public static var second: String { return "Explicit public" }
class PublicSubclass {
static var subfirst: String { return "Internal" }
public static var subsecond: String { return "Public" }
}
}
"""

let expectedPublic =
"""
public struct PublicStruct {}
public extension PublicStruct {
static var first: String { return "Implicit public" }
public static var second: String { return "Explicit public" }
class PublicSubclass {
public static var subfirst: String { return "Internal" }
public static var subsecond: String { return "Public" }
}
}
"""
         multilineTest(test: test, expected: expectedPublic, linesToChange: [2, 5], accessChange: .singleLevel(.public))
}
 /*
 MAKE INTERNAL
 public struct PublicStruct {}
 public extension PublicStruct {
 internal static var first: String { return "Implicit public" }
 public static var second: String { return "Explicit public" }
 class PublicSubclass {
 static var subfirst: String { return "Internal" }
 public static var subsecond: String { return "Public" }
 }
 }
 
 MAKE API
 public struct PublicStruct {}
 public extension PublicStruct {
 static var first: String { return "Implicit public" }
 public static var second: String { return "Explicit public" }
 class PublicSubclass {
 public static var subfirst: String { return "Internal" }
 public static var subsecond: String { return "Public" }
 }
 }
 
 REMOVE API
 public struct PublicStruct {}
 public extension PublicStruct {
 internal static var first: String { return "Implicit public" }
 public static var second: String { return "Explicit public" }
 class PublicSubclass {
 static var subfirst: String { return "Internal" }
 public static var subsecond: String { return "Public" }
 }
 }
 */
    
 
 
    func testChangeOnlySelectedLines() {
            let test = """
open class ViewController: NSViewController {
@objc open dynamic let things: [String] = []
open class MyFinalClass {
let internalProperty: String = "Hello world!"
}
open lazy var internalLazyThing: String = "Hello"
open weak var internalWeakLazyThing: NSNumber? = NSNumber(value: 50)
open override func viewDidLoad() {
super.viewDidLoad()
}
}
"""
        let expected = """
public class ViewController: NSViewController {
@objc open dynamic let things: [String] = []
public class MyFinalClass {
let internalProperty: String = "Hello world!"
}
open lazy var internalLazyThing: String = "Hello"
public weak var internalWeakLazyThing: NSNumber? = NSNumber(value: 50)
open override func viewDidLoad() {
super.viewDidLoad()
}
}
"""
            multilineTest(test: test, expected: expected, linesToChange: [0,2,6])
        }
        
    
    
    
    func testSomething() {
        let test = """

"""
        let expected = """

"""
        multilineTest(test: test, expected: expected)
    }
    
    
    func multilineTest(test: String, expected: String, linesToChange: [Int]? = nil, accessChange: AccessChange = .singleLevel(.public), file: StaticString = #file, line: UInt = #line) {

        let lines = test.components(separatedBy: .newlines)
        let changing = linesToChange ?? Array(0..<lines.count)

        let expectedLines = expected.components(separatedBy: .newlines)
        let parser = Parser(lines: lines)
        let parsedLines = parser.newLines(at: changing, accessChange: accessChange)
        for (index, expectedline) in expectedLines.enumerated() {
            if expectedline != lines[index] {
                // Parsed line should exist if the expected line is different
                XCTAssertNotNil(parsedLines[index], "Line \(index) incorrectly ignored (\"\(lines[index])\")", file: file, line: line)
            }
            if let parsedLine = parsedLines[index] {
                XCTAssertEqual(parsedLine, expectedline, "Line no.: \(index) \(lines[index]) was incorrectly parsed", file: file, line: line)
            }
        }
    }
}



