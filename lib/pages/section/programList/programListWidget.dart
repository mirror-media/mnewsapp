import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

import 'package:get/get.dart';
import 'package:tv/controller/program_list_controller.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/programListItem.dart';
import 'package:tv/pages/shared/tabContentNoResultWidget.dart';
import 'package:tv/widgets/customPicker.dart';

class ProgramListWidget extends StatefulWidget {
  @override
  _ProgramListWidgetState createState() => _ProgramListWidgetState();
}

class _ProgramListWidgetState extends State<ProgramListWidget> {
  final ProgramListController controller = Get.find<ProgramListController>();
  final TextScaleFactorController textScaleFactorController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
        final error = controller.error.value;
        if (error != null) {
          print('ProgramListError: ${error.message}');
          if (error is NoInternetException) {
            return error.renderWidget(onPressed: controller.fetchProgramList);
          }

          return error.renderWidget(isNoButton: true);
        }
        if (!controller.isLoading.value && controller.programList.isNotEmpty) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: [
                _buildChooseButton(),
                SizedBox(
                  height: 16,
                ),
                _buildLabel(),
                SizedBox(
                  height: 8,
                ),
                Expanded(
                  child: _buildContent(controller.programList),
                )
              ],
            ),
          );
        }
        return _loadingWidget();
      });
  }

  Widget _loadingWidget() => Center(
        child: CircularProgressIndicator.adaptive(),
      );

  Widget _buildChooseButton() {
    return OutlinedButton(
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Color(0xE5F4F5F6))),
        onPressed: () {
          DatePicker.showPicker(context,
              pickerModel: CustomPicker(
                  currentTime: DateTime.now(),
                  maxTime: DateTime.now().add(const Duration(days: 6)),
                  locale: LocaleType.zh),
              locale: LocaleType.tw, onConfirm: (date) {
            controller.updateSelectedDate(date);
          });
        },
        child: Container(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                  controller.buttonText.value,
                  style: TextStyle(
                    color: controller.isDefaultDate.value
                        ? Color(0x3f000000)
                        : Colors.black,
                    fontSize: 17,
                  ),
                  textScaler: TextScaler.linear(
                      textScaleFactorController.textScaleFactor.value),
                ),
              ),
              FittedBox(
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xE5757575),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildLabel() {
    return Obx(
      () => Row(
        children: [
          Text(
            '時間',
            style: TextStyle(fontSize: 15),
            textScaler: TextScaler.linear(
                textScaleFactorController.textScaleFactor.value),
          ),
          const Spacer(),
          SizedBox(
            width: 24.5 * textScaleFactorController.textScaleFactor.value,
          ),
          Text(
            '節目名稱',
            style: TextStyle(fontSize: 15),
            textScaler: TextScaler.linear(
                textScaleFactorController.textScaleFactor.value),
          ),
          const Spacer(),
          Text(
            '分級',
            style: TextStyle(fontSize: 15),
            textScaler: TextScaler.linear(
                textScaleFactorController.textScaleFactor.value),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<ProgramListItem> programList) {
    List<ProgramListItem> _pickedProgramList = [];
    int start = programList.indexWhere((element) =>
        element.year == controller.selectedDate.value.year &&
        element.month == controller.selectedDate.value.month &&
        element.day == controller.selectedDate.value.day);
    int end = programList.lastIndexWhere((element) =>
        element.year == controller.selectedDate.value.year &&
        element.month == controller.selectedDate.value.month &&
        element.day == controller.selectedDate.value.day);

    if (start == -1 || end == -1) {
      return TabContentNoResultWidget();
    }

    for (int i = start; i <= end; i++) {
      _pickedProgramList.add(programList[i]);
    }

    if (end != programList.length - 1) {
      _pickedProgramList.add(programList[end + 1]);
    } else {
      _pickedProgramList.add(programList[0]);
    }

    return ListView.separated(
      itemBuilder: (context, index) {
        return _programListViewItem(
            _pickedProgramList[index], _pickedProgramList[index + 1]);
      },
      separatorBuilder: (context, index) {
        return Divider(
          height: 16.5,
          thickness: 0.5,
          color: Colors.black,
        );
      },
      itemCount: _pickedProgramList.length - 1,
    );
  }

  Widget _programListViewItem(ProgramListItem now, ProgramListItem next) {
    print('channelId = ${now.channelId}, programme = ${now.programme}');
    String startHour = (now.startTimeHour < 10)
        ? '0${now.startTimeHour.toString()}'
        : now.startTimeHour.toString();
    String startMinute = (now.startTimeMinute < 10)
        ? '0${now.startTimeMinute.toString()}'
        : now.startTimeMinute.toString();
    String endHour = (next.startTimeHour < 10)
        ? '0${next.startTimeHour.toString()}'
        : next.startTimeHour.toString();
    String endMinute = (next.startTimeMinute < 10)
        ? '0${next.startTimeMinute.toString()}'
        : next.startTimeMinute.toString();
    if (endHour == '00' && endMinute == '00') endHour = '24';

    // Widget newOrRepeat;
    // if (now.txCategory == 'Repeat')
    //   newOrRepeat = Text(
    //     '(重播)',
    //     style: TextStyle(fontSize: 15, color: Color(0xE5979797)),
    //   );
    // else
    //   newOrRepeat = Text(
    //     '(新播)',
    //     style: TextStyle(fontSize: 15),
    //   );
    Widget name = Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Obx(
              () => Text(
                now.programme,
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
                textScaler: TextScaler.linear(
                    textScaleFactorController.textScaleFactor.value),
              ),
            ),
          ),
          SizedBox(
            width: 35,
          ),
          // newOrRepeat
        ],
      ),
    );

    return Obx(
      () {
        String time = '$startHour:$startMinute-$endHour:$endMinute';
        if (textScaleFactorController.textScaleFactor.value > 1.5) {
          time = '$startHour:$startMinute-\n$endHour:$endMinute';
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              time,
              style: TextStyle(fontSize: 15),
              textScaler: TextScaler.linear(
                  textScaleFactorController.textScaleFactor.value),
            ),
            // SizedBox(
            //   width: 21,
            // ),
            name,
            // SizedBox(
            //   width: 15,
            // ),
            Text(
              now.showClass,
              style: TextStyle(fontSize: 15, color: Color(0xE5979797)),
              textScaler: TextScaler.linear(
                  textScaleFactorController.textScaleFactor.value),
            )
          ],
        );
      },
    );
  }
}
