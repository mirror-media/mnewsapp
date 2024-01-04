import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tv/controller/ombuds/ombudsNewsController.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/data/value/string_default.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/pages/storyPage.dart';
import 'package:tv/services/ombudsService.dart';

class OmbudsNewsListPage extends StatelessWidget {
  OmbudsNewsListPage({Key? key}) : super(key: key);
  final OmbudsNewsController controller =
      Get.put(OmbudsNewsController(OmbudsService()));
  final TextScaleFactorController textScaleFactorController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
        onPressed: () => Get.back(),
      ),
      backgroundColor: appBarColor,
      centerTitle: true,
      title: const Text(
        '最新消息',
        style: const TextStyle(color: Colors.white, fontSize: 17),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildBody() {
    return Obx(
      () {
        if (controller.isError.isTrue) {
          return controller.error.value.renderWidget(
            onPressed: () => controller.fetchNewsList(),
          );
        }

        if (controller.isLoading.isFalse) {
          return _buildList();
        }

        return Center(child: const CircularProgressIndicator.adaptive());
      },
    );
  }

  Widget _buildList() {
    return Obx(
      () => ListView.builder(
        itemCount: controller.latestNewsList.length + 1,
        padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        itemBuilder: (context, index) {
          if (index == controller.latestNewsList.length) {
            if (controller.hasMore.isFalse) {
              return Container(
                padding: const EdgeInsets.only(bottom: 24),
              );
            }

            if (controller.isLoadingMore.isFalse) {
              controller.fetchMoreNews();
            }

            return Center(child: const CircularProgressIndicator.adaptive());
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildListItem(controller.latestNewsList[index]),
          );
        },
      ),
    );
  }

  Widget _buildListItem(StoryListItem story) {
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
              () => Text(
                story.name ?? StringDefault.nullString,
                style: TextStyle(fontSize: 20),
                textScaleFactor:
                    textScaleFactorController.textScaleFactor.value,
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        if (story.slug == null) return;
        Get.to(() => StoryPage(
              slug: story.slug!,
            ));
      },
    );
  }
}
