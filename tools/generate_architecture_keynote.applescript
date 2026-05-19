set outputDir to POSIX path of "/Users/mac/Desktop/mnewsapp/"
set keynotePath to outputDir & "mnews_architecture_review.key"
set powerpointPath to outputDir & "mnews_architecture_review.pptx"
set diagramPath to outputDir & "assets/diagrams/high_level_architecture_chrome.png"
set storyFlowPath to outputDir & "assets/diagrams/story_data_flow_chrome.png"
set directoryDiagramPath to outputDir & "assets/diagrams/directory_responsibility_chrome.png"

on joinLines(theLines)
	set AppleScript's text item delimiters to return
	set joinedText to theLines as text
	set AppleScript's text item delimiters to ""
	return joinedText
end joinLines

tell application "Finder"
	if exists POSIX file keynotePath then delete POSIX file keynotePath
	if exists POSIX file powerpointPath then delete POSIX file powerpointPath
end tell

tell application "Keynote"
	activate
	set theTheme to theme "白色"
	set theDocument to make new document with properties {document theme:theTheme}
	
	tell slide 1 of theDocument
		set base slide to master slide "大標題 - 中央" of theDocument
		set object text of default title item to "mnews 專案架構分析與統一方案"
		set object text of default body item to my joinLines({"內容涵蓋：現況架構流程圖、目前專案問題、統一架構建議", "結論：不建議繼續混用 Bloc 與 GetX，建議逐步收斂到 GetX", "專案位置：/Users/mac/Desktop/mnewsapp"})
	end tell

	set slideSummary to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slideSummary
		set object text of default title item to "結論摘要"
		set object text of default body item to my joinLines({"現況：Bloc / Cubit 與 GetX 混用，狀態來源與生命週期管理不一致", "建議：以 20 個工作天分階段收斂到 GetX-only 架構", "原因：專案入口、DI、部分核心控制流程已經以 GetX 為主", "風險最高區塊：首頁 section 切換、啟動流程、Remote Config / Push 整合", "預期收益：架構一致、維護成本降低、新功能開發與除錯更直接"})
	end tell
	
	set slide2 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide2
		set object text of default title item to "目前專案架構流程圖"
		set object text of default body item to my joinLines({"入口流程", "main_dev.dart / main_prod.dart", "Environment / Firebase / Ads / Comscore 初始化", "MNewsApp -> GetMaterialApp -> HomeBinding", "ConfigBloc -> InitialApp -> Remote Config / Push / Upgrade", "HomePage -> Section 切換 -> News / Live / Video / Show / Topic", "", "資料流程", "UI(Page/Widget) -> Bloc/Cubit 或 GetX Controller", "Service -> ApiBaseHelper / GraphQLClient", "REST API / GraphQL API / Firebase -> Model -> UI"})
	end tell

	set slideImage to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題 - 上方" of theDocument}
	tell slideImage
		set object text of default title item to "高階架構圖"
		set archImage to make new image with properties {file:POSIX file diagramPath}
		set width of archImage to 920
		set height of archImage to 795
		set position of archImage to {40, 90}
	end tell
	
	set slide3 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide3
		set object text of default title item to "專案目錄與責任分工"
		set object text of default body item to my joinLines({"lib/pages: 功能頁面，依新聞、影音、節目、直播等業務模組切分", "lib/widgets: 共用 UI 元件，文章內文播放與顯示元件特別多", "lib/blocs: 主要畫面狀態管理，包含 config、category、search、list", "lib/controller 與 pages/*_controller.dart: GetX controller 與局部頁面控制", "lib/services: REST / GraphQL / Firebase 整合與商業邏輯", "lib/models: API model 與資料結構", "lib/helpers / lib/configs / lib/core: 環境、常數、工具、錯誤處理"})
	end tell

	set slideDirectoryImage to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題 - 上方" of theDocument}
	tell slideDirectoryImage
		set object text of default title item to "目錄職責圖"
		set directoryImage to make new image with properties {file:POSIX file directoryDiagramPath}
		set width of directoryImage to 940
		set height of directoryImage to 504
		set position of directoryImage to {30, 150}
	end tell

	set slideStoryImage to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題 - 上方" of theDocument}
	tell slideStoryImage
		set object text of default title item to "文章頁資料流"
		set storyImage to make new image with properties {file:POSIX file storyFlowPath}
		set width of storyImage to 940
		set height of storyImage to 284
		set position of storyImage to {30, 220}
	end tell
	
	set slide4 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide4
		set object text of default title item to "目前專案的主要問題"
		set object text of default body item to my joinLines({"架構混用：Bloc/Cubit 與 GetX 同時存在，狀態來源不一致", "生命週期分散：有的靠 BlocProvider，有的靠 Get.put/Get.delete 手動管理", "首頁 shell 過度承擔控制責任，HomePage 直接建立與刪除 controller", "services 邊界偏鬆，資料存取與業務 fallback 邏輯耦合很深", "ApiBaseHelper 用固定 key 驗證 response，對 API 格式耦合高", "測試不足，目前 test/widget_test.dart 仍是預設範例，無法保護重構"})
	end tell

	set slideCompare to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slideCompare
		set object text of default title item to "改造前後對照"
		set object text of default body item to my joinLines({"現況：UI -> Bloc/Cubit + GetX -> Service -> API", "目標：UI -> GetX Controller -> Service -> API", "", "狀態管理：混用兩套 -> 單一收斂到 GetX", "依賴注入：BlocProvider + Get.put 混用 -> Binding 統一管理", "導航：Navigator / Get 混用 -> GetX 導航一致化", "頁面責任：Page 同時碰狀態與注入 -> Page / Controller / Service 邊界清楚"})
	end tell
	
	set slide5 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide5
		set object text of default title item to "統一架構建議"
		set object text of default body item to my joinLines({"建議統一到 GetX，而不是回頭統一到 Bloc", "原因 1：專案入口已經是 GetMaterialApp，GetX 已是既有基礎設施", "原因 2：DI 與部分核心頁面 controller 已經採用 GetX", "原因 3：改成 Bloc-only 需要回收既有 GetX 導航、Binding、controller", "目標架構：UI -> GetX Controller -> Service -> API/Provider", "原則：不再新增 Bloc/Cubit，新功能與重構後模組全部走 GetX"})
	end tell

	set slideRisk to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slideRisk
		set object text of default title item to "風險與應對"
		set object text of default body item to my joinLines({"風險 1：首頁 section 切換改造後可能出現狀態殘留或 controller 生命週期異常", "應對：先補 smoke test，再把 SectionCubit 收斂為單一 AppShellController", "", "風險 2：啟動流程改造可能影響 Remote Config、Push、GraphQL client 重建", "應對：把 AppInitController 放在最後階段處理，逐項驗證初始化流程", "", "風險 3：重構期間若同時插入新功能，容易讓架構再次混用", "應對：明確規定重構後新功能只允許使用 GetX 架構規範"})
	end tell

	set slideRemoval to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slideRemoval
		set object text of default title item to "本次重構建議拔除項目"
		set object text of default body item to my joinLines({"最終拔除目標：flutter_bloc", "逐步拔除：已遷移完成模組對應的 lib/blocs/*、BlocProvider、BlocBuilder、context.read/watch", "立即禁止新增：新的 Bloc/Cubit、新的混合式注入寫法", "", "本次不處理：webview 類、影音播放器類、Firebase / Ads / Analytics、cached_network_image / flutter_svg 等成熟 UI 套件", "", "原則：這次重構優先處理狀態管理收斂，不同步做第三方套件大清洗"})
	end tell

	set slidePmQa to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slidePmQa
		set object text of default title item to "PM 驗收方式"
		set object text of default body item to my joinLines({"驗收重點不看技術實作，只看功能是否與改版前一致", "", "1. 搜尋頁：輸入關鍵字後能正常看到結果，切換排序後結果會更新，滑到底可繼續載入更多", "2. 空結果與錯誤：查無結果時有正確提示，斷網時有錯誤畫面與重試按鈕", "3. 文章開啟：從搜尋結果點進文章能正常開啟，返回後搜尋結果仍保留", "4. 首頁切換：新聞、直播、影音、節目等主分區切換後畫面正常，沒有白畫面或卡住", "5. 啟動流程：開 app 不會卡在啟動畫面，版本提示、首頁載入、推播開啟流程正常", "", "PM 驗收判定：只要功能流程、畫面結果、錯誤處理與原本一致，即可視為通過"})
	end tell

	set slideChecklist to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slideChecklist
		set object text of default title item to "需要驗證的功能"
		set object text of default body item to my joinLines({"1. App 啟動：可正常進入首頁，沒有卡在啟動畫面或空白頁", "2. 首頁切換：新聞、直播、影音、節目、專題等主分區可正常切換", "3. 搜尋功能：輸入關鍵字、切換排序、載入更多、清空搜尋皆正常", "4. 搜尋例外處理：查無結果、網路中斷、重試流程顯示正確", "5. 文章頁：從搜尋結果或列表進入文章，內容、返回流程與分享功能正常", "6. 直播 / 影音：直播畫面、影片列表、影片播放與切換流程正常", "7. 節目 / 專題 / 其他列表頁：分類切換、列表載入、點擊進入內容正常", "8. 推播與設定：通知進入文章、字體大小調整、GDPR 首次提示流程正常", "9. 廣告與追蹤：頁面切換與文章頁廣告不影響操作，基本追蹤流程無異常", "10. 版本與設定：版本提示、Remote Config 相關行為與原本一致"})
	end tell

	set slideListRule to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slideListRule
		set object text of default title item to "工程師開發規範"
		set object text of default body item to my joinLines({"這套規範可作為本專案與其他專案共用的開發標準", "", "1. 新功能狀態管理一律使用 GetX，不再新增 Bloc / Cubit", "2. Page 只負責 UI 與事件觸發，不直接寫資料流程或建立 service", "3. Controller 負責狀態、頁面互動、loading / error / empty 邏輯", "4. Service / Provider 負責 API 存取、資料轉換與 fallback，不處理 UI 邏輯", "5. 頁面級依賴一律用 Binding 註冊，不在 HomePage 或 widget 內隨意 Get.put", "6. 全域單例只允許放在 App root，例如 Ads、TextScale、全域 Provider", "7. 每個列表功能都要能追到固定入口：Page -> Controller -> Service -> API", "8. 重構完成後，移除對應 Bloc 與舊寫法，避免新舊架構並存"})
	end tell
	
	set slide6 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide6
		set object text of default title item to "修改策略與落地建議"
		set object text of default body item to my joinLines({"第一階段：先改 Search / Tag / ProgramList / Contact 等低風險模組", "第二階段：整合 News / Video / Show / Topic / Live 的多個 Bloc", "第三階段：把 SectionCubit 收斂為 AppShellController", "第四階段：把 ConfigBloc 收斂為 AppInitController", "services、models、helpers 先保留，優先只改狀態管理層", "新增規範：Binding 管 DI、Controller 管狀態、Page 只負責 UI", "重構前先補 smoke test，避免首頁、啟動流程與文章頁回歸"})
	end tell

	set slide7 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide7
		set object text of default title item to "20 天寬鬆修改時程"
		set object text of default body item to my joinLines({"Day 1-2：盤點現況與定規範，統一 GetX controller / binding / 狀態格式", "Day 3-5：補最基本 smoke test，覆蓋首頁啟動、搜尋、文章頁", "Day 6-8：改低風險模組，先處理 Search / Tag / ProgramList / Contact", "Day 9-12：改中型列表模組，處理 categories / tabStoryList / topicList / newsMarquee", "Day 13-15：改主要 section 頁，整理 News / Video / Show / Live controller", "Day 16-17：改首頁 shell，把 SectionCubit 收斂為 AppShellController", "Day 18-19：改啟動流程，把 ConfigBloc 收斂為 AppInitController", "Day 20：清理 bloc 依賴、驗收與回歸測試"})
	end tell

	set slide8 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide8
		set object text of default title item to "時程細節：Day 1-8"
		set object text of default body item to my joinLines({"Day 1-2 盤點與定規範", "整理現有 Bloc、Cubit、GetX controller、Binding 與 Provider 對照表", "確認哪些模組先不動：services、models、helpers、原生平台設定", "定義新規範：Controller 命名、Binding 註冊方式、Page 與 Widget 責任邊界", "統一 loading / error / empty / success 的畫面呈現方式", "", "Day 3-5 補基礎測試", "補首頁啟動 smoke test，驗證 app 可進入 HomePage", "補搜尋頁 smoke test，驗證搜尋互動與結果顯示流程", "補文章頁 smoke test，驗證 StoryPage 載入與錯誤 fallback", "", "Day 6-8 改低風險模組", "把 Search / Tag / ProgramList / Contact 的 Bloc 改成 GetX Controller", "移除對應頁面的 BlocProvider / BlocBuilder 依賴", "為這批頁面補上 Binding 與 DI 註冊，確認頁面生命週期正常"})
	end tell

	set slide9 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide9
		set object text of default title item to "時程細節：Day 9-15"
		set object text of default body item to my joinLines({"Day 9-12 改中型列表模組", "處理 categories、tabStoryList、topicList、topicStoryList、newsMarquee", "把原本分散的 Bloc 收斂成較少數的頁面級 Controller", "確認分類切換、分頁切換、列表載入與 retry 行為一致", "逐步移除列表型模組對 flutter_bloc 的依賴", "", "Day 13-15 改主要 section 頁", "整理 News / Video / Show / Live 的主 controller 與子狀態", "把多個資料來源的載入順序改由 Controller 統一協調", "檢查首頁切換 section 後，頁面是否重建正確、狀態是否殘留", "驗證廣告、跑馬燈、影音播放與列表載入沒有行為回歸"})
	end tell

	set slide10 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide10
		set object text of default title item to "時程細節：Day 16-20"
		set object text of default body item to my joinLines({"Day 16-17 改首頁 shell", "把 SectionCubit 改為 AppShellController，統一管理 currentSection", "調整 Drawer、首頁切換、controller 建立與釋放邏輯", "避免 HomePage 繼續直接 Get.put / Get.delete 多個 controller", "", "Day 18-19 改啟動流程", "把 ConfigBloc 改為 AppInitController，集中管理 Remote Config、Push、版本資訊", "整理 InitialApp 啟動條件與錯誤處理，讓啟動流程單一化", "確認 GraphQL client 重建與環境設定切換仍正常", "", "Day 20 驗收與清理", "移除已不再使用的 blocs、events、states 與 flutter_bloc 依賴", "做完整 smoke test 與主要流程手動驗收", "整理文件與簡報，確認團隊後續只沿用 GetX 架構規範"})
	end tell
	
	save theDocument in POSIX file keynotePath
	export theDocument to POSIX file powerpointPath as Microsoft PowerPoint
	close theDocument saving no
end tell
