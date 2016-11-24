//
//  CommonUtil.swift
//  Somali
//
//  Created by 古川信行 on 2016/10/31.
//  Copyright © 2016年 ux-xu. All rights reserved.
//

import Foundation
import UIKit

extension DispatchQueue {
    class func mainSyncSafe(execute work: () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.sync(execute: work)
        }
    }
    
    class func mainSyncSafe<T>(execute work: () throws -> T) rethrows -> T {
        if Thread.isMainThread {
            return try work()
        } else {
            return try DispatchQueue.main.sync(execute: work)
        }
    }
}

//日付を変換
class DateUtils {
    class func dateFromString(string: String, format: String) -> NSDate {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)! as NSDate
    }
    
    class func stringFromDate(date: NSDate, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date as Date)
    }
}

/** 共通処理
 *
 */
class CommonUtil {
    /** ストーリーボードの識別子を指定して UIViewControllerを取得する
     *
     */
    static func instantiateViewController(storyboard:UIStoryboard,identifier:String) -> UIViewController? {
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
}
