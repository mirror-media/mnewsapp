import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tv/blocs/search/bloc.dart';
import 'package:tv/blocs/search/events.dart';
import 'package:tv/blocs/search/states.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/pages/search/searchNoResultWidget.dart';
import 'package:tv/pages/storyPage.dart';
import 'package:tv/pages/webStoryPage.dart';

class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _listviewController = ScrollController();
  late bool _isLoading;
  late bool _isLoadingMax;

  // 排序狀態：relevance / published_at
  String _orderBy = 'relevance';

  // 定義主題藍色，與截圖一致
  final Color themeBlue = const Color(0xFF0055BB);

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _isLoadingMax = false;

    _listviewController.addListener(() {
      if (!_isLoadingMax &&
          _listviewController.position.pixels ==
              _listviewController.position.maxScrollExtent &&
          !_isLoading) {
        _searchNextPageByKeyword(_textController.text);
      }
    });
  }

  void _searchNewsStoryByKeyword(String keyword) {
    if (keyword.trim().isEmpty) return;
    context
        .read<SearchBloc>()
        .add(SearchNewsStoryByKeyword(keyword, orderBy: _orderBy));
  }

  void _searchNextPageByKeyword(String keyword) {
    if (keyword.trim().isEmpty) return;
    context
        .read<SearchBloc>()
        .add(SearchNextPageByKeyword(keyword, orderBy: _orderBy));
  }

  void _clearKeyword() {
    _textController.clear();
    context.read<SearchBloc>().add(ClearKeyword());
  }

  // 當點擊切換按鈕時呼叫
  void _onChangeOrderBy(String nextOrderBy) {
    if (_orderBy == nextOrderBy) return;

    setState(() => _orderBy = nextOrderBy);

    final keyword = _textController.text.trim();
    if (keyword.isNotEmpty) {
      _searchNewsStoryByKeyword(keyword);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _listviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // 搜尋輸入框
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 12.0),
          child: _keywordTextField(width - 24),
        ),

        // ✅ 新增：並排切換按鈕 (依關聯性 / 依發布時間)
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: themeBlue, width: 1),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              children: [
                _buildSortButton('依關聯性', 'relevance'),
                // 中間的分隔線
                Container(width: 1, color: themeBlue),
                _buildSortButton('依發布時間', 'published_at'),
              ],
            ),
          ),
        ),

        // 搜尋結果列表
        BlocBuilder<SearchBloc, SearchState>(
          builder: (BuildContext context, SearchState state) {
            if (state is SearchError) {
              final error = state.error;
              if (error is NoInternetException) {
                return Expanded(
                  child: error.renderWidget(
                    onPressed: () =>
                        _searchNewsStoryByKeyword(_textController.text),
                  ),
                );
              }
              return Expanded(child: error.renderWidget());
            }

            if (state is SearchInitState) {
              return Container();
            }

            if (state is SearchLoaded) {
              _isLoading = false;
              final storyListItemList = state.storyListItemList;
              _isLoadingMax = storyListItemList.length == state.allStoryCount;

              return Expanded(
                child: _buildSearchList(
                  context,
                  storyListItemList,
                  _textController.text,
                ),
              );
            }

            if (state is SearchLoadingMore) {
              _isLoading = true;
              final storyListItemList = state.storyListItemList;

              return Expanded(
                child: _buildSearchList(
                  context,
                  storyListItemList,
                  _textController.text,
                  isLoadingMore: true,
                ),
              );
            }

            return _loadingWidget();
          },
        ),
      ],
    );
  }

  // ✅ 封裝切換按鈕的小元件
  Widget _buildSortButton(String label, String value) {
    bool isSelected = (_orderBy == value);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onChangeOrderBy(value),
        child: Container(
          alignment: Alignment.center,
          // 選中時藍色，未選中時白色
          color: isSelected ? themeBlue : Colors.white,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              // 選中時文字白色，未選中時文字藍色
              color: isSelected ? Colors.white : themeBlue,
            ),
          ),
        ),
      ),
    );
  }

  Widget _keywordTextField(double width) {
    return SizedBox(
      width: width,
      child: Theme(
        data: Theme.of(context).copyWith(primaryColor: Colors.grey),
        child: TextField(
          controller: _textController,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(3.0)),
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
            suffixIcon: IconButton(
              onPressed: _clearKeyword,
              icon: const Icon(Icons.clear),
            ),
            hintText: "請輸入關鍵字",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          onSubmitted: (_) {
            _searchNewsStoryByKeyword(_textController.text);
            AnalyticsHelper.logSearch(searchText: _textController.text);
          },
        ),
      ),
    );
  }

  Widget _buildSearchList(
      BuildContext context,
      List<StoryListItem> storyListItemList,
      String keyword, {
        bool isLoadingMore = false,
      }) {
    if (storyListItemList.isEmpty) {
      return SearchNoResultWidget(keyword: keyword);
    }

    return ListView.separated(
      controller: _listviewController,
      separatorBuilder: (_, __) => const SizedBox(height: 16.0),
      itemCount: storyListItemList.length,
      itemBuilder: (context, index) {
        if (index == storyListItemList.length - 1 && isLoadingMore) {
          return Column(
            children: [
              _buildListItem(context, storyListItemList[index], index),
              const Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Center(child: CupertinoActivityIndicator()),
              ),
            ],
          );
        }
        return _buildListItem(context, storyListItemList[index], index);
      },
    );
  }

  Widget _buildListItem(
      BuildContext context,
      StoryListItem storyListItem,
      int index,
      ) {
    final width = MediaQuery.of(context).size.width;
    final imageSize = 33.3 * (width - 32) / 100;

    return InkWell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              height: imageSize,
              width: imageSize,
              imageUrl: storyListItem.photoUrl,
              placeholder: (_, __) => Container(
                height: imageSize,
                width: imageSize,
                color: Colors.grey,
              ),
              errorWidget: (_, __, ___) => Container(
                height: imageSize,
                width: imageSize,
                color: Colors.grey,
                child: const Icon(Icons.error),
              ),
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                    height: 1.5,
                  ),
                  text: storyListItem.name ?? '',
                ),
              ),
            ),
          ],
        ),
      ),
        onTap: () {
          final slug = storyListItem.slug;
          final type = storyListItem.linkType;
          if (slug != null && slug.isNotEmpty) {
            Get.to(() => StoryPage(slug: slug, linkType: type));
            return;
          }
          // 如果沒有 slug：你可以選擇不做事或顯示提示
          // Get.snackbar('無法開啟', '此內容沒有 slug');
        }
    );
  }

  Widget _loadingWidget() => const Center(
    child: CircularProgressIndicator.adaptive(),
  );
}