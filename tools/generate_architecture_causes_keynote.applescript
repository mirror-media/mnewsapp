set outputDir to POSIX path of "/Users/mac/Desktop/mnewsapp/"
set keynotePath to outputDir & "mnews_architecture_causes_review.key"
set pdfPath to outputDir & "mnews_architecture_causes_review.pdf"

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
		set object text of default title item to "mnews 專案為何會變得凌亂"
		set object text of default body item to my joinLines({"主題：從這次重構延伸看專案失序的形成原因與代價", "目的：讓 PM / 主管理解這不是單點程式碼問題，而是長期演進累積的結構問題", "輸出：說明為什麼會變成現在這樣，以及如果不處理會持續付出哪些成本"})
	end tell
	
	set slide2 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide2
		set object text of default title item to "一句話結論"
		set object text of default body item to my joinLines({"這個專案之所以變亂，不是因為某一次改壞了，而是多年持續疊加功能、快速交付、局部修補後，缺少一次把架構重新收斂的機會。", "", "結果是：每個階段都選了當下最快能交付的方法，最後卻讓整體架構變成多套規則並存、責任邊界模糊、維護成本越來越高。"})
	end tell
	
	set slide3 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide3
		set object text of default title item to "為什麼會一步步變成這樣"
		set object text of default body item to my joinLines({"1. 專案不是從完整架構設計開始，而是邊做功能邊長大", "2. 舊功能持續在線上，新需求只能在既有結構上局部加掛", "3. 團隊在不同時期用了不同做法，像 Bloc、Cubit、GetX 都留下來", "4. 趕時程時優先交付功能，沒有同步做架構回收", "5. 臨時解法缺少後續清理機制，久了就變正式結構", "6. 測試與文件不足，讓重構風險高，大家更傾向繼續沿用舊寫法"})
	end tell
	
	set slide4 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide4
		set object text of default title item to "在這個專案裡的具體表現"
		set object text of default body item to my joinLines({"狀態管理混用：Bloc / Cubit 與 GetX 同時存在", "依賴注入混用：Binding、Get.put、BlocProvider、widget init 都有", "頁面生命週期不一致：有些 controller 全域常駐，有些在首頁切換時手動建立與刪除", "首頁 shell 承擔過多控制責任，HomePage 同時管 section、controller、頁面切換", "service 與業務邏輯耦合過深，資料來源 fallback 與轉換分散", "很多問題不是單一模組錯，而是全專案規則不一致"})
	end tell
	
	set slide5 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide5
		set object text of default title item to "為什麼這種狀態會越來越糟"
		set object text of default body item to my joinLines({"因為架構混亂會自我放大。", "", "當工程師不知道該用哪一套規則時，就會選最接近眼前頁面的寫法；下一位工程師又會沿用那個局部慣例。", "", "結果不是只多一個例外，而是新的例外會不斷複製，最後變成：同類型問題在不同頁面有不同解法，後續每次改動都要重新理解整段上下文。"})
	end tell
	
	set slide6 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide6
		set object text of default title item to "對工程團隊的壞處"
		set object text of default body item to my joinLines({"開發變慢：同樣一個需求，工程師要先判斷這頁到底是哪一套寫法", "除錯變難：bug 發生時，狀態來源、建立點、生命週期都不一致", "交接成本高：新人或跨模組支援的人很難快速理解", "重構風險高：因為缺測試又缺統一規則，大家會怕動核心流程", "技術債持續增加：每次小修都可能再製造新的例外"})
	end tell
	
	set slide7 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide7
		set object text of default title item to "對 PM / 業務 / 交付的壞處"
		set object text of default body item to my joinLines({"需求估時越來越不準：看起來小的改動，實際可能要碰很多隱藏耦合", "開發風險提高：同樣的功能修改，更容易帶出首頁、啟動流程、文章頁等回歸問題", "驗收成本變高：同一個需求改動後，需要驗證的連帶流程變多", "專案節奏變差：團隊花更多時間在理解舊邏輯，而不是開發新功能", "當人員更替時，知識落差會直接影響交付速度"})
	end tell
	
	set slide8 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide8
		set object text of default title item to "如果不處理，之後會發生什麼"
		set object text of default body item to my joinLines({"短期看起來還能繼續加功能，但每一次新增都會讓系統更不一致", "未來任何一次 Flutter 升級、第三方套件升級、首頁改版，成本都會比現在更高", "團隊會越來越依賴少數熟悉歷史的人，形成維護風險", "當產品要加快迭代時，真正拖慢速度的不是需求量，而是這種結構性摩擦", "也就是說：不整理的代價不是不變，而是持續複利成長"})
	end tell
	
	set slide9 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide9
		set object text of default title item to "這次重構真正要解的不是語法"
		set object text of default body item to my joinLines({"重構不是把 Bloc 改成 GetX 這麼單純。", "", "真正要解的是：", "1. 統一專案規則", "2. 讓頁面責任清楚", "3. 讓依賴注入與生命週期可預測", "4. 降低之後加功能與改功能的理解成本", "", "所以這次做的是『把專案重新收斂到一套可持續維護的方式』，不是單純換寫法。"})
	end tell
	
	set slide10 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide10
		set object text of default title item to "建議對外怎麼講"
		set object text of default body item to my joinLines({"這不是為了追求技術漂亮，而是為了降低專案持續開發的摩擦成本。", "", "可以這樣描述：", "目前專案的主要問題不是單一 bug，而是架構規則不一致，導致開發、除錯、驗收、估時都越來越困難。", "這次重構的目標，是把狀態管理與依賴注入方式統一，降低後續需求開發與回歸風險。"})
	end tell
	
	save theDocument in POSIX file keynotePath
	export theDocument to POSIX file pdfPath as PDF
	close theDocument saving no
end tell
