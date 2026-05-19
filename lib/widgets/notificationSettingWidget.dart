import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/controller/notification_setting_controller.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/notificationSetting.dart';

class NotificationSettingWidget extends GetView<NotificationSettingController> {
  const NotificationSettingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = controller.error.value;
      if (error != null) {
        print('NotificationSettingError: ${error.message}');
        return Container();
      }

      final notificationSettingList = controller.notificationSettingList;
      if (notificationSettingList.isNotEmpty) {
        return _buildNotificationSettingListSection(notificationSettingList);
      }

      return Container();
    });
  }

  _buildNotificationSettingListSection(
      List<NotificationSetting> notificationSettingList) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: notificationSettingList.length,
      itemBuilder: (context, listViewIndex) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
          child: ListTileTheme(
            contentPadding: EdgeInsets.all(0),
            child: ExpansionTile(
              initiallyExpanded: notificationSettingList[listViewIndex].value,
              leading: null,
              title: ListTile(
                title: Text(
                  notificationSettingList[listViewIndex].title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              trailing: IgnorePointer(
                child: CupertinoSwitch(
                    value: notificationSettingList[listViewIndex].value,
                    activeTrackColor: appBarColor,
                    onChanged: (bool value) {}),
              ),
              onExpansionChanged: (bool value) {
                controller.onExpansionChanged(listViewIndex, value);
              },
              children: _renderCheckBoxChildren(
                  context, notificationSettingList, listViewIndex),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _renderCheckBoxChildren(BuildContext context,
      List<NotificationSetting> notificationSettingList, int index) {
    if (notificationSettingList[index].id == 'notification') {
      return [
        _buildCheckbox(context, notificationSettingList, index, true, 4, 2.0)
      ];
    }

    return [];
  }

  Widget _buildCheckbox(
      BuildContext context,
      List<NotificationSetting> notificationSettingList,
      int index,
      bool isRepeatable,
      int count,
      double ratio) {
    List<NotificationSetting> checkboxList =
        notificationSettingList[index].notificationSettingList!;
    return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: checkboxList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count,
          childAspectRatio: ratio,
        ),
        itemBuilder: (context, checkboxIndex) {
          return InkWell(
            onTap: () {
              controller.onCheckBoxChanged(
                checkboxList,
                checkboxIndex,
                isRepeatable,
              );
            },
            child: IgnorePointer(
              child: Row(children: [
                Checkbox(
                  value: checkboxList[checkboxIndex].value,
                  onChanged: (value) {},
                ),
                Expanded(child: Text(checkboxList[checkboxIndex].title)),
              ]),
            ),
          );
        });
  }
}
