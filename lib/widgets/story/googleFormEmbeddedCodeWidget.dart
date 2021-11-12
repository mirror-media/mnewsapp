import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleFormEmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCoede;
  GoogleFormEmbeddedCodeWidget({
    required this.embeddedCoede,
  });

  @override
  _GoogleFormEmbeddedCodeWidgetState createState() =>
      _GoogleFormEmbeddedCodeWidgetState();
}

class _GoogleFormEmbeddedCodeWidgetState
    extends State<GoogleFormEmbeddedCodeWidget> {
  // <iframe src="https://docs.google.com/forms/d/e/1FAIpQLSeI8_vYyaJgM7SJM4Y9AWfLq-tglWZh6yt7bEXEOJr_L-hV1A/viewform?formkey=dGx0b1ZrTnoyZDgtYXItMWVBdVlQQWc6MQ/viewform?embedded=true" width="640" height="1098" frameborder="0" marginheight="0" marginwidth="0">載入中…</iframe>
  late String _launchUrl;

  @override
  void initState() {
    RegExp urlRegExp = new RegExp(
      r'src="(.*)?embedded=true"',
      caseSensitive: false,
    );
    _launchUrl = urlRegExp.firstMatch(widget.embeddedCoede)!.group(1)!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      child: OutlinedButton(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 16.0),
            child: Text(
              '表單連結',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Color(0xff014DB8),
              ),
            ),
          ),
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(
              TextStyle(
                color: Color(0xff014DB8),
              ),
            ),
            side: MaterialStateProperty.all(
              BorderSide(
                color: Color(0xff014DB8),
              ),
            ),
          ),
          onPressed: () async {
            if (await canLaunch(_launchUrl)) {
              await launch(_launchUrl);
            } else {
              throw 'Could not launch $_launchUrl';
            }
          }),
    );
  }
}
