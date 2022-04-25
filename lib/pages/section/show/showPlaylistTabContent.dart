import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/dateTimeFormat.dart';
import 'package:tv/models/youtubePlaylistInfo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/youtubePlaylist/bloc.dart';
import 'package:tv/blocs/youtubePlaylist/events.dart';
import 'package:tv/blocs/youtubePlaylist/states.dart';
import 'package:tv/models/youtubePlaylistItem.dart';
import 'package:tv/pages/section/show/showStoryPage.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';

class ShowPlaylistTabContent extends StatefulWidget {
  final YoutubePlaylistInfo youtubePlaylistInfo;
  final ScrollController listviewController;
  final bool isMoreShow;
  ShowPlaylistTabContent({
    Key? key,
    required this.youtubePlaylistInfo,
    required this.listviewController,
    this.isMoreShow = false,
  }) : super(key: key);

  @override
  _ShowPlaylistTabContentState createState() => _ShowPlaylistTabContentState();
}

class _ShowPlaylistTabContentState extends State<ShowPlaylistTabContent> {
  final int _fetchPlaylistMaxResult = 10;
  late bool _isLoading;
  final TextScaleFactorController textScaleFactorController = Get.find();

  @override
  void initState() {
    _fetchSnippetByPlaylistId(widget.youtubePlaylistInfo.youtubePlayListId);
    _initPagetokenAndIsLoading();

    widget.listviewController.addListener(() {
      if (widget.listviewController.position.pixels ==
              widget.listviewController.position.maxScrollExtent &&
          !_isLoading) {
        _fetchSnippetByPlaylistIdAndPageToken(
            widget.youtubePlaylistInfo.youtubePlayListId);
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(ShowPlaylistTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchSnippetByPlaylistId(widget.youtubePlaylistInfo.youtubePlayListId);
    _initPagetokenAndIsLoading();
  }

  _fetchSnippetByPlaylistId(String id) async {
    context
        .read<YoutubePlaylistBloc>()
        .add(FetchSnippetByPlaylistId(id, maxResults: _fetchPlaylistMaxResult));
  }

  _fetchSnippetByPlaylistIdAndPageToken(String id) async {
    context.read<YoutubePlaylistBloc>().add(
        FetchSnippetByPlaylistIdAndPageToken(id,
            maxResults: _fetchPlaylistMaxResult));
  }

  _initPagetokenAndIsLoading() {
    _isLoading = true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YoutubePlaylistBloc, YoutubePlaylistState>(
        builder: (BuildContext context, YoutubePlaylistState state) {
      if (state is YoutubePlaylistError) {
        final error = state.error;
        print('YoutubePlaylistError: ${error.message}');
        return Container();
      }
      if (state is YoutubePlaylistLoadingMore) {
        _isLoading = true;
        List<YoutubePlaylistItem> youtubePlaylistItemList =
            state.youtubePlaylistItemList;
        return _buildYoutubePlaylistItemList(
            widget.youtubePlaylistInfo.youtubePlayListId,
            youtubePlaylistItemList,
            isLoading: true);
      }
      if (state is YoutubePlaylistLoadingMoreFail) {
        List<YoutubePlaylistItem> youtubePlaylistItemList =
            state.youtubePlaylistItemList;
        _isLoading = false;

        return _buildYoutubePlaylistItemList(
            widget.youtubePlaylistInfo.youtubePlayListId,
            youtubePlaylistItemList,
            isLoading: true);
      }
      if (state is YoutubePlaylistLoaded) {
        List<YoutubePlaylistItem> youtubePlaylistItemList =
            state.youtubePlaylistItemList;
        _isLoading = false;

        return _buildYoutubePlaylistItemList(
          widget.youtubePlaylistInfo.youtubePlayListId,
          youtubePlaylistItemList,
        );
      }

      // state is Init, loading, or other
      return _loadMoreWidget();
    });
  }

  Widget _buildYoutubePlaylistItemList(String youtubePlayListId,
      List<YoutubePlaylistItem> youtubePlaylistItemList,
      {bool isLoading = false}) {
    List<YoutubePlaylistItem> firstToFive = [];
    List<YoutubePlaylistItem> sixToTen = [];
    List<YoutubePlaylistItem> others = [];
    for (int i = 0; i < youtubePlaylistItemList.length; i++) {
      if (i < 5) {
        firstToFive.add(youtubePlaylistItemList[i]);
      } else if (i < 10) {
        sixToTen.add(youtubePlaylistItemList[i]);
      } else {
        others.add(youtubePlaylistItemList[i]);
      }
    }

    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        SizedBox(height: 24),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (BuildContext context, int index) =>
              SizedBox(height: 16.0),
          itemCount: firstToFive.length,
          itemBuilder: (context, index) {
            return _buildListItem(
                context, youtubePlayListId, firstToFive[index]);
          },
        ),
        Align(
          alignment: Alignment.center,
          child: InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('ShowAT2'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
              AdSize(width: 320, height: 480),
            ],
            addHorizontalMargin: false,
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (BuildContext context, int index) =>
              SizedBox(height: 16.0),
          itemCount: sixToTen.length,
          itemBuilder: (context, index) {
            return _buildListItem(context, youtubePlayListId, sixToTen[index]);
          },
        ),
        Align(
          alignment: Alignment.center,
          child: InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('ShowAT3'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
            ],
            addHorizontalMargin: false,
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (BuildContext context, int index) =>
              SizedBox(height: 16.0),
          itemCount: others.length,
          itemBuilder: (context, index) {
            return _buildListItem(context, youtubePlayListId, others[index]);
          },
        ),
        if (isLoading) _loadMoreWidget(),
      ],
    );
  }

  Widget _buildListItem(
    BuildContext context,
    String youtubePlayListId,
    YoutubePlaylistItem youtubePlaylistItem,
  ) {
    DateTimeFormat dateTimeFormat = DateTimeFormat();
    var width = MediaQuery.of(context).size.width;
    double imageWidth = 33.3 * (width - 48) / 100;
    double imageHeight = imageWidth / 16 * 9;

    return InkWell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedNetworkImage(
            height: imageHeight,
            width: imageWidth,
            imageUrl: youtubePlaylistItem.photoUrl,
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
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => ExtendedText(
                    youtubePlaylistItem.name,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textScaleFactor:
                        textScaleFactorController.textScaleFactor.value,
                  ),
                ),
                if (youtubePlaylistItem.publishedAt != null) ...[
                  SizedBox(height: 12),
                  Text(
                    dateTimeFormat.changeStringToDisplayString(
                        youtubePlaylistItem.publishedAt!,
                        'yyyy-MM-ddTHH:mm:ssZ',
                        'yyyy年MM月dd日'),
                    style: TextStyle(
                      color: Color(0xff757575),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      onTap: () {
        if (widget.isMoreShow) {
          Get.off(
            () => ShowStoryPage(
              youtubePlayListId: youtubePlayListId,
              youtubePlaylistItem: youtubePlaylistItem,
            ),
            preventDuplicates: false,
          );
        } else {
          Get.to(
            () => ShowStoryPage(
              youtubePlayListId: youtubePlayListId,
              youtubePlaylistItem: youtubePlaylistItem,
            ),
            preventDuplicates: false,
          );
        }
      },
    );
  }

  Widget _loadMoreWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(child: CupertinoActivityIndicator()),
    );
  }
}
