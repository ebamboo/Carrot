//
//  Created by ebamboo on 2022/7/22.
//

import Foundation

struct MediaBrowserCellManager {
    
    static let shared = MediaBrowserCellManager()
    private let managedCells = NSPointerArray.weakObjects()
    
    func manage(_ cell: MediaBrowserVideoCell) {
        managedCells.compact()
        guard !managedCells.allObjects.contains(where: { item in
            return cell == (item as! MediaBrowserVideoCell)
        }) else { return }
        let pointer = Unmanaged.passUnretained(cell).toOpaque()
        managedCells.addPointer(pointer)
    }
    
    func pause() {
        managedCells.compact()
        managedCells.allObjects.forEach { item in
            (item as! MediaBrowserVideoCell).tryPause()
        }
    }
    
}
