//
//  Utiles.swift
//  InputBoxView-demo
//
//  Created by jimmy on 2020/12/8.
//

import Foundation

/// 延迟
/// - Parameters:
///   - seconds: 多少秒
///   - completion: 回调
func delay(seconds: Double, completion: @escaping ()-> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}
