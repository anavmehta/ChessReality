//
//  ViewController+UIView.swift
//  ChessReality
//
//  Created by Anav Mehta on 2/19/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import UIKit


extension ViewController {
    
    @objc func changePref(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            allowComputerPlay = true
            allowMultipeerPlay = false
            restartGame()
        case 2:
            allowMultipeerPlay = true
            allowComputerPlay = false
            restartGame()
        default:
            allowMultipeerPlay = false
            allowComputerPlay = false
            restartGame()
        }
    }
    func setupViews() {
        //let font=UIFont.boldSystemFont(ofSize: 10)
        let defaultFont = "TimesNewRomanPSMT"
        
        var font=UIFont(name: defaultFont, size: 12)
        customSC = UISegmentedControl(items: self.items)
        customSC.setTitleTextAttributes([NSAttributedString.Key.font: font!], for: .normal)
        customSC.selectedSegmentIndex = 0
        customSC.backgroundColor = .lightGray
        customSC.tintColor = .white
        self.view.addSubview(customSC)
        
        // Add target action method
        
        customSC.addTarget(self, action: #selector(self.changePref(_:)), for: .valueChanged)
        customSC.translatesAutoresizingMaskIntoConstraints = false
        customSC.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        customSC.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0).isActive = true
        customSC.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.05).isActive = true
        customSC.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        customSC.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        
        font=UIFont(name: defaultFont, size: 12)
        sessionInfoLabel.font = font
        sessionInfoLabel.textAlignment = .center
        sessionInfoLabel.backgroundColor = .black
        sessionInfoLabel.textColor = .white
        sessionInfoLabel.lineBreakMode = .byWordWrapping
        // allows the UILabel to display an unlimited number of lines
        sessionInfoLabel.numberOfLines = 0;
        self.view.addSubview(sessionInfoLabel)
        
        sessionInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        sessionInfoLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = false
        sessionInfoLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.75).isActive = true
        sessionInfoLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.025).isActive = true
        sessionInfoLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        sessionInfoLabel.topAnchor.constraint(equalTo: self.customSC.bottomAnchor, constant: 0).isActive = true
        
        font=UIFont(name: defaultFont, size: 8)
        myIdLabel.font = font
        myIdLabel.textAlignment = .center
        myIdLabel.backgroundColor = .black
        myIdLabel.textColor = .white
        myIdLabel.lineBreakMode = .byWordWrapping
        myIdLabel.text = UIDevice.current.name
        // allows the UILabel to display an unlimited number of lines
        myIdLabel.numberOfLines = 0;
        self.view.addSubview(myIdLabel)
        
        myIdLabel.translatesAutoresizingMaskIntoConstraints = false
        myIdLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = false
        myIdLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.25).isActive = true
        myIdLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0125).isActive = true
        myIdLabel.leadingAnchor.constraint(equalTo: self.sessionInfoLabel.trailingAnchor).isActive = true
        myIdLabel.topAnchor.constraint(equalTo: self.customSC.bottomAnchor, constant: 0).isActive = true
        
        peerIdLabel.font = font
        peerIdLabel.textAlignment = .center
        peerIdLabel.backgroundColor = .black
        peerIdLabel.textColor = .white
        peerIdLabel.lineBreakMode = .byWordWrapping
        peerIdLabel.text = ""
        // allows the UILabel to display an unlimited number of lines
        peerIdLabel.numberOfLines = 0;
        self.view.addSubview(peerIdLabel)
        
        peerIdLabel.translatesAutoresizingMaskIntoConstraints = false
        peerIdLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = false
        peerIdLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.25).isActive = true
        peerIdLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0125).isActive = true
        peerIdLabel.leadingAnchor.constraint(equalTo: self.sessionInfoLabel.trailingAnchor).isActive = true
        peerIdLabel.topAnchor.constraint(equalTo: self.myIdLabel.bottomAnchor, constant: 0).isActive = true
        
        font=UIFont(name: defaultFont, size: 12)
        banner.font = font
        banner.textAlignment = .center
        banner.backgroundColor = .black
        banner.textColor = .white
        banner.lineBreakMode = .byWordWrapping
        banner.text = "Move around and tap on screen to place chessboard"
        self.view.addSubview(banner)
        
        banner.translatesAutoresizingMaskIntoConstraints = false
        //banner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        banner.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.875).isActive = true
        banner.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.025).isActive = true
        banner.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        banner.topAnchor.constraint(equalTo: self.sessionInfoLabel.bottomAnchor, constant: 0).isActive = true
        

        inputStatusLabel.font = font
        inputStatusLabel.textAlignment = .center
        inputStatusLabel.backgroundColor = .green
        inputStatusLabel.textColor = .white
        inputStatusLabel.lineBreakMode = .byWordWrapping
        inputStatusLabel.text = ""
        self.view.addSubview(inputStatusLabel)
        
        inputStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        //banner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        inputStatusLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.0625).isActive = true
        inputStatusLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.025).isActive = true
        inputStatusLabel.leadingAnchor.constraint(equalTo: self.banner.trailingAnchor).isActive = true
        inputStatusLabel.topAnchor.constraint(equalTo: self.peerIdLabel.bottomAnchor, constant: 0).isActive = true
        
        connectionStatusLabel.font = font
        connectionStatusLabel.textAlignment = .center
        connectionStatusLabel.backgroundColor = .red
        connectionStatusLabel.textColor = .white
        connectionStatusLabel.lineBreakMode = .byWordWrapping
        connectionStatusLabel.text = ""
        self.view.addSubview(connectionStatusLabel)
        
        connectionStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        //banner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        connectionStatusLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.0625).isActive = true
        connectionStatusLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.025).isActive = true
        connectionStatusLabel.leadingAnchor.constraint(equalTo: self.inputStatusLabel.trailingAnchor).isActive = true
        connectionStatusLabel.topAnchor.constraint(equalTo: self.peerIdLabel.bottomAnchor, constant: 0).isActive = true

        font=UIFont(name: defaultFont, size: 10)
        fenBanner = UILabel()
        fenBanner.font = font
        fenBanner.textAlignment = .left
        fenBanner.backgroundColor = .black
        fenBanner.textColor = .white
        fenBanner.text = ""
        fenBanner.lineBreakMode = .byWordWrapping
        self.view.addSubview(fenBanner)
        
        fenBanner.translatesAutoresizingMaskIntoConstraints = false
        fenBanner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        fenBanner.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0).isActive = true
        fenBanner.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.025).isActive = true
        fenBanner.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        fenBanner.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        
        recordBanner = UILabel()
        recordBanner.font = font
        recordBanner.textAlignment = .left
        recordBanner.backgroundColor = .black
        recordBanner.textColor = .white
        recordBanner.lineBreakMode = .byWordWrapping
        recordBanner.text = ""
        self.view.addSubview(recordBanner)
        
        recordBanner.translatesAutoresizingMaskIntoConstraints = false
        recordBanner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        recordBanner.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0).isActive = true
        recordBanner.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.05).isActive = true
        recordBanner.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        recordBanner.bottomAnchor.constraint(equalTo: self.fenBanner.topAnchor, constant: 0).isActive = true
        
        

    }
}
