import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/programList/program_list_cubit.dart';
import 'package:tv/pages/section/programList/programListWidget.dart';

class ProgramListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocProvider(
        create: (context) => ProgramListCubit(),
        child: ProgramListWidget(),
      ),
    );
  }
}
