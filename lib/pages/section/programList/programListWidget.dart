import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:tv/blocs/programList/program_list_cubit.dart';
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
  DateTime _selectedDate = DateTime.now();
  String _buttonText = "請選擇日期";
  bool _isDefault = true;
  final TextScaleFactorController textScaleFactorController = Get.find();

  @override
  void initState() {
    _loadProgramList();
    super.initState();
  }

  _loadProgramList() async {
    context.read<ProgramListCubit>().fetchProgramList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramListCubit, ProgramListState>(
      builder: (context, state) {
        if (state is ProgramListError) {
          final error = state.error;
          print('ProgramListError: ${error.message}');
          if (error is NoInternetException) {
            return error.renderWidget(onPressed: () => _loadProgramList());
          }

          return error.renderWidget(isNoButton: true);
        }
        if (state is ProgramListLoaded) {
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
                  child: _buildContent(state.programList),
                )
              ],
            ),
          );
        }
        return _loadingWidget();
      },
    );
  }

  Widget _loadingWidget() => Center(
        child: CircularProgressIndicator.adaptive(),
      );

  Widget _buildChooseButton() {
    return OutlinedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Color(0xE5F4F5F6))),
        onPressed: () {
          _isDefault = false;
          DatePicker.showPicker(context,
              pickerModel: CustomPicker(
                  currentTime: DateTime.now(),
                  maxTime: DateTime.now().add(const Duration(days: 6)),
                  locale: LocaleType.zh),
              locale: LocaleType.tw, onConfirm: (date) {
            setState(() {
              _selectedDate = date;
              _buttonText =
                  '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日';
            });
          });
        },
        child: Container(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                  _buttonText,
                  style: TextStyle(
                    color: _isDefault ? Color(0x3f000000) : Colors.black,
                    fontSize: 17,
                  ),
                  textScaleFactor:
                      textScaleFactorController.textScaleFactor.value,
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
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          ),
          const Spacer(),
          SizedBox(
            width: 24.5 * textScaleFactorController.textScaleFactor.value,
          ),
          Text(
            '節目名稱',
            style: TextStyle(fontSize: 15),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          ),
          const Spacer(),
          Text(
            '分級',
            style: TextStyle(fontSize: 15),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<ProgramListItem> programList) {
    List<ProgramListItem> _pickedProgramList = [];
    int start = programList.indexWhere((element) =>
        element.year == _selectedDate.year &&
        element.month == _selectedDate.month &&
        element.day == _selectedDate.day);
    int end = programList.lastIndexWhere((element) =>
        element.year == _selectedDate.year &&
        element.month == _selectedDate.month &&
        element.day == _selectedDate.day);

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
    String time = '$startHour:$startMinute-$endHour:$endMinute';

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
                textScaleFactor:
                    textScaleFactorController.textScaleFactor.value,
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
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            time,
            style: TextStyle(fontSize: 15),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
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
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          )
        ],
      ),
    );
  }
}
