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
    
    @objc public func hinted(sender: UIButton!) {
        if(finishedAnalyzing == false) {return}
        if(!planeAnchorAdded) {return}
         hintButton.setTitleColor(UIColor.red, for: .normal)
        let (_,_,_,_) = self.analyze()
        hintButton.setTitleColor(UIColor.green, for: .normal)
    }
    func setupViews() {
        alertController.addAction(OKAction)
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
        customSC.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.04).isActive = true
        customSC.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        customSC.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        
        
        
        sessionInfoLabel = UILabel()
        sessionInfoLabel.font = font
        sessionInfoLabel.textAlignment = .center
        sessionInfoLabel.backgroundColor = .black
        sessionInfoLabel.textColor = .white
        sessionInfoLabel.lineBreakMode = .byWordWrapping
        // allows the UILabel to display an unlimited number of lines
        sessionInfoLabel.numberOfLines = 0;
        self.view.addSubview(sessionInfoLabel)
        
        sessionInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        sessionInfoLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        sessionInfoLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0).isActive = true
        sessionInfoLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.02).isActive = true
        sessionInfoLabel.topAnchor.constraint(equalTo: self.customSC.bottomAnchor, constant: 0).isActive = true
        
        banner = UILabel()
        banner.font = font
        banner.textAlignment = .center
        banner.backgroundColor = .black
        banner.textColor = .white
        banner.lineBreakMode = .byWordWrapping
        // allows the UILabel to display an unlimited number of lines
        banner.numberOfLines = 0;
        self.view.addSubview(banner)
        
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        banner.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0).isActive = true
        banner.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.02).isActive = true
        banner.topAnchor.constraint(equalTo: self.sessionInfoLabel.bottomAnchor, constant: 0).isActive = true
        
        
        font=UIFont(name: defaultFont, size: 8)
        idLabel.font = font
        idLabel.textAlignment = .center
        idLabel.backgroundColor = .red
        idLabel.textColor = .black
        idLabel.lineBreakMode = .byWordWrapping
        idLabel.text = UIDevice.current.name
        idLabel.numberOfLines = 0;
        self.view.addSubview(idLabel)
        
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        idLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = false
        idLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.125).isActive = true
        idLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.015).isActive = true
        idLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        idLabel.topAnchor.constraint(equalTo: self.banner.bottomAnchor, constant: 0).isActive = true
        
        
        
        peerIdLabel.font = font
        peerIdLabel.textAlignment = .center
        //peerIdLabel.backgroundColor = .red
        peerIdLabel.textColor = .black
        peerIdLabel.lineBreakMode = .byWordWrapping
        peerIdLabel.text = ""
        self.view.addSubview(peerIdLabel)
        
        peerIdLabel.translatesAutoresizingMaskIntoConstraints = false
        //banner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        peerIdLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.125).isActive = true
        peerIdLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.015).isActive = true
        peerIdLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        peerIdLabel.topAnchor.constraint(equalTo: self.banner.bottomAnchor, constant: 0).isActive = true
        
        
        
        font=UIFont(name: defaultFont, size: 10)
        
        hintButton.setTitle("?", for: .normal)
        hintButton.setTitleColor(UIColor.green, for: .normal)
        hintButton.addTarget(self, action: #selector(hinted(sender:)), for: .touchUpInside)
        self.view.addSubview(hintButton)
        hintButton.translatesAutoresizingMaskIntoConstraints = false
        hintButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = false

        hintButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.03).isActive = true
        hintButton.widthAnchor.constraint(equalTo: self.hintButton.heightAnchor, multiplier: 1.0).isActive = true
        hintButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        hintButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        fenBanner.font = font
        fenBanner.textAlignment = .left
        fenBanner.backgroundColor = .black
        fenBanner.textColor = .white
        fenBanner.lineBreakMode = .byWordWrapping
        fenBanner.text = ""
        self.view.addSubview(fenBanner)
        
        fenBanner.translatesAutoresizingMaskIntoConstraints = false
        fenBanner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = false
        fenBanner.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.01).isActive = true
        fenBanner.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        fenBanner.trailingAnchor.constraint(equalTo: self.hintButton.leadingAnchor).isActive = true
        fenBanner.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        
        
        recordBanner.font = font
        recordBanner.textAlignment = .left
        recordBanner.backgroundColor = .black
        recordBanner.textColor = .white
        recordBanner.lineBreakMode = .byWordWrapping
        recordBanner.text = ""
        self.view.addSubview(recordBanner)
        
        recordBanner.translatesAutoresizingMaskIntoConstraints = false
        recordBanner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = false
        recordBanner.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.02).isActive = true
        recordBanner.bottomAnchor.constraint(equalTo: self.fenBanner.topAnchor).isActive = true
        recordBanner.trailingAnchor.constraint(equalTo: self.hintButton.leadingAnchor).isActive = true
        recordBanner.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        

        
    }
}
