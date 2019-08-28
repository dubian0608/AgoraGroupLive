//
//  Constants.swift
//  Agora-Online-PK
//
//  Created by ZhangJi on 2018/6/4.
//  Copyright © 2018 CavanSu. All rights reserved.
//

import UIKit

/// 屏幕的宽
let ScreenWidth = UIScreen.main.bounds.size.width
/// 屏幕的高
let ScreenHeight = UIScreen.main.bounds.size.height

let ButtonBarHeight: CGFloat = 80

let ScrollViewHeight: CGFloat = 80

let SmallViewWidth: CGFloat = 75

let SmallViewSize = CGSize(width: 75, height: 75)

/// height / width for the contain view
let ContainViewRatio = (ScreenHeight - 20) / ScreenWidth

/// iphone4s
let isIPhone4 = ScreenHeight == 480 ? true : false
/// iPhone 5
let isIPhone5 = ScreenHeight == 568 ? true : false
/// iPhone 6
let isIPhone6 = ScreenHeight == 667 ? true : false
/// iPhone 6P
let isIPhone6P = ScreenHeight == 736 ? true : false

let isIPhoneX = ScreenHeight == 812 ? true : false

let BigSessionCount: UInt = ScreenHeight > 600 ? 4 : 3

let StatusBarHeight: CGFloat = isIPhoneX ? 44 : 20
