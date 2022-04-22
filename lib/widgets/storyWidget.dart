import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:tv/blocs/story/events.dart';
import 'package:tv/blocs/story/bloc.dart';
import 'package:tv/blocs/story/states.dart';
import 'package:tv/controller/interstitialAdController.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/dateTimeFormat.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/helpers/paragraphFormat.dart';
import 'package:tv/models/paragraph.dart';
import 'package:tv/models/people.dart';
import 'package:tv/models/story.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/models/tag.dart';
import 'package:tv/pages/storyPage.dart';
import 'package:tv/pages/tag/tagPage.dart';
import 'package:tv/widgets/imageViewerWidget.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';
import 'package:tv/widgets/story/fileDownloadWidget.dart';
import 'package:tv/widgets/story/mNewsVideoPlayer.dart';
import 'package:tv/widgets/story/parseTheTextToHtmlWidget.dart';
import 'package:tv/widgets/story/relatedStoryPainter.dart';
import 'package:tv/widgets/story/storyBriefFrameClipper.dart';
import 'package:tv/widgets/story/youtubePlayer.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class StoryWidget extends StatefulWidget {
  final String slug;
  final bool showAds;
  StoryWidget({
    required this.slug,
    this.showAds = true,
  });

  @override
  _StoryWidgetState createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  late String _currentSlug;
  late double _textSize;
  late Story _story;
  late File _ombudsLawFile;
  final interstitialAdController = Get.find<InterstitialAdController>();

  @override
  void initState() {
    _currentSlug = widget.slug;
    _loadStory(_currentSlug);
    super.initState();
  }

  bool _isNullOrEmpty(String? input) {
    return input == null || input == '';
  }

  _loadStory(String slug) async {
    if (_currentSlug == 'law') {
      _ombudsLawFile = await DefaultCacheManager().getSingleFile(ombudsLaw);
    }
    context.read<StoryBloc>().add(FetchPublishedStoryBySlug(slug));
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return BlocConsumer<StoryBloc, StoryState>(
      listener: (BuildContext context, StoryState state) async {
        if (state is StoryLoaded) {
          if (interstitialAdController.storyCounter.isOdd && widget.showAds) {
            await interstitialAdController.showStoryInterstitialAd();
          }
        }
      },
      builder: (BuildContext context, StoryState state) {
        if (state is StoryError) {
          final error = state.error;
          print('NewsCategoriesError: ${error.message}');
          if (error is NoInternetException) {
            return error.renderWidget(
                onPressed: () => _loadStory(_currentSlug));
          }

          return error.renderWidget();
        }
        if (state is StoryLoaded) {
          Story? story = state.story;
          if (story == null) {
            return Container();
          }
          _story = story;
          _textSize = state.textSize;
          AnalyticsHelper.logStory(
              slug: _currentSlug,
              title: story.name ?? '',
              category: story.categoryList);
          return _storyContent(width, story);
        } else if (state is TextSizeChanged) {
          _textSize = state.textSize;
          return _storyContent(width, _story);
        }

        // state is Init, loading, or other
        return _loadingWidget();
      },
    );
  }

  Widget _loadingWidget() => Center(
        child: CircularProgressIndicator.adaptive(),
      );

  Widget _storyContent(double width, Story story) {
    return ListView(
      shrinkWrap: true,
      children: [
        if (widget.showAds)
          InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('StoryHD'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
            ],
          ),
        _buildHeroWidget(width, story),
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
            textSize: _textSize,
          ),
        if (widget.showAds)
          InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('StoryAT2'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
            ],
          ),
        Center(child: _buildUpdatedTime(story.updatedAt!)),
        SizedBox(height: 32),
        if (story.tags != null && story.tags!.length > 0) ...[
          _buildTags(story.tags),
          SizedBox(height: 16),
        ],
        if (story.relatedStories!.length > 0) ...[
          _buildRelatedWidget(width, story.relatedStories!),
          SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildHeroWidget(double width, Story story) {
    double height = width / 16 * 9;

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
              width: width,
              imageUrl: story.heroImage!,
              placeholder: (context, url) => Container(
                height: height,
                width: width,
                color: Colors.grey,
              ),
              errorWidget: (context, url, error) => Container(
                height: height,
                width: width,
                color: Colors.grey,
                child: Icon(Icons.error),
              ),
              fit: BoxFit.cover,
            ),
          ),
        if (!_isNullOrEmpty(story.heroCaption))
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0.0),
            child: Text(
              story.heroCaption!,
              style:
                  TextStyle(fontSize: _textSize - 5, color: Color(0xff757575)),
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
      child: Row(
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
            ),
          Text(
            dateTimeFormat.changeStringToDisplayString(story.publishTime!,
                'yyyy-MM-ddTHH:mm:ssZ', 'yyyy.MM.dd HH:mm 臺北時間'),
            style: TextStyle(
              fontSize: 14,
              color: Color(0xff757575),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'PingFang TC',
          fontSize: 26,
          fontWeight: FontWeight.w500,
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
      authorItems.add(
        Text(
          "作者",
          style: TextStyle(fontSize: 15, color: authorColor),
        ),
      );
      authorItems.add(myVerticalDivider);

      authorItems.addAll(_addAuthorItems(story.writers!));
      authorItems.add(SizedBox(
        width: 12.0,
      ));
    }

    if (story.photographers!.length > 0) {
      authorItems.add(
        Text(
          "攝影",
          style: TextStyle(fontSize: 15, color: authorColor),
        ),
      );
      authorItems.add(myVerticalDivider);

      authorItems.addAll(_addAuthorItems(story.photographers!));
      authorItems.add(SizedBox(
        width: 12.0,
      ));
    }

    if (story.cameraOperators!.length > 0) {
      authorItems.add(
        Text(
          "影音",
          style: TextStyle(fontSize: 15, color: authorColor),
        ),
      );
      authorItems.add(myVerticalDivider);

      authorItems.addAll(_addAuthorItems(story.cameraOperators!));
      authorItems.add(SizedBox(
        width: 12.0,
      ));
    }

    if (story.designers!.length > 0) {
      authorItems.add(
        Text(
          "設計",
          style: TextStyle(fontSize: 15, color: authorColor),
        ),
      );
      authorItems.add(myVerticalDivider);

      authorItems.addAll(_addAuthorItems(story.designers!));
      authorItems.add(SizedBox(
        width: 12.0,
      ));
    }

    if (story.engineers!.length > 0) {
      authorItems.add(
        Text(
          "工程",
          style: TextStyle(fontSize: 15, color: authorColor),
        ),
      );
      authorItems.add(myVerticalDivider);

      authorItems.addAll(_addAuthorItems(story.engineers!));
      authorItems.add(SizedBox(
        width: 12.0,
      ));
    }

    if (story.vocals!.length > 0) {
      authorItems.add(
        Text(
          "主播",
          style: TextStyle(fontSize: 15, color: authorColor),
        ),
      );
      authorItems.add(myVerticalDivider);

      authorItems.addAll(_addAuthorItems(story.engineers!));
      authorItems.add(SizedBox(
        width: 12.0,
      ));
    }

    if (!_isNullOrEmpty(story.otherbyline)) {
      authorItems.add(
        Text(
          "作者",
          style: TextStyle(fontSize: 15, color: authorColor),
        ),
      );
      authorItems.add(myVerticalDivider);
      authorItems.add(Text(story.otherbyline!));
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
        child: Text(
          author.name,
          style: TextStyle(
            fontSize: 15,
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
              ParseTheTextToHtmlWidget(
                html: articles[i].contents![0].data,
                color: storyBriefTextColor,
                fontSize: _textSize,
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
    if (_currentSlug == 'law') {
      return PdfDocumentLoader.openFile(
        _ombudsLawFile.path,
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
      if (widget.showAds) {
        return InlineBannerAdWidget(
          adUnitId: AdUnitIdHelper.getBannerAdUnitId('StoryAT1'),
          sizes: [
            AdSize.mediumRectangle,
            AdSize(width: 336, height: 280),
            AdSize(width: 320, height: 480),
          ],
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
          if (widget.showAds) {
            return InlineBannerAdWidget(
              adUnitId: AdUnitIdHelper.getBannerAdUnitId('StoryAT1'),
              sizes: [
                AdSize.mediumRectangle,
                AdSize(width: 336, height: 280),
                AdSize(width: 320, height: 480),
              ],
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
            child: paragraphFormat.parseTheParagraph(
              paragraph,
              context,
              _textSize,
              imageUrlList: _story.imageUrlList,
            ),
          );
        }

        return Container();
      },
    );
  }

  Widget _buildUpdatedTime(String updateTime) {
    DateTimeFormat dateTimeFormat = DateTimeFormat();

    return Text(
      '更新時間：' +
          dateTimeFormat.changeStringToDisplayString(
              updateTime, 'yyyy-MM-ddTHH:mm:ssZ', 'yyyy.MM.dd HH:mm 臺北時間'),
      style: TextStyle(
        fontSize: 15,
        color: Color(0xff757575),
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
                child: Text(
                  '#' + tags[i].name,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: storyWidgetColor),
                  strutStyle: StrutStyle(
                      forceStrutHeight: true, fontSize: 18, height: 1),
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

  Widget _buildRelatedWidget(double width, List<StoryListItem> relatedStories) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (BuildContext context, int index) =>
              SizedBox(height: 16.0),
          itemCount: relatedStories.length,
          //padding: const EdgeInsets.only(bottom: 16),
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
                        child: AutoSizeText(
                          '相關文章',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: storyWidgetColor,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildRelatedItem(width, relatedStories[index]),
                  ]);
            }
            return _buildRelatedItem(width, relatedStories[index]);
          }),
    );
  }

  Widget _buildRelatedItem(double width, StoryListItem story) {
    double imageWidth = 33 * (width - 48) / 100;
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
        AnalyticsHelper.logClick(
            slug: story.slug, title: story.name, location: 'Article_相關文章');
        _currentSlug = story.slug;
        StoryPage.of(context)!.slug = _currentSlug;
        interstitialAdController.openStory();
        _loadStory(_currentSlug);
      },
    );
  }
}
