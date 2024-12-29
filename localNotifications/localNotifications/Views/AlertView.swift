//
//  AlertView.swift
//  localNotifications
//
//  Created by Joel on 31/7/24.
//

import SwiftUI

struct AlertView: Identifiable
{
    enum AlertView {
        case aTime
        case aDate
        case aEmpty
    }
    
    let id: AlertView
    let title: String
    let message: String
}
