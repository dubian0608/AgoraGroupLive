//
//  VideoSession.swift
//  AgoraGroupLive
//
//  Created by ZhangJi on 2018/8/7.
//  Copyright © 2018 ZhangJi. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit

protocol VideoSessionDelegate: NSObjectProtocol {
    func videoSession(_ session: VideoSession, didChangedViewType type: AgoraVideoStreamType)
    func videoSession(_ session: VideoSession, didChangedMuteStatus muteStatus: Bool)
}

class VideoSession: NSObject {
    weak var delegate: VideoSessionDelegate?
    
    var uid: UInt = 0
    
    var hostingView: UIView!
    
    var canvas: AgoraRtcVideoCanvas!
    
    var auidoVolume: UInt = 1
    
    var viewType: AgoraVideoStreamType = .low {
        didSet {
           delegate?.videoSession(self, didChangedViewType: viewType)
        }
    }
    
    var isMuted: Bool = true {
        didSet {
            delegate?.videoSession(self, didChangedMuteStatus: isMuted)
        }
    }
    
    init(uid: UInt) {
        self.uid = uid
        
        hostingView = UIView()
        hostingView.layer.cornerRadius = 8
        hostingView.layer.masksToBounds = true
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        canvas = AgoraRtcVideoCanvas()
        canvas.uid = UInt(uid)
        canvas.view = hostingView
        canvas.renderMode = .hidden
    }
}

extension VideoSession {
    static func localSession() -> VideoSession {
        return VideoSession(uid: 0)
    }
}
