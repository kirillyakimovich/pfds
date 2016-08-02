// Lists

import XCTest

// http://initwithstyle.net/2015/11/tdd-in-swift-playgrounds/
class PlaygroundTestObserver : NSObject, XCTestObservation {
    @objc func testCase(testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        print("Test failed on line \(lineNumber): \(testCase.name), \(description)")
    }
}

let observer = PlaygroundTestObserver()
let center = XCTestObservationCenter.sharedTestObservationCenter()
center.addTestObserver(observer)

struct TestRunner {
    func runTests(testClass: AnyClass) {
        print("Running test suite \(testClass)")
        
        let tests = testClass as! XCTestCase.Type
        let testSuite = tests.defaultTestSuite()
        testSuite.runTest()
        let run = testSuite.testRun as! XCTestSuiteRun
        
        print("Ran \(run.executionCount) tests in \(run.testDuration)s with \(run.totalFailureCount) failures")
    }
}

class ListTests: XCTestCase {
    func testShouldFail() {
        XCTFail()
    }
}

TestRunner().runTests(ListTests)

enum ListError: ErrorType {
    case Empty
    case Subscript
}

enum List<Element> {
    case empty
    indirect case cons(Element, List<Element>)
    
    init() { self = .empty }
}

extension List: CustomStringConvertible {
    var description: String {
        switch self {
        case .empty:
            return "[]"
        case let .cons(x, xs):
            return "\(x) : \(xs.description)"
        }
    }
}

extension List: ArrayLiteralConvertible {
    init(arrayLiteral elements:Element...) {
        var list = empty
        for element in elements.reverse() {
            list = cons(element, list)
            print(element)
        }
        self = list
    }
}

List(arrayLiteral: 1, 2, 3)

func empty<Element>() -> List<Element> {
    return .empty
}

func isEmpty<Element>(l: List<Element>) -> Bool {
    switch l {
    case .empty:
        return true
    case .cons(_, _):
        return false
    }
}

func cons<Element>(head: Element, tail: List<Element>) -> List<Element> {
    return .cons(head, tail)
}

func head<Element>(l: List<Element>) throws -> Element {
    switch l {
    case .empty:
        throw ListError.Empty
    case let .cons(value, _):
        return value;
    }
}

func tail<Element>(l: List<Element>) throws -> List<Element> {
    switch l {
    case .empty:
        throw ListError.Empty
    case let .cons(_, tail):
        return tail
    }
}

func concat<Element>(xs: List<Element>, ys: List<Element>) -> List<Element> {
    switch xs {
    case .empty:
        return ys
    case let .cons(x, xs):
        return cons(x, tail: concat(xs, ys: ys))
    }
}

func update<Element>(list: List<Element>, index: Int, value: Element) throws -> List<Element> {
    switch list {
    case .empty:
        throw ListError.Subscript
    case let .cons(x, xs):
        if index == 0 {
            return .cons(value, xs)
        } else {
            do {
                return try .cons(x, update(xs, index: index - 1, value: value))
            }
        }
    }
}

infix operator ++ { associativity left precedence 140 }
func ++<Element> (left: List<Element>, right: List<Element>) -> List<Element> {
    switch left {
    case .empty:
        return right
    case let .cons(x, xs):
        return cons(x, tail: xs ++ right)
    }
}

func ==<Element: Equatable> (left: List<Element>, right: List<Element>) -> Bool {
    switch (left, right) {
    case (.empty, .empty):
        return true
    case let (.cons(x, xs), .cons(y, ys)):
        if x == y {
            return xs == ys
        } else {
            return false
        }
    default:
        return false
    }
}

func suffixes<Element>(xs: List<Element>) -> List<List<Element>> {
    return empty()
}

let l: List<Int> = empty()
isEmpty(l)
isEmpty(l)

do {
    try  head(l)
} catch {
    print("thrown")
}

let shortList = cons(13, tail: empty())
let longList = cons(10, tail: cons(7, tail: cons(15, tail: empty())))
let newList = concat(shortList, ys:longList)
let oneMoreList = concat(longList, ys: shortList)
let anotherList = shortList ++ longList
let updatedList = try! update(longList, index: 0, value: 143)

