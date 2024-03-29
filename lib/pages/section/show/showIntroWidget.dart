import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/blocs/show/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/show/events.dart';
import 'package:tv/blocs/show/states.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/showIntro.dart';
import 'package:tv/pages/section/show/showPlaylistWidget.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';

class BuildShowIntro extends StatefulWidget {
  final String showCategoryId;
  BuildShowIntro({
    required this.showCategoryId,
  });

  @override
  _BuildShowIntroState createState() => _BuildShowIntroState();
}

class _BuildShowIntroState extends State<BuildShowIntro> {
  @override
  void initState() {
    _fetchShowIntro(widget.showCategoryId);
    super.initState();
  }

  _fetchShowIntro(String showCategoryId) async {
    context.read<ShowIntroBloc>().add(FetchShowIntro(showCategoryId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShowIntroBloc, ShowState>(
        builder: (BuildContext context, ShowState state) {
      if (state is ShowError) {
        final error = state.error;
        print('ShowError: ${error.message}');
        if (error is NoInternetException) {
          return error.renderWidget(
              onPressed: () => _fetchShowIntro(widget.showCategoryId));
        }

        return error.renderWidget(isNoButton: true);
      }
      if (state is ShowIntroLoaded) {
        ShowIntro showIntro = state.showIntro;

        return ShowIntroWidget(
          showIntro: showIntro,
        );
      }

      // state is Init, loading, or other
      return Container();
    });
  }
}

class ShowIntroWidget extends StatefulWidget {
  final ShowIntro showIntro;
  ShowIntroWidget({required this.showIntro});

  @override
  _ShowIntroWidgetState createState() => _ShowIntroWidgetState();
}

class _ShowIntroWidgetState extends State<ShowIntroWidget> {
  ScrollController _listviewController = ScrollController();

  @override
  void dispose() {
    _listviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = width / 375 * 140;
    final TextScaleFactorController textScaleFactorController = Get.find();

    return ListView(controller: _listviewController, children: [
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
          child: Icon(Icons.error),
        ),
        fit: BoxFit.cover,
      ),
      SizedBox(height: 32),
      Padding(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: Obx(
          () => Text(
            widget.showIntro.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          ),
        ),
      ),
      SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: Obx(
          () => Text(
            widget.showIntro.introduction,
            style: TextStyle(
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
      SizedBox(height: 24),
      Padding(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: ShowPlaylistWidget(
          showIntro: widget.showIntro,
          listviewController: _listviewController,
        ),
      ),
    ]);
  }
}
