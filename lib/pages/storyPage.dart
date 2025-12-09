import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tv/controller/interstitialAdController.dart';
import 'package:tv/controller/storyPageController.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/data/value/string_default.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/dateTimeFormat.dart';
import 'package:tv/helpers/environment.dart';
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
import 'package:tv/widgets/youtube_stream_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/story_html_helper.dart';


class StoryPage extends StatelessWidget {
  final String slug;
  final bool showAds;

  StoryPage({required this.slug, this.showAds = true});

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
        Widget body;

        if (controller.isLoading) {
          body = const Center(child: CircularProgressIndicator.adaptive());
        } else if (controller.isError) {
          if (controller.error is NoInternetException) {
            body = controller.error.renderWidget(
              onPressed: () => controller.loadStory(slug),
            );
          } else {
            body = controller.error.renderWidget();
          }
        } else {
          body = Column(
            children: [
              Expanded(child: _storyContent(controller.story)),
              Obx(() {
                if (interstitialAdController.storyCounter.isEven &&
                    interstitialAdController.storyCounter.value != 0 &&
                    showAds) {
                  return AnchoredBannerAdWidget(
                    adUnitId: AdUnitIdHelper.getBannerAdUnitId('StoryFooter'),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          );
        }

        return Scaffold(appBar: _buildBar(), body: body);
      },
    );
  }

  PreferredSizeWidget _buildBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Get.back(),
      ),
      backgroundColor: appBarColor,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.font_download),
          tooltip: '更改字體大小',
          onPressed: () => Get.to(() => ChangeFontSizePage()),
        ),
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: 'Share',
          onPressed: () {
            AnalyticsHelper.logShare(
              name: Get.find<StoryPageController>(tag: slug).currentSlug,
              type: 'story',
            );
            final url =
                '${Environment().config.mNewsWebsiteLink}/story/${Get.find<StoryPageController>(tag: slug).currentSlug}';
            Share.share(
              url,
              sharePositionOrigin: Rect.fromLTWH(Get.width - 100, 0, 100, 100),
            );
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
            sizes: [AdSize.mediumRectangle, const AdSize(width: 336, height: 280)],
            wantKeepAlive: true,
          ),
        _buildHeroWidget(story),
        const SizedBox(height: 24),
        _buildCategoryAndPublishedDate(story),
        const SizedBox(height: 10),
        _buildStoryTitle(story.name ?? ''),
        const SizedBox(height: 8),
        _buildAuthors(story),
        const SizedBox(height: 32),

        // 內文摘要：先走 Paragraph；為空再 fallback external HTML
        _buildBrief(story.brief ?? [], story.externalBriefHtml),

        // 內文內容：先走 Paragraph；為空再 fallback external HTML
        _buildContent(
          story.contentApiData ?? [],
          story.externalContentHtml,
          story.style,
        ),

        if (story.downloadFileList != null && story.downloadFileList!.isNotEmpty)
          FileDownloadWidget(
            story.downloadFileList!,
            textSize: 17 * textScaleFactorController.textScaleFactor.value,
          ),
        if (showAds)
          InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('StoryAT2'),
            sizes: [AdSize.mediumRectangle, const AdSize(width: 336, height: 280)],
            wantKeepAlive: true,
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildUpdatedTime(story.updatedAt),
        ),
        const SizedBox(height: 32),
        if (story.tags != null && story.tags!.isNotEmpty) ...[
          _buildTags(story.tags),
          const SizedBox(height: 16),
        ],GestureDetector(
          onTap: () async {
            final url = Uri.parse("https://mnews.oen.tw/");
            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
              throw Exception("Could not launch");
            }
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Image.asset(
              mnewsAdEntry,
              fit: BoxFit.fitWidth,
              width: double.infinity,
            ),
          ),
        ),
        if (story.relatedStories != null && story.relatedStories!.isNotEmpty) ...[
          _buildRelatedWidget(story.relatedStories!),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildHeroWidget(Story story) {
    final double height = Get.width / 16 * 9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (story.heroVideo != null) _buildVideoWidget(story.heroVideo!),
        if (story.heroImage != null && story.heroVideo == null)
          InkWell(
            onTap: () {
              int index = story.imageUrlList?.indexOf(story.heroImage!) ?? 0;
              if (index == -1) index = 0;
              Get.to(
                ImageViewerWidget(story.imageUrlList ?? [story.heroImage!], openIndex: index),
              );
            },
            child: CachedNetworkImage(
              width: Get.width,
              imageUrl: story.heroImage!,
              placeholder: (context, url) =>
                  Container(height: height, width: Get.width, color: Colors.grey),
              errorWidget: (context, url, error) => Container(
                height: height,
                width: Get.width,
                color: Colors.grey,
                child: const Icon(Icons.error),
              ),
              fit: BoxFit.cover,
            ),
          ),
        if (!StoryHtmlHelper.isNullOrEmpty(story.heroCaption))
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0.0),
            child: Obx(
                  () => Text(
                story.heroCaption!,
                style: const TextStyle(fontSize: 15, color: Color(0xff757575)),
                textScaler: TextScaler.linear(textScaleFactorController.textScaleFactor.value),
              ),
            ),
          ),
      ],
    );
  }

  _buildVideoWidget(String videoUrl) {
    const youtubeString = 'youtube';
    if (videoUrl.contains(youtubeString)) {
      return YoutubeStreamWidget(youtubeUrl: videoUrl);
    }
    return MNewsVideoPlayer(videourl: videoUrl, aspectRatio: 16 / 9);
  }

  Widget _buildCategoryAndPublishedDate(Story story) {
    final dateTimeFormat = DateTimeFormat();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
      child: Obx(
            () => Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            if (story.categoryList == null || story.categoryList!.isEmpty)
              const SizedBox.shrink()
            else
              Text(
                story.categoryList![0].name,
                style: const TextStyle(
                  fontSize: 15,
                  color: storyWidgetColor,
                  fontWeight: FontWeight.w500,
                ),
                textScaler: TextScaler.linear(textScaleFactorController.textScaleFactor.value),
              ),
            Text(
              (story.publishTime == null || story.publishTime!.isEmpty)
                  ? ''
                  : dateTimeFormat.changeStringToDisplayString(
                story.publishTime!,
                'yyyy-MM-ddTHH:mm:ssZ',
                'yyyy.MM.dd HH:mm 臺北時間',
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xff757575)),
              textScaler: TextScaler.linear(textScaleFactorController.textScaleFactor.value),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
          style: const TextStyle(
            fontFamily: 'PingFang TC',
            fontSize: 26,
            fontWeight: FontWeight.w500,
          ),
          textScaler: TextScaler.linear(textScaleFactorController.textScaleFactor.value),
        ),
      ),
    );
  }

  Widget _buildAuthors(Story story) {
    const authorColor = Color(0xff757575);
    final List<Widget> authorItems = [];

    final myVerticalDivider = Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
      child: Container(color: const Color(0xff757575), width: 1, height: 15),
    );

    if ((story.writers?.length ?? 0) > 0) {
      final items = <Widget>[
        Obx(() => Text(
          "記者",
          style: const TextStyle(fontSize: 15, color: authorColor),
          textScaler: TextScaler.linear(textScaleFactorController.textScaleFactor.value),
        )),
        myVerticalDivider,
        ..._addAuthorItems(story.writers!),
      ];
      authorItems.add(Row(mainAxisSize: MainAxisSize.min, children: items));
      authorItems.add(const SizedBox(width: 12.0));
    }

    if ((story.photographers?.length ?? 0) > 0) {
      final items = <Widget>[
        Obx(() => Text(
          "攝影",
          style: const TextStyle(fontSize: 15, color: authorColor),
          textScaler: TextScaler.linear(textScaleFactorController.textScaleFactor.value),
        )),
        myVerticalDivider,
        ..._addAuthorItems(story.photographers!),
      ];
      authorItems.add(Row(mainAxisSize: MainAxisSize.min, children: items));
      authorItems.add(const SizedBox(width: 12.0));
    }

    if ((story.cameraOperators?.length ?? 0) > 0) {
      final items = <Widget>[
        Obx(() => Text(
          "影音",
          style: const TextStyle(fontSize: 15, color: authorColor),
          textScaler: TextScaler.linear(textScaleFactorController.textScaleFactor.value),
        )),
        myVerticalDivider,
        ..._addAuthorItems(story.cameraOperators!),
      ];
      authorItems.add(Row(mainAxisSize: MainAxisSize.min, children: items));
      authorItems.add(const SizedBox(width: 12.0));
    }

    if ((story.designers?.length ?? 0) > 0) {
      final items = <Widget>[
        Obx(() => Text(
          "設計",
          style: const TextStyle(fontSize: 15, color: authorColor),
          textScaler: TextScaler.linear(textScaleFactorController.textScaleFactor.value),
        )),
        myVerticalDivider,
        ..._addAuthorItems(story.designers!),
      ];
      authorItems.add(Row(mainAxisSize: MainAxisSize.min, children: items));
      authorItems.add(const SizedBox(width: 12.0));
    }

    if ((story.engineers?.length ?? 0) > 0) {
      final items = <Widget>[
        Obx(() => Text(
          "工程",
          style: const TextStyle(fontSize: 15, color: authorColor),
          textScaler: TextScaler.linear(textScaleFactorController.textScaleFactor.value),
        )),
        myVerticalDivider,
        ..._addAuthorItems(story.engineers!),
      ];
      authorItems.add(Row(mainAxisSize: MainAxisSize.min, children: items));
      authorItems.add(const SizedBox(width: 12.0));
    }

    if ((story.vocals?.length ?? 0) > 0) {
      final items = <Widget>[
        Obx(() => Text(
          "主播",
          style: const TextStyle(fontSize: 15, color: authorColor),
          textScaler: TextScaler.linear(textScaleFactorController.textScaleFactor.value),
        )),
        myVerticalDivider,
        ..._addAuthorItems(story.vocals!),
      ];
      authorItems.add(Row(mainAxisSize: MainAxisSize.min, children: items));
      authorItems.add(const SizedBox(width: 12.0));
    }

    if (!StoryHtmlHelper.isNullOrEmpty(story.otherbyline)) {
      final items = <Widget>[
        Obx(() => Text(
          "作者",
          style: const TextStyle(fontSize: 15, color: authorColor),
          textScaler: TextScaler.linear(textScaleFactorController.textScaleFactor.value),
        )),
        myVerticalDivider,
        Obx(() => ExtendedText(
          story.otherbyline!,
          joinZeroWidthSpace: true,
          style: const TextStyle(fontSize: 15),
          textScaler: TextScaler.linear(textScaleFactorController.textScaleFactor.value),
        )),
      ];
      authorItems.add(Row(mainAxisSize: MainAxisSize.min, children: items));
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
    final List<Widget> authorItems = [];
    for (final author in peopleList) {
      authorItems.add(
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Obx(
                () => Text(
              author.name,
              style: const TextStyle(fontSize: 15),
              textScaler: TextScaler.linear(textScaleFactorController.textScaleFactor.value),
            ),
          ),
        ),
      );
    }
    return authorItems;
  }

  /// 摘要：先渲染 Paragraph，如果沒有資料，且有 externalBriefHtml → 用 HTML 小工具渲染
  Widget _buildBrief(List<Paragraph> articles, String? externalBriefHtml) {
    if (articles.isNotEmpty) {
      final List<Widget> articleWidgets = [];

      for (int i = 0; i < articles.length; i++) {
        if (articles[i].type == 'unstyled') {
          if ((articles[i].contents?.length ?? 0) > 0 &&
              !StoryHtmlHelper.isNullOrEmpty(articles[i].contents![0].data)) {
            articleWidgets.add(
              Obx(
                    () => ParseTheTextToHtmlWidget(
                  html: articles[i].contents![0].data,
                  color: storyBriefTextColor,
                  fontSize: 17 * textScaleFactorController.textScaleFactor.value,
                ),
              ),
            );
          }
          if (i != articles.length - 1) {
            articleWidgets.add(const SizedBox(height: 16));
          }
        }
      }

      if (articleWidgets.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 32.0),
        child: Column(
          children: [
            ClipPath(
              clipper: StoryBriefTopFrameClipper(),
              child: Container(
                height: 16,
                decoration: const BoxDecoration(color: storyBriefFrameColor),
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
                decoration: const BoxDecoration(color: storyBriefFrameColor),
              ),
            ),
          ],
        ),
      );
    }

    // Fallback：external 摘要 HTML
    final safeHtml = StoryHtmlHelper.sanitizeExternalHtml(externalBriefHtml);
    if (safeHtml != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 32.0),
        child: Obx(
              () => ParseTheTextToHtmlWidget(
            html: safeHtml,
            color: storyBriefTextColor,
            fontSize: 17 * textScaleFactorController.textScaleFactor.value,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// 內容：先渲染 Paragraph，若完全沒有段落，externalContentHtml 存在則直接用 HTML 渲染
  Widget _buildContent(
      List<Paragraph> storyContents,
      String? externalContentHtml,
      String? storyStyle,
      ) {
    // 完全沒有段落 → 先試 external HTML → 再顯示廣告
    if (storyContents.isEmpty) {
      final safeHtml = StoryHtmlHelper.sanitizeExternalHtml(externalContentHtml);
      if (storyStyle == 'external' && safeHtml != null && safeHtml.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Obx(
                () => ParseTheTextToHtmlWidget(
              html: safeHtml,
              color: Colors.black,
              fontSize: 17 * textScaleFactorController.textScaleFactor.value,
            ),
          ),
        );
      }

      if (!showAds) return const SizedBox.shrink();
      return InlineBannerAdWidget(
        adUnitId: AdUnitIdHelper.getBannerAdUnitId('StoryAT1'),
        sizes: [
          AdSize.mediumRectangle,
          const AdSize(width: 336, height: 280),
          const AdSize(width: 320, height: 480),
        ],
        wantKeepAlive: true,
      );
    }

    final paragraphFormat = ParagraphFormat();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: storyContents.length + 1,
      itemBuilder: (context, index) {
        if (index == 1) {
          if (!showAds) return const SizedBox.shrink();
          return InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('StoryAT1'),
            sizes: [
              AdSize.mediumRectangle,
              const AdSize(width: 336, height: 280),
              const AdSize(width: 320, height: 480),
            ],
            wantKeepAlive: true,
          );
        }

        final contentIndex = index > 1 ? index - 1 : index;
        final Paragraph paragraph = storyContents[contentIndex];

        final String? data = (paragraph.contents != null && paragraph.contents!.isNotEmpty)
            ? paragraph.contents![0].data
            : null;

        final bool maybeExternalHtml = storyStyle == 'external' &&
            paragraph.type == 'unstyled' &&
            data != null &&
            data.trim().isNotEmpty &&
            StoryHtmlHelper.looksLikeHtml(data);

        if (maybeExternalHtml) {
          final html = StoryHtmlHelper.sanitizeExternalHtml(data);
          if (html != null && html.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Obx(
                    () => ParseTheTextToHtmlWidget(
                  html: html,
                  color: Colors.black,
                  fontSize: 17 * textScaleFactorController.textScaleFactor.value,
                ),
              ),
            );
          }
        }

        // 其他情況：交給舊 parser（image、slideshow、internal 文字段落等）
        if ((paragraph.contents?.isNotEmpty ?? false) &&
            !(paragraph.contents![0].data?.isEmpty ?? true)) {
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

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildUpdatedTime(String? updateTime) {
    if (updateTime == null || updateTime.isEmpty) {
      return const SizedBox.shrink();
    }
    final dateTimeFormat = DateTimeFormat();
    return Obx(
          () => Text(
        '更新時間：' +
            dateTimeFormat.changeStringToDisplayString(
              updateTime,
              'yyyy-MM-ddTHH:mm:ssZ',
              'yyyy.MM.dd HH:mm 臺北時間',
            ),
        style: const TextStyle(fontSize: 15, color: Color(0xff757575)),
        textScaler: TextScaler.linear(textScaleFactorController.textScaleFactor.value),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTags(List<Tag>? tags) {
    if (tags == null) return const SizedBox.shrink();

    final List<Widget> tagWidgets = [];
    for (int i = 0; i < tags.length; i++) {
      tagWidgets.add(
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: GestureDetector(
            onTap: () {
              AnalyticsHelper.logClick(
                slug: '',
                title: tags[i].name,
                location: 'Article_關鍵字',
              );
              Get.to(() => TagPage(tag: tags[i]));
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 2.0, color: storyWidgetColor),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Obx(
                    () => Text(
                  '#${tags[i].name}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: storyWidgetColor),
                  strutStyle: const StrutStyle(forceStrutHeight: true, fontSize: 18, height: 1),
                  textScaler: TextScaler.linear(textScaleFactorController.textScaleFactor.value),
                ),
              ),
            ),
          ),
        ),
      );
      if (i != tags.length - 1) tagWidgets.add(const SizedBox(width: 4));
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Wrap(children: tagWidgets),
    );
  }

  Widget _buildRelatedWidget(List<StoryListItem> relatedStories) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, __) => const SizedBox(height: 16.0),
        itemCount: relatedStories.length,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomPaint(
                  painter: RelatedStoryPainter(),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14.0, 4.5, 14.0, 4.5),
                    child: Obx(
                          () => AutoSizeText(
                        '相關文章',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: storyWidgetColor,
                        ),
                        maxLines: 1,
                        textScaleFactor: textScaleFactorController.textScaleFactor.value,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildRelatedItem(relatedStories[index]),
              ],
            );
          }
          return _buildRelatedItem(relatedStories[index]);
        },
      ),
    );
  }

  Widget _buildRelatedItem(StoryListItem story) {
    final double imageWidth = 33 * (Get.width - 48) / 100;
    final double imageHeight = imageWidth;

    return InkWell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedNetworkImage(
            height: imageHeight,
            width: imageWidth,
            imageUrl: story.photoUrl,
            placeholder: (context, url) =>
                Container(height: imageHeight, width: imageWidth, color: Colors.grey),
            errorWidget: (context, url, error) => Container(
              height: imageHeight,
              width: imageWidth,
              color: Colors.grey,
              child: const Icon(Icons.error),
            ),
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(
                  () => ExtendedText(
                story.name ?? StringDefault.nullString,
                joinZeroWidthSpace: true,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 20),
                textScaler: TextScaler.linear(textScaleFactorController.textScaleFactor.value),
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        AnalyticsHelper.logClick(
          slug: story.slug ?? StringDefault.nullString,
          title: story.name ?? StringDefault.nullString,
          location: 'Article_相關文章',
        );
        if (showAds) {
          interstitialAdController.openStory();
        }
        Get.find<StoryPageController>(tag: slug)
            .loadStory(story.slug ?? StringDefault.nullString);
      },
    );
  }

}
