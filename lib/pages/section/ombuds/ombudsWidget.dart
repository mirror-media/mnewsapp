import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tv/blocs/story/bloc.dart';
import 'package:tv/blocs/story/events.dart';
import 'package:tv/blocs/story/states.dart';
import 'package:tv/blocs/video/video_cubit.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/paragraph.dart';
import 'package:tv/models/story.dart';
import 'package:tv/models/video.dart' as myVideo;
import 'package:tv/pages/section/ombuds/ombudsButton.dart';
import 'package:tv/pages/section/ombuds/ombudsNewsListPage.dart';
import 'package:tv/pages/storyPage.dart';
import 'package:tv/widgets/story/mNewsVideoPlayer.dart';
import 'package:tv/widgets/story/youtubePlayer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class OmbudsWidget extends StatefulWidget {
  @override
  _OmbudsWidgetState createState() => _OmbudsWidgetState();
}

class _OmbudsWidgetState extends State<OmbudsWidget> {
  //double _leftAndRightPaddingNumber = 24.0;
  final TextScaleFactorController textScaleFactorController = Get.find();

  @override
  void initState() {
    _loadOmbuds();
    super.initState();
  }

  _loadOmbuds() async {
    context.read<StoryBloc>().add(FetchPublishedStoryBySlug('biography'));
    context.read<VideoCubit>().fetchVideoByName('ombuds_office_main_video');
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return BlocBuilder<StoryBloc, StoryState>(
        builder: (BuildContext context, StoryState state) {
      if (state is StoryError) {
        final error = state.error;
        print('NewsCategoriesError: ${error.message}');
        if (error is NoInternetException) {
          return error.renderWidget(onPressed: () => _loadOmbuds());
        }

        return error.renderWidget(isNoButton: true);
      }
      if (state is StoryLoaded) {
        Story? story = state.story;
        if (story == null) {
          return Container();
        }

        return _buildContent(width, story);
      }

      // state is Init, loading, or other
      return _loadingWidget();
    });
  }

  Widget _loadingWidget() => Center(
        child: CircularProgressIndicator.adaptive(),
      );

  Widget _buildContent(double width, Story story) {
    return ListView(children: [
      SizedBox(
        height: 44,
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
        child: _buildHeroWidget(width - 48, story),
      ),
      SizedBox(
        height: 28,
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
        child: _buildBrief(story.brief!),
      ),
      SizedBox(
        height: 8,
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
        child: _understandMoreBlock(),
      ),
      SizedBox(
        height: 40,
      ),
      Container(
        width: width,
        color: Color(0xffF4F5F6),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
          child: Column(
            children: [
              SizedBox(
                height: 28,
              ),
              _appealBlock(width),
              SizedBox(
                height: 28,
              ),
              _ombudsIntroBlock(width),
              SizedBox(
                height: 28,
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _buildHeroWidget(double width, Story story) {
    return BlocBuilder<VideoCubit, VideoState>(
        builder: (BuildContext context, VideoState state) {
      if (state is VideoError) {
        final error = state.error;
        print('OmbudsVideoError: ${error.message}');
        return Container();
      }
      if (state is VideoLoaded) {
        myVideo.Video? video = state.video;
        if (video == null) {
          return Container();
        }

        return _buildVideoWidget(video.url);
      }

      // state is Init, loading, or other
      return _loadingWidget();
    });
  }

  _buildVideoWidget(String videoUrl) {
    String youtubeString = 'youtube';
    if (videoUrl.contains(youtubeString)) {
      String? ytId = VideoId.parseVideoId(videoUrl) ?? '';
      return YoutubePlayer(ytId);
    }

    return MNewsVideoPlayer(
      videourl: videoUrl,
      autoPlay: true,
      aspectRatio: 16 / 9,
      muted: true,
    );
  }

  Widget _buildBrief(List<Paragraph> brief) {
    List<Paragraph> unstyledBrief = [];
    for (int i = 0; i < brief.length; i++) {
      if (brief[i].type == 'unstyled') {
        unstyledBrief.add(brief[i]);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Text(
            '外部公評人翁秀琪',
            style: TextStyle(
              fontSize: 20,
              color: themeColor,
            ),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          ),
        ),
        SizedBox(height: 8.0),
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: unstyledBrief.length,
            itemBuilder: (context, index) {
              return Obx(
                () => Text(
                  unstyledBrief[index].contents![0].data,
                  style: TextStyle(
                    fontSize: 17,
                  ),
                  textScaleFactor:
                      textScaleFactorController.textScaleFactor.value,
                ),
              );
            }),
      ],
    );
  }

  Widget _understandMoreBlock() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(),
      InkWell(
        child: Obx(
          () => Text(
            '了解更多＞',
            style: TextStyle(
              fontSize: 20,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
            ),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          ),
        ),
        onTap: () => Get.to(() => StoryPage(
              slug: 'biography',
              showAds: false,
            )),
      )
    ]);
  }

  // ignore: unused_element
  Widget _appealBlock(double width) {
    return Column(children: [
      Obx(
        () => Text(
          '我要向公評人申訴',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Color(0xff004DBC),
          ),
          textScaleFactor: textScaleFactorController.textScaleFactor.value,
        ),
      ),
      SizedBox(height: 24),
      Obx(
        () => Text(
          '如果您對於我們的新聞內容有意見，例如：事實錯誤、侵害人權，或違反新聞倫理等，請按下方的向公評人申訴鍵；如果您對於我們的客服有意見，請按下方的向客服申訴鍵。',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xff014DB8),
          ),
          textScaleFactor: textScaleFactorController.textScaleFactor.value,
        ),
      ),
      SizedBox(height: 36),
      _appealButton(
        width,
        '向公評人申訴',
        () => Get.to(() => StoryPage(
              slug: 'complaint',
              showAds: false,
            )),
      ),
      SizedBox(height: 12),
      _appealButton(width, '向客服申訴', () async {
        final Uri emailLaunchUri = Uri(
          scheme: 'mailto',
          path: mNewsMail,
        );

        if (await canLaunch(emailLaunchUri.toString())) {
          await launch(emailLaunchUri.toString());
        } else {
          throw 'Could not launch $mNewsMail';
        }
      }),
    ]);
  }

  Widget _appealButton(
    double width,
    String title,
    VoidCallback? onPressed,
  ) {
    return Container(
      width: width,
      child: OutlinedButton(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 16.0),
          child: Obx(
            () => Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Color(0xff014DB8),
              ),
              textScaleFactor: textScaleFactorController.textScaleFactor.value,
            ),
          ),
        ),
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(
            TextStyle(
              color: Color(0xff014DB8),
            ),
          ),
          side: MaterialStateProperty.all(
            BorderSide(
              color: Color(0xff014DB8),
            ),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _ombudsIntroBlock(double width) {
    double ombudsWidth = (width - 48 - 26) / 2;

    return Obx(() {
      double aspectRatio = ombudsWidth /
          (50 * textScaleFactorController.textScaleFactor.value + 72);
      return GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 24 * textScaleFactorController.textScaleFactor.value,
          crossAxisSpacing: 26,
          childAspectRatio: aspectRatio,
        ),
        padding: const EdgeInsets.all(0),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          OmbudsButton(
            width: ombudsWidth,
            imageLocationString: tvSvg,
            title1: textScaleFactorController.textScaleFactor.value > 1.0
                ? '關於'
                : '關於鏡新聞',
            title2: '公評人',
            onTap: () => Get.to(() => StoryPage(
                  slug: 'biography',
                  showAds: false,
                )),
          ),
          OmbudsButton(
            width: ombudsWidth,
            imageLocationString: phoneSvg,
            title1: '最新',
            title2: '消息',
            onTap: () => Get.to(() => OmbudsNewsListPage()),
          ),
          OmbudsButton(
            width: ombudsWidth,
            imageLocationString: paperSvg,
            title1: '申訴',
            title2: '流程',
            onTap: () => Get.to(() => StoryPage(
                  slug: 'complaint',
                  showAds: false,
                )),
          ),
          OmbudsButton(
            width: ombudsWidth,
            imageLocationString: hammerSvg,
            title1: textScaleFactorController.textScaleFactor.value > 1.0
                ? '公評人'
                : '外部公評人',
            title2: '設置章程',
            onTap: () => Get.to(() => StoryPage(
                  slug: 'law',
                  showAds: false,
                )),
          ),
          OmbudsButton(
            width: ombudsWidth,
            imageLocationString: paperSvg,
            title1: '新聞自律 /',
            title2: '他律規範',
            onTap: () => Get.to(() => StoryPage(
                  slug: 'standards',
                  showAds: false,
                )),
          ),
          OmbudsButton(
            width: ombudsWidth,
            imageLocationString: faqSvg,
            title1: '常見問題',
            title2: 'FAQ',
            onTap: () => Get.to(() => StoryPage(
                  slug: 'faq',
                  showAds: false,
                )),
          ),
          // OmbudsButton(
          //   width: ombudsWidth,
          //   imageLocationString: reportSvg,
          //   title1: '季報',
          //   title2: '年報',
          //   onTap: () => RouteGenerator.navigateToStory(context, 'reports'),
          // ),
        ],
      );
    });
  }
}
