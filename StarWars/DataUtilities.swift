//
//  DataUtilities.swift
//  StarWars
//
//  Created by Ephraim Kunz on 1/31/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import Foundation
struct DataUtilities{
    static func idFromUrl(url: String) -> String{
        let array = url.components(separatedBy: "/")
        return array[array.count - 2] //Second to last item
    }
    
    static func spacesToUnderscores(string: String) -> String{
        return string.replacingOccurrences(of: " ", with: "_")
    }
}
