import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/contact/bloc.dart';
import 'package:tv/blocs/contact/events.dart';
import 'package:tv/blocs/contact/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/helpers/routeGenerator.dart';
import 'package:tv/models/contact.dart';
import 'package:tv/models/contactList.dart';

class AnchorpersonListWidget extends StatefulWidget {
  @override
  _AnchorpersonListWidgetState createState() => _AnchorpersonListWidgetState();
}

class _AnchorpersonListWidgetState extends State<AnchorpersonListWidget> {
  @override
  void initState() {
    _fetchAnchorpersonOrHostContactList();
    super.initState();
  }

  _fetchAnchorpersonOrHostContactList() async {
    context.read<ContactBloc>().add(FetchAnchorpersonOrHostContactList());
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width - 48 - 15;

    return BlocBuilder<ContactBloc, ContactState>(
        builder: (BuildContext context, ContactState state) {
      if (state is ContactError) {
        final error = state.error;
        print('ContactError: ${error.message}');
        if (error is NoInternetException) {
          return error.renderWidget(
              onPressed: () => _fetchAnchorpersonOrHostContactList());
        }

        return error.renderWidget(isNoButton: true);
      }
      if (state is ContactListLoaded) {
        ContactList contactList = state.contactList;
        List<Contact> anchorpersonContactList =
            contactList.where((contact) => contact.isAnchorperson).toList();
        List<Contact> hostContactList =
            contactList.where((contact) => contact.isHost).toList();

        return ListView(
          children: [
            if (anchorpersonContactList.length > 0) ...[
              SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                ),
                child: _buildContactTypeTitle('鏡主播', width),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 24 - 7.5,
                  right: 24 - 7.5,
                  top: 24 - 16.0,
                  bottom: 24 - 16.0,
                ),
                child: _buildContactList(anchorpersonContactList, width),
              ),
            ],
            if (hostContactList.length > 0) ...[
              SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                ),
                child: _buildContactTypeTitle('鏡主持', width),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 24 - 7.5,
                  right: 24 - 7.5,
                  top: 24 - 16.0,
                  bottom: 24 - 16.0,
                ),
                child: _buildContactList(hostContactList, width),
              ),
            ],
          ],
        );
      }

      // state is Init, loading, or other
      return _loadingWidget();
    });
  }

  Widget _loadingWidget() => Center(
        child: CircularProgressIndicator.adaptive(),
      );

  Widget _buildContactTypeTitle(String title, double width) {
    return Container(
        width: width,
        decoration: BoxDecoration(
            color: Color(0xff004DBC),
            borderRadius: BorderRadius.circular((4.0))),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ));
  }

  Widget _buildContactList(List<Contact> contactList, double width) {
    double imageWidth = width / 2;
    double imageHeight = imageWidth * 0.56;

    return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0),
        itemCount: contactList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(7.5, 16, 7.5, 16),
            child: InkWell(
              child: Wrap(children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: CachedNetworkImage(
                    height: imageHeight,
                    width: imageWidth,
                    imageUrl: contactList[index].photoUrl,
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
                    contactList[index].name,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                  ),
                ),
              ]),
              onTap: () {
                RouteGenerator.navigateToAnchorpersonStory(
                  context,
                  contactList[index].id,
                  contactList[index].name,
                );
              },
            ),
          );
        });
  }
}
