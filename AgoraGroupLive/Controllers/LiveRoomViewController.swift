//
//  LiveRoomViewController.swift
//  AgoraGroupLive
//
//  Created by ZhangJi on 2018/8/7.
//  Copyright © 2018 ZhangJi. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit

class LiveRoomViewController: UIViewController {
    
    @IBOutlet weak var buttonBarView: UIView!
    @IBOutlet weak var bigSessionContainView: UIView!
    @IBOutlet weak var leaveButton: UIButton!
    
    var roomName: String!
    var agoraKit: AgoraRtcEngineKit!
    
    var clientRole = AgoraClientRole.audience {
        didSet {
            
        }
    }
    
    fileprivate var isBroadcaster: Bool {
        return clientRole == .broadcaster
    }
    
    var videoProfile: CGSize!
    
    var mySession: VideoSession?
    
    fileprivate var bigViewSessions = [VideoSession]() {
        didSet {
            self.updateBigViews()
        }
    }
    
    fileprivate var smallSessionsContainView: UIScrollView?
    
    fileprivate var smallViewSessions = [VideoSession]() {
        didSet {
            UIView.animate(withDuration: 0.5) {
                self.updateSamllViews()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    fileprivate var fullContainerView: UIView?
    fileprivate var fullSession: VideoSession?
    
    fileprivate var isFullViewMode: Bool {
        return fullContainerView != nil
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.isStatusBarHidden
    }
    
    var isStatusBarHidden = true {
        didSet{
            UIView.animate(withDuration: 0.5) {
                self.view.bringSubview(toFront: self.buttonBarView)
                if self.isStatusBarHidden {
                    self.bigSessionContainView.transform = .identity
                    self.mySession?.hostingView.transform = .identity
                    self.smallSessionsContainView?.transform = .identity
                } else {
                    let height = ScreenHeight - (self.smallSessionsContainView == nil ? 0 : SmallViewWidth - 10)
                    let yMove = ((isIPhoneX ? 34 : StatusBarHeight) + (self.smallSessionsContainView == nil ? 0 : 10)  - ButtonBarHeight) / 2
                    let scaleRatio = (height - ButtonBarHeight - (isIPhoneX ? -34 : StatusBarHeight) + (self.smallSessionsContainView == nil ? 0 : 10)) / height
                    self.bigSessionContainView.transform = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio).concatenating(CGAffineTransform(translationX: 0, y: yMove))
                    if self.bigViewSessions.count > 0 {
                        let yTransform = CGAffineTransform(translationX: 0, y: (isIPhoneX ? 44 : 10) - ButtonBarHeight)
                        self.mySession?.hostingView.transform = yTransform
                        self.smallSessionsContainView?.transform = yTransform
                    }
                    
                }
                
                self.buttonBarView.transform = self.isStatusBarHidden ? .identity : CGAffineTransform(translationX: 0, y: -self.buttonBarView.frame.height)
                
                self.setNeedsStatusBarAppearanceUpdate()
                self.view.layoutIfNeeded()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bigSessionContainView.frame = isIPhoneX ? CGRect(x: 0, y: StatusBarHeight, width: ScreenWidth, height: ScreenHeight - StatusBarHeight - 34) : self.view.frame
        self.buttonBarView.frame = CGRect(x: 0, y: ScreenHeight + (isIPhoneX ? 34 : 0), width: ScreenWidth, height: ButtonBarHeight)
        self.isStatusBarHidden = false
        
        // Add GestureRecognizer
        self.addGestureRecognizer()
        
        self.loadAgoraKit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addGestureRecognizer() {
        let swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeUpGestureRecognizer.direction = .up
        view.addGestureRecognizer(swipeUpGestureRecognizer)
        view.isUserInteractionEnabled = true
        
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDownGestureRecognizer.direction = .down
        view.addGestureRecognizer(swipeDownGestureRecognizer)
        view.isUserInteractionEnabled = true
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGestureRecognizer)
        view.isUserInteractionEnabled = true
    }
    
    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .up:
            self.isStatusBarHidden = false
        case .down:
            self.isStatusBarHidden = true
        default:
            return
        }
    }
    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if isFullViewMode || bigViewSessions.count < 3 {
            return
        }
        guard let session = responseSession(of: sender) else { return }
        if !isStatusBarHidden {
            isStatusBarHidden = true
        }
        fullContainerView = UIView(frame: bigSessionContainView.frame)
        fullContainerView?.backgroundColor = UIColor(hex: 0x000000, alpha: 0.7)
        
        let narrowButton = UIButton()
        narrowButton.translatesAutoresizingMaskIntoConstraints = false
        narrowButton.setImage(#imageLiteral(resourceName: "narrow"), for: .normal)
        narrowButton.isHidden = true
        narrowButton.addTarget(self, action: #selector(handleNarrowPressed(_:)), for: .touchUpInside)
        
        let transformFrame = session.hostingView.convert(session.hostingView.bounds, to: fullContainerView)
        fullSession = VideoSession(uid: session.uid)
        fullSession?.hostingView.frame = transformFrame
        
        self.view.insertSubview(fullContainerView!, aboveSubview: bigSessionContainView)
        fullContainerView?.addSubview((fullSession?.hostingView)!)
        
        agoraKit.setupRemoteVideo((fullSession?.canvas)!)
        agoraKit.setRemoteVideoStream(session.uid, type: .high)
        
        UIView.animate(withDuration: 0.5, animations: {
            VideoViewLayouter.layoutFullSession(self.fullSession!, withButton: narrowButton, inContainer: self.fullContainerView!)
            self.view.layoutIfNeeded()
        }) { (_) in
            narrowButton.isHidden = false
        }
    }
    
    @objc func handleNarrowPressed(_ sender: UIButton?) {
        sender?.isHidden = true
        let session = fetchSession(ofUid: (fullSession?.uid)!)
    
        UIView.animate(withDuration: 0.5, animations: {
            let transformFrame = session?.hostingView.convert((session?.hostingView.bounds)!, to: self.fullContainerView)
            self.fullContainerView?.backgroundColor = UIColor.clear
            self.fullSession?.hostingView.frame = transformFrame!
        }) { (_) in
            self.agoraKit.setupRemoteVideo((session?.canvas)!)
            session?.viewType = (session?.viewType)!
            self.fullSession?.hostingView.removeFromSuperview()
            self.fullSession = nil
            self.fullContainerView?.removeFromSuperview()
            self.fullContainerView = nil
            self.updateBigViews()
            self.updateSamllViews()
        }
    }
    
    func responseSession(of gesture: UIGestureRecognizer) -> VideoSession? {
        let location = gesture.location(in: self.bigSessionContainView)
        for session in bigViewSessions {
            if let view = session.hostingView , view.frame.contains(location) {
                return session
            }
        }
        let smallLocation = gesture.location(in: self.smallSessionsContainView)
        for session in smallViewSessions {
            if let view = session.hostingView , view.frame.contains(smallLocation) {
                return session
            }
        }
        return nil
    }
    
    @IBAction func doLeaveButtonPressed(_ sender: UIButton) {
        leaveChannel()
    }
    
    func setIdleTimerActive(_ active: Bool) {
        UIApplication.shared.isIdleTimerDisabled = !active
    }
}

// MARK: - Agora Function
private extension LiveRoomViewController {
    func loadAgoraKit() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: self)
        agoraKit.setChannelProfile(.liveBroadcasting)
        agoraKit.setClientRole(self.clientRole)
        agoraKit.enableVideo()
        agoraKit.enableAudioVolumeIndication(1500, smooth: 3)
        agoraKit.setDefaultMuteAllRemoteVideoStreams(true)
//        agoraKit.setParameters("{\"che.audio.live_for_comm\":true}")
//        agoraKit.setParameters("{\"che.video.moreFecSchemeEnable\":true}")
        
        if isBroadcaster {
            agoraKit.enableDualStreamMode(true)
            agoraKit.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: videoProfile,
                                                                                 frameRate: .fps15,
                                                                                 bitrate: AgoraVideoBitrateStandard,
                                                                                 orientationMode: .adaptative))
            agoraKit.startPreview()
            self.addLocalSession()
        }
        
        let code = agoraKit.joinChannel(byToken: nil, channelId: roomName, info: nil, uid: 0, joinSuccess: nil)
        if code == 0 {
            setIdleTimerActive(false)
            agoraKit.setEnableSpeakerphone(true)
        } else {
            DispatchQueue.main.async(execute: {
                AlertUtil.showAlert(message: "Join channel failed: \(code)")
            })
        }
    }
    
    func leaveChannel() {
        setIdleTimerActive(true)
        
        agoraKit.setupLocalVideo(nil)
        agoraKit.leaveChannel(nil)
        if isBroadcaster {
            agoraKit.stopPreview()
        }
        
        if isFullViewMode {
            fullSession?.hostingView.removeFromSuperview()
            fullContainerView?.removeFromSuperview()
            fullSession = nil
            fullContainerView = nil
        }
        
        for session in bigViewSessions {
            session.hostingView.removeFromSuperview()
        }
        
        for session in smallViewSessions {
            session.hostingView.removeFromSuperview()
        }
        
        bigViewSessions.removeAll()
        smallViewSessions.removeAll()
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension LiveRoomViewController: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        print("=======My uid: \(uid)==========")
    }
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        let session = videoSession(ofUid: uid)
        agoraKit.setupRemoteVideo(session.canvas)
        print("======did join of uid :\(uid), 人数：\(bigViewSessions.count + smallViewSessions.count + 1)======")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
//        let session = videoSession(ofUid: uid)
//        agoraKit.setupRemoteVideo(session.canvas)
//        print("======first video decode of uid :\(uid), 人数：\(bigViewSessions.count + smallViewSessions.count + 1)======")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        print("======did off line of uid: \(uid), 人数：\(bigViewSessions.count + smallViewSessions.count)======")
        if isFullViewMode {
            if uid == fullSession?.uid {
                for view in (fullContainerView?.subviews)! {
                    if view is UIButton {
                        view.isHidden = true
                    }
                }
                handleNarrowPressed(nil)
            }
        }
        var indexToDelete: Int?
        for (index, session) in bigViewSessions.enumerated() {
            if session.uid == uid {
                indexToDelete = index
            }
        }
        
        if let indexToDelete = indexToDelete {
            let deletedSession = bigViewSessions.remove(at: indexToDelete)
            deletedSession.hostingView.removeFromSuperview()
            return
        }
        
        for (index, session) in smallViewSessions.enumerated() {
            if session.uid == uid {
                indexToDelete = index
            }
        }
        
        if let indexToDelete = indexToDelete {
            let deletedSession = smallViewSessions.remove(at: indexToDelete)
            deletedSession.hostingView.removeFromSuperview()
            return
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, reportAudioVolumeIndicationOfSpeakers speakers: [AgoraRtcAudioVolumeInfo], totalVolume: Int) {
        if bigViewSessions.count >= 3 && !isFullViewMode {
            updateBigViewsWith(speakers: speakers)
        }
    }
}

// MARK: - VideoSession && Video View Update
private extension LiveRoomViewController {
    func addLocalSession() {
        let localSession = VideoSession.localSession()
        mySession = localSession
        localSession.delegate = self
        localSession.viewType = .high
        
        agoraKit.setupLocalVideo(localSession.canvas)
    }
    
    func fetchSession(ofUid uid: UInt) -> VideoSession? {
        for session in bigViewSessions {
            if session.uid == uid {
                return session
            }
        }
        
        for session in smallViewSessions {
            if session.uid == uid {
                return session
            }
        }
        return nil
    }
    
    func videoSession(ofUid uid: UInt) -> VideoSession {
        if let fetchedSession = fetchSession(ofUid: uid) {
            return fetchedSession
        } else {
            let newSession = VideoSession(uid: uid)
            newSession.delegate = self
            if bigViewSessions.count < BigSessionCount {
                newSession.viewType = .high
//                newSession.isMuted = false
                bigViewSessions.append(newSession)
            } else {
                newSession.viewType = .low
//                newSession.isMuted = true
                smallViewSessions.append(newSession)
            }
            return newSession
        }
    }
    
    func updateBigViews() {
        self.isStatusBarHidden = true
        for session in bigViewSessions {
            session.isMuted = false
        }
        
        if bigViewSessions.count < BigSessionCount {
            if !smallViewSessions.isEmpty {
                let session = smallViewSessions.last
                smallViewSessions.remove(at: smallViewSessions.count - 1)
                let transformFrame = session?.hostingView.convert((session?.hostingView.bounds)!, to: self.bigSessionContainView)
                session?.hostingView.frame = transformFrame!
                self.bigSessionContainView.addSubview((session?.hostingView)!)
                session?.viewType = .high
                bigViewSessions.append(session!)
            }
        }
        UIView.animate(withDuration: 0.5) {
            if !self.bigViewSessions.isEmpty {
                if self.mySession?.viewType == .high {
                    self.mySession?.viewType = .low
                    self.isStatusBarHidden = true
                }
                VideoViewLayouter.layoutBigSessions(self.bigViewSessions, inContainer: self.bigSessionContainView)
            } else {
                if self.smallViewSessions.isEmpty && self.mySession?.viewType == .low {
                    self.mySession?.viewType = .high
                    VideoViewLayouter.layoutMySession(self.mySession, inContainer: self.view, withType: .high)
                    self.isStatusBarHidden = false
                }
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    func updateBigViewsWith(speakers: [AgoraRtcAudioVolumeInfo]) {
        var isUpdateNeeded = false
        var totalChanged = 0
        var bigSessions = [VideoSession]()
        var smallSessions = [VideoSession]()
        
        for user in speakers {
            if let session = fetchSession(ofUid: user.uid) {
                switch session.viewType {
                case .high:
                    totalChanged = abs(Int(session.auidoVolume) - Int(user.volume))
                    session.auidoVolume = user.volume
                    bigSessions.append(session)
                case .low:
                    if session.auidoVolume > 0 {
                        totalChanged = abs(Int(session.auidoVolume) - Int(user.volume))
                        session.auidoVolume = user.volume
                        smallSessions.append(session)
                    }
                }
            }
        }
        
        for session in bigViewSessions {
            var hasVolum = false
            for bigSession in bigSessions {
                if bigSession.uid == session.uid {
                    hasVolum = true
                    break
                }
            }
            if hasVolum {
                continue
            }
            session.auidoVolume = 0
        }
        
        if smallSessions.count > 0 {
            isUpdateNeeded = true
            for session in smallSessions {
                for (smallIndex, smallSession) in smallViewSessions.enumerated() {
                    if smallSession.uid == session.uid {
                        for (bigIndex, bigSession) in bigViewSessions.enumerated() {
                            if bigSession.auidoVolume == 0 {
                                let bigTransformFrame = bigSession.hostingView.convert(bigSession.hostingView.bounds, to: self.smallSessionsContainView)
                                bigSession.hostingView.frame = bigTransformFrame
                                let smallTransformFrame = smallSession.hostingView.convert(smallSession.hostingView.bounds, to: self.bigSessionContainView)
                                smallSession.hostingView.frame = smallTransformFrame
                                
                                smallViewSessions.remove(at: smallIndex)
                                bigViewSessions.insert(smallSession, at: bigIndex)
                                
                                bigViewSessions.remove(at: bigIndex+1)
                                smallViewSessions.insert(bigSession, at: smallIndex)
                                
                                bigSession.viewType = .low
                                smallSession.viewType = .high
                                break
                            }
                        }
                        break
                    }
                }
            }
        }
        
        if isUpdateNeeded || totalChanged > 50 {
            UIView.animate(withDuration: 1) {
                VideoViewLayouter.layoutBigSessions(self.bigViewSessions, inContainer: self.bigSessionContainView)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func updateSamllViews() {
        self.isStatusBarHidden = true
        
        if !smallViewSessions.isEmpty {
            self.bigSessionContainView.frame = isIPhoneX ? CGRect(x: 0, y: StatusBarHeight, width: ScreenWidth, height: ScreenHeight - StatusBarHeight - 34 - SmallViewWidth - 10) : CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - SmallViewWidth - 10)
            
            VideoViewLayouter.layoutBigSessions(self.bigViewSessions, inContainer: self.bigSessionContainView)
            if self.smallSessionsContainView == nil {
                self.smallSessionsContainView = UIScrollView(frame: CGRect(x: 10, y: ScreenHeight - SmallViewWidth - 10 - (isIPhoneX ? 34 : 0), width: ScreenWidth - 90, height: SmallViewWidth))
                self.smallSessionsContainView?.backgroundColor = UIColor.black
                self.smallSessionsContainView?.layer.cornerRadius = 8
                self.smallSessionsContainView?.layer.masksToBounds = true
                self.smallSessionsContainView?.delegate = self
                self.view.addSubview(self.smallSessionsContainView!)
                if let view = mySession?.hostingView {
                    self.view.bringSubview(toFront: view)
                }
            }
            
            VideoViewLayouter.layoutSmallSession(self.smallViewSessions, inContainer: self.smallSessionsContainView!)
        } else {
            self.bigSessionContainView.frame = isIPhoneX ? CGRect(x: 0, y: StatusBarHeight, width: ScreenWidth, height: ScreenHeight - StatusBarHeight - 34) : self.view.frame
            VideoViewLayouter.layoutBigSessions(self.bigViewSessions, inContainer: self.bigSessionContainView)
            smallSessionsContainView?.removeFromSuperview()
            smallSessionsContainView = nil
        }
        
        caculateDisplaySessions()
    }
}


extension LiveRoomViewController: VideoSessionDelegate {
    func videoSession(_ session: VideoSession, didChangedViewType type: AgoraVideoStreamType) {
        if session.uid != mySession?.uid {
            agoraKit.setRemoteVideoStream(session.uid, type: type)
            if type == .high {
//                session.isMuted = false
            }
        } else {
            VideoViewLayouter.layoutMySession(session, inContainer: self.view, withType: session.viewType)
        }
    }
    
    func videoSession(_ session: VideoSession, didChangedMuteStatus muteStatus: Bool) {
        agoraKit.muteRemoteVideoStream(session.uid, mute: muteStatus)
    }
}

extension LiveRoomViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        caculateDisplaySessions()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            caculateDisplaySessions()
        }
    }
    
    func caculateDisplaySessions() {
        for session in smallViewSessions {
            if isFullViewMode {
                if session.uid == fullSession?.uid {
                    continue
                }
            }
            if !session.isMuted {
                session.isMuted = true
            }
        }
        guard let pageWidth = smallSessionsContainView?.frame.width else { return }
        guard let offset = smallSessionsContainView?.contentOffset.x else { return }
        
        let sessionWidth = SmallViewWidth + 3
        let beginIndex = Int(offset / sessionWidth)
        let showNum = ceil((pageWidth - (sessionWidth - offset.truncatingRemainder(dividingBy: sessionWidth))) / sessionWidth) + 1
    
        for index in beginIndex ..< beginIndex + Int(showNum) {
            if index >= smallViewSessions.count {
                continue
            }
            smallViewSessions[index].isMuted = false
            print("======Unmute: \(smallViewSessions[index].uid)=======")
        }
        print("--------------------------------------------------")
    }
}
