//
//  PushNotificationService.swift
//  Plantasia
//
//  Created by bogdan razvan on 29/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit
import RealmSwift

final class PushNotificationService: NSObject, UNUserNotificationCenterDelegate {

    enum NotificationAction: String {
        case snooze1Hour
        case markAsComplete
        case skip
    }

    // MARK: - Properties
    static let shared = PushNotificationService()
    private let notificationCenter = UNUserNotificationCenter.current()

    // MARK: - Lifecycle
    override private init() { }

    // MARK: - Internal
    func requestPushNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    func scheduleNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()

        if let realm = try? Realm(), !realm.objects(Plant.self).isEmpty {
            let content = UNMutableNotificationContent()
            let userActions = "Plantasia User Actions"
            content.title = "Hey 👋. Your plants would enjoy your attention."
            content.body = "Open the app to see which ones need watering or fertilizing. 🌿"
            content.sound = UNNotificationSound.default
            content.badge = NSNumber(value: 1)
            content.categoryIdentifier = userActions

            //ora si minutele din settings
            let remindersDateComponents = Calendar.current.dateComponents([.hour, .minute], from: UserDefaults.standard.getRemindersTime())

            //data curenta
            var triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
            //seteaza ora si minute din settings pe data curenta
            triggerDateComponents.hour = remindersDateComponents.hour
            triggerDateComponents.minute = remindersDateComponents.minute

            //adauga zilele de attention pe data curenta
            if let date = triggerDateComponents.date,
                let triggerDate = Calendar.current.date(byAdding: .day, value: getPlantsAttentionRemainingDays(), to: date) {
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
            if let realm = try? Realm() {
                let plants = Array(realm.objects(Plant.self).filter({ $0.requiresAttention() }))
                plants.forEach {
                    if $0.requiresWatering() {
                        $0.water()

                    }
                    if $0.requiresFertilizing() {
                        $0.fertilize()
                    }
                }
                scheduleNotifications()
            }
        default:
            break
        }
        completionHandler()
    }

    // MARK: - Private

    ///
    /// - Returns: Returns the number of days until any of the stored plants requires attention (watering or fertilizing)
    private func getPlantsAttentionRemainingDays() -> Int {
        if let realm = try? Realm() {
            let plants = Array(realm.objects(Plant.self))
            if !plants.isEmpty {
                var minNumberOfDays = Int.max
                for plant in plants {
                    let wateringRemainingDays = plant.getWateringRemainingDays()
                    let fertilizingRemainingDays = plant.getFertilizingRemainingDays()
                    if wateringRemainingDays < minNumberOfDays {
                        minNumberOfDays = wateringRemainingDays
                    }
                    if fertilizingRemainingDays < minNumberOfDays {
                        minNumberOfDays = fertilizingRemainingDays
                    }
                }
                return minNumberOfDays
            }
        }
        return 0
    }

}
