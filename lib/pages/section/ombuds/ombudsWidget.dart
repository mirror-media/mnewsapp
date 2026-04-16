import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/controller/ombuds_controller.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/paragraph.dart';
import 'package:tv/models/story.dart';
import 'package:tv/pages/section/ombuds/ombudsButton.dart';
import 'package:tv/pages/section/ombuds/ombudsNewsListPage.dart';
import 'package:tv/pages/storyPage.dart';
import 'package:tv/widgets/story/mNewsVideoPlayer.dart';
import 'package:tv/widgets/youtube/youtubePlayer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class OmbudsWidget extends StatefulWidget {
  const OmbudsWidget({super.key});

  @override
  State<OmbudsWidget> createState() => _OmbudsWidgetState();
}

class _OmbudsWidgetState extends State<OmbudsWidget> {
  final TextScaleFactorController textScaleFactorController = Get.find();
  final OmbudsController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Obx(() {
      final error = controller.error.value;
      if (error != null) {
        if (error is NoInternetException) {
          return error.renderWidget(onPressed: controller.loadOmbuds);
        }
        return error.renderWidget(isNoButton: true);
      }

      final story = controller.story.value;
      if (controller.isLoading.value && story == null) {
        return _loadingWidget();
      }

      if (story == null) {
        return Container();
      }

      return _buildContent(width, story);
    });
  }

  Widget _loadingWidget() {
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }

  Widget _buildContent(double width, Story story) {
    return ListView(
      children: [
        const SizedBox(height: 44),
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
          child: _buildHeroWidget(width - 48),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
          child: _buildBrief(story.brief!),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
          child: _understandMoreBlock(),
        ),
        const SizedBox(height: 40),
        Container(
          width: width,
          color: const Color(0xffF4F5F6),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
            child: Column(
              children: [
                const SizedBox(height: 28),
                _appealBlock(width),
                const SizedBox(height: 32),
                _ombudsIntroBlock(width),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroWidget(double width) {
    return Obx(() {
      final video = controller.video.value;
      if (controller.isLoading.value && video == null) {
        return _loadingWidget();
      }

      if (video == null) {
        return Container();
      }

      return _buildVideoWidget(video.url);
    });
  }

  Widget _buildVideoWidget(String videoUrl) {
    if (videoUrl.contains('youtube')) {
      final ytId = VideoId.parseVideoId(videoUrl) ?? '';
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
    final unstyledBrief = <Paragraph>[];
    for (final paragraph in brief) {
      if (paragraph.type == 'unstyled') {
        unstyledBrief.add(paragraph);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Text(
            '外部公評人翁秀琪',
            style: const TextStyle(
              fontSize: 20,
              color: themeColor,
            ),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          ),
        ),
        const SizedBox(height: 8.0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: unstyledBrief.length,
          itemBuilder: (context, index) {
            return Obx(
              () => Text(
                unstyledBrief[index].contents![0].data,
                style: const TextStyle(fontSize: 17),
                textScaleFactor:
                    textScaleFactorController.textScaleFactor.value,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _understandMoreBlock() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(),
        InkWell(
          onTap: () => Get.to(
            () => StoryPage(
              slug: 'biography',
              showAds: false,
            ),
          ),
          child: Obx(
            () => Text(
              '了解更多＞',
              style: const TextStyle(
                fontSize: 20,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
              textScaleFactor: textScaleFactorController.textScaleFactor.value,
            ),
          ),
        ),
      ],
    );
  }

  Widget _appealBlock(double width) {
    return Column(
      children: [
        Obx(
          () => Text(
            '我要向公評人申訴',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Color(0xff004DBC),
            ),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          ),
        ),
        const SizedBox(height: 24),
        Obx(
          () => Text(
            '如果您對於我們的新聞內容有意見，例如：事實錯誤、侵害人權，或違反新聞倫理等，請按下方的向公評人申訴鍵。',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color(0xff014DB8),
            ),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          ),
        ),
        const SizedBox(height: 32),
        _appealButton(
          width,
          '向公評人申訴',
          () => Get.to(
            () => StoryPage(
              slug: 'complaint',
              showAds: false,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Obx(
          () => RichText(
            text: const TextSpan(
              text: '如果您要爆料給鏡新聞，或投書給鏡新聞，\n請來信',
              children: [
                TextSpan(
                  text: 'newsbreak@mnews.tw',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xff014DB8),
              ),
            ),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          ),
        ),
        const SizedBox(height: 20),
        Obx(
          () => RichText(
            text: TextSpan(
              text: '客服事項請打客服專線：',
              children: [
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () async {
                      const url = 'tel:02-7752-5678';
                      if (!await launchUrl(Uri.parse(url))) {
                        throw 'Could not launch $url';
                      }
                    },
                    child: const Text(
                      '（02）7752-5678',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff014DB8),
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: '\n或洽客服信箱：'),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () async {
                      const url = 'mailto:mnews.cs@mnews.com.tw';
                      if (!await launchUrl(Uri.parse(url))) {
                        throw 'Could not launch $url';
                      }
                    },
                    child: const Text(
                      'mnews.cs@mnews.com.tw',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff014DB8),
                      ),
                    ),
                  ),
                ),
              ],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xff014DB8),
              ),
            ),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          ),
        ),
      ],
    );
  }

  Widget _appealButton(
    double width,
    String title,
    VoidCallback? onPressed,
  ) {
    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(
            const TextStyle(
              color: Color(0xff014DB8),
            ),
          ),
          side: MaterialStateProperty.all(
            const BorderSide(
              color: Color(0xff014DB8),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 16.0),
          child: Obx(
            () => Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Color(0xff014DB8),
              ),
              textScaleFactor: textScaleFactorController.textScaleFactor.value,
            ),
          ),
        ),
      ),
    );
  }

  Widget _ombudsIntroBlock(double width) {
    final ombudsWidth = (width - 48 - 26) / 2;

    return Obx(() {
      final height = 54 * textScaleFactorController.textScaleFactor.value + 72;
      final aspectRatio = ombudsWidth / height;
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
            height: height,
            imageLocationString: tvSvg,
            title1: textScaleFactorController.textScaleFactor.value > 1.0
                ? '關於'
                : '關於鏡新聞',
            title2: '公評人',
            onTap: () => Get.to(
              () => StoryPage(
                slug: 'biography',
                showAds: false,
              ),
            ),
          ),
          OmbudsButton(
            width: ombudsWidth,
            height: height,
            imageLocationString: speakerSvg,
            title1: '最新',
            title2: '消息',
            onTap: () => Get.to(() => OmbudsNewsListPage()),
          ),
          OmbudsButton(
            width: ombudsWidth,
            height: height,
            imageLocationString: phoneSvg,
            title1: '申訴',
            title2: '流程',
            onTap: () => Get.to(
              () => StoryPage(
                slug: 'complaint',
                showAds: false,
              ),
            ),
          ),
          OmbudsButton(
            width: ombudsWidth,
            height: height,
            imageLocationString: reportSvg,
            title1: '業務',
            title2: '報告',
            onTap: () => Get.to(
              () => StoryPage(
                slug: 'reports',
                showAds: false,
              ),
            ),
          ),
          OmbudsButton(
            width: ombudsWidth,
            height: height,
            imageLocationString: hammerSvg,
            title1: '公評人',
            title2: '設置章程',
            onTap: () => Get.to(
              () => StoryPage(
                slug: 'law',
                showAds: false,
              ),
            ),
          ),
          OmbudsButton(
            width: ombudsWidth,
            height: height,
            imageLocationString: paperSvg,
            title1: '新聞自律 /',
            title2: '他律規範',
            onTap: () => Get.to(
              () => StoryPage(
                slug: 'standards',
                showAds: false,
              ),
            ),
          ),
          OmbudsButton(
            width: ombudsWidth,
            height: height,
            imageLocationString: faqSvg,
            title1: '常見問題',
            title2: 'FAQ',
            onTap: () => Get.to(
              () => StoryPage(
                slug: 'faq',
                showAds: false,
              ),
            ),
          ),
        ],
      );
    });
  }
}
