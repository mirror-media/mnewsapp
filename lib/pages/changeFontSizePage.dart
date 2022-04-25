import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/environment.dart';

class ChangeFontSizePage extends StatelessWidget {
  ChangeFontSizePage({Key? key}) : super(key: key);

  final TextScaleFactorController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBarColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text(
          '文字大小',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: appBarColor,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: _buildBody(),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 24,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '列表預覽',
            style: TextStyle(
              fontSize: 17,
              color: appBarColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Card(
          elevation: 5,
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CachedNetworkImage(
                  height: 90,
                  width: 90,
                  imageUrl: Environment().config.mirrorNewsDefaultImageUrl,
                  placeholder: (context, url) => Container(
                    height: 90,
                    width: 90,
                    color: Colors.grey,
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 90,
                    width: 90,
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
                      '把握牛年添好運　易經命理師：6生肖運勢最強',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        height: 1.5,
                      ),
                      textScaleFactor: controller.textScaleFactor.value,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 36,
        ),
        const Divider(
          color: appBarColor,
          height: 1,
          thickness: 1,
          indent: 24,
          endIndent: 24,
        ),
        const SizedBox(
          height: 36,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '文章預覽',
            style: TextStyle(
              fontSize: 17,
              color: appBarColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
          child: Obx(
            () => Text(
              '等24年等到了好消息  總統蔡英文：口蹄疫疫區台灣確定除名',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textScaleFactor: controller.textScaleFactor.value,
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
            child: Obx(
              () => ExtendedText(
                '台灣向世界動物衛生組織申請口蹄疫疫區除名，農委會指出仍未獲相關訊息，原先預估本週結果將會出爐，如今確認除名希望能洗掉23年來的汙名。',
                style: TextStyle(
                  fontSize: 17,
                  height: 2,
                  color: Colors.black,
                ),
                textScaleFactor: controller.textScaleFactor.value,
                overflow: TextOverflow.ellipsis,
                joinZeroWidthSpace: true,
                maxLines: 4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: appBarColor,
      constraints: BoxConstraints(maxHeight: 123),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _optionButton('小', 0.9),
          _optionButton('預設', 1.0),
          _optionButton('中', 1.1),
          _optionButton('大', 1.2),
        ],
      ),
    );
  }

  Widget _optionButton(String text, double setValue) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Theme(
          data: ThemeData(
            unselectedWidgetColor: Colors.white,
          ),
          child: Obx(() => Radio<double>(
                value: setValue,
                activeColor: Colors.white,
                groupValue: controller.textScaleFactor.value,
                onChanged: (selectValue) {
                  controller.textScaleFactor.value = selectValue!;
                },
              )),
        ),
        const SizedBox(
          height: 7,
        ),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
        )
      ],
    );
  }
}
