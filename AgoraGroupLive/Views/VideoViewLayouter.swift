//
//  VideoViewLayouter.swift
//  AgoraGroupLive
//
//  Created by ZhangJi on 2018/8/8.
//  Copyright © 2018 ZhangJi. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit

class VideoViewLayouter: NSObject {
    static fileprivate var bigSessionsLayoutContraints = [NSLayoutConstraint]()
    static fileprivate var smallSessionsLayoutContraints = [NSLayoutConstraint]()
    static fileprivate var mySessionLayoutContraints = [NSLayoutConstraint]()
    static fileprivate var fullSessionLayoutContraints = [NSLayoutConstraint]()
    
    static func layoutBigSessions(_ sessions: [VideoSession], inContainer container: UIView) {
        guard !sessions.isEmpty else {
            return
        }
        let views = viewList(from: sessions)
        
        let transformA = container.transform.a
        
        NSLayoutConstraint.deactivate(bigSessionsLayoutContraints)
        bigSessionsLayoutContraints.removeAll()
        
        for view in views {
            view.removeFromSuperview()
            NSLayoutConstraint.deactivate(view.constraints)
            container.addSubview(view)
        }
        switch views.count {
        case 1:
            let firstView = views[0]
            bigSessionsLayoutContraints = [
                NSLayoutConstraint(item: firstView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: container.frame.width - 20),
                NSLayoutConstraint(item: firstView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: container.frame.height - 20),
                NSLayoutConstraint(item: firstView, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: firstView, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: 0)
            ]
        case 2:
            let firstView = views[1]
            let secondView = views[0]
            let viewWidth = min(container.frame.width - 20, (container.frame.height - 30) / 2)
            bigSessionsLayoutContraints = [
                NSLayoutConstraint(item: firstView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewWidth),
                NSLayoutConstraint(item: firstView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewWidth),
                NSLayoutConstraint(item: firstView, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: -(viewWidth / 2 + 5)),
                NSLayoutConstraint(item: firstView, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: 0),
                
                NSLayoutConstraint(item: secondView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewWidth),
                NSLayoutConstraint(item: secondView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewWidth),
                NSLayoutConstraint(item: secondView, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: (viewWidth / 2 + 5)),
                NSLayoutConstraint(item: secondView, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: 0)
            ]
        case 3:
            let firstView = views[2]
            let secondView = views[1]
            let thirdView = views[0]
            
            let width = container.frame.width / transformA
            
            let ratio = setRatioFor(sessions: sessions, inContainer: container)//.map{ return $0 / transformA }
        
            bigSessionsLayoutContraints = [
                NSLayoutConstraint(item: firstView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width * ratio[2]),
                NSLayoutConstraint(item: firstView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width * ratio[2]),
                NSLayoutConstraint(item: firstView, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: 10),
                NSLayoutConstraint(item: firstView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: container, attribute: .leading, multiplier: 1, constant: 10),
                
                NSLayoutConstraint(item: secondView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width * ratio[1]),
                NSLayoutConstraint(item: secondView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width * ratio[1]),
                NSLayoutConstraint(item: secondView, attribute: .top, relatedBy: .equal, toItem: firstView, attribute: .bottom, multiplier: 1, constant: -15),
                NSLayoutConstraint(item: secondView, attribute: .leading, relatedBy: .lessThanOrEqual, toItem: firstView, attribute: .trailing, multiplier: 1, constant: -15),
                NSLayoutConstraint(item: secondView, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: container, attribute: .trailing, multiplier: 1, constant: -10),
                
                NSLayoutConstraint(item: thirdView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width * ratio[0]),
                NSLayoutConstraint(item: thirdView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width * ratio[0]),
                NSLayoutConstraint(item: thirdView, attribute: .top, relatedBy: .equal, toItem: secondView, attribute: .bottom, multiplier: 1, constant: -15),
                NSLayoutConstraint(item: thirdView, attribute: .trailing, relatedBy: .greaterThanOrEqual, toItem: secondView, attribute: .leading, multiplier: 1, constant: 15),
                NSLayoutConstraint(item: thirdView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: container, attribute: .leading, multiplier: 1, constant: 10),
            ]
        case 4:
            let firstView = views[3]
            let secondView = views[2]
            let thirdView = views[1]
            let fourthView = views[0]
            
            let width = container.frame.width / transformA
            
            let ratio = setRatioFor(sessions: sessions, inContainer: container)//.map{ return $0 / transformA }
            
            bigSessionsLayoutContraints = [
                NSLayoutConstraint(item: firstView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width * ratio[3]),
                NSLayoutConstraint(item: firstView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width * ratio[3]),
                NSLayoutConstraint(item: firstView, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: 10),
                NSLayoutConstraint(item: firstView, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: container, attribute: .trailing, multiplier: 1, constant: -10),
                
                NSLayoutConstraint(item: secondView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width * ratio[2]),
                NSLayoutConstraint(item: secondView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width * ratio[2]),
                NSLayoutConstraint(item: secondView, attribute: .top, relatedBy: .equal, toItem: firstView, attribute: .bottom, multiplier: 1, constant: -15),
                NSLayoutConstraint(item: secondView, attribute: .trailing, relatedBy: .greaterThanOrEqual, toItem: firstView, attribute: .leading, multiplier: 1, constant: 15),
                NSLayoutConstraint(item: secondView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: container, attribute: .leading, multiplier: 1, constant: 10),
                
                NSLayoutConstraint(item: thirdView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width * ratio[1]),
                NSLayoutConstraint(item: thirdView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width * ratio[1]),
                NSLayoutConstraint(item: thirdView, attribute: .top, relatedBy: .equal, toItem: secondView, attribute: .bottom, multiplier: 1, constant: -15),
                NSLayoutConstraint(item: thirdView, attribute: .leading, relatedBy: .lessThanOrEqual, toItem: secondView, attribute: .trailing, multiplier: 1, constant: -15),
                NSLayoutConstraint(item: thirdView, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: container, attribute: .trailing, multiplier: 1, constant: -10),
                
                NSLayoutConstraint(item: fourthView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width * ratio[0]),
                NSLayoutConstraint(item: fourthView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width * ratio[0]),
                NSLayoutConstraint(item: fourthView, attribute: .top, relatedBy: .equal, toItem: thirdView, attribute: .bottom, multiplier: 1, constant: -15),
                NSLayoutConstraint(item: fourthView, attribute: .trailing, relatedBy: .greaterThanOrEqual, toItem: thirdView, attribute: .leading, multiplier: 1, constant: 15),
                NSLayoutConstraint(item: fourthView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: container, attribute: .leading, multiplier: 1, constant: 10)
                ]
        default:
            break
        }
        
        if !bigSessionsLayoutContraints.isEmpty {
            NSLayoutConstraint.activate(bigSessionsLayoutContraints)
        }
    }
    
    static func layoutSmallSession(_ sessions: [VideoSession], inContainer container: UIScrollView) {
        guard !sessions.isEmpty else {
            return
        }
        
        NSLayoutConstraint.deactivate(smallSessionsLayoutContraints)
        smallSessionsLayoutContraints.removeAll()
        
        let views = viewList(from: sessions)
        container.contentSize = CGSize(width: 80 * (views.count), height: 0)
        
        var lastView: UIView?
        let itemSpace: CGFloat = 3
        
        for view in views {
            NSLayoutConstraint.deactivate(view.constraints)
            container.addSubview(view)
            let viewWidth = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: SmallViewWidth)
            let viewHeight = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: SmallViewWidth)
            let viewTop = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: 0)
            let viewLeft: NSLayoutConstraint
            if let lastView = lastView {
                viewLeft = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: lastView, attribute: .right, multiplier: 1, constant: itemSpace)
            } else {
                viewLeft = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: container, attribute: .left, multiplier: 1, constant: 0)
            }
            
            smallSessionsLayoutContraints.append(contentsOf: [viewWidth, viewHeight, viewTop, viewLeft])
            lastView = view
        }
        
        if !smallSessionsLayoutContraints.isEmpty {
            NSLayoutConstraint.activate(smallSessionsLayoutContraints)
        }
    }
    
    static func layoutMySession(_ session: VideoSession?, inContainer container: UIView, withType type: AgoraVideoStreamType) {
        guard let session = session else { return }
        
        NSLayoutConstraint.deactivate(mySessionLayoutContraints)
        mySessionLayoutContraints.removeAll()
        let view = session.hostingView!
        
        view.removeFromSuperview()
        
        container.addSubview(view)
        switch type {
        case .high:
            mySessionLayoutContraints = [
                NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: container.frame.width - 20),
                NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: container.frame.width - 20),
                NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: 0)
            ]
        case .low:
            mySessionLayoutContraints = [
                NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: SmallViewWidth),
                NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: SmallViewWidth),
                NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: -10),
                NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1, constant: -10)
            ]
        }
        
        if !mySessionLayoutContraints.isEmpty {
            NSLayoutConstraint.activate(mySessionLayoutContraints)
        }
    }
    
    static func layoutFullSession(_ session: VideoSession, withButton button: UIButton, inContainer container: UIView) {
        NSLayoutConstraint.deactivate(session.hostingView.constraints)
        fullSessionLayoutContraints.removeAll()
        
        let view = session.hostingView!

        container.addSubview(view)
        container.addSubview(button)
        fullSessionLayoutContraints = [
            NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: container.frame.width - 20),
            NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: container.frame.width - 20),
            NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: 0),
            
            NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -5),
            NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: -15),
            NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
        ]
        
        if !fullSessionLayoutContraints.isEmpty {
            NSLayoutConstraint.activate(fullSessionLayoutContraints)
        }
    }
}

private extension VideoViewLayouter {
    static func viewList(from sessions: [VideoSession]) -> [UIView] {
        var views = [UIView]()
        for session in sessions {
            views.append(session.hostingView)
        }
        return views
    }
    
    static func setRatioFor(sessions: [VideoSession], inContainer container: UIView) -> [CGFloat] {
        
        var viewRatio = [CGFloat]()
        var volumeRatio = [CGFloat]()
//        var volumeRatio1 = [CGFloat]()
        
        var sumVolume: UInt = 0
        for session in sessions {
            sumVolume += session.auidoVolume
        }
        
        for session in sessions {
            let ratio = sumVolume == 0 ? 1.0 / CGFloat(sessions.count) : CGFloat(session.auidoVolume) / CGFloat(sumVolume)
            volumeRatio.append(ratio)
        }
        
//        let sum: CGFloat = container.frame.height / container.frame.width
//        let maxRatio: CGFloat = min(sum / 2, 0.8) / sum
//        let minRatio: CGFloat = max(sum / 6, 0.2) / sum
//        var a: CGFloat = 0
//        for (index, var num) in volumeRatio.enumerated() {
//            num += a
//            if num > maxRatio {
//                a += (num - maxRatio) / CGFloat(volumeRatio.count - index)
//                num = maxRatio
//            } else if num < minRatio {
//                a += (num - minRatio) / CGFloat(volumeRatio.count - index)
//                num = minRatio
//            }
//            volumeRatio1.append(num)
//        }
//        viewRatio = volumeRatio1.map{ return ($0 + a / CGFloat(volumeRatio.count))  * sum }
        
        var sum: CGFloat = container.frame.height / container.frame.width
        let minRatio: CGFloat = SmallViewWidth / container.frame.width * container.transform.a
        let maxRatio: CGFloat = min(sum / 2, 0.8)
        
        sum -= minRatio * CGFloat(volumeRatio.count)
        viewRatio = volumeRatio.map{ return ($0 * sum + minRatio) }
        
        var a: CGFloat = 0
        var count = 0
        repeat {
            a = 0
            for (index, num) in viewRatio.enumerated() {
                if num > maxRatio {
                    a += (num - maxRatio)
                    viewRatio[index] = maxRatio
                }
            }
            for (index, _) in viewRatio.enumerated() {
                viewRatio[index] += a / CGFloat(volumeRatio.count)
            }
//            count += 1
//            print(count)
        } while a > 0.1 && count < 5
        
        return viewRatio
    }
}



