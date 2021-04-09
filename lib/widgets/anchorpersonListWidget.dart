import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/anchorperson/bloc.dart';
import 'package:tv/blocs/anchorperson/events.dart';
import 'package:tv/blocs/anchorperson/states.dart';
import 'package:tv/models/anchorpersonList.dart';

class AnchorpersonListWidget extends StatefulWidget {
  @override
  _AnchorpersonListWidgetState createState() => _AnchorpersonListWidgetState();
}

class _AnchorpersonListWidgetState extends State<AnchorpersonListWidget> {

  @override
  void initState() {
    _fetchAnchorpersonList();
    super.initState();
  }

  _fetchAnchorpersonList() async {
    context.read<AnchorpersonBloc>().add(FetchAnchorpersonList());
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width - 48- 15;

    return BlocBuilder<AnchorpersonBloc, AnchorpersonState>(
      builder: (BuildContext context, AnchorpersonState state) {
        if (state is AnchorpersonError) {
          final error = state.error;
          print('AnchorpersonError: ${error.message}');
          return Container();
        }
        if (state is AnchorpersonListLoaded) {
          AnchorpersonList anchorpersonList = state.anchorpersonList;
          
          return Padding(
            padding: const EdgeInsets.only(
              left: 24-7.5, right: 24-7.5,
              top: 24-16.0, bottom: 24-16.0,
            ),
            child: _buildAnchorpersonList(anchorpersonList, width),
          );
        }

        // state is Init, loading, or other 
        return _loadingWidget();
      }
    );
  }

  Widget _loadingWidget() =>
      Center(
        child: CircularProgressIndicator(),
      );

  Widget _buildAnchorpersonList(AnchorpersonList anchorpersonList, double width) {
    double imageWidth = width/2;
    double imageHeight = imageWidth / 1.333;

    return GridView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: anchorpersonList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1 - 16/imageWidth,
      ),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(7.5, 16, 7.5, 16),
          child: InkWell(
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: CachedNetworkImage(
                    height: imageHeight,
                    width: imageWidth,
                    imageUrl: anchorpersonList[index].photoUrl,
                    placeholder: (context, url) => Container(
                      height: imageHeight,
                      width: imageWidth,
                      color: Colors.grey,
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: imageHeight,
                      width: imageWidth,
                      color: Colors.grey,
                      child: Icon(Icons.error),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                Center(
                  child: Text(
                    anchorpersonList[index].name,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                  ),
                ),
              ]
            ),
            onTap: (){},
          ),
        );
      }
    );
  }
}