import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:tv/blocs/programList/program_list_cubit.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/programList.dart';
import 'package:tv/models/programListItem.dart';
import 'package:tv/widgets/customPicker.dart';

class ProgramListWidget extends StatefulWidget {
  @override
  _ProgramListWidgetState createState() => _ProgramListWidgetState();
}

class _ProgramListWidgetState extends State<ProgramListWidget> {
  DateTime _selectedDate = DateTime.now();
  String _buttonText = "請選擇日期";
  bool _isDefault = true;

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
        child: CircularProgressIndicator(),
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
              locale: LocaleType.zh, onConfirm: (date) {
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
              Text(
                _buttonText,
                style: TextStyle(
                  color: _isDefault ? Color(0x3f000000) : Colors.black,
                  fontSize: 17,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '時間',
          style: TextStyle(fontSize: 15),
        ),
        Text(
          '節目名稱',
          style: TextStyle(fontSize: 15),
        ),
        Text(
          '分級',
          style: TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildContent(ProgramList programList) {
    ProgramList _pickedProgramList = new ProgramList();
    int start = programList.indexWhere((element) =>
        element.year == _selectedDate.year &&
        element.weekDay == _selectedDate.weekday);
    int end = programList.lastIndexWhere((element) =>
        element.year == _selectedDate.year &&
        element.weekDay == _selectedDate.weekday);

    for (int i = start; i <= end; i++) {
      _pickedProgramList.add(programList[i]);
    }

    if (end != programList.length - 1) {
      _pickedProgramList.add(programList[end + 1]);
    } else {
      if (_selectedDate.weekday == 7) {
        _pickedProgramList.add(programList.firstWhere(
            (element) =>
                element.weekDay == 1 && element.year == _selectedDate.year,
            orElse: () {
          return programList.firstWhere((element) => element.weekDay == 1);
        }));
      } else {
        _pickedProgramList.add(programList.firstWhere(
            (element) =>
                element.weekDay == _selectedDate.weekday + 1 &&
                element.year == _selectedDate.year, orElse: () {
          return programList.firstWhere(
              (element) => element.weekDay == _selectedDate.weekday + 1);
        }));
      }
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

  Widget _programListViewItem(ProgramListItem today, ProgramListItem tomorrow) {
    String startHour = (today.startTimeHour < 10)
        ? '0${today.startTimeHour.toString()}'
        : today.startTimeHour.toString();
    String startMinute = (today.startTimeMinute < 10)
        ? '0${today.startTimeMinute.toString()}'
        : today.startTimeMinute.toString();
    String endHour = (tomorrow.startTimeHour < 10)
        ? '0${tomorrow.startTimeHour.toString()}'
        : tomorrow.startTimeHour.toString();
    String endMinute = (tomorrow.startTimeMinute < 10)
        ? '0${tomorrow.startTimeMinute.toString()}'
        : tomorrow.startTimeMinute.toString();
    if (endHour == '00' && endMinute == '00') endHour = '24';
    String time = '$startHour:$startMinute-$endHour:$endMinute';

    Widget newOrRepeat;
    if (today.txCategory == 'Repeat')
      newOrRepeat = Text(
        '(重播)',
        style: TextStyle(fontSize: 15, color: Color(0xE5979797)),
      );
    else
      newOrRepeat = Text(
        '(新播)',
        style: TextStyle(fontSize: 15),
      );
    Widget name = Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              today.programme,
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          newOrRepeat
        ],
      ),
    );

    return Row(
      children: [
        Text(
          time,
          style: TextStyle(fontSize: 15),
        ),
        SizedBox(
          width: 20,
        ),
        name,
        SizedBox(
          width: 20,
        ),
        Text(
          today.showClass,
          style: TextStyle(fontSize: 15, color: Color(0xE5979797)),
        )
      ],
    );
  }
}
