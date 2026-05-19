import 'package:flutter/cupertino.dart';
import 'package:tv/bindings/program_list_binding.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/pages/section/programList/program_list_widget.dart';

class ProgramListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.sendScreenView(screenName: 'ProgramListPage');
    ProgramListBinding().dependencies();
    return Center(
      child: ProgramListWidget(),
    );
  }
}
