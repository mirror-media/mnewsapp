import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/bindings/show_playlist_binding.dart';
import 'package:tv/controller/show_playlist_controller.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/dateTimeFormat.dart';
import 'package:tv/models/youtubePlaylistInfo.dart';
import 'package:tv/models/youtubePlaylistItem.dart';
import 'package:tv/pages/section/show/showStoryPage.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';

class ShowPlaylistTabContent extends StatefulWidget {
  const ShowPlaylistTabContent({
    super.key,
    required this.controllerTag,
    required this.youtubePlaylistInfo,
    required this.listviewController,
    this.isMoreShow = false,
    this.firstYoutubePlaylistItem,
  });

  final String controllerTag;
  final YoutubePlaylistInfo youtubePlaylistInfo;
  final ScrollController listviewController;
  final bool isMoreShow;
  final YoutubePlaylistItem? firstYoutubePlaylistItem;

  @override
  State<ShowPlaylistTabContent> createState() => _ShowPlaylistTabContentState();
}

class _ShowPlaylistTabContentState extends State<ShowPlaylistTabContent> {
  static const int fetchPlaylistMaxResult = 10;
  final TextScaleFactorController textScaleFactorController = Get.find();
  late final ShowPlaylistController controller;

  @override
  void initState() {
    super.initState();
    ShowPlaylistBinding(
      controllerTag: widget.controllerTag,
      playlistId: widget.youtubePlaylistInfo.youtubePlayListId,
      maxResults: fetchPlaylistMaxResult,
    ).dependencies();
    controller = Get.find<ShowPlaylistController>(tag: widget.controllerTag);

    widget.listviewController.addListener(() {
      if (widget.listviewController.position.pixels ==
              widget.listviewController.position.maxScrollExtent &&
          !controller.isLoadingMore.value) {
        controller.fetchMore();
      }
    });
  }

  @override
  void dispose() {
    if (Get.isRegistered<ShowPlaylistController>(tag: widget.controllerTag)) {
      Get.delete<ShowPlaylistController>(tag: widget.controllerTag);
    }
    if (Get.isRegistered(tag: widget.controllerTag)) {
      Get.delete(tag: widget.controllerTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = controller.error.value;
      if (error != null) {
        return Container();
      }

      final youtubePlaylistItemList = controller.youtubePlaylistItemList.toList();
      if (youtubePlaylistItemList.isNotEmpty) {
        return buildYoutubePlayListItemList(
          widget.youtubePlaylistInfo.youtubePlayListId,
          youtubePlaylistItemList,
          isLoading: controller.isLoadingMore.value,
        );
      }

      return loadMoreWidget();
    });
  }

  Widget buildYoutubePlayListItemList(
    String youtubePlayListId,
    List<YoutubePlaylistItem> youtubePlaylistItemList, {
    bool isLoading = false,
  }) {
    youtubePlaylistItemList.removeWhere(
      (element) => element.name == widget.firstYoutubePlaylistItem?.name,
    );

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 24),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (BuildContext context, int index) {
            if (index == 4) {
              return Align(
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
              );
            }
            if (index == 9) {
              return Align(
                alignment: Alignment.center,
                child: InlineBannerAdWidget(
                  adUnitId: AdUnitIdHelper.getBannerAdUnitId('ShowAT3'),
                  sizes: [
                    AdSize.mediumRectangle,
                    AdSize(width: 336, height: 280),
                  ],
                  addHorizontalMargin: false,
                ),
              );
            }

            return const SizedBox(height: 16.0);
          },
          itemCount: youtubePlaylistItemList.length,
          itemBuilder: (context, index) {
            return buildListItem(
              context,
              youtubePlayListId,
              youtubePlaylistItemList[index],
            );
          },
        ),
        if (isLoading) loadMoreWidget(),
      ],
    );
  }

  Widget buildListItem(
    BuildContext context,
    String youtubePlayListId,
    YoutubePlaylistItem youtubePlaylistItem,
  ) {
    final dateTimeFormat = DateTimeFormat();
    final width = MediaQuery.of(context).size.width;
    final imageWidth = 33.3 * (width - 48) / 100;
    final imageHeight = imageWidth / 16 * 9;

    return InkWell(
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
              child: const Icon(Icons.error),
            ),
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => ExtendedText(
                    youtubePlaylistItem.name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textScaler: TextScaler.linear(
                      textScaleFactorController.textScaleFactor.value,
                    ),
                  ),
                ),
                if (youtubePlaylistItem.publishedAt != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    dateTimeFormat.changeStringToDisplayString(
                      youtubePlaylistItem.publishedAt!,
                      'yyyy-MM-ddTHH:mm:ssZ',
                      'yyyy年MM月dd日',
                    ),
                    style: const TextStyle(
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
    );
  }

  Widget loadMoreWidget() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: CupertinoActivityIndicator()),
    );
  }
}
