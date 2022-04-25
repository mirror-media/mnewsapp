import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/blocs/contact/bloc.dart';
import 'package:tv/blocs/contact/events.dart';
import 'package:tv/blocs/contact/states.dart';
import 'package:tv/controller/interstitialAdController.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/helpers/paragraphFormat.dart';
import 'package:tv/models/contact.dart';
import 'package:tv/models/paragraph.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';
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
  final interstitialAdController = Get.find<InterstitialAdController>();
  final TextScaleFactorController textScaleFactorController = Get.find();
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
        AnalyticsHelper.sendScreenView(
            screenName: 'AnchorpersonStoryPage name=${contact.name}');
        interstitialAdController.ramdomShowInterstitialAd();
        return _buildAnchorpersonStory(contact, width);
      }

      // state is Init, loading, or other
      return _loadingWidget();
    });
  }

  Widget _loadingWidget() => Center(
        child: CircularProgressIndicator.adaptive(),
      );

  Widget _buildAnchorpersonStory(Contact contact, double width) {
    double imageWidth = width;
    double imageHeight = imageWidth;
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('AnchorHD'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
            ],
            wantKeepAlive: true,
          ),
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
          InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('AnchorAT1'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
              AdSize(width: 320, height: 480),
            ],
            wantKeepAlive: true,
          ),
          _buildBioWidget(contact.bio),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                      FontAwesomeIcons.facebookF, contact.facebookUrl!),
                ),
              if (contact.instatgramUrl != null)
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: _thirdPartyMediaLinkButton(
                      FontAwesomeIcons.instagram, contact.instatgramUrl!),
                ),
            ],
          ),
          InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('AnchorAT2'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
            ],
            wantKeepAlive: true,
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _thirdPartyMediaLinkButton(IconData icon, String link) {
    return ElevatedButton(
      onPressed: () async {
        if (await canLaunch(link)) {
          await launch(link);
        } else {
          throw 'Could not launch $link';
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FaIcon(icon, size: 20, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        primary: Color(0xffC1C2C2),
        elevation: 5,
        shape: CircleBorder(),
      ),
    );
  }

  Widget _buildBioWidget(List<Paragraph>? bio) {
    ParagraphFormat paragraphFormat = ParagraphFormat();
    if (bio != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 44.0, right: 44.0),
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: bio.length,
            itemBuilder: (context, index) {
              Paragraph paragraph = bio[index];
              if (paragraph.contents != null &&
                  paragraph.contents!.length > 0 &&
                  !_isNullOrEmpty(paragraph.contents![0].data)) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Obx(
                    () => paragraphFormat.parseTheParagraph(
                      paragraph,
                      context,
                      17 * textScaleFactorController.textScaleFactor.value,
                    ),
                  ),
                );
              }

              return Container();
            },
          ),
        ),
      );
    }

    return Container();
  }

  bool _isNullOrEmpty(String? input) {
    return input == null || input == '';
  }
}
