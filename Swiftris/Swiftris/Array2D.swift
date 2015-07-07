//
//  Array2D.swift
//  Swiftris
//
//  Created by Julicia on 5/28/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//


// #1 Define a class named Array2D. Generic arrays in Swift are actually of type struct, not class but we need a class in this case
class Array2D<T> {
    let columns: Int
    let rows: Int
    
    //#2 Declare the Swift array. This will be the underlying data structure which maintains references to our objects.
    
    var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        
    //#3 Instantiate our internal array structure with a size of rows * columns
        array = Array<T?>(count:rows * columns, repeatedValue: nil)
        
    }
    
    // #4 Create a custom subscript for Array2D
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[(row * columns) + column]
        }
        set(newValue) {
            array[(row * columns) + column] = newValue
        }
    }
}
    
