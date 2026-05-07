import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/controller/search_controller.dart' as search;
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/pages/search/search_no_result_widget.dart';
import 'package:tv/pages/story_page.dart';

class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final search.SearchController controller = Get.find<search.SearchController>();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _listviewController = ScrollController();

  final Color themeBlue = const Color(0xFF0055BB);

  @override
  void initState() {
    super.initState();
    _listviewController.addListener(() {
      if (!controller.isLoadingMax &&
          _listviewController.position.pixels ==
              _listviewController.position.maxScrollExtent &&
          !controller.isLoading.value &&
          !controller.isLoadingMore.value) {
        controller.searchNextPage();
      }
    });
  }

  void _searchNewsStoryByKeyword(String keyword) {
    controller.searchNewsStoryByKeyword(keyword);
  }

  void _clearKeyword() {
    _textController.clear();
    controller.clearKeyword();
  }

  void _onChangeOrderBy(String nextOrderBy) {
    controller.changeOrderBy(nextOrderBy);
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
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 12.0),
          child: _keywordTextField(width - 24),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
          child: Obx(
            () => Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: themeBlue, width: 1),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Row(
                children: [
                  _buildSortButton('依關聯性', 'relevance'),
                  Container(width: 1, color: themeBlue),
                  _buildSortButton('依發布時間', 'published_at'),
                ],
              ),
            ),
          ),
        ),
        Obx(
          () {
            final error = controller.error.value;
            if (error != null) {
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

            if (controller.isInitState) {
              return Container();
            }

            if (controller.isLoading.value &&
                controller.storyListItemList.isEmpty) {
              return _loadingWidget();
            }

            return Expanded(
              child: _buildSearchList(
                context,
                controller.storyListItemList,
                _textController.text,
                isLoadingMore: controller.isLoadingMore.value,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSortButton(String label, String value) {
    final bool isSelected = controller.orderBy.value == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onChangeOrderBy(value),
        child: Container(
          alignment: Alignment.center,
          color: isSelected ? themeBlue : Colors.white,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
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
        }
      },
    );
  }

  Widget _loadingWidget() => const Center(
    child: CircularProgressIndicator.adaptive(),
  );
}
