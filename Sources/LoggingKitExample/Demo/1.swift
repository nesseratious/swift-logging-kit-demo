//
//  1.swift
//  LoggingKit
//
//  Created by Denis Esie on 11.12.2025.
//

import LoggingKit

func OSLogMessageExample() {
    
    // Public
    let userName = "Mr.Fresh"
    let userAdrress = "Mr.Fresh's Mojo Dojo Casa House"
    #logInfo("User name: \(userName)")
    #logInfo("User address: \(userAdrress)")
    
    // Full public
    let userCardNumber = "1234-5678-9012-3456 12/35 789"
    #logInfo("User card number: \(userCardNumber)")
    
    // Private
    let userHoroscope = "Sagittarius"
    #logInfo("User horoscope: \(userHoroscope)")
    
}
