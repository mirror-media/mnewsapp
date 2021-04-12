import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tv/blocs/anchorperson/bloc.dart';
import 'package:tv/blocs/anchorperson/events.dart';
import 'package:tv/blocs/anchorperson/states.dart';
import 'package:tv/models/anchorperson.dart';
import 'package:url_launcher/url_launcher.dart';

class AnchorpersonStoryWidget extends StatefulWidget {
  final String anchorpersonId;
  AnchorpersonStoryWidget({
    @required this.anchorpersonId,
  });

  @override
  _AnchorpersonStoryWidgetState createState() => _AnchorpersonStoryWidgetState();
}

class _AnchorpersonStoryWidgetState extends State<AnchorpersonStoryWidget> {
  @override
  void initState() {
    _fetchAnchorpersonList(widget.anchorpersonId);
    super.initState();
  }

  _fetchAnchorpersonList(String anchorpersonId) async {
    context.read<AnchorpersonBloc>().add(FetchAnchorpersonById(anchorpersonId));
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return BlocBuilder<AnchorpersonBloc, AnchorpersonState>(
      builder: (BuildContext context, AnchorpersonState state) {
        if (state is AnchorpersonError) {
          final error = state.error;
          print('AnchorpersonError: ${error.message}');
          return Container();
        }
        if (state is AnchorpersonLoaded) {
          Anchorperson anchorperson = state.anchorperson;
          
          return _buildAnchorpersonStory(anchorperson, width);
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
  
  Widget _buildAnchorpersonStory(Anchorperson anchorperson, double width) {


    return ListView(
      children: [
        SizedBox(height: 55),
        _buildAnchorpersonProfile(anchorperson, width),
        SizedBox(height: 20),
        _buildBioWidget(anchorperson.bio),
      ],
    );
  }

  Widget _buildAnchorpersonProfile(Anchorperson anchorperson, double width) {
    double imageWidth = width/2;
    double imageHeight = imageWidth / 1.333;

    return Column(
      children: [
        CachedNetworkImage(
          height: imageHeight,
          width: imageWidth,
          imageUrl: anchorperson.photoUrl,
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
          fit: BoxFit.fitWidth,
        ),
        SizedBox(height: 12),
        Text(
          anchorperson.name,
          style: TextStyle(
            fontSize: 17, 
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(anchorperson.twitterUrl != null)
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: _thirdPartyMediaLinkButton(
                  FontAwesomeIcons.twitter,
                  anchorperson.twitterUrl
                ),
              ),
            if(anchorperson.facebookUrl != null)
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: _thirdPartyMediaLinkButton(
                  FontAwesomeIcons.facebook,
                  anchorperson.facebookUrl
                ),
              ),
            if(anchorperson.instatgramUrl != null)
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: _thirdPartyMediaLinkButton(
                  FontAwesomeIcons.instagram,
                  anchorperson.instatgramUrl
                ),
              ),
          ]
        ),
      ]
    );
  }

  Widget _thirdPartyMediaLinkButton(IconData icon, String link) {
    return ClipOval(
      child: Material(
        color: Color(0xffC1C2C2),
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: FaIcon(
              icon,
              size: 18,
              color: Colors.white
            ),
          ),
          onTap: () async{
            if (await canLaunch(link)) {
              await launch(link);
            } else {
              throw 'Could not launch $link';
            }
          }
        ),
      ),
    );
  }

  Widget _buildBioWidget(String bio) {
    if(bio != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 44.0, right: 44.0),
          child: Text(
            bio,
            style: TextStyle(
              height: 1.8,
              fontSize: 17, 
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );
    }

    return Container();
  }
}