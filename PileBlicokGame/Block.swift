//
//  Block.swift
//  PileBlicokGame
//
//  Created by zhuguangyang on 16/7/20.
//  Copyright © 2016年 Giant. All rights reserved.
//

import Foundation

struct Block  {
    var x: Int
    var y: Int
    var color: Int
    var description: String {
        return "Block[x=\(x),y=\(y),color=\(color)]"
    }
}
