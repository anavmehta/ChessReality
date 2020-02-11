//
//  ViewController+ChessEngine.swift
//  ChessReality
//
//  Created by Anav Mehta on 2/10/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import ChessEngine

extension ViewController {
    
    func computerMove() {
        if(!computerPlays && allowComputerPlay) {return}

        let fenStr = get_fen(arr:position)
        gameFen="position fen "+fenStr+" "+curColor+" "+castling+" -"
        print(gameFen)
        startAnalysis()
        removeOverlay()
        displayMove()
        if(curColor == "w"){curColor = "b"}
        else {curColor = "w"}
        if(curColor == "b") {
            banner.text = "Black to play "
            banner.backgroundColor = .white
            banner.textColor = .black
        } else {
            banner.text = "White to play"
            banner.backgroundColor = .black
            banner.textColor = .white
        }
        computerPlays = false
    }

    func setupChessEngine() {
        engineManager.delegate = self
        engineManager.gameFen = gameFen
        engineManager.depth = 5
    }

    func startAnalysis() {
        finishedAnalyzing = false
        engineManager.gameFen = gameFen
        engineManager.startAnalyzing()
        let time = DispatchTime.now() + DispatchTimeInterval.milliseconds(25)
        DispatchQueue.global().asyncAfter(deadline: time, execute: {
                self.engineManager.stopAnalyzing()
        })
        repeat{
            RunLoop.main.run(mode: .default, before: Date(timeIntervalSinceNow: 0.5))
        } while (finishedAnalyzing == false)

    }
    
    public func engineManager(_ engineManager: EngineManager, didReceivePrincipalVariation pv: String) {
        print("PV: \(pv)")
    }
    
    public func engineManager(_ engineManager: EngineManager, didUpdateSearchingStatus searchingStatus: String) {
        print("Searching status: \(searchingStatus)")
    }
    
    public func engineManager(_ engineManager: EngineManager, didReceiveBestMove bestMove: String?, ponderMove: String?) {
        if let bestMove = bestMove {
            bestMoveNext = bestMove
            print("Best move is \(bestMove)")
            finishedAnalyzing = true
            computerPlays = false
        } else {
            print("No available moves")
        }
    }
    
    public func engineManager(_ engineManager: EngineManager, didAnalyzeCurrentMove currentMove: String, number: Int, depth: Int) {
        
    }
}