//
//  Created by ebamboo on 2022/7/22.
//

import Foundation

class MediaBrowserCellManager {
    
    private var managedCells = NSPointerArray.weakObjects()
    
    /// 添加播放视频的 cell，表示管理该 cell
    func manage(_ cell: MediaBrowserVideoCell) {
        managedCells.compact()
        guard !managedCells.allObjects.contains(where: { item in
            return cell == (item as! MediaBrowserVideoCell)
        }) else { return }
        let pointer = Unmanaged.passUnretained(cell).toOpaque()
        managedCells.addPointer(pointer)
    }
    
    /// 移除 cell，表示不再管理该 cell
    func remove(_ cell: MediaBrowserVideoCell) {
        managedCells.compact()
        guard let index = managedCells.allObjects.firstIndex(where: { item in
            return cell == (item as! MediaBrowserVideoCell)
        }) else { return }
        managedCells.removePointer(at: index)
    }
    
    /// 使所有 cell 暂停播放，一般当某个 cell 播放视频时，其他 cells 应该暂停播放
    func pauseAllCells() {
        managedCells.compact()
        managedCells.allObjects.forEach { item in
            (item as! MediaBrowserVideoCell).tryPause()
        }
    }
    
    /// 是否有正在播放视频的 cell
    func someOneIsPlaying() -> Bool {
        managedCells.compact()
        for item in managedCells.allObjects {
            if (item as! MediaBrowserVideoCell).status == .playing {
                return true
            }
        }
        return false
    }
    
}
