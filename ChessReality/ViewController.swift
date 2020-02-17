/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 The sample app's main view controller.
 */

import UIKit
import ARKit
import RealityKit
import MultipeerConnectivity
import ChessEngine




public class ViewController: UIViewController, EngineManagerDelegate {
    let engineManager: EngineManager = EngineManager()
    var messageLabel: UILabel!
    var bestMoveNext: String! = ""
    var finishedAnalyzing: Bool = false
    var computerPlays: Bool = false
    var numMoves:Int = 0
    /// The app's root view.
    //@IBOutlet var arView: ARView!
    public var arView: ARView!
    var banner:UILabel! = UILabel()
    var recordBanner:UITextView!
    var fenBanner:UILabel!
    var sessionInfoView: UIView! = UIView()
    var sessionInfoLabel: UILabel! = UILabel()
    var mappingStatusLabel: UILabel! = UILabel()
    var peerSessionIDs = [MCPeerID: String]()
    
    var gameFen: String = "position fen rnbqkbnr/pppp1ppp/8/4p3/3P4/8/PPP1PPPP/RNBQKBNR w KQkq -"
    var castling: String = "-"
    var curColor: String = "w"
    let allowComputerPlay: Bool = false
    let allowMultipeerPlay: Bool = true
    var game: Entity!
    //var cb:Entity!
    var gameAnchored: Bool = false
    var modelTapped: Bool = false
    
    var mapProvider: MCPeerID?
    var planeAnchor: ARAnchor!
    
    public let coachingOverlay = ARCoachingOverlayView()
    
    var selectedPiece: Entity! = nil
    var selectedAnchor: AnchorEntity! = nil
    var selectedBoard: Bool = false
    
    var multipeerSession: MultipeerSession!
    var sessionIDObservation: NSKeyValueObservation?
    
    var overlayEntities: [[ModelEntity]] = Array<[ModelEntity]>(repeating: Array<ModelEntity>(repeating: ModelEntity(), count: 8), count:8)
    var occupied: [[Bool]] = Array<[Bool]>(repeating: Array<Bool>(repeating: false, count:8), count: 8)
    var position: [[String]] = Array(repeating: Array(repeating: " ", count: 8), count: 8)
    
    var moves: [(Int, Int)] = []
    var startPos: SIMD3<Float>!
    var startPosXY: (Int, Int)!
    
    
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        arView.addGestureRecognizer(tap)
    }
    
    @objc
    func handleTap1(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)
        
        // Attempt to find a 3D location on a horizontal surface underneath the user's touch location.
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        if let firstResult = results.first {
            // Add an ARAnchor at the touch location with a special name you check later in `session(_:didAdd:)`.
            let anchor = ARAnchor(name: "Anchor for object placement", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
            
        } else {
            print("Warning: Object placement failed.")
        }
    }
    
    
    func setupMultipeerSession() {
        /*
         sessionIDObservation = observe(\.arView.session.identifier, options: [.new]) { object, change in
         print("SessionID changed to: \(change.newValue!)")
         // Tell all other peers about your ARSession's changed ID, so
         // that they can keep track of which ARAnchors are yours.
         guard let multipeerSession = self.multipeerSession else { return }
         self.sendARSessionIDTo(peers: multipeerSession.connectedPeers)
         
         }*/
        if(self.multipeerSession != nil) {
            //self.sendARSessionIDTo(peers: multipeerSession.connectedPeers)
        }
        multipeerSession = MultipeerSession(receivedDataHandler: receivedData, peerJoinedHandler: peerJoined, peerLeftHandler: peerLeft, peerDiscoveredHandler: peerDiscovered)
        
        guard let syncService = self.multipeerSession.syncService else {
            fatalError("could not create multipeerHelp.syncService")
        }
        arView.scene.synchronizationService = syncService
        
        
    }
    
    
    
    
    
    
    
    
    
    func setupViews() {
        //sessionInfoLabel = UILabel()
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
        
        //banner = UILabel()
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
        setupViews()
        setupARconfig()
        setupGestures()
        //setupChessBoard()
        if(allowMultipeerPlay) {setupMultipeerSession()}
        if(allowComputerPlay) {setupChessEngine()}
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
    
    override public func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        setupAll()
        
    }
    
    //override public func viewDidAppear(_ animated: Bool) {
    //super.viewDidAppear(animated)
    override public func viewDidLoad() {
        super.viewDidLoad()
        arView = ARView.init(frame: self.view.frame, cameraMode: .ar, automaticallyConfigureSession: true)
        self.view.addSubview(arView)
        arView.session.delegate = self
        // For now
        
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        //UIApplication.shared.isIdleTimerDisabled = true
        
        
        
    }
    
    override public func loadView() {
        super.loadView()
        let view = UIView(frame: UIScreen.main.bounds)
        self.view = view
    }
    
    
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        recordBanner.isHidden = false
        
        var col: Color = .black
        if(curColor == "w") {col = .white}
        if(computerPlays && allowComputerPlay) {return}
        if(selectedPiece == nil)  {removeOverlay()}
        
        // handling code
        guard let touchInView = sender?.location(in: self.arView) else {
            return
        }
        
        
        if let result = arView.raycast(
            from: touchInView,
            allowing: .estimatedPlane, alignment: .horizontal
        ).first {
            if(!modelTapped) {
                if(!allowMultipeerPlay || ((multipeerSession != nil) &&
                    ((!multipeerSession.connectedPeers.isEmpty &&
                        (multipeerSession.clientPeerID != multipeerSession.myPeerID)) ||
                        multipeerSession.connectedPeers.isEmpty))) {
                    // if its not connected disable the connection
                    setupChessBoard()
                    planeAnchor = ARAnchor(name: "Base", transform: result.worldTransform)
                    self.arView.session.add(anchor: self.planeAnchor)
                    
                }
                if(!multipeerSession.connectedPeers.isEmpty) {
                    guard let syncService = self.multipeerSession.syncService else {
                        fatalError("could not create multipeerHelp.syncService")
                    }
                    if(syncService.giveOwnership(of: game, toPeer: multipeerSession.myPeerID)) {
                        print("Transfer succeeded")
                        
                    }
                }
                modelTapped = true
                return
            }
            if(!multipeerSession.connectedPeers.isEmpty) {
                guard let syncService = self.multipeerSession.syncService else {
                    fatalError("could not create multipeerHelp.syncService")
                }
                if(syncService.owner(of: self.game) != nil) {
                    print("wait for your turn")
                    return
                    
                }
            }
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
                    startPos = selectedPiece.position(relativeTo: game)
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
            let tmp = game.convert(transform: transformation, from: nil)
            
            selectedPiece.setTransformMatrix(tmp.matrix, relativeTo: game)
            
            let pos = selectedPiece.position(relativeTo:game)
            //print(pos)
            let (xs, zs) = snapToBoard(x: pos[0], z: pos[2])
            if(!isValidMove(coord: (xs, zs), coords: moves)) {
                selectedBoard = false
                selectedPiece.setPosition(startPos, relativeTo: game)
                return
            } else {
                let (x, y, z) = boardCoord(i: xs, j: zs, piece: entity2piece(str:selectedPiece.name))
                selectedPiece.setPosition([x, y, z], relativeTo: game)
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
            if(((multipeerSession != nil) && multipeerSession.connectedPeers.isEmpty) && allowComputerPlay) {
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
            } else if (!allowMultipeerPlay) {
                if(curColor == "w") {
                    banner.text = "White to play"
                    banner.textColor = .white
                    banner.backgroundColor = .black
                } else {
                    banner.text = "Black to play"
                    banner.textColor = .black
                    banner.backgroundColor = .white
                }
            } else {
                if(!multipeerSession.connectedPeers.isEmpty) {
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
}





