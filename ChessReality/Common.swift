// Common.swift
// ChessReality
// Created by Anav Mehta 2/18/2020
// Copyright (c) 2020 Anav Mehta. All rights reserved
import Foundation
import UIKit

//import PlaygroundSupport


public enum PlayingMode {
    case SingleDevice
    case Computer
    case MultiDevice
}



struct PlayGroundVars {

    public var hintSx: Int! = -1
    public var hintSy: Int! = -1
    public var hintTx: Int! = -1
    public var hintTy: Int! = -1
    public var soundEnabled: Bool = true
    public var status: Int! = -1
    public var response: Bool = false
}
var playGroundVars: PlayGroundVars = PlayGroundVars()

/*

let proxy = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy
public class PlaygroundListener: PlaygroundRemoteLiveViewProxyDelegate {
    public static let shared = PlaygroundListener()
    
    public func setup() {
        if let proxy = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy {
            proxy.delegate = self
        }
    }
    public func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy,
                                    received message: PlaygroundValue) {
        switch message {
        case let .string(text):
            let strArr = text.split(separator: " ")
            switch strArr[0] {
            case "analyze":
                playGroundVars.hintSx = Int(strArr[1])!
                playGroundVars.hintSy = Int(strArr[2])!
                playGroundVars.hintTx = Int(strArr[3])!
                playGroundVars.hintTy = Int(strArr[4])!
            default:
                print("Not a recognized command")
            }
        default:
            print("A valid message not received")
        }
        playGroundVars.response = true
    }
    public func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) {
        PlaygroundPage.current.finishExecution()
    }
}

public func sound(enabled: Bool) {
    proxy?.send(.string("sound "+String(enabled)))
}

public func animation(enabled: Bool) {
    proxy?.send(.string("animation "+String(enabled)))
}

func mode2str(mode: PlayingMode) -> String {
    if(mode == .SingleDevice) {return "single"}
    else if(mode == .Computer) {return "computer"}
    else if(mode == .MultiDevice) {return "multi"}
    else {return ""}
}

public func setMode(mode: PlayingMode) {
    let str=mode2str(mode: mode)
    proxy?.send(.string("mode "+String(str)))
}

public func play() {
    proxy?.send(.string("play"))
}

public func tap(x: Int, y: Int) {
    proxy?.send(.string("tap "+String(x)+" "+String(y)))
}

public func move(sx: Int, sy: Int, tx: Int, ty: Int) {
    proxy?.send(.string("move "+String(sx)+" "+String(sy)+" "+String(tx)+" "+String(ty)))
}

public func analyze() {
    playGroundVars.response = false
    proxy?.send(.string("analyze"))
    repeat{
        RunLoop.main.run(mode: .default, before: Date(timeIntervalSinceNow: 0.1))
    } while playGroundVars.response == false
}

*/
