# GetX Refactor Handoff

這份文件是給下一個對話視窗 / 下一位接手者用的重點交接。

## 目前分支

- branch: `codex/getx-search-migration`

## 目前重構方向

目標是把專案從 `Bloc/Cubit + GetX` 混用，逐步收斂到 `GetX-only`。

目前策略是：

- 每完成一個模組就做一個獨立 commit
- 先改低風險模組，再往中型模組與首頁 shell 推進
- 每次優先把 `Page -> Binding -> Controller -> Service` 建立起來
- 若某個舊 Bloc 已經沒有使用端，就順手刪除

## 已完成模組

### 第一批

- `search`
- `tag`
- `programList`
- `anchorperson / contact`

對應 commit:

- `d0a4a55` `refactor: migrate search tag program list and anchorperson to getx`

### 第二批

- `topic`
- `topicStoryList`
- `ombuds`

對應 commit:

- `16ea5a3` `refactor: migrate topic and ombuds to getx`

### 第三批

- `show` 主流程
  - `ShowPage`
  - `ShowCategoryTab`
  - `ShowTabContent`
  - `ShowIntroWidget`

對應 commit:

- `a6c3d88` `refactor: migrate show page flow to getx`

### 第四批

- `show playlist`
  - `ShowPlaylistWidget`
  - `ShowPlaylistTabContent`
  - `ShowStoryPage` 內更多節目內容

對應 commit:

- `ee8b823` `refactor: migrate show playlist flow to getx`

### 第五批

- 移除已棄用 `videoCategoryTab`

對應 commit:

- `92f47ed` `refactor: remove deprecated video category tab`

### 第六批

- `news` 外層分類流程
  - `NewsPage`
  - `NewsCategoryTab`
  - `NewsCategoryBinding`
  - `NewsCategoryController`

對應 commit:

- `d25e5a1` `refactor: migrate news category flow to getx`

### 第七批

- `news` 主列表流程
  - `NewsTabContent`
  - `NewsTabStoryList`
  - `NewsPopularTabStoryList`
  - `NewsStoryListBinding`
  - `NewsStoryListController`

對應 commit:

- `504b516` `refactor: migrate news story list flow to getx`

### 第八批

- `newsMarquee`
  - `BuildNewsMarquee` 改為自給自足 GetX
  - `NewsMarqueeBinding`
  - `NewsMarqueeController`
  - 移除舊 `lib/blocs/newsMarquee/*`

對應 commit:

- `8275351` `refactor: migrate news marquee to getx`

### 第九批

- 移除已無使用端的舊 bloc / widget
  - `lib/blocs/editorChoice/*`
  - `lib/blocs/tabStoryList/*`
  - `lib/pages/section/video/videoTabStoryList.dart`
  - `lib/pages/section/video/popularVideoTabStoryList.dart`
  - `lib/pages/shared/editorChoice/editorChoiceStoryList.dart`
  - 清理 `editorChoiceCarousel.dart`

對應 commit:

- `df4a401` `refactor: remove obsolete editor choice and tab story blocs`

### 第十批

- `HomePage / SectionCubit` shell flow
  - 新增 `AppShellController`
  - `HomeDrawer` 改由 GetX section flow 控制
  - `InitialApp` 不再建立 `SectionCubit`
  - 刪除：
    - `lib/blocs/section/section_cubit.dart`
    - `lib/blocs/section/section_state.dart`
    - `lib/services/sectionService.dart`

對應 commit:

- `61d9ecd` `refactor: migrate home shell section flow to getx`

## 目前仍存在的重要 Bloc / Cubit

截至這份交接文件撰寫時，repo 裡還存在這些 bloc/cubit：

- `lib/blocs/categories/*`
- `lib/blocs/config/*`
- `lib/blocs/contact/*`
- `lib/blocs/election/*`
- `lib/blocs/live/*`
- `lib/blocs/notificationSetting/*`
- `lib/blocs/programList/*`
- `lib/blocs/promotionVideo/*`
- `lib/blocs/search/*`
- `lib/blocs/show/*`
- `lib/blocs/story/*`
- `lib/blocs/tag/*`
- `lib/blocs/topicList/*`
- `lib/blocs/topicStoryList/*`
- `lib/blocs/video/*`
- `lib/blocs/youtubePlaylist/*`

但其中有些已經沒有使用端，只是還沒做最終清理。

## 已確認移除的舊 bloc

這些已經從使用端移除，且檔案已刪：

- `lib/blocs/newsMarquee/*`
- `lib/blocs/editorChoice/*`
- `lib/blocs/tabStoryList/*`
- `lib/blocs/section/*`

## 目前最重要的現況判斷

1. `HomePage` 的 section flow 已經不是 `SectionCubit`，而是 `AppShellController`
2. `news` 的外層分類與主列表流程都已切成 GetX
3. `show` 模組已基本完成 GetX 收斂
4. `topic`、`ombuds`、`search`、`tag`、`programList`、`anchorperson` 都已完成
5. `video` 主流程本來就已是半套 GetX，目前只清掉了舊殘留入口與舊列表檔

## 下一步最建議做的事

最建議直接接：

### 1. `live`

原因：

- 還有 `LiveCubit`
- 還有 `PromotionVideoBloc`
- 是首頁 section 之一
- 與現在 shell flow 已經接近

優先看：

- `lib/pages/section/live/livePage.dart`
- `lib/pages/section/live/promotionVideos.dart`
- `lib/blocs/live/*`
- `lib/blocs/promotionVideo/*`

### 2. `config / InitialApp`

如果想收核心流程，可考慮下一步整理：

- `lib/blocs/config/*`
- `InitialApp`

但這條風險高於 `live`。

## 已知注意事項

### 1. `flutter analyze` 與 `dart analyze`

有時候 shell 直接找不到 `dart` / `flutter`，可以改用：

- `fvm flutter analyze ...`

其中有一次需要升權是因為 FVM SDK cache 權限問題。

### 2. `textScaleFactor` deprecation

目前很多頁面還會出現：

- `textScaleFactor` deprecated

這是專案既有問題，不是這次重構新增問題。  
如果 analyze 只剩這類 info，可以先視為可接受，不一定要在每批重構裡順手清。

### 3. 未追蹤檔案很多是簡報 / 文件產物

目前工作區未追蹤檔案包含：

- `assets/diagrams/`
- `docs/`
- `tools/`
- `mnews_*.key`
- `mnews_*.pdf`
- `mnews_architecture_review.pptx`

這些大多是這次討論與簡報產物，不要和程式重構 commit 混在一起，除非使用者明確要求。

### 4. Git 操作習慣

這次重構的慣例是：

- 每完成一個模組就獨立 commit
- commit message 用 `refactor: ...`

## 建議接手開場語句

如果下一個視窗要快速接手，可以直接用這段：

> 目前分支是 `codex/getx-search-migration`，已完成 search/tag/programList/anchorperson、topic/ombuds、show、news 外層分類與主列表、newsMarquee，以及 HomePage/SectionCubit -> AppShellController 的重構。  
> 接下來請從 `live` 模組開始，把 `LiveCubit` 和 `PromotionVideoBloc` 收成 GetX，延續每完成一個模組就做一個 commit 的節奏。
