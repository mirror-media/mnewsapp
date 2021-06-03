import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/show/bloc.dart';
import 'package:tv/models/category.dart';
import 'package:tv/services/showService.dart';
import 'package:tv/widgets/showIntroWidget.dart';

class ShowTabContent extends StatefulWidget {
  final Category category;
  ShowTabContent({
    required this.category,
  });

  @override
  _ShowTabContentState createState() => _ShowTabContentState();
}

class _ShowTabContentState extends State<ShowTabContent> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShowIntroBloc(showRepos: ShowServices()),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: BuildShowIntro(showCategoryId: widget.category.id!,),
      ),
    );
  }
}