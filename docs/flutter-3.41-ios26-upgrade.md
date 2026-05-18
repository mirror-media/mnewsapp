# Flutter 3.41 / iOS 26 SDK 升版交接文件

> 用途:給下一次對話 / 接手的人快速掌握這次升版的背景、現況與待辦。
> 建立日期:2026-05-15

---

## 1. 背景:為什麼要升

App Store 自 **2026-04-28** 起規定,所有送審的 build 必須使用 **Xcode 26 + iOS 26 SDK** 建置,否則直接退件。專案目前鎖在 **Flutter 3.29.3**,其 iOS toolchain 產出的是舊 SDK build,因此 **Codemagic CI/CD 上傳已被擋**(期限已過,目前完全無法送審)。

## 2. 目標版本

- **最低門檻:Flutter 3.38** — 第一個完整支援 iOS 26 / Xcode 26 / macOS 26,並提供 Apple 強制的 UIScene 生命週期 API 的版本。
- **建議目標:Flutter 3.41.5**(撰寫當時最新穩定版)— UIScene 自動遷移在 3.41 變預設、會自動改 AppDelegate,並修掉 3.29 引入的 Android 記憶體洩漏。
- 本文件以 **3.41.5** 為目標。

## 3. 專案現況快照(升版前)

| 項目 | 現值 |
|---|---|
| Flutter (FVM) | 3.29.3 |
| Dart SDK 限制 | `>=3.7.0 <4.0.0` |
| iOS Podfile | `platform :ios, '15.0'`，post_install 已統一 pods/targets 為 `15.0` |
| iOS pbxproj | `IPHONEOS_DEPLOYMENT_TARGET` 已統一為 `15.0` |
| CocoaPods | 1.16.2 |
| Swift | 5.0 |
| iOS targets | `Runner` + `ImageNotification`(推播服務 extension,Obj-C) |
| `AppDelegate.swift` | 近乎原廠樣板,只多一行未使用的 `import GoogleMobileAds` |
| `Info.plist` | **尚無** `UIApplicationSceneManifest`;有 `UIBackgroundModes` (fetch, remote-notification) |
| Android | AGP 8.7.2 / Kotlin 2.1.0 / Gradle 8.9 / compileSdk 35 / targetSdk 35 / minSdk 24 / Java 17 / NDK 28 |
| CI/CD | Codemagic(用 `FCI_*` 環境變數;repo 內無 `codemagic.yaml`,workflow 在 Codemagic 後台 UI 設定) |
| App | Mirror News,bundle id `com.mirrortv.mnews`,版本 1.5.12+76 |

主要相依套件(已解析版本,大多偏新):firebase_core 4.1.0 / firebase_messaging 16.0.1 / firebase_crashlytics 5.0.1 / firebase_analytics 12.0.1 / firebase_remote_config 6.0.1 / google_mobile_ads 6.0.0 / webview_flutter 4.13.0 / video_player 2.10.0 / chewie 1.12.1 / flutter_bloc 9.1.1 / get 4.7.2 / graphql_flutter 5.2.1 / youtube_player_flutter 9.1.2 / youtube_explode_dart 2.5.2 / comscore_analytics_flutter 1.1.0 / upgrader 11.5.0。

## 4. 已完成的變更(repo 版本鎖定)

於 2026-05-15 已修改下列檔案並完成下列驗證:

- `.fvmrc` → `"flutter": "3.41.5"`
- `.fvm/fvm_config.json` → `"flutterSdkVersion": "3.41.5"`
- `.fvm/flutter_sdk` → 已切到本機安裝的 `3.41.5`
- `pubspec.yaml` → `environment.flutter` 從 `>=3.29.0` 改為 `>=3.41.0`，並把 `intl` 從 `^0.19.0` 升到 `^0.20.2` 以符合 Flutter 3.41 的 `flutter_localizations`
- `ios/Podfile` → pods 與使用者 targets 的 `IPHONEOS_DEPLOYMENT_TARGET` 全部統一成 `15.0`
- `ios/Runner.xcodeproj/project.pbxproj` → 移除殘留的 `12.0 / 12.1` deployment target，全部統一成 `15.0`
- `ios/Runner/AppDelegate.swift` → Flutter 3.41 build 過程已自動遷移為 `FlutterImplicitEngineDelegate`
- `ios/Runner/Info.plist` → Flutter 3.41 build 過程已自動加入 `UIApplicationSceneManifest`
- `pubspec.lock` / `ios/Podfile.lock` → 已重新解析並鎖定相依
- `pod install` → 已成功完成
- `flutter build ios --flavor prod -t lib/main_prod.dart --no-codesign` → **已成功**

> ⚠️ 目前已完成 Flutter 3.41.5 安裝、`pub get`、`pod install`、UIScene 自動遷移與一次 iOS build 驗證；但**實機測試、深連結驗證、推播驗證、Codemagic Xcode 26 workflow 調整**仍未完成。

## 5. 風險評估

### 高:UIScene / UISceneDelegate 遷移(Apple 強制)
- `AppDelegate.swift` 已由 Flutter 3.41 自動遷移。
- `Info.plist` 已自動新增 Application Scene Manifest。
- 第二個 target `ImageNotification`(推播 extension)需一起確認。
- **已知回報:3.38/3.41 遷移後可能出現 deep link 失效** → 務必測試深連結。

### 中:套件相容性
- 依賴大多已很新,`flutter pub upgrade` 應大致可解;少數可能需 `--major-versions`。
- 重點盯:`comscore_analytics_flutter`、`youtube_player_flutter` / `youtube_explode_dart`(第三方相依較深)。

### 低:其他
- iOS 部署目標不一致問題已先在 repo 內統一為 `15.0`；後續只需確認 pods 重裝後沒有被額外覆寫。
- Android 已相當新,Flutter 3.41 可能要求小幅 Gradle/AGP 調整,風險小。
- CocoaPods 1.16.2 可用,建議順手更新到較新版。

## 6. Mac 端執行步驟(Runbook)

1. 開新分支:`git checkout -b chore/flutter-3.41-ios26`
2. 安裝並切換 SDK:`fvm install 3.41.5 && fvm use 3.41.5`
   - 已完成；目前 `./.fvm/flutter_sdk/bin/flutter --version` 為 `3.41.5`
3. 解相依:`fvm flutter pub get` → `fvm flutter pub outdated` → 必要時 `fvm flutter pub upgrade --major-versions`
   - 已完成 `pub get`
4. iOS pods:`cd ios && pod repo update && pod install`
   - 完成後確認 `Podfile.lock` 與 Xcode 專案沒有把 deployment target 又寫回舊值
   - 已完成
5. `fvm flutter build ios` — 觸發 UIScene 自動遷移。**用 `git diff` 檢查 `AppDelegate.swift` 與 `Info.plist`**;若 AppDelegate 未被自動改,依官方 UISceneDelegate 指南手動遷移。
   - 已以 `--flavor prod -t lib/main_prod.dart --no-codesign` 成功 build，且自動完成 UIScene 遷移
6. 用 Xcode 26 開 `ios/Runner.xcworkspace`,確認 `ImageNotification` extension 也能編譯。
7. 實機測試清單:
   - 推播(firebase_messaging + ImageNotification 圖片通知)
   - **深連結 / universal links**(已知回歸風險)
   - Google Mobile Ads 廣告顯示
   - 影片 / YouTube 播放(video_player、chewie、youtube_player_flutter)
   - App 啟動、背景/前景切換、ATT 追蹤授權彈窗
8. 升 build number → Xcode archive → 上傳 TestFlight 驗證。
9. **Codemagic**:到後台 workflow 設定,將 build machine image 改為含 **Xcode 26** 的版本,並確認 Flutter 版本對應 3.41.5(FVM)。

## 7. 驗收標準

- `fvm flutter build ios` 成功且無 UIScene 相關阻塞。
- Codemagic build 成功並能上傳 App Store Connect(不再出現 SDK 過舊退件)。
- 上述實機測試清單全部通過,深連結與推播正常。

## 8. 參考來源

- iOS 26 SDK 要求與 Flutter 3.38 期程:https://www.linkedin.com/posts/amorna_apples-ios-26-sdk-requirement-and-the-roadmap-activity-7419270214242078721-fNiU
- Flutter on latest iOS:https://docs.flutter.dev/platform-integration/ios/ios-latest
- Announcing Flutter 3.38 & Dart 3.10:https://blog.flutter.dev/announcing-flutter-3-38-dart-3-10-building-the-future-of-apps-503429eeb685
- UISceneDelegate adoption:https://docs.flutter.dev/release/breaking-changes/uiscenedelegate
- Breaking changes and migration guides:https://docs.flutter.dev/release/breaking-changes
