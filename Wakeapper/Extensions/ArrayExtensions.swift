//
//  ArrayExtensions.swift
//  Wakeapper
//
//  Created by Sergey Borovikov on 11/14/18.
//  Copyright © 2018 Sergey Borovikov. All rights reserved.
//

import Foundation

extension Array {
    
    func pair(at i: Index) -> (Element, Element?) {
        return (self[i], i < self.count - 1 ? self[i+1] : nil)
    }
}
