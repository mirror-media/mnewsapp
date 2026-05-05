import 'package:flutter/material.dart';
import 'embeddedCodeType.dart';
import 'platform/dcardEmbeddedCodeWidget.dart';
import 'platform/generalEmbeddedCodeWidget.dart';
import 'platform/googleDocsEmbeddedCodeWidget.dart';
import 'platform/googleFormsEmbeddedCodeWidget.dart';
import 'platform/googleMapEmbeddedWidget.dart';
import 'platform/googleSpreadsheetsEmbeddedCodeWidget.dart';
import 'platform/instagramEmbeddedCodeWidget.dart';
import 'platform/tiktokEmbeddedCodeWidget.dart';
import 'platform/twitterEmbeddedCodeWidget.dart';
import 'platform/ytEmbeddedCodeWidget.dart';

@immutable
class EmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCode;
  final double? aspectRatio;

  const EmbeddedCodeWidget({
    Key? key,
    required this.embeddedCode,
    this.aspectRatio,
  }) : super(key: key);

  @override
  _EmbeddedCodeWidgetState createState() => _EmbeddedCodeWidgetState();
}

class _EmbeddedCodeWidgetState extends State<EmbeddedCodeWidget>
    with AutomaticKeepAliveClientMixin {
  late final EmbeddedCodeType? _embeddedCodeType;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _embeddedCodeType = EmbeddedCode.findEmbeddedCodeType(widget.embeddedCode);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    switch (_embeddedCodeType) {
      case EmbeddedCodeType.facebook:
        return Container();
      case EmbeddedCodeType.instagram:
        return InstagramEmbeddedCodeWidget(
          embeddedCode: widget.embeddedCode,
        );
      case EmbeddedCodeType.twitter:
        return TwitterEmbeddedCodeWidget(
          embeddedCode: widget.embeddedCode,
        );
      case EmbeddedCodeType.tiktok:
        return TiktokEmbeddedCodeWidget(
          embeddedCode: widget.embeddedCode,
        );
      case EmbeddedCodeType.dcard:
        return DcardEmbeddedCodeWidget(
          embeddedCode: widget.embeddedCode,
        );
      case EmbeddedCodeType.googleForms:
        return GoogleFormsEmbeddedCodeWidget(
          embeddedCode: widget.embeddedCode,
        );
      case EmbeddedCodeType.googleMap:
        return GoogleMapEmbeddedCodeWidget(
          embeddedCode: widget.embeddedCode,
        );
      case EmbeddedCodeType.youtube:
        return YtEmbeddedCodeWidget(
          embeddedCode: widget.embeddedCode,
          aspectRatio: widget.aspectRatio,
        );
      case EmbeddedCodeType.googleDocs:
        return GoogleDocsEmbeddedCodeWidget(
          embeddedCode: widget.embeddedCode,
        );
      case EmbeddedCodeType.googleSpreadsheets:
        return GoogleSpreadsheetsEmbeddedCodeWidget(
          embeddedCode: widget.embeddedCode,
        );
      default:
        return GeneralEmbeddedCodeWidget(embeddedCode: widget.embeddedCode);
    }
  }
}
