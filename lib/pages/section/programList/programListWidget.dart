import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:tv/widgets/customPicker.dart';

class ProgramListWidget extends StatefulWidget{
  @override
  _ProgramListWidgetState createState() => _ProgramListWidgetState();
}

class _ProgramListWidgetState extends State<ProgramListWidget>{
  DateTime _selectedDate = DateTime.now();
  String _buttonText = "請選擇日期";
  bool _isDefault = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          _buildChooseButton(),
          SizedBox(height: 16,),
          _buildLabel(),
          SizedBox(height: 8,),
        ],
      ),
    );
  }

  Widget _buildChooseButton(){
    return OutlinedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Color(0xE5F4F5F6))
        ),
        onPressed: (){
          _isDefault = false;
          DatePicker.showPicker(context,
              pickerModel: CustomPicker(
                  currentTime: DateTime.now(),
                  maxTime: DateTime.now().add(const Duration(days: 6)),
                  locale: LocaleType.zh
              ),
              locale: LocaleType.zh,
              onConfirm: (date){
                setState(() {
                  _selectedDate = date;
                  _buttonText = '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日';
                });
              }
          );
        },
        child: Container(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_buttonText,
                style: TextStyle(
                  color: _isDefault ? Color(0x3f000000):Colors.black,
                  fontSize: 17,
                ),
              ),
              FittedBox(
                child: Icon(Icons.keyboard_arrow_down,
                  color: Color(0xE5757575),
                ),
              ),
            ],
          ),
        )
    );
  }

  Widget _buildLabel(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('時間',style: TextStyle(fontSize: 15),),
        Text('節目名稱',style: TextStyle(fontSize: 15),),
        Text('分級',style: TextStyle(fontSize: 15),),
      ],
    );
  }
}