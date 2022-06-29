import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tv/controller/interstitialAdController.dart';
import 'package:tv/controller/storyPageController.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/helpers/dateTimeFormat.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/helpers/paragraphFormat.dart';
import 'package:tv/models/paragraph.dart';
import 'package:tv/models/people.dart';
import 'package:tv/models/story.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/models/tag.dart';
import 'package:tv/pages/changeFontSizePage.dart';
import 'package:tv/pages/tag/tagPage.dart';
import 'package:tv/services/storyService.dart';
import 'package:tv/widgets/anchoredBannerAdWidget.dart';
import 'package:tv/widgets/imageViewerWidget.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';
import 'package:tv/widgets/story/fileDownloadWidget.dart';
import 'package:tv/widgets/story/mNewsVideoPlayer.dart';
import 'package:tv/widgets/story/parseTheTextToHtmlWidget.dart';
import 'package:tv/widgets/story/relatedStoryPainter.dart';
import 'package:tv/widgets/story/storyBriefFrameClipper.dart';
import 'package:tv/widgets/story/youtubePlayer.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class StoryPage extends StatelessWidget {
  final String slug;
  final bool showAds;
  StoryPage({
    required this.slug,
    this.showAds = true,
  });
  final interstitialAdController = Get.find<InterstitialAdController>();
  final TextScaleFactorController textScaleFactorController = Get.find();

  @override
  Widget build(BuildContext context) {
    if (showAds) {
      interstitialAdController.openStory();
    }

    return GetBuilder<StoryPageController>(
      init: StoryPageController(StoryServices(), slug),
      tag: slug,
      builder: (controller) {
        Widget body = Center(
          child: CircularProgressIndicator.adaptive(),
        );

        if (controller.isError) {
          if (controller.error is NoInternetException) {
            body = controller.error
                .renderWidget(onPressed: () => controller.loadStory(slug));
          }

          body = controller.error.renderWidget();
        } else if (!controller.isLoading) {
          body = Column(
            children: [
              Expanded(
                child: _storyContent(controller.story),
              ),
              Obx(
                () {
                  if (interstitialAdController.storyCounter.isEven &&
                      interstitialAdController.storyCounter.value != 0 &&
                      showAds) {
                    return AnchoredBannerAdWidget(
                      adUnitId: AdUnitIdHelper.getBannerAdUnitId('StoryFooter'),
                    );
                  }
                  return Container();
                },
              ),
            ],
          );
        }

        return Scaffold(
          appBar: _buildBar(),
          body: body,
        );
      },
    );
  }

  PreferredSizeWidget _buildBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () => Get.back(),
      ),
      backgroundColor: appBarColor,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.font_download),
          tooltip: '更改字體大小',
          onPressed: () => Get.to(() => ChangeFontSizePage()),
        ),
        IconButton(
          icon: Icon(Icons.share),
          tooltip: 'Share',
          onPressed: () {
            AnalyticsHelper.logShare(
                name: Get.find<StoryPageController>(tag: slug).currentSlug,
                type: 'story');
            String url = Environment().config.mNewsWebsiteLink +
                '/story/' +
                Get.find<StoryPageController>(tag: slug).currentSlug;
            Share.share(url);
          },
        ),
      ],
    );
  }

  Widget _storyContent(Story story) {
    return ListView(
      shrinkWrap: true,
      children: [
        if (showAds)
          InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('StoryHD'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
            ],
            wantKeepAlive: true,
          ),
        _buildHeroWidget(story),
        SizedBox(height: 24),
        _buildCategoryAndPublishedDate(story),
        SizedBox(height: 10),
        _buildStoryTitle(story.name ?? ''),
        SizedBox(height: 8),
        _buildAuthors(story),
        SizedBox(height: 32),
        _buildBrief(story.brief ?? []),
        _buildContent(story.contentApiData ?? []),
        if (story.downloadFileList != null &&
            story.downloadFileList!.isNotEmpty)
          FileDownloadWidget(
            story.downloadFileList!,
            textSize: 17 * textScaleFactorController.textScaleFactor.value,
          ),
        if (showAds)
          InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('StoryAT2'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
            ],
            wantKeepAlive: true,
          ),
        Center(child: _buildUpdatedTime(story.updatedAt!)),
        SizedBox(height: 32),
        if (story.tags != null && story.tags!.length > 0) ...[
          _buildTags(story.tags),
          SizedBox(height: 16),
        ],
        if (story.relatedStories!.length > 0) ...[
          _buildRelatedWidget(story.relatedStories!),
          SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildHeroWidget(Story story) {
    double height = Get.width / 16 * 9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (story.heroVideo != null) _buildVideoWidget(story.heroVideo!),
        if (story.heroImage != null && story.heroVideo == null)
          InkWell(
            onTap: () {
              int index = story.imageUrlList?.indexOf(story.heroImage!) ?? 0;
              if (index == -1) {
                index = 0;
              }
              Get.to(ImageViewerWidget(
                story.imageUrlList ?? [story.heroImage!],
                openIndex: index,
              ));
            },
            child: CachedNetworkImage(
              width: Get.width,
              imageUrl: story.heroImage!,
              placeholder: (context, url) => Container(
                height: height,
                width: Get.width,
                color: Colors.grey,
              ),
              errorWidget: (context, url, error) => Container(
                height: height,
                width: Get.width,
                color: Colors.grey,
                child: Icon(Icons.error),
              ),
              fit: BoxFit.cover,
            ),
          ),
        if (!_isNullOrEmpty(story.heroCaption))
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0.0),
            child: Obx(
              () => Text(
                story.heroCaption!,
                style: TextStyle(fontSize: 15, color: Color(0xff757575)),
                textScaleFactor:
                    textScaleFactorController.textScaleFactor.value,
              ),
            ),
          ),
      ],
    );
  }

  _buildVideoWidget(String videoUrl) {
    String youtubeString = 'youtube';
    if (videoUrl.contains(youtubeString)) {
      String? ytId = VideoId.parseVideoId(videoUrl) ?? '';
      return YoutubePlayer(ytId);
    }

    return MNewsVideoPlayer(
      videourl: videoUrl,
      aspectRatio: 16 / 9,
    );
  }

  Widget _buildCategoryAndPublishedDate(Story story) {
    DateTimeFormat dateTimeFormat = DateTimeFormat();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (story.categoryList!.length == 0) Container(),
            if (story.categoryList!.length > 0)
              Text(
                story.categoryList![0].name,
                style: TextStyle(
                  fontSize: 15,
                  color: storyWidgetColor,
                  fontWeight: FontWeight.w500,
                ),
                textScaleFactor:
                    textScaleFactorController.textScaleFactor.value,
              ),
            Text(
              dateTimeFormat.changeStringToDisplayString(story.publishTime!,
                  'yyyy-MM-ddTHH:mm:ssZ', 'yyyy.MM.dd HH:mm 臺北時間'),
              style: TextStyle(
                fontSize: 14,
                color: Color(0xff757575),
              ),
              textScaleFactor: textScaleFactorController.textScaleFactor.value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
      child: Obx(
        () => Text(
          title,
          style: TextStyle(
            fontFamily: 'PingFang TC',
            fontSize: 26,
            fontWeight: FontWeight.w500,
          ),
          textScaleFactor: textScaleFactorController.textScaleFactor.value,
        ),
      ),
    );
  }

  Widget _buildAuthors(Story story) {
    Color authorColor = Color(0xff757575);
    List<Widget> authorItems = List.empty(growable: true);

    // VerticalDivider is broken? so use Container
    var myVerticalDivider = Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
      child: Container(
        color: Color(0xff757575),
        width: 1,
        height: 15,
      ),
    );

    if (story.writers!.length > 0) {
      List<Widget> items = [];
      items.add(
        Obx(
          () => Text(
            "記者",
            style: TextStyle(fontSize: 15, color: authorColor),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          ),
        ),
      );
      items.add(myVerticalDivider);

      items.addAll(_addAuthorItems(story.writers!));
      authorItems.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ));
      authorItems.add(SizedBox(
        width: 12.0,
      ));
    }

    if (story.photographers!.length > 0) {
      List<Widget> items = [];
      items.add(
        Obx(
          () => Text(
            "攝影",
            style: TextStyle(fontSize: 15, color: authorColor),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          ),
        ),
      );
      items.add(myVerticalDivider);

      items.addAll(_addAuthorItems(story.photographers!));
      authorItems.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ));
      authorItems.add(SizedBox(
        width: 12.0,
      ));
    }

    if (story.cameraOperators!.length > 0) {
      List<Widget> items = [];
      items.add(
        Obx(
          () => Text(
            "影音",
            style: TextStyle(fontSize: 15, color: authorColor),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          ),
        ),
      );
      items.add(myVerticalDivider);

      items.addAll(_addAuthorItems(story.cameraOperators!));
      authorItems.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ));
      authorItems.add(SizedBox(
        width: 12.0,
      ));
    }

    if (story.designers!.length > 0) {
      List<Widget> items = [];
      items.add(
        Obx(
          () => Text(
            "設計",
            style: TextStyle(fontSize: 15, color: authorColor),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          ),
        ),
      );
      items.add(myVerticalDivider);

      items.addAll(_addAuthorItems(story.designers!));
      authorItems.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ));
      authorItems.add(SizedBox(
        width: 12.0,
      ));
    }

    if (story.engineers!.length > 0) {
      List<Widget> items = [];
      items.add(
        Obx(
          () => Text(
            "工程",
            style: TextStyle(fontSize: 15, color: authorColor),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          ),
        ),
      );
      items.add(myVerticalDivider);

      items.addAll(_addAuthorItems(story.engineers!));
      authorItems.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ));
      authorItems.add(SizedBox(
        width: 12.0,
      ));
    }

    if (story.vocals!.length > 0) {
      List<Widget> items = [];
      items.add(
        Obx(
          () => Text(
            "主播",
            style: TextStyle(fontSize: 15, color: authorColor),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          ),
        ),
      );
      items.add(myVerticalDivider);
      items.addAll(_addAuthorItems(story.engineers!));
      authorItems.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ));
      authorItems.add(SizedBox(
        width: 12.0,
      ));
    }

    if (!_isNullOrEmpty(story.otherbyline)) {
      List<Widget> items = [];
      items.add(
        Obx(
          () => Text(
            "作者",
            style: TextStyle(fontSize: 15, color: authorColor),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          ),
        ),
      );
      items.add(myVerticalDivider);
      items.add(Obx(
        () => ExtendedText(
          story.otherbyline!,
          joinZeroWidthSpace: true,
          style: TextStyle(
            fontSize: 15,
          ),
          textScaleFactor: textScaleFactorController.textScaleFactor.value,
        ),
      ));
      authorItems.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: authorItems,
      ),
    );
  }

  List<Widget> _addAuthorItems(List<People> peopleList) {
    List<Widget> authorItems = List.empty(growable: true);

    for (People author in peopleList) {
      authorItems.add(Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: Obx(
          () => Text(
            author.name,
            style: TextStyle(
              fontSize: 15,
            ),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          ),
        ),
      ));
    }
    return authorItems;
  }

  // only display unstyled paragraph type in brief
  Widget _buildBrief(List<Paragraph> articles) {
    if (articles.length > 0) {
      List<Widget> articleWidgets = List.empty(growable: true);

      for (int i = 0; i < articles.length; i++) {
        if (articles[i].type == 'unstyled') {
          if (articles[i].contents!.length > 0 &&
              !_isNullOrEmpty(articles[i].contents![0].data)) {
            articleWidgets.add(
              Obx(
                () => ParseTheTextToHtmlWidget(
                  html: articles[i].contents![0].data,
                  color: storyBriefTextColor,
                  fontSize:
                      17 * textScaleFactorController.textScaleFactor.value,
                ),
              ),
            );
          }

          if (i != articles.length - 1) {
            articleWidgets.add(
              SizedBox(height: 16),
            );
          }
        }
      }

      if (articleWidgets.length == 0) {
        return Container();
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 32.0),
        child: Column(
          children: [
            ClipPath(
              clipper: StoryBriefTopFrameClipper(),
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  color: storyBriefFrameColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: articleWidgets,
              ),
            ),
            ClipPath(
              clipper: StoryBriefBottomFrameClipper(),
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  color: storyBriefFrameColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container();
  }

  Widget _buildContent(List<Paragraph> storyContents) {
    if (Get.find<StoryPageController>(tag: slug).currentSlug == 'law') {
      return PdfDocumentLoader.openFile(
        Get.find<StoryPageController>(tag: slug).ombudsLawFile.path,
        documentBuilder: (context, pdfDocument, pageCount) => LayoutBuilder(
          builder: (context, constraints) => ListView.builder(
            itemCount: pageCount,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) => Container(
              color: Colors.black12,
              child: PdfPageView(
                pdfDocument: pdfDocument,
                pageNumber: index + 1,
              ),
            ),
          ),
        ),
      );
    }
    if (storyContents.isEmpty) {
      if (showAds) {
        return InlineBannerAdWidget(
          adUnitId: AdUnitIdHelper.getBannerAdUnitId('StoryAT1'),
          sizes: [
            AdSize.mediumRectangle,
            AdSize(width: 336, height: 280),
            AdSize(width: 320, height: 480),
          ],
          wantKeepAlive: true,
        );
      } else {
        return Container();
      }
    }
    ParagraphFormat paragraphFormat = ParagraphFormat();
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: storyContents.length + 1,
      itemBuilder: (context, index) {
        if (index == 1) {
          if (showAds) {
            return InlineBannerAdWidget(
              adUnitId: AdUnitIdHelper.getBannerAdUnitId('StoryAT1'),
              sizes: [
                AdSize.mediumRectangle,
                AdSize(width: 336, height: 280),
                AdSize(width: 320, height: 480),
              ],
              wantKeepAlive: true,
            );
          } else {
            return Container();
          }
        }
        int contentIndex = index;
        if (index > 1) {
          contentIndex = index - 1;
        }
        Paragraph paragraph = storyContents[contentIndex];
        if (paragraph.contents != null &&
            paragraph.contents!.length > 0 &&
            !_isNullOrEmpty(paragraph.contents![0].data)) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Obx(
              () => paragraphFormat.parseTheParagraph(
                paragraph,
                context,
                17 * textScaleFactorController.textScaleFactor.value,
                imageUrlList:
                    Get.find<StoryPageController>(tag: slug).story.imageUrlList,
              ),
            ),
          );
        }

        return Container();
      },
    );
  }

  Widget _buildUpdatedTime(String updateTime) {
    DateTimeFormat dateTimeFormat = DateTimeFormat();

    return Obx(
      () => Text(
        '更新時間：' +
            dateTimeFormat.changeStringToDisplayString(
                updateTime, 'yyyy-MM-ddTHH:mm:ssZ', 'yyyy.MM.dd HH:mm 臺北時間'),
        style: TextStyle(
          fontSize: 15,
          color: Color(0xff757575),
        ),
        textScaleFactor: textScaleFactorController.textScaleFactor.value,
      ),
    );
  }

  Widget _buildTags(List<Tag>? tags) {
    if (tags == null) {
      return Container();
    } else {
      List<Widget> tagWidgets = List.empty(growable: true);
      for (int i = 0; i < tags.length; i++) {
        tagWidgets.add(
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: GestureDetector(
              onTap: () {
                AnalyticsHelper.logClick(
                    slug: '', title: tags[i].name, location: 'Article_關鍵字');
                Get.to(() => TagPage(
                      tag: tags[i],
                    ));
              },
              child: Container(
                decoration: BoxDecoration(
                  //color: storyWidgetColor,
                  border: Border.all(width: 2.0, color: storyWidgetColor),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Obx(
                  () => Text(
                    '#' + tags[i].name,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: storyWidgetColor),
                    strutStyle: StrutStyle(
                        forceStrutHeight: true, fontSize: 18, height: 1),
                    textScaleFactor:
                        textScaleFactorController.textScaleFactor.value,
                  ),
                ),
              ),
            ),
          ),
        );
        if (i != tags.length - 1) {
          tagWidgets.add(SizedBox(
            width: 4,
          ));
        }
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: Wrap(
          children: tagWidgets,
        ),
      );
    }
  }

  Widget _buildRelatedWidget(List<StoryListItem> relatedStories) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (BuildContext context, int index) =>
              SizedBox(height: 16.0),
          itemCount: relatedStories.length,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomPaint(
                      painter: RelatedStoryPainter(),
                      child: Container(
                        padding:
                            const EdgeInsets.fromLTRB(14.0, 4.5, 14.0, 4.5),
                        child: Obx(
                          () => AutoSizeText(
                            '相關文章',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: storyWidgetColor,
                            ),
                            maxLines: 1,
                            textScaleFactor:
                                textScaleFactorController.textScaleFactor.value,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildRelatedItem(relatedStories[index]),
                  ]);
            }
            return _buildRelatedItem(relatedStories[index]);
          }),
    );
  }

  Widget _buildRelatedItem(StoryListItem story) {
    double imageWidth = 33 * (Get.width - 48) / 100;
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
            child: Obx(
              () => ExtendedText(
                story.name,
                joinZeroWidthSpace: true,
                style: TextStyle(fontSize: 20),
                textScaleFactor:
                    textScaleFactorController.textScaleFactor.value,
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        AnalyticsHelper.logClick(
            slug: story.slug, title: story.name, location: 'Article_相關文章');
        if (showAds) {
          interstitialAdController.openStory();
        }
        Get.find<StoryPageController>(tag: slug).loadStory(story.slug);
      },
    );
  }

  bool _isNullOrEmpty(String? input) {
    return input == null || input == '';
  }
}
