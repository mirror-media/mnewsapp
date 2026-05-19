set outputDir to POSIX path of "/Users/mac/Desktop/mnewsapp/"
set keynotePath to outputDir & "mnews_ai_agent_cost_report.key"
set pdfPath to outputDir & "mnews_ai_agent_cost_report.pdf"

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
		set object text of default title item to "AI Agent 與重構成本"
		set object text of default body item to my joinLines({"主題：如果不先重構，AI agent 為什麼每次都會多花 token", "用途：協助團隊理解架構混亂不只影響人，也會影響 AI 協作效率", "結論：重構不是增加 AI 成本，而是在降低後續每一次 AI 任務的平均成本"})
	end tell
	
	set slide2 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide2
		set object text of default title item to "一句話結論"
		set object text of default body item to my joinLines({"會，而且通常不是一次性的。", "", "只要專案規則不一致，AI agent 在每一次任務裡，都要先花額外 token 重新理解：這個模組用了哪套規則、狀態在哪裡、依賴怎麼注入、資料流從哪裡進來。", "", "這些 token 消耗掉的是理解成本，不是功能產出。"})
	end tell
	
	set slide3 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide3
		set object text of default title item to "為什麼是每一次都會多花"
		set object text of default body item to my joinLines({"AI agent 不是靠印象工作，而是每次任務都要重新建立上下文。", "", "如果專案規則穩定，agent 可以很快套用同一套假設。", "如果專案規則混亂，agent 就必須額外讀更多檔案來驗證：", "1. 是 Bloc 還是 GetX", "2. controller / bloc 在哪裡建立", "3. 這頁有沒有特殊 fallback", "4. 改這裡會不會牽動其他模組"})
	end tell
	
	set slide4 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide4
		set object text of default title item to "哪些狀況最容易放大 token 消耗"
		set object text of default body item to my joinLines({"狀態管理混用：Bloc / Cubit / GetX 並存", "依賴注入混用：Binding、Get.put、BlocProvider、widget init 都有", "生命週期不一致：有些全域、有些 page-scoped、有些首頁切換時手動建立", "同類型頁面寫法不同：同樣列表頁卻走不同資料流", "service 邊界過厚：資料來源 fallback、格式轉換與業務邏輯混在一起"})
	end tell
	
	set slide5 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide5
		set object text of default title item to "對 AI 協作的直接影響"
		set object text of default body item to my joinLines({"每次任務要先讀更多檔案", "上下文建立時間變長，token 消耗增加", "agent 花更多成本在判斷專案規則，而不是直接修改功能", "同樣一個需求，在乾淨專案和混亂專案中的 AI 成本差距會越來越明顯", "複雜任務或核心頁面改動時，這個額外成本會被放大"})
	end tell
	
	set slide6 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide6
		set object text of default title item to "對團隊與 PM 的影響"
		set object text of default body item to my joinLines({"AI 不會自動讓混亂專案變快，因為它也要先考古", "需求估時會更難穩定，因為小需求也可能牽動很多隱藏耦合", "驗收範圍容易變大，因為相依關係不清楚", "團隊可能會誤以為 AI 不夠準，但很多時候其實是專案規則本身不穩定", "專案越不一致，AI 協作的收益就越容易被上下文成本吃掉"})
	end tell
	
	set slide7 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide7
		set object text of default title item to "為什麼先重構反而更省"
		set object text of default body item to my joinLines({"如果專案逐步收斂成固定資料流，例如：Page -> Controller -> Service -> API", "而且新功能都遵守同一套規則，那 agent 後續通常可以：", "1. 用更少檔案建立上下文", "2. 更快找到真正修改點", "3. 用更穩定的模式複製到其他模組", "4. 減少每一次任務重複理解的成本", "", "重構的價值之一，就是讓 AI 協作效率變得可預測。"})
	end tell
	
	set slide8 to make new slide at end of slides of theDocument with properties {base slide:master slide "大標題與項目符號" of theDocument}
	tell slide8
		set object text of default title item to "建議團隊形成的共識"
		set object text of default body item to my joinLines({"把 AI 協作成本視為架構品質的一部分", "新功能不要再新增新的狀態管理模式", "頁面資料流固定走 Page -> Controller -> Service", "完成重構的模組要順手清掉舊寫法，不要雙軌並存", "用穩定規則降低人類工程師與 AI agent 的共同理解成本"})
	end tell
	
	save theDocument in POSIX file keynotePath
	export theDocument to POSIX file pdfPath as PDF
	close theDocument saving no
end tell
