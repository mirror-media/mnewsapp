set outputDir to POSIX path of "/Users/mac/Desktop/mnewsapp/"
set keynotePath to outputDir & "mnews_team_discussion_report.key"
set pdfPath to outputDir & "mnews_team_discussion_report.pdf"

on joinLines(theLines)
	set AppleScript's text item delimiters to return
	set joinedText to theLines as text
	set AppleScript's text item delimiters to ""
	return joinedText
end joinLines

tell application "Finder"
	if exists POSIX file keynotePath then delete POSIX file keynotePath
	if exists POSIX file pdfPath then delete POSIX file pdfPath
end tell

tell application "Keynote"
	activate
	set theTheme to theme "白色"
	set theDocument to make new document with properties {document theme:theTheme}
	
	tell slide 1 of theDocument
		set base slide to master slide "大標題 - 中央" of theDocument
		set object text of default title item to "mnews 重構討論報告"
		set object text of default body item to my joinLines({"用途：與同事討論目前專案的狀態、形成原因與後續收斂方向", "重點：不是追究誰寫成這樣，而是整理出我們現在面對的是什麼問題", "目標：讓後續重構與新功能開發有一套比較一致的共識"})
	end tell
	
	set slide2 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide2
		set object text of default title item to "這份報告想討論什麼"
		set object text of default body item to my joinLines({"1. 專案現在為什麼會讓人感覺很亂", "2. 這種混亂在 code 裡實際長成什麼樣子", "3. 它已經造成了哪些開發成本", "4. 如果我們要一起整理，最合理的收斂方式是什麼", "5. 接下來重構時，團隊需要怎麼配合比較順"})
	end tell
	
	set slide3 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide3
		set object text of default title item to "Bloc vs GetX"
		set object text of default body item to my joinLines({"Bloc：偏事件驅動，流程是 Event -> Bloc -> State -> UI", "GetX：偏 controller 直接管理狀態，流程是 UI -> Controller -> Rx State -> UI", "", "Bloc 的優點：狀態變化路徑清楚、多人協作時規範感強", "GetX 的優點：寫法輕、頁面導向開發快、DI/導航/狀態可一起管理", "", "這次討論的重點不是哪個理論上比較好，而是：在這個既有專案裡，混用兩套讓規則變得不一致，後續需要收斂成一套"})
	end tell
	
	set slide4 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide4
		set object text of default title item to "先講結論"
		set object text of default body item to my joinLines({"這個專案會變亂，不是因為某一段 code 特別差，而是它長期在功能持續堆疊的情況下，沒有機會把舊規則回收乾淨。", "", "久了之後，專案裡就同時存在不同時期留下來的做法，大家都能跑，但整體規則越來越不一致。"})
	end tell
	
	set slide5 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide5
		set object text of default title item to "為什麼會變成這樣"
		set object text of default body item to my joinLines({"專案是邊做功能邊長大，不是先完整規劃再開始", "功能壓力大時，優先順序通常是先讓需求上線", "不同時期有不同工程師、不同偏好的寫法進來", "舊邏輯還在運作時，新的需求往往只能貼著現有結構改", "缺少一次真正把舊規則統一回收的時間", "最後就變成每個階段都留下一點自己的痕跡"})
	end tell
	
	set slide6 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide6
		set object text of default title item to "在這個專案裡，混亂長什麼樣子"
		set object text of default body item to my joinLines({"狀態管理混用：Bloc、Cubit、GetX 都在", "依賴注入混用：Binding、Get.put、BlocProvider、widget init 都存在", "頁面生命週期不一致：有的 controller 是全域，有的是首頁切換時手動建立", "同樣是列表頁，不同模組卻有不同資料流走法", "HomePage 承擔了太多控制責任，像 shell、section、controller 生命周期都塞在一起", "service 逐漸吸收了很多 fallback 與整合邏輯，邊界變得很厚"})
	end tell
	
	set slide7 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide7
		set object text of default title item to "這種狀態最麻煩的地方"
		set object text of default body item to my joinLines({"不是它不能動，而是每次動都要先重新理解上下文。", "", "看起來只是改一個頁面，但實際上可能要先搞清楚：", "1. 這頁用哪一套狀態管理", "2. controller 是在哪裡被建立", "3. 這個 service 還有沒有 fallback", "4. 改這裡會不會影響首頁或其他 section", "", "這種理解成本其實就是我們平常最常感受到的摩擦。"})
	end tell
	
	set slide8 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide8
		set object text of default title item to "實際壞處"
		set object text of default body item to my joinLines({"開發速度變慢：改之前要先考古", "除錯困難：狀態來源與生命週期不一致", "接手成本高：不是自己寫的模組很難快速判斷", "估時容易失準：小需求可能牽動很多隱藏耦合", "重構阻力大：因為缺少一致規則，大家自然會怕碰核心", "團隊協作變辛苦：每個人理解的『正常寫法』可能不一樣"})
	end tell
	
	set slide9 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide9
		set object text of default title item to "為什麼我們現在要整理"
		set object text of default body item to my joinLines({"不是因為現在完全不能用，而是再不整理，之後每次需求都會更痛。", "", "現在整理的好處是：", "1. 還能分階段做，不用一次大爆炸", "2. 我們已經確認 GetX 在這個專案裡是可落地的", "3. 已經有幾個低風險模組可以當模板往外複製", "4. 趁還能掌握時收斂，比等到下一次大改版再救火更划算"})
	end tell
	
	set slide10 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide10
		set object text of default title item to "這次重構的共識建議"
		set object text of default body item to my joinLines({"之後的新功能不要再新增 Bloc / Cubit", "頁面級依賴改用 Binding 管理", "Page 只做 UI，Controller 負責狀態與互動，Service 專心處理資料", "每完成一個模組就順手清掉對應的舊 bloc 寫法", "先從低風險模組開始擴散，不先碰首頁 shell 與啟動流程", "讓重構和新需求可以並行，但規則只往同一個方向收斂"})
	end tell
	
	set slide11 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide11
		set object text of default title item to "討論後希望形成的結果"
		set object text of default body item to my joinLines({"1. 我們對現況問題有一致認知", "2. 我們知道這不是單點 bug，而是結構性問題", "3. 我們同意後續以 GetX 收斂為主要方向", "4. 我們同意每做完一個模組就清一個模組，不再持續擴張混用", "5. 我們後續 review code 時，會用同一套規則檢查"})
	end tell
	
	save theDocument in POSIX file keynotePath
	export theDocument to POSIX file pdfPath as PDF
	close theDocument saving no
end tell
