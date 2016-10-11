//: Playground - noun: a place where people can play

import UIKit

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
        // if it's larger come up the column
        if array[i][j] == target {
            print("Found \(array[i][j]) in \(steps) steps")
            return array[i][j]
        } else if array[i][j] > target {
            // binary search won't work for i=1, since there's only 1 element remaining.
            if (i <= 1) {
                i -= 1
                continue
            }
            // binary search
            var start:Int = 0, end = i-1, k = i-1, kOver = i-1
            while(start < end) {
                print("start, end: \(start),\(end)")
                steps += 1
                k = (start + end)/2
                if array[k][j] == target {
                    print("Found \(array[k][j]) in \(steps) steps")
                    return array[k][j]
                } else if array[k][j] > target {
                    end = k - 1
                    kOver = k
                } else {
                    start = k + 1
                }
            }
            i = kOver - 1 // progress up the column
        } else {
            j += 1 // pivot
        }
    }
    print("Wahh wahh, not found in \(steps) steps")
    return nil
}

let a = [[ 10, 20, 21, 30, 40, 41],
         [ 11, 21, 22, 35, 50, 51],
         [ 50, 60, 61, 63, 70, 71],
         [ 51, 61, 80, 81, 82, 83],
         [ 52, 62, 90, 91, 98, 99]]
let x63I = searchArrayInc(63, in:a)
let x63B = searchArrayBinary(63, in:a)

let x75I = searchArrayInc(75, in:a)
let x75B = searchArrayBinary(75, in:a)

let y40I = searchArrayInc(40, in:a)
let y40B = searchArrayBinary(40, in:a)
