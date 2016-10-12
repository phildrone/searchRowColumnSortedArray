//: Playground - noun: a place where people can play

import UIKit
import XCTest

/*
    In an interview yesterday I got asked a great algorithms
    question. Efficiently search an array which is sorted
    such that each row increases across and each colunm
    increased down
 
        [ a11 < a12 < a13 ... < a1m ]
        [  ᴧ     ᴧ               ᴧ  ]
        [ a21 < a22 <  ....   < a2m ]
        [  .     .               .  ]
        [  .     .               .  ]
        [  ᴧ     ᴧ     ....      ᴧ  ]
        [ an1 < an2 <  ....   < anm ]
 

    My first thought was, to do a binary search across the
    first row, and lop off all of the trailing rows that were
    > than our search target. And then do a binary search down
    the column and lop off any rows and then do a recursive ...
    yeah, that doesn't work. Oops. :)
 
    After lots of fumbling around, the solution was more or less spoon
    fed to me by my interviewer: start at either a_n1 or a_1m
    (the lower left or upper right). If you start at say a_n1, the 
    lower left, walk upwards by 1 until you hit an entry smaller than
    your target, then pivot to the next column and repeat the
    process until you run out of stuff to search or find your target.
    O(n+m) operations.
 
    Which is really cool, but I still think a binary search might be
    effective here. If we used binary search on the column instead of
    walking up. We essentially get O(log(n) + m) on average
    Which is really good for a really large matrix. That said, the worse
    case where you pivot to the next column one row up every column is
    O(log(n!) + m).
 
    My little array test cases all do worse, but I think if we fed it
    a really large one, it would improve.
 
    UPDATE: I added a more swift-ish solution. Which I thought might be
    smaller (codewise), but it didn't turn out that much smaller (see: searchArraySwift)
    For this solution I pulled out binarySearch, as well as a column routine
    and extended them to array. This has the added advantage of doing a binary search
    up the first column initially, but after that we advance up the column by
    1 like in the other solutions. There's no point to advancing other columns
    by binary search, at least the way I implemented it, since we need to check
    the adjacent column to see if it too is larger than our target.
 */

func searchArrayInc<Element:Comparable>(_ target:Element, in array:[[Element]]) -> Element? {
    let n = array.count
    if (n == 0) { return nil }
    let m = array[0].count
    if (m == 0) { return nil }
    
    // reality checks, target must be between the 0,0 and n,m values
    if (target < array[0][0]) { return nil }
    if (target > array[n-1][m-1]) { return nil }
    
    var i:Int = n-1, j:Int = 0
    var steps:Int = 0
    while ( i >= 0 && i < n && j >= 0 && j < m ) {
        steps += 1
        print("\(i),\(j) : \(array[i][j])")
        // if it's larger come up the column
        if ( array[i][j] == target ) {
            print("Found \(array[i][j]) in \(steps) steps")
            return array[i][j]
        } else if ( array[i][j] > target ) {
            i -= 1 // progress up the column
        } else {
            j += 1 // pivot
        }
    }
    print("Wahh wahh, not found in \(steps) steps")
    return nil
}


// the binary search would normally be pulled out
// into a separate routine, but I'll keep everything
// together for the playground.
func searchArrayBinary<Element:Comparable>(_ target:Element, in array:[[Element]]) -> Element? {
    let n = array.count
    print(n)
    if (n == 0) { return nil }
    let m = array[0].count
    print(m)
    if (m == 0) { return nil }
    
    // reality checks, target must be between the 0,0 and n,m values
    if (target < array[0][0]) { return nil }
    if (target > array[n-1][m-1]) { return nil }
    
    var i:Int = n-1, j:Int = 0
    var steps:Int = 0
    while ( i >= 0 && i < n && j >= 0 && j < m ) {
        steps += 1
        print("\(i),\(j) : \(array[i][j])")
        if array[i][j] == target {
            print("Found \(array[i][j]) in \(steps) steps")
            return array[i][j]

        // if it's larger come up the column
        } else if array[i][j] > target {
            // binary search won't work for i=1, since there's only 1 element remaining.
            if (i <= 1) {
                i -= 1
                continue
            }
            // binary search
            var start:Int = 0, end = i-1, k = i-1, kOver = i
            while(start < end) {
                steps += 1
                k = (start + end)/2
                print("start, end: \(start),\(end),\(k)")
                if array[k][j] == target {
                    print("Found \(array[k][j]) in \(steps) steps")
                    return array[k][j]
                } else if array[k][j] > target {
                    end = k - 1
                    kOver = k
                } else {
                    start = k + 1
                }
                //print("POST start, end: \(start),\(end),\(kOver)")
            }
            i = kOver-1 // progress up the column
        } else {
            j += 1 // pivot
        }
    }
    print("Wahh wahh, not found in \(steps) steps")
    return nil
}


// Lastly lets try and solve this via a little more Swift-like approach.
// The above is more or less something you could almost write in C

// what I want to do is use functional programming's suite of functions
// as much as possible. This means operating on rows and columns. And unfortunatey
// there's no way to access a column cleanly in swift (it's not contiguous memory
// so I think they're trying to tell me something, but we'll forge on).
// So, sadly this array[0..<array.count][1] does not work, it just returns the first
// row.
//
// We'll extend array to add both a binary search and a column accessor.
extension Array where Element:Collection {
    public func column(_ position:Element.Index) -> [Element.Iterator.Element] {
        return self.map { $0[position] }
    }
}

// this returns either element or the index of the element that is the next smaller
extension Array where Element:Comparable {
    
    // binary search
    func searchBinary(_ target:Element) -> Index {
        //print("----")
        var start:Index = 0, end = count-1, k = end, kOver = count
        var steps:Int = 1
        while(start <= end) {
            k = (start + end)/2
            //print("start, end: \(start),\(end),\(k)")
            if self[k] == target {
                //print("Found \(self[k]) in \(steps) steps")
                return k
            } else if self[k] > target {
                end = k - 1
                kOver = k
            } else {
                start = k + 1
            }
            //print("POST start, end: \(start),\(end),\(kOver)")
            steps += 1
        }
        return kOver-1 < 0 ? 0 : kOver-1
    }
}

//
// Now we'll try binary searching in both directions. The first step will be to slice off
// excess rows and columns which are beyond our target by binary searching on the first row
// and column. Then we will alternately search rows and columns as above.
func searchArraySwift<Element:Comparable>(_ target:Element, in array:Array<Array<Element>>) -> Element? {
    let rowMax = array.count
    if (rowMax == 0) { return nil }
    let colMax = array[0].count
    if (colMax == 0) { return nil }

    // reality checks, target must be between the 0,0 and n,m values
    if (target < array[0][0]) { return nil }
    if (target > array[rowMax-1][colMax-1]) { return nil }
    
    print("\(rowMax),\(colMax) max")
    
    var i:Int, j:Int = 0
    var steps:Int = 0
    
    // binary search up the first column to find the starting
    // point.
    let col = array.column(0)[0..<rowMax]
    // need to figure out how to extend both Array and ArraySlice
    // but for now this'll do
    i = Array(col).searchBinary(target)
    while ( i >= 0 && i < rowMax && j >= 0 && j < colMax ) {
        steps += 1
        print("\(i),\(j) : \(array[i][j])")
        if array[i][j] == target {
            print("Found \(array[i][j]) in \(steps) steps")
            return array[i][j]
            
        // if it's larger or the next value in the row is larger so we can't advance
        // down the row, come up the column,
        } else if array[i][j] > target || (j+1 < colMax && array[i][j+1] > target) {
            i -= 1
        // if it's smaller look down the row
        } else if j+1 < colMax {
            let jtmp = Array(array[i][j+1...colMax-1]).searchBinary(target)
            print("\(j) + \(jtmp) + 1")
            j += jtmp + 1
        } else {
            j += 1
        }
        //print("POST \(i),\(j) : \(array[i][j])")
    }
    print("Wahh wahh, not found in \(steps) steps")
    return nil
}

// end


let a = [[ 10, 20, 21, 30, 40, 41],
         [ 11, 21, 22, 35, 50, 51],
         [ 50, 60, 61, 63, 70, 71],
         [ 51, 61, 80, 81, 82, 83],
         [ 52, 62, 90, 91, 98, 99]]
let x63I = searchArrayInc(63, in:a)
let x63B = searchArrayBinary(63, in:a)
let x63S = searchArraySwift(63, in:a)

// This was kind of an interesting case to see if I could get XCTestCases working in
// a playground but in practice, the testrunner not displaying a failure next
// to the test case is sort of underwhelming. Doing vanilla asserts is probably more
// productive?
//
class MyTests : XCTestCase {
    let smallExampleMatrix = [[ 10, 20, 21, 30, 40, 41],
                              [ 11, 21, 22, 35, 50, 51],
                              [ 50, 60, 61, 63, 70, 71],
                              [ 51, 61, 80, 81, 82, 83],
                              [ 52, 62, 90, 91, 98, 99]]

    override func setUp() {
    }
    
    func testBeyondBounds() {
        XCTAssertNil(searchArrayInc(1, in: smallExampleMatrix))
        XCTAssertNil(searchArrayBinary(1, in: smallExampleMatrix))
        XCTAssertNil(searchArraySwift(1, in: smallExampleMatrix))
        XCTAssertNil(searchArrayInc(100, in: smallExampleMatrix))
        XCTAssertNil(searchArrayBinary(100, in: smallExampleMatrix))
        XCTAssertNil(searchArraySwift(100, in: smallExampleMatrix))
    }
    
    func testArrayForSimpleRow() {
        let a = [[ 1, 2, 3, 4, 5]]
        XCTAssertEqual(searchArrayInc(3, in: a), 3)
        XCTAssertEqual(searchArrayBinary(3, in: a), 3)
        XCTAssertEqual(searchArraySwift(3, in: a), 3)
        XCTAssertNil(searchArrayInc(100, in: a))
        XCTAssertNil(searchArrayBinary(100, in: a))
        XCTAssertNil(searchArraySwift(100, in: a))
    }
    
    func testArrayForSimpleColumn() {
        let a = [[ 1 ],[ 2 ],[ 3 ],[ 4 ],[ 5 ]]
        var x = searchArrayInc(3, in: a)
        XCTAssertEqual(x, 3)
        x = searchArrayBinary(3, in: a)
        XCTAssertEqual(x, 3)
        x = searchArraySwift(3, in: a)
        XCTAssertEqual(x, 3)
        XCTAssertNil(searchArrayInc(100, in: a))
        XCTAssertNil(searchArrayBinary(100, in: a))
        XCTAssertNil(searchArraySwift(100, in: a))
    }
    
    func testArraySmall() {
        var x = searchArrayInc(63, in:smallExampleMatrix)
        XCTAssertEqual(x, 63)
        x = searchArrayBinary(63, in:smallExampleMatrix)
        XCTAssertEqual(x, 63)
        x = searchArraySwift(63, in:smallExampleMatrix)
        XCTAssertEqual(x, 63)
        
        x = searchArrayInc(75, in:smallExampleMatrix)
        XCTAssertNil(x)
        x = searchArrayBinary(75, in:smallExampleMatrix)
        XCTAssertNil(x)
        x = searchArraySwift(75, in:smallExampleMatrix)
        XCTAssertNil(x)
        
        x = searchArrayInc(40, in:smallExampleMatrix)
        XCTAssertEqual(x, 40)
        x = searchArrayBinary(40, in:smallExampleMatrix)
        XCTAssertEqual(x, 40)
        x = searchArraySwift(40, in:smallExampleMatrix)
        XCTAssertEqual(x, 40)
        
        x = searchArrayInc(83, in: smallExampleMatrix)
        XCTAssertEqual(x, 83)
        x = searchArrayBinary(83, in: smallExampleMatrix)
        XCTAssertEqual(x, 83)
        x = searchArraySwift(83, in: smallExampleMatrix)
        XCTAssertEqual(x, 83)
        
        let upperLeftI = searchArrayInc(10, in: smallExampleMatrix)
        XCTAssertEqual(upperLeftI, 10)
        let upperLeftB = searchArrayBinary(10, in:smallExampleMatrix)
        XCTAssertEqual(upperLeftB, 10)
        let upperLeftS = searchArraySwift(10, in:smallExampleMatrix)
        XCTAssertEqual(upperLeftS, 10)
        
        let upperRightI = searchArrayInc(41, in: smallExampleMatrix)
        XCTAssertEqual(upperRightI, 41)
        let upperRightB = searchArrayBinary(41, in: smallExampleMatrix)
        XCTAssertEqual(upperRightB, 41)
        let upperRightS = searchArraySwift(41, in: smallExampleMatrix)
        XCTAssertEqual(upperRightS, 41)
        
        let lowerRightI = searchArrayInc(99, in: smallExampleMatrix)
        XCTAssertEqual(lowerRightI, 99)
        let lowerRightB = searchArrayBinary(99, in: smallExampleMatrix)
        XCTAssertEqual(lowerRightB, 99)
        let lowerRightS = searchArraySwift(99, in: smallExampleMatrix)
        XCTAssertEqual(lowerRightS, 99)
    }
    
    override func tearDown() {
    }
}


// XCTest code inside playgrounds is a little awkward and requires
// some scaffolding
//
// This is a modified, updated version from:
//  http://initwithstyle.net/2015/11/tdd-in-swift-playgrounds/
//
class PlaygroundTestObserver : NSObject, XCTestObservation {
    @objc func testCase(_ testCase:XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        print("Test failed on line \(lineNumber): \(testCase.name), \(description)")
    }
}

let observer = PlaygroundTestObserver()
let center = XCTestObservationCenter.shared()
center.addTestObserver(observer)

struct TestRunner {
    
    func run(_ testClass:AnyClass) {
        print("Running test suite \(testClass)")
        let tests = testClass as! XCTestCase.Type
        let testSuite = tests.defaultTestSuite()
        testSuite.run()
        let run = testSuite.testRun as! XCTestSuiteRun
        
        print("Ran \(run.executionCount) tests in \(run.testDuration)s with \(run.totalFailureCount) failures")
    }
    
}

TestRunner().run(MyTests.self)
//: [Next](@next)
