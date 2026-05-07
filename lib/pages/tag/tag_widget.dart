import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/controller/tag_controller.dart';
import 'package:tv/controller/text_scale_factor_controller.dart';
import 'package:tv/data/value/string_default.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/models/tag.dart';
import 'package:tv/pages/story_page.dart';

class TagWidget extends StatefulWidget {
  final Tag tag;
  const TagWidget(this.tag);

  @override
  _TagWidgetState createState() => _TagWidgetState();
}

class _TagWidgetState extends State<TagWidget> {
  final TextScaleFactorController textScaleFactorController = Get.find();
  late final TagController controller;

  @override
  void initState() {
    controller = Get.find<TagController>(tag: widget.tag.slug);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = controller.error.value;
      if (error != null) {
        if (error is NoInternetException) {
          return error.renderWidget(
            onPressed: controller.fetchStoryListByTagSlug,
          );
        }
        return error.renderWidget();
      }

      if (controller.isInitState || controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator.adaptive());
      }

      return _buildList(controller.tagStoryList);
    });
  }

  Widget _buildList(List<StoryListItem> tagStoryList) {
    return ListView.builder(
      itemCount: tagStoryList.length + 1,
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
      itemBuilder: (context, index) {
        if (index == tagStoryList.length) {
          if (controller.isAllLoaded) {
            return Container(
              padding: const EdgeInsets.only(bottom: 24),
            );
          }
          if (!controller.isLoadingMore.value) {
            controller.fetchNextPageByTagSlug();
          }
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildListItem(tagStoryList[index]),
        );
      },
    );
  }

  Widget _buildListItem(StoryListItem story) {
    double imageWidth = 33 * (MediaQuery.of(context).size.width - 48) / 100;
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
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
