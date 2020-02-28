//
//  ViewController+Playground.swift
//  ChessReality
//
//  Created by Anav Mehta on 2/20/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation

/*
 
import PlaygroundSupport
extension ViewController : PlaygroundLiveViewMessageHandler {
    
    public func receive(_ message: PlaygroundValue) {
        var sx: Int! = -1
        var sy: Int! = -1
        var tx: Int! = -1
        var ty: Int! = -1
        var status: Int! = -1
        switch message {
        case let .string(text):
            let strArr = text.split(separator: " ")
            switch strArr[0] {
            case "play":
                play()
                _ = 0
            case "analyze":
                (sx!,sy!,tx!,ty!) = analyze()
                self.send(.string("analyze " + String(sx!) + " " + String(sy!) + " " + String(tx!) + " " + String(ty!)))
            case "sound":
                if(strArr[1] == "true") {sound(enabled: true)}
                else {sound(enabled: false)}
                _ = 0
            case "animation":
                if(strArr[1] == "true") {animation(enabled: true)}
                else {animation(enabled: false)}
            case "move":
                if(strArr.size() > 2) {
                    move(sx: Int(strArr[1])!, sy: Int(strArr[2])!, tx: Int(strArr[3])!, ty: Int(strArr[4])!
                } else {move(str: strArr[1]!)}
            case "tap":
                tap(x: Int(strArr[1])!-1, y: Int(strArr[2])!-1)

            default:
                print("Not a recognized command")
            }
        default:
            print("A valid message not received")
        }
        
    }
    
}
*/
