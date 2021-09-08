import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tv/blocs/contact/bloc.dart';
import 'package:tv/blocs/contact/events.dart';
import 'package:tv/blocs/contact/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/contact.dart';
import 'package:url_launcher/url_launcher.dart';

class AnchorpersonStoryWidget extends StatefulWidget {
  final String anchorpersonId;
  AnchorpersonStoryWidget({
    required this.anchorpersonId,
  });

  @override
  _AnchorpersonStoryWidgetState createState() =>
      _AnchorpersonStoryWidgetState();
}

class _AnchorpersonStoryWidgetState extends State<AnchorpersonStoryWidget> {
  @override
  void initState() {
    _fetchContactById(widget.anchorpersonId);
    super.initState();
  }

  _fetchContactById(String contactId) async {
    context.read<ContactBloc>().add(FetchContactById(contactId));
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return BlocBuilder<ContactBloc, ContactState>(
        builder: (BuildContext context, ContactState state) {
      if (state is ContactError) {
        final error = state.error;
        print('ContactError: ${error.message}');
        if (error is NoInternetException) {
          return error.renderWidget(
              onPressed: () => _fetchContactById(widget.anchorpersonId));
        }

        return error.renderWidget();
      }
      if (state is ContactLoaded) {
        Contact contact = state.contact;

        return _buildAnchorpersonStory(contact, width);
      }

      // state is Init, loading, or other
      return _loadingWidget();
    });
  }

  Widget _loadingWidget() => Center(
        child: CircularProgressIndicator(),
      );

  Widget _buildAnchorpersonStory(Contact contact, double width) {
    return ListView(
      children: [
        SizedBox(height: 55),
        _buildAnchorpersonProfile(contact, width),
        SizedBox(height: 20),
        _buildBioWidget(contact.bio),
      ],
    );
  }

  Widget _buildAnchorpersonProfile(Contact contact, double width) {
    double imageWidth = width / 2;
    double imageHeight = imageWidth / 1.333;

    return Column(children: [
      CachedNetworkImage(
        height: imageHeight,
        width: imageWidth,
        imageUrl: contact.photoUrl,
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
        contact.name,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (contact.twitterUrl != null)
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: _thirdPartyMediaLinkButton(
                FontAwesomeIcons.twitter, contact.twitterUrl!),
          ),
        if (contact.facebookUrl != null)
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: _thirdPartyMediaLinkButton(
                FontAwesomeIcons.facebook, contact.facebookUrl!),
          ),
        if (contact.instatgramUrl != null)
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: _thirdPartyMediaLinkButton(
                FontAwesomeIcons.instagram, contact.instatgramUrl!),
          ),
      ]),
    ]);
  }

  Widget _thirdPartyMediaLinkButton(IconData icon, String link) {
    return ClipOval(
      child: Material(
        color: Color(0xffC1C2C2),
        child: InkWell(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: FaIcon(icon, size: 18, color: Colors.white),
            ),
            onTap: () async {
              if (await canLaunch(link)) {
                await launch(link);
              } else {
                throw 'Could not launch $link';
              }
            }),
      ),
    );
  }

  Widget _buildBioWidget(String? bio) {
    if (bio != null) {
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
