import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/anchorperson/bloc.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/services/contactService.dart';
import 'package:tv/widgets/anchorpersonStoryWidget.dart';

class AnchorpersonStoryPage extends StatefulWidget {
  final String anchorpersonId;
  final String anchorpersonName;
  AnchorpersonStoryPage({
    @required this.anchorpersonId,
    @required this.anchorpersonName,
  });

  @override
  _AnchorpersonStoryPageState createState() => _AnchorpersonStoryPageState();
}

class _AnchorpersonStoryPageState extends State<AnchorpersonStoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: BlocProvider(
        create: (context) => AnchorpersonBloc(contactRepos: ContactServices()),
        child: AnchorpersonStoryWidget(anchorpersonId: widget.anchorpersonId,),
      ),
    );
  }

  Widget _buildBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: appBarColor,
      centerTitle: true,
      title: Text(widget.anchorpersonName),
    );
  }
}