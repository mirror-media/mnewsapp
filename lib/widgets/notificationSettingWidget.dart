import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/notificationSetting/bloc.dart';
import 'package:tv/blocs/notificationSetting/events.dart';
import 'package:tv/blocs/notificationSetting/states.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/notificationSetting.dart';

class NotificationSettingWidget extends StatefulWidget {
  @override
  _NotificationSettingWidgetState createState() =>
      _NotificationSettingWidgetState();
}

class _NotificationSettingWidgetState extends State<NotificationSettingWidget> {
  @override
  void initState() {
    _getNotificationSettingList();
    super.initState();
  }

  _getNotificationSettingList() async {
    context.read<NotificationSettingBloc>().add(GetNotificationSettingList());
  }

  _onExpansionChanged(List<NotificationSetting> notificationSettingList,
      int index, bool value) async {
    context.read<NotificationSettingBloc>().add(
        NotificationOnExpansionChanged(notificationSettingList, index, value));
  }

  _onCheckBoxChanged(
      List<NotificationSetting> notificationSettingList,
      List<NotificationSetting> checkboxList,
      int index,
      bool isRepeatable) async {
    context.read<NotificationSettingBloc>().add(
          NotificationOnCheckBoxChanged(
              notificationSettingList, checkboxList, index, isRepeatable),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationSettingBloc, NotificationSettingState>(
        builder: (BuildContext context, NotificationSettingState state) {
      if (state is NotificationSettingError) {
        final error = state.error;
        print('NotificationSettingError: ${error.message}');
        return Container();
      }
      if (state is NotificationSettingLoaded) {
        List<NotificationSetting> notificationSettingList =
            state.notificationSettingList;

        return _buildNotificationSettingListSection(notificationSettingList);
      }

      // state is Init, loading, or other
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
                    activeColor: appBarColor,
                    onChanged: (bool value) {}),
              ),
              onExpansionChanged: (bool value) {
                _onExpansionChanged(
                    notificationSettingList, listViewIndex, value);
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
              _onCheckBoxChanged(notificationSettingList, checkboxList,
                  checkboxIndex, isRepeatable);
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
