//
//  Parse.swift
//  Rocket
//
//  Created by ebamboo on 2022/3/3.
//

import Foundation
import KakaJSON

/// 试图解析数据 data 为基本数据类型如：bool, Int, Double, String, Array, Dictionary
func parse<T>(_ data: Any?, _ type: T.Type, keys: [String] = []) -> T? {
    var parseData = data
    for key in keys {
        guard let dic = parseData as? [String: Any] else { return nil }
        parseData = dic[key]
    }
    return parseData as? T
}

/// 试图解析数据 data 为模型 M
func model<M: Convertible>(_ data: Any?, _ type: M.Type, keys: [String] = []) -> M? {
    var parseData = data
    for key in keys {
        guard let dic = parseData as? [String: Any] else { return nil }
        parseData = dic[key]
    }
    guard let dic = parseData as? [String: Any] else { return nil }
    return model(from: dic, type)
}

/// 试图解析数据 data 为模型列表 [M]
func modelList<M: Convertible>(_ data: Any?, _ type: M.Type, keys: [String] = []) -> [M]? {
    var parseData = data
    for key in keys {
        guard let dic = parseData as? [String: Any] else { return nil }
        parseData = dic[key]
    }
    guard let list = parseData as? [Any] else { return nil }
    return modelArray(from: list, type)
}

