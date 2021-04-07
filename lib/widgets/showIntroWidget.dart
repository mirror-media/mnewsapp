import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tv/blocs/show/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/show/events.dart';
import 'package:tv/blocs/show/states.dart';
import 'package:tv/models/showIntro.dart';
import 'package:tv/widgets/showPlaylistWidget.dart';

class BuildShowIntro extends StatefulWidget {
  final String showCategoryId;
  BuildShowIntro({
    @required this.showCategoryId,
  });

  @override
  _BuildShowIntroState createState() => _BuildShowIntroState();
}

class _BuildShowIntroState extends State<BuildShowIntro> {

  @override
  void initState() {
    _fetchShowIntro(widget.showCategoryId);
    super.initState();
  }

  _fetchShowIntro(String showCategoryId) async {
    context.read<ShowIntroBloc>().add(FetchShowIntro(showCategoryId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShowIntroBloc, ShowState>(
      builder: (BuildContext context, ShowState state) {
        if (state is ShowError) {
          final error = state.error;
          String message = '${error.message}\nTap to Retry.';
          return Center(
            child: Text(message),
          );
        }
        if (state is ShowIntroLoaded) {
          ShowIntro showIntro = state.showIntro;

          return ShowIntroWidget(
            showIntro: showIntro,
          );
        }

        // state is Init, loading, or other 
        return Container();
      }
    );
  }
}

class ShowIntroWidget extends StatelessWidget {
  final ShowIntro showIntro;
  ShowIntroWidget({
    @required this.showIntro,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = width/375*140;

    return ListView(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CachedNetworkImage(
          width: width,
          imageUrl: showIntro.pictureUrl,
          placeholder: (context, url) => Container(
            height: height,
            width: width,
            color: Colors.grey,
          ),
          errorWidget: (context, url, error) => Container(
            height: height,
            width: width,
            color: Colors.grey,
            child: Icon(Icons.error),
          ),
          fit: BoxFit.cover,
        ),
        SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Text(
            showIntro.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Text(
            showIntro.introduction??'',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: ShowPlaylistWidget(showIntro: showIntro,),
        ),
      ]
    );
  }
}