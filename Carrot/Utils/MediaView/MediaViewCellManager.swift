//
//  MediaViewCellManager.swift
//  Carrot
//
//  Created by ebamboo on 2022/10/10.
//

import Foundation

struct MediaViewCellManager {
    
    static let managedCells = NSPointerArray.weakObjects()
    
    static func manage(_ cell: MediaViewVideoCell) {
        managedCells.compact()
        guard !managedCells.allObjects.contains(where: { item in
            return cell == (item as! MediaViewVideoCell)
        }) else { return }
        let pointer = Unmanaged.passUnretained(cell).toOpaque()
        managedCells.addPointer(pointer)
    }
    
    static func pause() {
        managedCells.compact()
        managedCells.allObjects.forEach { item in
            (item as! MediaViewVideoCell).tryPause()
        }
    }
    
}
