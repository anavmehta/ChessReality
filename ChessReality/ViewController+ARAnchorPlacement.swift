/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Extensions for the sample app's main view controller to handle ARAnchor placement
*/

import UIKit
import ARKit
import RealityKit
import simd
import MultipeerConnectivity

extension ARFrame.WorldMappingStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notAvailable:
            return "Not Available"
        case .limited:
            return "Limited"
        case .extending:
            return "Extending"
        case .mapped:
            return "Mapped"
        @unknown default:
            return "Uknown"
        }
    }
}

/// Used to display the coaching overlay view and kick-off the search for a horizontal plane anchor.
extension ViewController: ARCoachingOverlayViewDelegate {
    public func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        // Ask the user to gather more data before placing the game into the scene
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Set the view controller as the delegate of the session to get updates per-frame
            self.arView.session.delegate = self
        }
    }
}

/// Used to find a horizontal plane anchor before placing the game into the world.
extension ViewController: ARSessionDelegate {
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
        //let anchorEntity = AnchorEntity(anchor: anchor)
        //arView.scene.addAnchor(anchorEntity)
        }
    }
    /*
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        let screenCenter = CGPoint(x: arView.frame.midX, y: arView.frame.midY)

        let results = arView.hitTest(screenCenter, types: [.existingPlaneUsingExtent])
        guard let result = results.first(where: { result -> Bool in

            // Ignore results that are too close or too far away to the camera when initially placing
            guard result.distance > 0.5 && result.distance < 2.0 || self.coachingOverlay.isActive else {
                return false
            }

            // Make sure the anchor is a horizontal plane with a reasonable extent
            guard let planeAnchor = result.anchor as? ARPlaneAnchor,
                planeAnchor.alignment == .horizontal else {
                    return false
            }

            // Make sure the horizontal plane has a reasonable extent
            let extent = simd_length(planeAnchor.extent)
            //guard extent > 1 && extent < 2 else {
            //    return false
            //}
            guard extent > 1 else {
                return false
            }
            return true
        }),
        let planeAnchor = result.anchor as? ARPlaneAnchor else {
            return
        }

        // Create an anchor and add it to the session to place the game at this location
        let gameAnchor = ARAnchor(name: "Game Anchor", transform: normalize(planeAnchor.transform))
        arView.session.add(anchor: gameAnchor)
        //arView.scene.addAnchor(gameAnchor)

        gameController.anchorPlacement = Experience.AnchorPlacement(arAnchorIdentifier: gameAnchor.identifier,
                                                                    placementTransform: Transform(matrix: planeAnchor.transform))

        // Remove the coaching overlay view
        self.coachingOverlay.delegate = nil
        self.coachingOverlay.setActive(false, animated: false)
        self.coachingOverlay.removeFromSuperview()
        


        // Now that an anchor has been found, remove the view controller as a delegate to stop receiving updates per-frame
        //arView.session.delegate = nil

        // Reset the session to stop searching for horizontal planes after we found the anchor for the game
        arView.session.run(ARWorldTrackingConfiguration())

        self.gameController.playerReadyToPlayFrame()

        //mappingStatusLabel.text = frame.worldMappingStatus.description
        //updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)

    } */
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        /*
        let screenCenter = CGPoint(x: arView.frame.midX, y: arView.frame.midY)

        let results = arView.hitTest(screenCenter, types: [.existingPlaneUsingExtent])
        guard let result = results.first(where: { result -> Bool in

            // Ignore results that are too close or too far away to the camera when initially placing
            guard result.distance > 0.5 && result.distance < 2.0 || self.coachingOverlay.isActive else {
                return false
            }

            // Make sure the anchor is a horizontal plane with a reasonable extent
            guard let planeAnchor = result.anchor as? ARPlaneAnchor,
                planeAnchor.alignment == .horizontal else {
                    return false
            }

            // Make sure the horizontal plane has a reasonable extent
            let extent = simd_length(planeAnchor.extent)
            //guard extent > 1 && extent < 2 else {
            //    return false
            //}
            guard extent > 1 else {
                return false
            }
            return true
        }),
        let planeAnchor = result.anchor as? ARPlaneAnchor else {
            return
        }

        // Create an anchor and add it to the session to place the game at this location
        let gameAnchor = ARAnchor(name: "Game Anchor", transform: normalize(planeAnchor.transform))
        arView.session.add(anchor: gameAnchor)

        gameController.anchorPlacement = Experience.AnchorPlacement(arAnchorIdentifier: gameAnchor.identifier,
                                                                    placementTransform: Transform(matrix: planeAnchor.transform))

        // Remove the coaching overlay view
        self.coachingOverlay.delegate = nil
        self.coachingOverlay.setActive(false, animated: false)
        self.coachingOverlay.removeFromSuperview()
        


        // Now that an anchor has been found, remove the view controller as a delegate to stop receiving updates per-frame
        arView.session.delegate = nil

        // Reset the session to stop searching for horizontal planes after we found the anchor for the game
        arView.session.run(ARWorldTrackingConfiguration())

        self.gameController.playerReadyToPlayFrame()

        mappingStatusLabel.text = frame.worldMappingStatus.description
        //updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
 */
    }
    
    // MARK: - ARSessionDelegate
    /// - Tag: PeerJoined
    func peerJoined(_ peer: MCPeerID) {
        //messageLabel.displayMessage("""
            //A peer wants to join the experience.
            //Hold the phones next to each other.
            //""", duration: 6.0)
        sendARSessionIDTo(peers: [peer])
    }
        
    func peerLeft(_ peer: MCPeerID) {
        //messageLabel.displayMessage("A peer has left the shared experience.")
        // Remove all ARAnchors associated with the peer that just left the experience.
        if let sessionID = peerSessionIDs[peer] {
            peerSessionIDs.removeValue(forKey: peer)
        }
    }
    
    public func sendARSessionIDTo(peers: [MCPeerID]) {
        guard let multipeerSession = multipeerSession else { return }
        print("Sending ARSessionID to peers...")
        let idString = arView.session.identifier.uuidString
        let command = "SessionID:" + idString
        if let commandData = command.data(using: .utf8) {
            multipeerSession.sendToPeers(commandData, reliably: true, peers: peers)
        }
    }
    
    func peerDiscovered(_ peer: MCPeerID) -> Bool {
        guard let multipeerSession = multipeerSession else { return false }
        
        if multipeerSession.connectedPeers.count > 2 {
            //messageLabel.displayMessage("A third peer wants to join the experience.\nThis //app is limited to two users.", duration: 6.0)
            return false
        } else {
            return true
        }
    }
    
    // MARK: - AR session management
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty && multipeerSession.connectedPeers.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Start to play with computer, or wait to join a shared session."
            
        case .normal where !multipeerSession.connectedPeers.isEmpty && mapProvider == nil:
            let peerNames = multipeerSession.connectedPeers.map({ $0.displayName }).joined(separator: ", ")
            message = "Connected with \(peerNames)."
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing) where mapProvider != nil,
             .limited(.relocalizing) where mapProvider != nil:
            message = "Received map from \(mapProvider!.displayName)."
            
        case .limited(.relocalizing):
            message = "Resuming session — move to where you were when the session was interrupted."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""
            
        }
        
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }
    
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    } 
    
    /// Begins the coaching process that instructs the user's movement during
    /// ARKit's session initialization.
    func presentCoachingOverlay() {
        coachingOverlay.session = arView.session
        coachingOverlay.delegate = self
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.activatesAutomatically = false
        self.coachingOverlay.setActive(true, animated: true)
    }

    /// - Tag: ReceiveData
    func receivedData(_ data: Data, from peer: MCPeerID) {
        if let collaborationData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARSession.CollaborationData.self, from: data) {
            mapProvider = peer
            arView.session.update(with: collaborationData)
            return
        }

        let sessionIDCommandString = "SessionID:"
        if let commandString = String(data: data, encoding: .utf8), commandString.starts(with: sessionIDCommandString) {
            let newSessionID = String(commandString[commandString.index(commandString.startIndex,
                                                                     offsetBy: sessionIDCommandString.count)...])
            // If this peer was using a different session ID before, remove all its associated anchors.
            // This will remove the old participant anchor and its geometry from the scene.
            
            peerSessionIDs[peer] = newSessionID
        }
    }
    

    
    // MARK: - ARSessionObserver
    
    public func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                self.resetTracking(nil)
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    public func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
        guard let multipeerSession = multipeerSession else { return }
        //if(!self.isOwner) {return}

        if !multipeerSession.connectedPeers.isEmpty {
            print("Outputing Collaboration Data...")
            guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
                else { fatalError("Unexpectedly failed to encode collaboration data.") }
            // Use reliable mode if the data is critical, and unreliable mode if the data is optional.
            //let dataIsCritical = data.priority == .critical
            multipeerSession.sendToAllPeers(encodedData)
        } else {
            //print("Deferred sending collaboration to later because there are no peers.")
        }
    }


    
    @IBAction func resetTracking(_ sender: UIButton?) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    func normalize(_ matrix: float4x4) -> float4x4 {
        var normalized = matrix
        normalized.columns.0 = simd.normalize(normalized.columns.0)
        normalized.columns.1 = simd.normalize(normalized.columns.1)
        normalized.columns.2 = simd.normalize(normalized.columns.2)
        return normalized
    }
}
