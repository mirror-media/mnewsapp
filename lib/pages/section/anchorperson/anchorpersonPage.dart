import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/contact/bloc.dart';
import 'package:tv/services/contactService.dart';
import 'package:tv/pages/section/anchorperson/anchorpersonListWidget.dart';

class AnchorpersonPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContactBloc(contactRepos: ContactServices()),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: AnchorpersonListWidget(),
      ),
    );
  }
}