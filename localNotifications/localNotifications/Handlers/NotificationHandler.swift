//
//  NotificationHandler.swift
//  localNotifications
//
//  Created by Joel on 10/4/23.
//

import SwiftUI
import Foundation
import UserNotifications

// Estructura para representar una notificación pendiente
struct PendingNotification: Identifiable, Hashable {
    let id: String
    let title: String
    let body: String
    let scheduledDate: Date
    let type: String // "date" o "time"
}

class NotificationHandler: ObservableObject
{
    let notificationCenter = UNUserNotificationCenter.current()
    
    @Published var pendingNotifications: [PendingNotification] = []
    
    func askPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if (success) {
                self.showNotifications()
            } else if (!success) {
                print("Permiso denegado!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func sendNotification(date: Date, type: String, timeInverval: Double = 10, title: String, body: String) {
        notificationCenter.getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                if (settings.authorizationStatus == .authorized) {
                    var trigger: UNNotificationTrigger?
                    
                    if (type == "date") {
                        let dateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: date)
                        trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    } else if (type == "time") {
                        trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInverval, repeats: false)
                    }
                    
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = body
                    content.sound = UNNotificationSound.default
                    
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    self.notificationCenter.add(request) { (error) in
                        if (error != nil) {
                            print("Error: " + error.debugDescription)
                            return
                        }
                    }
                    
                    self.showNotifications()
                } else {
                    self.askPermission()
                }
            }
        }
    }
    
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy 'a las' HH:mm"
        return formatter.string(from: date)
    }
    
    func showNotifications() {
        notificationCenter.getPendingNotificationRequests(completionHandler: { requests in
            DispatchQueue.main.async {
                self.pendingNotifications = requests.compactMap { request in
                    var scheduledDate = Date()
                    var type = "unknown"
                    
                    if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                        if let date = Calendar.current.date(from: trigger.dateComponents) {
                            scheduledDate = date
                            type = "date"
                        }
                    } else if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                        scheduledDate = Calendar.current.date(byAdding: .second, value: Int(trigger.timeInterval), to: Date()) ?? Date()
                        type = "time"
                    }
                    
                    return PendingNotification(
                        id: request.identifier,
                        title: request.content.title,
                        body: request.content.body,
                        scheduledDate: scheduledDate,
                        type: type
                    )
                }
            }
        })
    }
    
    // Método para eliminar una notificación específica
    func removeNotification(withId id: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        // Actualizar la lista después de eliminar
        showNotifications()
    }
    
    // Método para eliminar todas las notificaciones
    func removeAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        // Actualizar la lista después de eliminar
        showNotifications()
    }
}
