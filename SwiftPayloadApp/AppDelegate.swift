//
//  AppDelegate.swift
//  SwiftPayloadApp
//
//  Created by Natsumo Ikeda on 2016/10/07.
//  Copyright 2017 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
//

import UIKit
import UserNotifications
import NCMB

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // ViewController
    var viewController: ViewController?

    // payload
    var payloadKeyData: Array<String> = []
    var payloadValueData: Array<String> = []
    var payload_flag = false

    // APIキーの設定
    let applicationkey = "YOUR_NCMB_APPLICATIONKEY"
    let clientkey      = "YOUR_NCMB_CLIENTKEY"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // SDKの初期化
        NCMB.initialize(applicationKey: applicationkey, clientKey: clientkey)

        // デバイストークンの要求
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) {granted, error in
            if error != nil {
                // エラー時の処理
                print("エラーが発生しました：[\(String(describing: error))]")
                return
            }
            if granted {
                // デバイストークンの要求
                UIApplication.shared.registerForRemoteNotifications()
            }
        }

        // 【ペイロード：アプリ非起動時に受信】アプリが起動されたときにプッシュ通知の情報を取得する
        if let remoteNotification = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? NSDictionary {
            // flag
            payload_flag = true
            // log(実機)
            NSLog("【ペイロード】アプリ起動時に取得")
            //プッシュ通知情報の取得
            let key: Array! = Array(remoteNotification.allKeys)
            let value: Array! = Array(remoteNotification.allValues)

            if key != nil && value != nil {

                for i in 0..<key.count {
                    let key0 = key[i] as! String
                    payloadKeyData.append(key0)

                    let value0 = String(describing: value[i])
                    payloadValueData.append(value0)

                    NSLog("<<device_log>>:key[\(key0)], value[\(value0)]")

                }

            } else {
                NSLog("<<device_log>>:ペイロードを取得できませんでした")

            }

        }

        return true
    }

    // デバイストークンが取得されたら呼び出されるメソッド
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 端末情報を扱うNCMBInstallationのインスタンスを作成
        let installation : NCMBInstallation = NCMBInstallation.currentInstallation
        // デバイストークンの設定
        installation.setDeviceTokenFromData(data: deviceToken)
        // 端末情報をデータストアに登録
        installation.saveInBackground {result in
            switch result {
                case .success:
                    print("デバイストークン取得に成功しました")
                    break
            case let .failure(error):
                    // 端末情報の登録に失敗した時の処理
                    print("デバイストークン取得に失敗しました：\(error)")
                    break
            }
        }
    }

    // 【ペイロード：アプリ起動時に受信】アプリが起動中にプッシュ通知の情報を取得する
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // 状態Check
        if application.applicationState == UIApplication.State.inactive {
            // inactive
            print("inactive")
        } else if application.applicationState == UIApplication.State.active {
            // active
            print("active")
        } else {
            // バックグラウンド
            print("バックグラウンド")
            /* 本サンプルアプリでは動作しません */
        }

        // log
        print("【ペイロード】アプリ起動中に取得")
        // 初期化
        payloadKeyData = []
        payloadValueData = []

        // プッシュ通知情報の取得
        let key: Array! = Array(userInfo.keys)

        if key != nil {
            print(key)

            for i in 0..<key.count {
                let key0 = key[i] as! String
                let value0 = userInfo["\(key0)"]

                payloadKeyData.append(key0)

                if let unwrapValue = value0 {
                    if key0 == "aps" {
                        let apsUnwrapValue = String(describing: unwrapValue)
                        payloadValueData.append(apsUnwrapValue)
                    } else {
                        payloadValueData.append(unwrapValue as! String)
                    }

                    print("key[\(key0)], value[\(unwrapValue)]")
                }

            }

            // テーブルに表示
            viewController?.getTable()

        } else {
            print("ペイロードを取得できませんでした")

        }

    }

}
