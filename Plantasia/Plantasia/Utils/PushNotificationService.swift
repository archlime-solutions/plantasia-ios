//
//  PushNotificationService.swift
//  Plantasia
//
//  Created by bogdan razvan on 29/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit
import FirebaseCrashlytics
import FirebaseAnalytics

final class PushNotificationService: NSObject, UNUserNotificationCenterDelegate {

    private enum NotificationAction: String {
        case snooze1Hour
        case markAsComplete
        case skip
    }

    // MARK: - Properties
    static let shared = PushNotificationService()
    private let notificationCenter = UNUserNotificationCenter.current()
    private let plantsService = PlantsService()
    private let categoryIdentifier = "com.archlime-solutions.plantasia.reminder-notification"

    // MARK: - Lifecycle
    override private init() { }

    // MARK: - Internal
    func requestPushNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    func scheduleNotifications() {
        do {
            notificationCenter.removeAllPendingNotificationRequests()
            setNotificationCategories()

            let remindersTime = UserDefaults.standard.getRemindersTime()

            if let date = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: remindersTime),
                                                minute: Calendar.current.component(.minute, from: remindersTime),
                                                second: 0,
                                                of: Date()),
                let triggerDate1 = Calendar.current.date(byAdding: .day, value: try plantsService.getRequiredAttentionRemainingDays(), to: date),
                let triggerDate2 = Calendar.current.date(byAdding: .day, value: 1, to: triggerDate1),
                let triggerDate3 = Calendar.current.date(byAdding: .day, value: 2, to: triggerDate1) {

                [triggerDate1, triggerDate2, triggerDate3].forEach { createNotificationRequest(triggerDate: $0) }
            }
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
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
            Analytics.logEvent("notification_action_snooze", parameters: nil)
            guard let notificationDate = Calendar.current.date(byAdding: .hour, value: 1, to: response.notification.date) else { return }
            let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: notificationDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: response.notification.request.content, trigger: trigger)
            notificationCenter.add(request) { _ in }

        case NotificationAction.markAsComplete.rawValue:
            Analytics.logEvent("notification_action_mark_as_complete", parameters: nil)
            if plantsService.waterAndFertilizeRequiringPlants() {
                scheduleNotifications()
            }

        case NotificationAction.skip.rawValue:
            Analytics.logEvent("notification_action_skip", parameters: nil)

        default:
            break
        }
        completionHandler()
    }

    // MARK: - Private
    private func createNotificationRequest(triggerDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Hey 👋. Your plants would enjoy your attention."
        content.body = "Open the app to see which ones need watering or fertilizing. 🌿"
        content.sound = UNNotificationSound.default
        content.badge = NSNumber(value: 1)
        content.categoryIdentifier = categoryIdentifier

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
            repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        notificationCenter.add(request) { error in
            guard let error = error else { return }
            Crashlytics.crashlytics().record(error: error)
        }
    }

    private func setNotificationCategories() {
        let snooze1HourAction = UNNotificationAction(identifier: NotificationAction.snooze1Hour.rawValue, title: "Snooze 1 Hour", options: [])
        let markAsCompleteAction = UNNotificationAction(identifier: NotificationAction.markAsComplete.rawValue, title: "Mark as Complete", options: [])
        let skipAction = UNNotificationAction(identifier: NotificationAction.skip.rawValue, title: "Skip", options: [.destructive])
        let category = UNNotificationCategory(identifier: categoryIdentifier,
                                              actions: [snooze1HourAction, markAsCompleteAction, skipAction],
                                              intentIdentifiers: [],
                                              options: [])
        notificationCenter.setNotificationCategories([category])
    }

}
