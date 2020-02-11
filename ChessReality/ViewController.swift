/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 The sample app's main view controller.
 */

import UIKit
import ARKit
import RealityKit
import simd
import Combine
import MultipeerConnectivity
import ChessEngine

extension Experience {
    
    public struct AnchorPlacement {
        /// The identifier of the anchor the game is placed on. Used to re-localized the game between levels.
        var arAnchorIdentifier: UUID?
        /// The transform of the anchor the game is placed on . Used to re-localize the game between levels.
        var placementTransform: Transform?
    }

}


public class ViewController: UIViewController, EngineManagerDelegate {
    let engineManager: EngineManager = EngineManager()
    var messageLabel: UILabel!
    var bestMoveNext: String! = ""
    var finishedAnalyzing: Bool = false
    var computerPlays: Bool = false
    var numMoves:Int = 0
    /// The app's root view.
    @IBOutlet var arView: ARView!
    var banner:UILabel!
    var recordBanner:UITextView!
    var fenBanner:UILabel!
    var sessionInfoView: UIView! = UIView()
    var sessionInfoLabel: UILabel!
    var mappingStatusLabel: UILabel! = UILabel()
    var peerSessionIDs = [MCPeerID: String]()
    
    var gameFen: String = "position fen rnbqkbnr/pppp1ppp/8/4p3/3P4/8/PPP1PPPP/RNBQKBNR w KQkq -"
    var castling: String = "-"
    var curColor: String = "w"
    let allowComputerPlay: Bool = true
    var game: Experience.Game!
    var gameAnchored: Bool = false
    
    var mapProvider: MCPeerID?
    
    

    
    /// A view that instructs the user's movement during session initialization.
   // @IBOutlet weak var coachingOverlay: ARCoachingOverlayView!
    let coachingOverlay = ARCoachingOverlayView()

    

    /// The game controller, which manages game state.
    //var gameController: Experience.GameController!
    
    var gestureRecognizer: EntityTranslationGestureRecognizer?
    
    /// The world location at which the current translate gesture began.
    var gestureStartLocation: SIMD3<Float>?
    
    /// Storage for collision event streams
    var collisionEventStreams = [AnyCancellable]()
    var selectedPiece: Entity! = nil
    var selectedAnchor: AnchorEntity! = nil
    var selectedBoard: Bool = false
    
    var multipeerSession: MultipeerSession!
    var sessionIDObservation: NSKeyValueObservation?
    
    var overlayEntities: [[ModelEntity]] = Array<[ModelEntity]>(repeating: Array<ModelEntity>(repeating: ModelEntity(), count: 8), count:8)
    var occupied: [[Bool]] = Array<[Bool]>(repeating: Array<Bool>(repeating: false, count:8), count: 8)
    var position: [[String]] = Array(repeating: Array(repeating: " ", count: 8), count: 8)
    deinit {
        collisionEventStreams.removeAll()
    }
    var moves: [(Int, Int)] = []
    var startPos: SIMD3<Float>!
    var startPosXY: (Int, Int)!
    var isOwner:Bool = false

    

    

    


    
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        arView.addGestureRecognizer(tap)
    }
    

    func setupMultipeerSession() {
        sessionIDObservation = observe(\.arView.session.identifier, options: [.new]) { object, change in
            print("SessionID changed to: \(change.newValue!)")
            // Tell all other peers about your ARSession's changed ID, so
            // that they can keep track of which ARAnchors are yours.
            guard let multipeerSession = self.multipeerSession else { return }
            self.sendARSessionIDTo(peers: multipeerSession.connectedPeers)

        }
        multipeerSession = MultipeerSession(receivedDataHandler: receivedData, peerJoinedHandler: peerJoined, peerLeftHandler: peerLeft, peerDiscoveredHandler: peerDiscovered)
        
        guard let syncService = self.multipeerSession.syncService else {
          fatalError("could not create multipeerHelp.syncService")
        }
        arView.scene.synchronizationService = syncService

        
    }
    
    

    
    


    
    
    func setupViews() {
        sessionInfoLabel = UILabel()
        sessionInfoLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        sessionInfoLabel.textAlignment = .center
        sessionInfoLabel.textColor = .blue
        //sessionInfoLabel.text = "checking"
        self.view.addSubview(sessionInfoLabel)
        

        
        sessionInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        sessionInfoLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        sessionInfoLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0).isActive = true
        sessionInfoLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.1).isActive = true
        sessionInfoLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        sessionInfoLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 25).isActive = true
        
        banner = UILabel()
        banner.font = UIFont.boldSystemFont(ofSize: 25.0)
        banner.textAlignment = .center
        //banner.backgroundColor = .black
        //banner.textColor = .white
        banner.text = ""
        //banner.isHidden = true
        self.view.addSubview(banner)
        

        
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        banner.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0).isActive = true
        banner.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.1).isActive = true
        banner.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        banner.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true

        
        recordBanner = UITextView()
        recordBanner.font = UIFont.boldSystemFont(ofSize: 25.0)
        recordBanner.textAlignment = .left
        recordBanner.backgroundColor = .white
        recordBanner.textColor = .black
        recordBanner.text = ""
        //banner.isHidden = true
        self.view.addSubview(recordBanner)
        

        
        recordBanner.translatesAutoresizingMaskIntoConstraints = false
        recordBanner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        recordBanner.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0).isActive = true
        recordBanner.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.1).isActive = true
        recordBanner.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        recordBanner.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 25).isActive = true
    }
    
    func setupAll () {
        setupARconfig()
        setupMultipeerSession()
        setupViews()
        setupGestures()

        setupChessEngine()
        setupBoard()

    }
    
    func setupARconfig () {
        // Configure the AR session for horizontal plane tracking.
        let arConfiguration = ARWorldTrackingConfiguration()
        arConfiguration.planeDetection = .horizontal
        arConfiguration.isLightEstimationEnabled = true
        // Enable realistic reflections.
        arConfiguration.environmentTexturing = .automatic
        arConfiguration.isCollaborationEnabled = true
        
        arView.session.run(arConfiguration)
        
    }
    
    /* override public func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        arView.session.delegate = self
        setupARconfig()
        setupMultipeerSession()
        
    } */
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arView.session.delegate = self
        

        setupAll()

        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
        

        //presentCoachingOverlay()
        if multipeerSession.connectedPeers.isEmpty {
            Experience.loadGameAsync { [weak self] result in
                switch result {
                case .success(let game):
                    guard let self = self else { return }
                    self.game = game
                    //game.anchoring = AnchoringComponent(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0, 0)))
                    self.arView.scene.addAnchor(game)
                    self.setupOverlay()
                    self.game.synchronization?.ownershipTransferMode = .manual
                    guard let syncService = self.multipeerSession.syncService else {
                      fatalError("could not create multipeerHelp.syncService")
                    }
                    self.isOwner = true
                    //print(syncService.owner(of: game)!)
                    if(syncService.giveOwnership(of: game, toPeer: MCPeerID(displayName: UIDevice.current.name))) {
                        print("Ownership transfered to ", MCPeerID(displayName: UIDevice.current.name))
                    }

                    print("successfully loaded")
                 
                case .failure(let error):
                    print("Unable to load the game with error: \(error.localizedDescription)")
                }
            }
        }
 
        
    }


    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        if(game == nil) {return}
        recordBanner.isHidden = false
        
        var col: Color = .black
        if(curColor == "w") {col = .white}
        if(computerPlays && allowComputerPlay) {return}
        if(selectedPiece == nil)  {removeOverlay()}
        
        // handling code
        guard let touchInView = sender?.location(in: self.arView) else {
            return
        }
        // Send the anchor info to peers, so they can place the same content.
        let cb: Entity! = arView.scene.findEntity(named: "cb")
        if(!game.isOwner) {return}

        
        
        if let result = arView.raycast(
            from: touchInView,
            allowing: .estimatedPlane, alignment: .horizontal
        ).first {
            
            guard let entities = self.arView?.entities(
                at: touchInView
                )  else {
                    // no entity was hit
                    return
            }
            for entity in entities {
                //print(entity)
                if((selectedPiece != nil) && (isPiece(entity:entity)
                    && (entity2color(str: selectedPiece.name) == entity2color(str: entity.name)))){
                    print(selectedPiece.name," already selected")
                    return
                }
                if(isPiece(entity:entity) && selectedPiece == nil && (entity2color(str: entity.name) == col)) {
                    selectedPiece = entity
                    startPos = selectedPiece.position(relativeTo: cb)
                    let (xs, zs) = snapToBoard(x: startPos[0], z: startPos[2])
                    startPosXY = (xs, zs)
                    moves = validMoves(x: xs, y: zs)
                    if (moves.count == 0) {
                        print(selectedPiece.name, " selected piece cannot be moved")
                        selectedPiece = nil

                        return
                    }
                    //print(moves)
                    displayValidMoves(x: xs, y: zs)
                    displayCell(x: xs, y: zs)
                    return
                }
                if((selectedPiece != nil) && !selectedBoard &&
                    (!isPiece(entity:entity) ||
                        (entity2color(str: entity.name) != entity2color(str: selectedPiece.name))) &&
                    isBoard(entity:entity)) {
                    //selectedAnchor = entity
                    selectedBoard = true
                    break
                    
                }
            }
            for entity in entities {
                if(selectedPiece == nil && !isPiece(entity:entity) && isBoard(entity:entity)) {
                    print("Select piece first")
                    return
                }
            }
            
            
            
            if(!selectedBoard || (selectedPiece == nil)) {return}
            
            
            let transformation = Transform(matrix: result.worldTransform)
            let tmp = cb.convert(transform: transformation, from: nil)
            
            //print("Moving ", selectedPiece.name, " to ", tmp.matrix)
            
            selectedPiece.setTransformMatrix(tmp.matrix, relativeTo: cb)
            
            let pos = selectedPiece.position(relativeTo:cb)
            //print(pos)
            let (xs, zs) = snapToBoard(x: pos[0], z: pos[2])
            if(!isValidMove(coord: (xs, zs), coords: moves)) {
                selectedBoard = false
                selectedPiece.setPosition(startPos, relativeTo: cb)
                return
            } else {
                let x = 0.05*Float(xs)-0.175
                let z = 0.05*Float(zs)-0.175
                selectedPiece.setPosition([x, 0.0, z], relativeTo: cb)
            }

            algebraicNotation(srow: startPosXY.0, scol: startPosXY.1, erow: xs, ecol: zs, piece: entity2piece(str: selectedPiece.name), color: col)
            updateBoard(pieceName: selectedPiece.name, sx: startPosXY.0, sy: startPosXY.1, tx: xs, ty: zs)




            
            if(curColor == "w"){curColor = "b"}
            else {curColor = "w"}
            selectedPiece = nil
            selectedBoard = false
            moves=[]
            removeOverlay()
            displayCell(x: xs, y: zs)
            if(multipeerSession.connectedPeers.isEmpty && allowComputerPlay) {
                computerPlays = true
                if(curColor == "w") {
                    banner.text = "White to play (Computer)"
                    banner.textColor = .white
                    banner.backgroundColor = .black
                } else {
                    banner.text = "Black to play (Computer)"
                    banner.textColor = .black
                    banner.backgroundColor = .white
                }
                computerMove()
            } else {
                isOwner = false
                guard let syncService = self.multipeerSession.syncService else {
                  fatalError("could not create multipeerHelp.syncService")
                }
                if(syncService.giveOwnership(of: game, toPeer: mapProvider!)) {
                    print("Transfer succeeded")
                }

            }
            
        }
    }
    
    
    

    

    
}





