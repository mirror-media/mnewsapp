import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/controller/show_intro_controller.dart';
import 'package:tv/controller/text_scale_factor_controller.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/showIntro.dart';
import 'package:tv/pages/section/show/show_playlist_widget.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';

class BuildShowIntro extends StatefulWidget {
  const BuildShowIntro({
    super.key,
    required this.showCategoryId,
  });

  final String showCategoryId;

  @override
  State<BuildShowIntro> createState() => _BuildShowIntroState();
}

class _BuildShowIntroState extends State<BuildShowIntro> {
  late final ShowIntroController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ShowIntroController>(tag: widget.showCategoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = controller.error.value;
      if (error != null) {
        if (error is NoInternetException) {
          return error.renderWidget(
            onPressed: controller.fetchShowIntro,
          );
        }

        return error.renderWidget(isNoButton: true);
      }

      final showIntro = controller.showIntro.value;
      if (showIntro != null) {
        return ShowIntroWidget(showIntro: showIntro);
      }

      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator.adaptive());
      }

      return Container();
    });
  }
}

class ShowIntroWidget extends StatefulWidget {
  const ShowIntroWidget({
    super.key,
    required this.showIntro,
  });

  final ShowIntro showIntro;

  @override
  State<ShowIntroWidget> createState() => _ShowIntroWidgetState();
}

class _ShowIntroWidgetState extends State<ShowIntroWidget> {
  final ScrollController listviewController = ScrollController();

  @override
  void dispose() {
    listviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = width / 375 * 140;
    final TextScaleFactorController textScaleFactorController = Get.find();

    return ListView(
      controller: listviewController,
      children: [
        CachedNetworkImage(
          width: width,
          height: 160,
          imageUrl: widget.showIntro.pictureUrl,
          placeholder: (context, url) => Container(
            height: height,
            width: width,
            color: Colors.grey,
          ),
          errorWidget: (context, url, error) => Container(
            height: height,
            width: width,
            color: Colors.grey,
            child: const Icon(Icons.error),
          ),
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Obx(
            () => Text(
              widget.showIntro.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
              textScaleFactor: textScaleFactorController.textScaleFactor.value,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Obx(
            () => Text(
              widget.showIntro.introduction,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
              textScaleFactor: textScaleFactorController.textScaleFactor.value,
            ),
          ),
        ),
        InlineBannerAdWidget(
          adUnitId: AdUnitIdHelper.getBannerAdUnitId('ShowAT1'),
          sizes: [
            AdSize.mediumRectangle,
            AdSize(width: 336, height: 280),
          ],
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ShowPlaylistWidget(
            showIntro: widget.showIntro,
            listviewController: listviewController,
          ),
        ),
      ],
    );
  }
}
