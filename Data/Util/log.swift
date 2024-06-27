//
//  log.swift
//  Data
//
//  Created by choijunios on 6/27/24.
//

import Foundation

func printIfDebug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if Debug
    print(items, separator: separator, terminator: terminator)
    #endif
}
