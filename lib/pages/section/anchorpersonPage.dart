import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/anchorperson/bloc.dart';
import 'package:tv/services/contactService.dart';
import 'package:tv/widgets/anchorpersonListWidget.dart';

class AnchorpersonPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnchorpersonBloc(contactRepos: ContactServices()),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: AnchorpersonListWidget(),
      ),
    );
  }
}