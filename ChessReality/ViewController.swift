/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 The sample app's main view controller.
 */

import UIKit
import ARKit
import RealityKit
import Combine
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
    var recordBanner:UILabel!
    var fenBanner:UILabel!
    var sessionInfoLabel: UILabel! = UILabel()
    let items = ["Single device", "Play with Computer", "Play with opponent"]
    var customSC: UISegmentedControl!
    var peerSessionIDs = [MCPeerID: String]()
    
    var gameFen: String = "position fen rnbqkbnr/pppp1ppp/8/4p3/3P4/8/PPP1PPPP/RNBQKBNR w KQkq -"
    var castling: String = "-"
    var curColor: String = "w"
    var allowComputerPlay: Bool = false
    var allowMultipeerPlay: Bool = false
    var game: Entity!
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
    var endPosXY: (Int, Int)!
    var planeAnchorAdded: Bool = false
    var connectedWithPeer: Bool = false
    var placedBoard: Bool = false
    var owner: Bool = false
    var recordString: String = ""
    var myIdLabel: UILabel! = UILabel()
    var peerIdLabel: UILabel! = UILabel()
    var connectionStatusLabel: UILabel! = UILabel()
    var inputStatusLabel: UILabel! = UILabel()
    
    
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        arView.addGestureRecognizer(tap)
    }
    
    
    
    func setupMultipeerSession() {
        if(self.multipeerSession != nil) {
            self.sendARSessionIDTo(peers: multipeerSession.connectedPeers)
        }
        multipeerSession = MultipeerSession(receivedDataHandler: receivedData, peerJoinedHandler: peerJoined, peerLeftHandler: peerLeft, peerDiscoveredHandler: peerDiscovered)
        
        guard let syncService = self.multipeerSession.syncService else {
            fatalError("could not create multipeerHelp.syncService")
        }
        arView.scene.synchronizationService = syncService
        
        
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setMode(mode:PlayingMode) {
        allowComputerPlay = false
        allowMultipeerPlay = false
        if(mode == .Computer) {allowComputerPlay = true}
        else if(mode == .MultiDevice) {allowMultipeerPlay = true}
    }
    func play() {
        restartGame()
    }
    
    func restartGame() {
        resetBoard()
        curColor = "w"
        if(allowMultipeerPlay) {
            setupMultipeerSession()
            banner.text = "Wait for participants to join"
        }
        if(allowComputerPlay) {
            banner.text = "White to move- tap a piece to select"
            setupChessEngine()
        }
        sessionInfoLabel.text = "Restarted game"
        fenBanner.text = ""
        recordBanner.text = ""
        
    }
    
    
    
    
    
    func setupAll () {
        setupViews()
        setupARconfig()
        setupGestures()
        if(allowMultipeerPlay) {setupMultipeerSession()}
        if(allowComputerPlay) {setupChessEngine()}
        setupChessBoard()
    }
    
    func setupARconfig () {
        // Configure the AR session for horizontal plane tracking.
        let arConfiguration = ARWorldTrackingConfiguration()
        arConfiguration.planeDetection = .horizontal
        //arConfiguration.isLightEstimationEnabled = true
        arConfiguration.isCollaborationEnabled = true
        arView.session.run(arConfiguration)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupAll()
    }
    
    override public var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        arView = ARView.init(frame: self.view.frame, cameraMode: .ar, automaticallyConfigureSession: true)
        self.view.addSubview(arView)
        arView.session.delegate = self
    }
    
    override public func loadView() {
        super.loadView()
        let view = UIView(frame: UIScreen.main.bounds)
        self.view = view
    }
    
    func tap(x: Int, y: Int) {
        if(selectedPiece == nil) {
            if(position[x][y] == "") {return}
            selectedPiece = game.findEntity(named: position[x][y])
            let moves = validMoves(x: x, y: y)
            if (moves.count == 0) {
                sessionInfoLabel.text = selectedPiece.name + " selected piece cannot be moved"
                selectedPiece = nil
                return
            }
            removeOverlay()
            displayValidMoves(x: x, y: y)
            startPosXY = (x, y)
        } else {
            if(!isValidMove(coord: (x, y), coords: moves)) {
                return
            }
            endPosXY = (x, y)
            movePiece(sx: startPosXY.0, sy: startPosXY.1, tx: endPosXY.0, ty: endPosXY.1)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        recordBanner.isHidden = false
        
        var col: Color = .black
        if(curColor == "w") {col = .white}
        if(computerPlays && allowComputerPlay) {return}
        guard let touchInView = sender?.location(in: self.arView) else {
            return
        }
        
        
        if let result = arView.raycast(
            from: touchInView,
            allowing: .estimatedPlane, alignment: .horizontal
        ).first {
            if(!modelTapped && !planeAnchorAdded) {
                if(!allowMultipeerPlay || ((multipeerSession != nil) &&
                    connectedWithPeer &&
                    (!multipeerSession.connectedPeers.isEmpty &&
                        (multipeerSession.clientPeerID != multipeerSession.myPeerID)))) {
                    planeAnchor = ARAnchor(name: "Base", transform: result.worldTransform)
                    self.arView.session.add(anchor: self.planeAnchor)
                    banner.text = "White to move- tap a piece to select"
                    owner = true
                    
                    if(allowMultipeerPlay && !multipeerSession.connectedPeers.isEmpty) {
                        peerIdLabel.text = "\(String(describing: multipeerSession.clientPeerID))"
                        myIdLabel.backgroundColor = .green
                        peerIdLabel.backgroundColor = .white
                    }
                }
                modelTapped = true
                return
            }
            if(self.game == nil) {return}
            guard let entities = self.arView?.entities(
                at: touchInView
                )  else {
                    // no entity was hit
                    return
            }
            for entity in entities {
                let entityName = pieceName(str:entity.name)
                if((selectedPiece != nil) && (isPiece(entity:entity)
                    && (entity2color(str:selectedPiece.name) == entity2color(str: entityName)))){
                    sessionInfoLabel.text = selectedPiece.name+" already selected"
                    return
                }
                if(isPiece(entity:entity) && selectedPiece == nil && (entity2color(str: entityName) == col)) {
                    selectedPiece = board2piece(str:entity.name)
                    let (xs, zs) = board2position(str:entity.name)
                    startPosXY = (xs, zs)
                    moves = validMoves(x: xs, y: zs)
                    if (moves.count == 0) {
                        sessionInfoLabel.text = selectedPiece.name + " selected piece cannot be moved"
                        selectedPiece = nil
                        return
                    }
                    removeOverlay()
                    displayValidMoves(x: xs, y: zs)
                    displayCell(x: xs, y: zs)
                    if(allowMultipeerPlay) {
                        guard let myData = highlightCommand(coords: moves).data(using: .ascii) else {
                            return
                        }
                        multipeerSession.sendToAllPeers(myData)
                    }
                    banner.text = "Tap on board to place piece"
                    return
                }
                if((selectedPiece != nil) && !selectedBoard &&
                    // either its an empty board or the piece is opposite color for capture
                    (isBoard(entity:entity) ||
                        (entity2color(str: entityName) != entity2color(str: selectedPiece.name)))) {
                    endPosXY = board2position(str:entity.name)
                    selectedBoard = true
                    break
                }
            }
            for entity in entities {
                if(selectedPiece == nil && !isPiece(entity:entity) && isBoard(entity:entity)) {
                    sessionInfoLabel.text = "Select piece first"
                    return
                }
            }
            
            if(!selectedBoard || (selectedPiece == nil)) {return}
            if(!isValidMove(coord: (endPosXY.0, endPosXY.1), coords: moves)) {
                selectedBoard = false
                return
            }
            movePiece(sx: startPosXY.0, sy: startPosXY.1, tx: endPosXY.0, ty: endPosXY.1)
            
            if(curColor == "w"){curColor = "b"}
            else {curColor = "w"}
            selectedPiece = nil
            selectedBoard = false
            moves=[]
            if(curColor == "w") {
                banner.text = "White to move"
            } else {
                banner.text = "Black to move"
            }
            if(allowComputerPlay) {
                computerPlays = true
                banner.text = banner.text! + "(Computer)"
                inputStatusLabel.backgroundColor = .red
                computerMove()
                inputStatusLabel.backgroundColor = .green
            } else if (!allowMultipeerPlay) {
                banner.text = banner.text! + " tap of a piece to select"
                
            } else {
                if(self.owner) {curColor = "w"}
                else {curColor = "b"}
                if(!multipeerSession.connectedPeers.isEmpty) {
                    guard let myData = "move \(startPosXY.0),\(startPosXY.1) \(endPosXY.0),\(endPosXY.1)".data(using: .ascii) else {
                        return
                    }
                    multipeerSession.sendToAllPeers(myData)
                    peerIdLabel.backgroundColor = .green
                    myIdLabel.backgroundColor = .white
                    //banner.text = banner.text! + " \(String(describing: multipeerSession.clientPeerID)) to play"
                    
                }
                inputStatusLabel.backgroundColor = .red
            }
            recordBanner.text = recordString
            fenBanner.text = "position fen "+get_fen(arr:position)+" "+curColor+" "+castling+" -"
            sessionInfoLabel.text = ""
        }
    }
}





