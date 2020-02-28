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

let runLoop = CFRunLoopGetCurrent()

struct PlayGroundVars {
    
    public var hintSx: Int! = -1
    public var hintSy: Int! = -1
    public var hintTx: Int! = -1
    public var hintTy: Int! = -1
    public var hintStr: String! = ""
    public var soundEnabled: Bool = true
    public var status: Int! = -1
    public var response: Bool = false
    public var wait:Bool = true
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
                playGroundVars.hintStr = int2string(s:playGroundVars.hintSx)+String(playGroundVars.hintSy)+int2string(s:playGroundVars.hintTx)+String(playGroundVars.hintTy)
            case "wait":
                if(strArr[1] == "false") {
                    playGroundVars.wait = false
                } else {
                    playGroundVars.wait = true
                }
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
 */

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

func string2int(s:String) -> Int {
    if(s == "a") {return(0)}
    else if(s == "b") {return(1)}
    else if(s == "c") {return(2)}
    else if(s == "d") {return(3)}
    else if(s == "e") {return(4)}
    else if(s == "f") {return(5)}
    else if(s == "g") {return(6)}
    else if(s == "h") {return(7)}
    return(0)
}

/*
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

func str2mode(str: String) -> PlayingMode {
    if(str == "single") {return .SingleDevice}
    else if(str == "computer") {return .Computer}
    else if(str == "multi") {return .MultiDevice}
    else {return .SingleDevice}
}

public func setMode(mode: PlayingMode) {
    let str=mode2str(mode: mode)
    proxy?.send(.string("mode "+String(str)))
}

public func wait() {
    CFRunLoopRun()
}

public func play() {
    proxy?.send(.string("play"))
}

public func tap(str: String) {
    proxy?.send(.string("tap "+String(str)))
}

public func move(str: String) {
    proxy?.send(.string("move "+String(str)))
}

public func analyze() {
    playGroundVars.response = false
    proxy?.send(.string("analyze"))
    repeat{
        RunLoop.main.run(mode: .default, before: Date(timeIntervalSinceNow: 0.1))
    } while playGroundVars.response == false
}

*/
