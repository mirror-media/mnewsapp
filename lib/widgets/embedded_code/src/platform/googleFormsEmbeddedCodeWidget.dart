import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class GoogleFormsEmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCode;
  const GoogleFormsEmbeddedCodeWidget({
    Key? key,
    required this.embeddedCode,
  }) : super(key: key);

  @override
  _GoogleFormsEmbeddedCodeWidgetState createState() =>
      _GoogleFormsEmbeddedCodeWidgetState();
}

class _GoogleFormsEmbeddedCodeWidgetState
    extends State<GoogleFormsEmbeddedCodeWidget> {
  // <iframe src="https://docs.google.com/forms/d/e/1FAIpQLSeI8_vYyaJgM7SJM4Y9AWfLq-tglWZh6yt7bEXEOJr_L-hV1A/viewform?formkey=dGx0b1ZrTnoyZDgtYXItMWVBdVlQQWc6MQ/viewform?embedded=true" width="640" height="1098" frameborder="0" marginheight="0" marginwidth="0">載入中…</iframe>
  late String _launchUrl;

  @override
  void initState() {
    RegExp urlRegExp = RegExp(
      r'src="(.*)?embedded=true"',
      caseSensitive: false,
    );
    _launchUrl = urlRegExp.firstMatch(widget.embeddedCode)!.group(1)!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    var outlinedButton = OutlinedButton(
        child: const Padding(
          padding: EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 16.0),
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
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              color: Color(0xff014DB8),
            ),
          ),
          side: WidgetStateProperty.all(
            const BorderSide(
              color: Color(0xff014DB8),
            ),
          ),
        ),
        onPressed: () async {
          if (await canLaunchUrlString(_launchUrl)) {
            await launchUrlString(_launchUrl);
          } else {
            throw 'Could not launch $_launchUrl';
          }
        });
    return SizedBox(
      width: width,
      child: outlinedButton,
    );
  }
}
