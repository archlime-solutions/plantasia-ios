//
//  PushNotificationService.swift
//  Plantasia
//
//  Created by bogdan razvan on 29/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit

final class PushNotificationService: NSObject, UNUserNotificationCenterDelegate {

    enum NotificationAction: String {
        case snooze1Hour
        case markAsComplete
        case skip
    }

    // MARK: - Properties
    static let shared = PushNotificationService()
    private let notificationCenter = UNUserNotificationCenter.current()
    private let plantsService = PlantsService()

    // MARK: - Lifecycle
    override private init() { }

    // MARK: - Internal
    func requestPushNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    func scheduleNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()

        if plantsService.plantsExist() {
            let content = UNMutableNotificationContent()
            let userActions = "Plantasia User Actions"
            content.title = "Hey 👋. Your plants would enjoy your attention."
            content.body = "Open the app to see which ones need watering or fertilizing. 🌿"
            content.sound = UNNotificationSound.default
            content.badge = NSNumber(value: 1)
            content.categoryIdentifier = userActions

            let remindersDateComponents = Calendar.current.dateComponents([.hour, .minute], from: UserDefaults.standard.getRemindersTime())

            var triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
            triggerDateComponents.hour = remindersDateComponents.hour
            triggerDateComponents.minute = remindersDateComponents.minute

            if let date = triggerDateComponents.date,
                let triggerDate = Calendar.current.date(byAdding: .day, value: plantsService.getPlantsAttentionRemainingDays(), to: date) {
                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],
                                                                                                          from: triggerDate),
                                                            repeats: true)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                notificationCenter.add(request) { _ in }

                let snooze1HourAction = UNNotificationAction(identifier: NotificationAction.snooze1Hour.rawValue, title: "Snooze 1 Hour", options: [])
                let markAsCompleteAction = UNNotificationAction(identifier: NotificationAction.markAsComplete.rawValue, title: "Mark as Complete", options: [])
                let skipAction = UNNotificationAction(identifier: NotificationAction.skip.rawValue, title: "Skip", options: [.destructive])
                let category = UNNotificationCategory(identifier: userActions,
                                                      actions: [snooze1HourAction, markAsCompleteAction, skipAction],
                                                      intentIdentifiers: [],
                                                      options: [])
                notificationCenter.setNotificationCategories([category])
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case NotificationAction.snooze1Hour.rawValue:
            guard let notificationDate = Calendar.current.date(byAdding: .hour, value: 1, to: response.notification.date) else { return }
            let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: notificationDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: response.notification.request.content, trigger: trigger)
            notificationCenter.add(request) { _ in }
        case NotificationAction.markAsComplete.rawValue:
            let success = plantsService.waterAndFertilizeRequiringPlants()
            if success {
                scheduleNotifications()
            }
        default:
            break
        }
        completionHandler()
    }

}
