/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Extensions for the sample app's main view controller to handle ARAnchor placement
 */

import UIKit
import ARKit
import RealityKit
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
        
        sessionInfoLabel.text = ""
        for anchor in anchors {
            if let participantAnchor = anchor as? ARParticipantAnchor {
                sessionInfoLabel.text="Established joint experience with a peer."
                let anchorEntity = AnchorEntity(anchor: participantAnchor)
                let coloredSphere = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.025), materials: [SimpleMaterial(color: .white, isMetallic: true)])
                anchorEntity.addChild(coloredSphere)
                arView.scene.addAnchor(anchorEntity)
            } else if anchor.name == "Base" {
                sessionInfoLabel.text="Added plane anchor"
                let anchorEntity = AnchorEntity(anchor: anchor)
                //let cb: Entity! = arView.scene.findEntity(named: "cb")
                if(self.game != nil) {anchorEntity.addChild(self.game)}
                
                //if(self.game != nil) {anchorEntity.addChild(self.game)}
                arView.scene.addAnchor(anchorEntity)
            }
            sessionInfoLabel.isHidden = sessionInfoLabel.text?.isEmpty ?? true
            
        }
    }
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch frame.worldMappingStatus {
        case .notAvailable, .limited:
            mappingStatusLabel.isEnabled = false
        case .extending:
            mappingStatusLabel.isEnabled = !multipeerSession.connectedPeers.isEmpty
        case .mapped:
            mappingStatusLabel.isEnabled = !multipeerSession.connectedPeers.isEmpty
        @unknown default:
            print("Unknown state")
        }
        mappingStatusLabel.text = frame.worldMappingStatus.description
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    // MARK: - ARSessionDelegate
    /// - Tag: PeerJoined
    public func peerJoined(_ peer: MCPeerID) {
        sendARSessionIDTo(peers: [peer])
    }
    
    public func peerLeft(_ peer: MCPeerID) {
        peerSessionIDs.removeValue(forKey: peer)
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
    
    public func peerDiscovered(_ peer: MCPeerID) -> Bool {
        guard let multipeerSession = multipeerSession else { return false }
        
        if multipeerSession.connectedPeers.count > 2 {
            return false
        } else {
            return true
        }
    }
    
    // MARK: - AR session management
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        if(!allowMultipeerPlay) {return}
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
        //sessionInfoView.isHidden = message.isEmpty
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
            if(collaborationData.isKind(of: Entity.self)) {
                print("here")
            }
            /*
             if let entity = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: Entity.self, from: data) {
             if(entity.name == "game") {game = entity}
             }*/
            arView.session.update(with: collaborationData)
            return
        }
        
        let sessionIDCommandString = "SessionID:"
        if let commandString = String(data: data, encoding: .utf8), commandString.starts(with: sessionIDCommandString) {
            let newSessionID = String(commandString[commandString.index(commandString.startIndex,
                                                                        offsetBy: sessionIDCommandString.count)...])
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
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    public func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
        guard let multipeerSession = multipeerSession else { return }
        if !multipeerSession.connectedPeers.isEmpty {
            //print(multipeerSession.myPeerID, "Outputing Collaboration Data...")
            guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
                else { fatalError("Unexpectedly failed to encode collaboration data.") }
            // Use reliable mode if the data is critical, and unreliable mode if the data is optional.
            //let dataIsCritical = data.priority == .critical
            multipeerSession.sendToAllPeers(encodedData)
        } else {
            //print("Deferred sending collaboration to later because there are no peers.")
        }
    }
    
    
    
    
    func normalize(_ matrix: float4x4) -> float4x4 {
        var normalized = matrix
        normalized.columns.0 = simd.normalize(normalized.columns.0)
        normalized.columns.1 = simd.normalize(normalized.columns.1)
        normalized.columns.2 = simd.normalize(normalized.columns.2)
        return normalized
    }
}

extension MeshResource {
    /**
     Generate three axes of a coordinate system with x axis = red, y axis = green and z axis = blue
     - parameters:
     - axisLength: Length of the axes in m
     - thickness: Thickness of the axes as a percentage of their length
     */
    static func generateCoordinateSystemAxes(length: Float = 0.1, thickness: Float = 2.0) -> Entity {
        let thicknessInM = (length / 100) * thickness
        let cornerRadius = thickness / 2.0
        let offset = length / 2.0
        
        let xAxisBox = MeshResource.generateBox(size: [length, thicknessInM, thicknessInM], cornerRadius: cornerRadius)
        let yAxisBox = MeshResource.generateBox(size: [thicknessInM, length, thicknessInM], cornerRadius: cornerRadius)
        let zAxisBox = MeshResource.generateBox(size: [thicknessInM, thicknessInM, length], cornerRadius: cornerRadius)
        
        let xAxis = ModelEntity(mesh: xAxisBox, materials: [UnlitMaterial(color: .red)])
        let yAxis = ModelEntity(mesh: yAxisBox, materials: [UnlitMaterial(color: .green)])
        let zAxis = ModelEntity(mesh: zAxisBox, materials: [UnlitMaterial(color: .blue)])
        
        xAxis.position = [offset, 0, 0]
        yAxis.position = [0, offset, 0]
        zAxis.position = [0, 0, offset]
        
        let axes = Entity()
        axes.addChild(xAxis)
        axes.addChild(yAxis)
        axes.addChild(zAxis)
        return axes
    }
}

extension UUID {
    /**
     - Tag: ToRandomColor
     Pseudo-randomly return one of several fixed standard colors, based on this UUID's first four bytes.
     */
    func toRandomColor() -> UIColor {
        var firstFourUUIDBytesAsUInt32: UInt32 = 0
        let data = withUnsafePointer(to: self) {
            return Data(bytes: $0, count: MemoryLayout.size(ofValue: self))
        }
        _ = withUnsafeMutableBytes(of: &firstFourUUIDBytesAsUInt32, { data.copyBytes(to: $0) })
        
        let colors: [UIColor] = [.red, .green, .blue, .yellow, .magenta, .cyan, .purple,
                                 .orange, .brown, .lightGray, .gray, .darkGray, .black, .white]
        
        let randomNumber = Int(firstFourUUIDBytesAsUInt32) % colors.count
        return colors[randomNumber]
    }
}
