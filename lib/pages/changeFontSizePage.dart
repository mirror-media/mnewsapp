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
    return ListView(
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
                      '上千隻列隊游成魚球　小琉球潛水目睹「梭魚風暴」',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        height: 1.5,
                      ),
                      textScaler:
                          TextScaler.linear(controller.textScaleFactor.value),
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
              '1家公司工作84年  百歲老翁獲金氏世界紀錄',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textScaler: TextScaler.linear(controller.textScaleFactor.value),
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 28.0),
          child: Obx(
            () => ExtendedText(
              '工作，累了嗎？相信大家對於拿捏工作和生活的平衡，都有深刻的體會和感觸。巴西南部有一名百歲老翁奧斯曼，在同一家紡織公司連續任職長達84年，他不僅獲得金氏世界紀錄的認證，頒獎後，奧斯曼每到上班日還是鬥志昂揚。外媒訪問奧斯曼「活到老，工作到老」的訣竅，他說做你喜愛做的事，遠離垃圾食物。',
              style: TextStyle(
                fontSize: 17,
                height: 2,
                color: Colors.black,
              ),
              textScaler: TextScaler.linear(controller.textScaleFactor.value),
              overflow: TextOverflow.ellipsis,
              joinZeroWidthSpace: true,
              maxLines: 5,
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
          _optionButton('大', 1.7),
        ],
      ),
    );
  }

  Widget _optionButton(String text, double setValue) {
    return GestureDetector(
      onTap: () => controller.textScaleFactor.value = setValue,
      child: Column(
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
      ),
    );
  }
}
