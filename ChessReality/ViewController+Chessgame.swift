//
//  ViewController+Chessgame.swift
//  ChessReality
//
//  Created by Anav Mehta on 2/10/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import RealityKit

extension ViewController {
    
    enum Piece {
        case pawn
        case rook
        case queen
        case king
        case bishop
        case knight
        case empty
    }
    enum Color {
        case black
        case white
    }

    func setupBoard() {
        for i in 0...7 {
            for j in 0...7 {
                position[i][j] = ""
            }
        }
        position[0][0] = "wr0"
        position[0][1] = "wn0"
        position[0][2] = "wb0"
        position[0][3] = "wq"
        position[0][4] = "wk"
        position[0][5] = "wb1"
        position[0][6] = "wn1"
        position[0][7] = "wr1"
        position[1][0] = "wp0"
        position[1][1] = "wp1"
        position[1][2] = "wp2"
        position[1][3] = "wp3"
        position[1][4] = "wp4"
        position[1][5] = "wp5"
        position[1][6] = "wp6"
        position[1][7] = "wp7"
        
        position[7][0] = "br0"
        position[7][1] = "bn0"
        position[7][2] = "bb0"
        position[7][3] = "bq"
        position[7][4] = "bk"
        position[7][5] = "bb1"
        position[7][6] = "bn1"
        position[7][7] = "br1"
        position[6][0] = "bp0"
        position[6][1] = "bp1"
        position[6][2] = "bp2"
        position[6][3] = "bp3"
        position[6][4] = "bp4"
        position[6][5] = "bp5"
        position[6][6] = "bp6"
        position[6][7] = "bp7"
        
    }
    
    func int2string(s:Int) -> String {
        if(s == 0) {return("a")}
        else if(s == 1) {return("b")}
        else if(s == 2) {return("c")}
        else if(s == 3) {return("d")}
        else if(s == 4) {return("e")}
        else if(s == 5) {return("f")}
        else if(s == 6) {return("g")}
        else if(s == 7) {return("h")}
        return("")
    }
    
    func displayValidMoves(x: Int, y: Int) {
        let coords: [(Int, Int)] = validMoves(x: x, y: y)
        for coord in coords {
            let (x, z) = coord
            overlayEntities[x][z].isEnabled = true
            
        }
        
    }
    
    func displayCell(x: Int, y: Int) {
        overlayEntities[x][y].isEnabled = true
    }
    
    func removeCell(x: Int, y: Int) {
        overlayEntities[x][y].isEnabled = false
    }
    
    func isValidMove(coord: (Int, Int), coords: [(Int, Int)]) -> Bool {
        for c in coords {
            if(coord == c) {
                return(true)
            }
        }
        return(false)
    }
    
    func isBoard(entity: Entity) -> Bool{
        if(entity.name == "cb"){return(true)}
        return(false)
    }
    
    func isPiece(entity: Entity) -> Bool{
        if(entity.name == "wr0"){return(true)}
        if(entity.name == "wn0"){return(true)}
        if(entity.name == "wb0"){return(true)}
        if(entity.name == "wq"){return(true)}
        if(entity.name == "wk"){return(true)}
        if(entity.name == "wb1"){return(true)}
        if(entity.name == "wn1"){return(true)}
        if(entity.name == "wr1"){return(true)}
        if(entity.name == "wp0"){return(true)}
        if(entity.name == "wp1"){return(true)}
        if(entity.name == "wp2"){return(true)}
        if(entity.name == "wp3"){return(true)}
        if(entity.name == "wp4"){return(true)}
        if(entity.name == "wp5"){return(true)}
        if(entity.name == "wp6"){return(true)}
        if(entity.name == "wp7"){return(true)}
        
        if(entity.name == "br0"){return(true)}
        if(entity.name == "bn0"){return(true)}
        if(entity.name == "bb0"){return(true)}
        if(entity.name == "bq"){return(true)}
        if(entity.name == "bk"){return(true)}
        if(entity.name == "br1"){return(true)}
        if(entity.name == "bb1"){return(true)}
        if(entity.name == "bn1"){return(true)}
        if(entity.name == "bp0"){return(true)}
        if(entity.name == "bp1"){return(true)}
        if(entity.name == "bp2"){return(true)}
        if(entity.name == "bp3"){return(true)}
        if(entity.name == "bp4"){return(true)}
        if(entity.name == "bp5"){return(true)}
        if(entity.name == "bp6"){return(true)}
        if(entity.name == "bp7"){return(true)}
        
        return(false)
    }
    
    func entity2color(str: String) -> Color {
        let start = str.index(str.startIndex, offsetBy: 0)
        let end = str.index(str.startIndex, offsetBy: 1)
        let range = start..<end
        let subStr = str[range]
        if(subStr == "w") {return(.white)}
        return(.black)
        
    }
    
    func entity2piece(str: String) -> Piece {
        let start = str.index(str.startIndex, offsetBy: 1)
        let end = str.index(str.startIndex, offsetBy: 2)
        let range = start..<end
        let subStr = str[range]
        if(subStr == "r") {return(.rook)}
        if(subStr == "b") {return(.bishop)}
        if(subStr == "n") {return(.knight)}
        if(subStr == "q") {return(.queen)}
        if(subStr == "k") {return(.king)}
        if(subStr == "p") {return(.pawn)}
        
        return(.empty)
    }
    
    func isValid(x: Int, y: Int) -> Bool {
        return(x >= 0 && x < 8 && y >= 0 && y < 8)
    }
    func isAvailable(x: Int, y: Int) -> Bool {
        if(position[x][y] == ""){return true}
        return false
    }
    
    func isOppositeColor(x: Int,y: Int,color:Color) -> Bool {
        let str : String = position[x][y]
        let start = str.index(str.startIndex, offsetBy: 0)
        let end = str.index(str.startIndex, offsetBy: 1)
        let range = start..<end
        let subStr = str[range]
        if((subStr == "w") && (color == .black)) {return(true)}
        if((subStr == "b") && (color == .white)) {return(true)}
        return(false)
    }
    
    func snapToBoard(x: Float, z: Float) -> (xs: Int, zs:Int) {
        var xs, zs: Int
        xs = Int((x+0.20)/0.05)
        zs = Int((z+0.20)/0.05)
        if(xs < 0){xs = 0}
        if(zs < 0){zs = 0}
        if(xs > 8){xs = 7}
        if(zs > 8){zs = 7}
        return(xs, zs)
    }
    
    func boardToPieceCoords(x: Int, z: Int) -> (xs: Float, zs: Float) {
        var xs, zs: Float
        xs = Float(x)*0.05-0.2
        zs = Float(z)*0.05-0.2
        return(xs, zs)
    }
    // MARK: EngineManagerDelegate
    
    func translateMove(move: String) -> (Int,Int,Int,Int) {
        if((move == "") || (move == "(none)")) {return(-1,-1,-1,-1)}
        let tmpArry = Array(move)
        let scol: Int = Int(tmpArry[0].unicodeScalars.map{$0.value}[0]-"a".unicodeScalars.map{$0.value}[0])
        let srow: Int = Int(tmpArry[1].unicodeScalars.map{$0.value}[0]-"1".unicodeScalars.map{$0.value}[0])
        let ecol: Int = Int(tmpArry[2].unicodeScalars.map{$0.value}[0]-"a".unicodeScalars.map{$0.value}[0])
        let erow: Int = Int(tmpArry[3].unicodeScalars.map{$0.value}[0]-"1".unicodeScalars.map{$0.value}[0])
        return (srow, scol, erow, ecol)
    }
    
    func updateBoard(pieceName: String, sx: Int, sy: Int, tx: Int, ty: Int) {
        position[sx][sy] = ""
        if(position[tx][ty] != "") {
            let entity: Entity! = arView.scene.findEntity(named: position[tx][ty])
            entity.removeFromParent()
            entity.isEnabled = false
        }
        position[tx][ty] = pieceName
    }
    
    func algebraicNotation(srow: Int, scol: Int, erow: Int, ecol: Int, piece: Piece, color: Color) {
        var s: String = ""
        let spiece: String = position[srow][scol]
        let epiece: String = position[erow][ecol]
        let piece = entity2piece(str: spiece)
        let color = entity2color(str: spiece)
        if(color == .white) {
            numMoves = numMoves + 1
            s = String(numMoves) + "."
        }

        if(piece == .king) {s = s + "K"}
        else if(piece == .queen) {s = s + "Q"}
        else if(piece == .knight) {s = s + "N"}
        else if(piece == .rook) {s = s + "R"}
        else if(piece == .bishop) {s = s + "B"}
        if(epiece != "") {s = s + "x"}
        if(piece != .pawn) {s = s + int2string(s:scol)}
        //s = s + String(erow)
        let c:String! = int2string(s: ecol)
        s = s + c + String(erow+1) + " "
        recordBanner.text = recordBanner.text + s
    }
    
    func setupOverlay() {
        
        let cb: Entity! = arView.scene.findEntity(named: "cb")
        let box = MeshResource.generateBox(size: [0.025,0.01,0.025]) // Generate mesh
        //var material = SimpleMaterial(color: .green, isMetallic: true)
        var material = SimpleMaterial()
        material.baseColor = MaterialColorParameter.color(.init(red: 0.0,
                                                                green: 1.0,
                                                                blue: 0.0,
                                                                alpha: 0.8))
        material.roughness = MaterialScalarParameter(floatLiteral: 0.0)
        material.metallic = MaterialScalarParameter(floatLiteral: 1.0)
        
       
        for i in 0...7 {
            for j in 0...7 {
                overlayEntities[i][j] = ModelEntity(mesh: box, materials: [material])
                cb.addChild(overlayEntities[i][j])
                let x = 0.05*Float(i)-0.175
                let z = 0.05*Float(j)-0.175
                overlayEntities[i][j].setPosition([x, 0.01, z], relativeTo: cb)
                overlayEntities[i][j].isEnabled = false
            }
        }
    }
    
    func removeOverlay() {
        for i in 0...7 {
            for j in 0...7 {
                overlayEntities[i][j].isEnabled = false
            }
        }
    }
    
    func displayMove() {
        var col: Color = .black
        if(curColor == "w") {col = .white}
        let cb: Entity! = arView.scene.findEntity(named: "cb")
        let (srow, scol, erow, ecol) = translateMove(move: bestMoveNext)
        let pieceName = position[srow][scol]
        let piece: Entity! = arView.scene.findEntity(named: pieceName)
        let x = 0.05*Float(erow)-0.175
        let z = 0.05*Float(ecol)-0.175
        piece.setPosition([x, 0.0, z], relativeTo: cb)
        algebraicNotation(srow: srow, scol: scol, erow: erow, ecol: ecol, piece: entity2piece(str: piece.name), color: col)
        updateBoard(pieceName: pieceName, sx: srow, sy: scol, tx: erow, ty: ecol)
        displayCell(x: erow, y: ecol)
        bestMoveNext = ""
    }
    
    func validMoves(x: Int, y: Int) -> [(Int, Int)] {
        let str = position[x][y]
        let piece = entity2piece(str: str)
        let color = entity2color(str: str)
        var retArr: [(Int, Int)] = []
        switch piece {
        case .empty :
            return([])
            
        case .bishop :
            for i in 1...7 {
                if(isValid(x: x+i, y:y+i)) {
                    if(isAvailable(x: x+i, y:y+i)) {
                        retArr.append((x+i, y+i))
                    } else {
                        if(isOppositeColor(x:x+i,y:y+i,color:color)) {
                            retArr.append((x+i,y+i))
                        }
                        break;
                    }
                }
            }
            for i in 1...7 {
                if(isValid(x: x+i, y:y-i)) {
                    if(isAvailable(x: x+i, y:y-i)) {
                        retArr.append((x+i, y-i))
                    } else {
                        if(isOppositeColor(x:x+i,y:y-i,color:color)) {
                            retArr.append((x+i,y-i))
                        }
                        break;
                    }
                }
            }
            for i in 1...7 {
                if(isValid(x: x-i, y:y+i)) {
                    if(isAvailable(x: x-i, y:y+i)) {
                        retArr.append((x-i, y+i))
                    } else {
                        if(isOppositeColor(x:x-i,y:y+i,color:color)) {
                            retArr.append((x-i,y+i))
                        }
                        break;
                    }
                }
            }
            for i in 1...7 {
                if(isValid(x: x-i, y:y-i)) {
                    if(isAvailable(x: x-i, y:y-i)) {
                        retArr.append((x-i, y-i))
                    } else {
                        if(isOppositeColor(x:x-i,y:y-i,color:color)) {
                            retArr.append((x-i,y-i))
                        }
                        break;
                    }
                }
            }
            
        case .queen : // a queen is basically moving like a bishop or a rook
// bishop
            for i in 1...7 {
                if(isValid(x: x+i, y:y+i)) {
                    if(isAvailable(x: x+i, y:y+i)) {
                        retArr.append((x+i, y+i))
                    } else {
                        if(isOppositeColor(x:x+i,y:y+i,color:color)) {
                            retArr.append((x+i,y+i))
                        }
                        break;
                    }
                }
            }
            for i in 1...7 {
                if(isValid(x: x+i, y:y-i)) {
                    if(isAvailable(x: x+i, y:y-i)) {
                        retArr.append((x+i, y-i))
                    } else {
                        if(isOppositeColor(x:x+i,y:y-i,color:color)) {
                            retArr.append((x+i,y-i))
                        }
                        break;
                    }
                }
            }
            for i in 1...7 {
                if(isValid(x: x-i, y:y+i)) {
                    if(isAvailable(x: x-i, y:y+i)) {
                        retArr.append((x-i, y+i))
                    } else {
                        if(isOppositeColor(x:x-i,y:y+i,color:color)) {
                            retArr.append((x-i,y+i))
                        }
                        break;
                    }
                }
            }
            for i in 1...7 {
                if(isValid(x: x-i, y:y-i)) {
                    if(isAvailable(x: x-i, y:y-i)) {
                        retArr.append((x-i, y-i))
                    } else {
                        if(isOppositeColor(x:x-i,y:y-i,color:color)) {
                            retArr.append((x-i,y-i))
                        }
                        break;
                    }
                }
            }
// rook
            for i in 1...7 {
                if(isValid(x: x, y:y+i)) {
                    if(isAvailable(x: x, y:y+i)) {
                        retArr.append((x, y+i))
                    } else {
                        if(isOppositeColor(x:x,y:y+i,color:color)) {
                            retArr.append((x,y+i))
                        }
                        break;
                    }
                }
            }
            for i in 1...7 {
                if(isValid(x: x, y:y-i)) {
                    if(isAvailable(x: x, y:y-i)) {
                        retArr.append((x, y-i))
                    } else {
                        if(isOppositeColor(x:x,y:y-i,color:color)) {
                            retArr.append((x,y-i))
                        }
                        break;
                    }
                }
            }
            for i in 1...7 {
                if(isValid(x: x+i, y:y)) {
                    if(isAvailable(x: x+i, y:y)) {
                        retArr.append((x+i, y))
                    } else {
                        if(isOppositeColor(x:x+i,y:y,color:color)) {
                            retArr.append((x+i,y))
                        }
                        break;
                    }
                }
            }
            for i in 1...7 {
                if(isValid(x: x-i, y:y)) {
                    if(isAvailable(x: x-i, y:y)) {
                        retArr.append((x-i, y))
                    } else {
                        if(isOppositeColor(x:x-i,y:y,color:color)) {
                            retArr.append((x-i,y))
                        }
                        break;
                    }
                }
            }
            
        case .king :
            for i in 0...1 {
                for j in 0...1 {
                    if(i == 0 && j == 0) {continue}
                    if(isValid(x:x+i,y:y+j) && isAvailable(x: x+i, y:y+j)) {
                        retArr.append((x+i,y+j))
                    }
                    if(isValid(x:x-i,y:y+j) && isAvailable(x: x-i, y:y+j)) {
                        retArr.append((x-i,y+j))
                    }
                    if(isValid(x:x+i,y:y-j) && isAvailable(x: x+i, y:y-j)) {
                        retArr.append((x+i,y-j))
                    }
                    if(isValid(x:x-i,y:y-j) && isAvailable(x: x-i, y:y-j)) {
                        retArr.append((x-i,y-j))
                    }
                }
            }
        case .rook :
            for i in 1...7 {
                if(isValid(x: x, y:y+i)) {
                    if(isAvailable(x: x, y:y+i)) {
                        retArr.append((x, y+i))
                    } else {
                        if(isOppositeColor(x:x,y:y+i,color:color)) {
                            retArr.append((x,y+i))
                        }
                        break;
                    }
                }
            }
            for i in 1...7 {
                if(isValid(x: x, y:y-i)) {
                    if(isAvailable(x: x, y:y-i)) {
                        retArr.append((x, y-i))
                    } else {
                        if(isOppositeColor(x:x,y:y-i,color:color)) {
                            retArr.append((x,y-i))
                        }
                        break;
                    }
                }
            }
            for i in 1...7 {
                if(isValid(x: x+i, y:y)) {
                    if(isAvailable(x: x+i, y:y)) {
                        retArr.append((x+i, y))
                    } else {
                        if(isOppositeColor(x:x+i,y:y,color:color)) {
                            retArr.append((x+i,y))
                        }
                        break;
                    }
                }
            }
            for i in 1...7 {
                if(isValid(x: x-i, y:y)) {
                    if(isAvailable(x: x-i, y:y)) {
                        retArr.append((x-i, y))
                    } else {
                        if(isOppositeColor(x:x-i,y:y,color:color)) {
                            retArr.append((x-i,y))
                        }
                        break;
                    }
                }
            }
            
        case .knight :
            if(isValid(x: x+1, y:y+2)) {
                if(isAvailable(x: x+1, y:y+2)) {
                    retArr.append((x+1, y+2))
                } else {
                    if(isOppositeColor(x:x+1,y:y+2,color:color)) {
                        retArr.append((x+1,y+2))
                    }
                }
            }
            if(isValid(x: x-1, y:y+2)) {
                if(isAvailable(x: x-1, y:y+2)) {
                    retArr.append((x-1, y+2))
                } else {
                    if(isOppositeColor(x:x-1,y:y+2,color:color)) {
                        retArr.append((x-1,y+2))
                    }
                }
            }
            if(isValid(x: x+1, y:y-2)) {
                if(isAvailable(x: x+1, y:y-2)) {
                    retArr.append((x+1, y-2))
                } else {
                    if(isOppositeColor(x:x+1,y:y-2,color:color)) {
                        retArr.append((x+1,y-2))
                    }
                }
            }
            if(isValid(x: x-1, y:y-2)) {
                if(isAvailable(x: x-1, y:y-2)) {
                    retArr.append((x-1, y-2))
                } else {
                    if(isOppositeColor(x:x-1,y:y-2,color:color)) {
                        retArr.append((x-1,y-2))
                    }
                }
            }
            if(isValid(x: x+2, y:y+1)) {
                if(isAvailable(x: x+2, y:y+1)) {
                    retArr.append((x+2, y+1))
                } else {
                    if(isOppositeColor(x:x+2,y:y+1,color:color)) {
                        retArr.append((x+2,y+1))
                    }
                }
            }
            if(isValid(x: x-2, y:y+1)) {
                if(isAvailable(x: x-2, y:y+1)) {
                    retArr.append((x-2, y+1))
                } else {
                    if(isOppositeColor(x:x-2,y:y+1,color:color)) {
                        retArr.append((x-2,y+1))
                    }
                }
            }
            if(isValid(x: x+2, y:y-1)) {
                if(isAvailable(x: x+2, y:y-1)) {
                    retArr.append((x+2, y-1))
                } else {
                    if(isOppositeColor(x:x+2,y:y-1,color:color)) {
                        retArr.append((x+2,y-1))
                    }
                }
            }
            if(isValid(x: x-2, y:y-1)) {
                if(isAvailable(x: x-2, y:y-1)) {
                    retArr.append((x-2, y-1))
                } else {
                    if(isOppositeColor(x:x-2,y:y-1,color:color)) {
                        retArr.append((x-2,y-1))
                    }
                }
            }
        case .pawn:
            if(color == .white) {
                if(isValid(x: x+1, y:y)) {
                    if(isAvailable(x: x+1, y:y)) {
                        retArr.append((x+1, y))
                    }
                }
                if(x == 1) {
                    if(isValid(x: x+2, y:y)) {
                        if(isAvailable(x:x+2,y:y) && isAvailable(x:x+1,y:y)) {
                            retArr.append((x+2, y))
                        }
                    }
                }
                if(isValid(x:x+1,y:y+1)) {
                    if(!isAvailable(x:x+1, y:y+1) && isOppositeColor(x:x+1,y:y+1, color:color)) {
                        retArr.append((x+1,y+1))
                        
                    }
                }
                if(isValid(x:x+1,y:y+1)) {
                    if(!isAvailable(x:x+1, y:y-1) && isOppositeColor(x:x+1,y:y-1, color:color)) {
                        retArr.append((x+1,y-1))
                        
                    }
                }
            } else {
                if(isValid(x: x-1, y:y)) {
                    if(isAvailable(x: x-1, y:y)) {
                        retArr.append((x-1, y))
                    }
                }
                if(x == 6) {
                    if(isValid(x: x-2, y:y)) {
                        if(isAvailable(x: x-2, y:y) && isAvailable(x:x-1,y:y)) {
                            retArr.append((x-2, y))
                        }
                    }
                }
                if(isValid(x:x-1,y:y+1)) {
                    if(!isAvailable(x:x-1, y:y+1) && isOppositeColor(x:x-1,y:y+1, color:color)) {
                        retArr.append((x-1,y+1))
                        
                    }
                }
                if(isValid(x:x-1,y:y+1)) {
                    if(!isAvailable(x:x-1, y:y-1) && isOppositeColor(x:x-1,y:y-1, color:color)) {
                        retArr.append((x-1,y-1))
                        
                    }
                }
            }
        }
        
        return(retArr)
        
    }
    func get_fen(arr: [[String]]) -> String {
        var fen: String = ""
        var fen_row: String = ""
        var prev_blanks: Int = 0
        var sq: String
        
        for row in (0...7).reversed() {
            fen_row = ""
            prev_blanks = 0
            for col in 0...7 {
                sq = arr[row][col]
                if (sq == "empty" || sq == "" || sq == " ") {
                    prev_blanks = prev_blanks+1
                    if(col == 7) {
                        fen_row += String(prev_blanks)
                        prev_blanks = 0
                    }
                } else {
                    if(prev_blanks != 0) {fen_row += String(prev_blanks)}
                    prev_blanks = 0
                    let start = sq.index(sq.startIndex, offsetBy: 1)
                    let end = sq.index(sq.startIndex, offsetBy: 2)
                    if(sq.prefix(1) == "b") {
                        fen_row += sq[start..<end]
                    } else {
                        fen_row += sq[start..<end].uppercased()
                    }
                }
            }
            if(7 > row) {fen_row = "/" + fen_row}
            fen = fen + fen_row
        }
        return fen
    }
}
