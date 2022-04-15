import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tv/blocs/tag/bloc.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/models/tag.dart';
import 'package:tv/pages/storyPage.dart';

class TagWidget extends StatefulWidget {
  final Tag tag;
  const TagWidget(this.tag);

  @override
  _TagWidgetState createState() => _TagWidgetState();
}

class _TagWidgetState extends State<TagWidget> {
  bool loadingMore = false;
  late List<StoryListItem> _tagStoryList;
  int _allStoryCount = 0;

  @override
  void initState() {
    _fetchStoryListByTagSlug();
    super.initState();
  }

  _fetchStoryListByTagSlug() {
    context
        .read<TagStoryListBloc>()
        .add(FetchStoryListByTagSlug(widget.tag.slug));
  }

  _fetchNextPageByTagSlug() async {
    context
        .read<TagStoryListBloc>()
        .add(FetchNextPageByTagSlug(widget.tag.slug));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TagStoryListBloc, TagStoryListState>(
        builder: (BuildContext context, TagStoryListState state) {
      if (state.status == TagStoryListStatus.error) {
        final error = state.error;
        print('TagStoryListError: ${error.message}');
        if (loadingMore) {
          _fetchNextPageByTagSlug();
        } else {
          if (error is NoInternetException) {
            return error.renderWidget(
                onPressed: () => _fetchNextPageByTagSlug());
          }

          return error.renderWidget();
        }
      }

      if (state.status == TagStoryListStatus.loadingMore) {
        _tagStoryList = state.tagStoryList!;
        loadingMore = true;
        return _buildList(_tagStoryList);
      }

      if (state.status == TagStoryListStatus.loadingMoreFail) {
        _tagStoryList = state.tagStoryList!;
        loadingMore = true;
        _fetchNextPageByTagSlug();
        return _buildList(_tagStoryList);
      }

      if (state.status == TagStoryListStatus.loaded) {
        _tagStoryList = state.tagStoryList!;
        loadingMore = false;
        _allStoryCount = state.allStoryCount!;
        return _buildList(_tagStoryList);
      }
      // state is Init, loading, or other
      return Center(child: const CircularProgressIndicator.adaptive());
    });
  }

  Widget _buildList(List<StoryListItem> tagStoryList) {
    bool isAll = false;
    if (tagStoryList.length == _allStoryCount) {
      isAll = true;
    }
    return ListView.builder(
      itemCount: tagStoryList.length + 1,
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
      itemBuilder: (context, index) {
        if (index == tagStoryList.length) {
          if (isAll) {
            return Container(
              padding: const EdgeInsets.only(bottom: 24),
            );
          }
          if (!loadingMore) _fetchNextPageByTagSlug();
          return Center(child: const CircularProgressIndicator.adaptive());
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildListItem(tagStoryList[index]),
        );
      },
    );
  }

  Widget _buildListItem(StoryListItem story) {
    double imageWidth = 33 * (MediaQuery.of(context).size.width - 48) / 100;
    double imageHeight = imageWidth;

    return InkWell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedNetworkImage(
            height: imageHeight,
            width: imageWidth,
            imageUrl: story.photoUrl,
            placeholder: (context, url) => Container(
              height: imageHeight,
              width: imageWidth,
              color: Colors.grey,
            ),
            errorWidget: (context, url, error) => Container(
              height: imageHeight,
              width: imageWidth,
              color: Colors.grey,
              child: Icon(Icons.error),
            ),
            fit: BoxFit.cover,
          ),
          SizedBox(
            width: 16,
          ),
          Expanded(
            child: Text(
              story.name,
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
      onTap: () {
        Get.to(() => StoryPage(
              slug: story.slug,
            ));
      },
    );
  }
}
