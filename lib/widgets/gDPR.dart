import 'package:flutter/material.dart';
import 'package:tv/baseConfig.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:url_launcher/url_launcher.dart';

class GDPR extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      height: 350,
      child: ListView(
        children: [
          Container(
            height: 15,
            color: Color(0xff004DBC),
          ),
          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24,),
            child: Text(
              '隱私權保護政策之修正',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: themeColor,
              ),
            ),
          ),
          SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24,),
            child: Text(
              '本網站隱私權保護政策將因應需求隨時進行修正，修正後的條款將刊登於網站上。',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24,),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: themeColor,
                padding: const EdgeInsets.only(top: 12, bottom: 12,),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: Text(
                '同意',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SizedBox(height: 32),
          Center(
            child: InkWell(
              child: Text(
                '隱私政策',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: themeColor,
                ),
              ),
              onTap: () async{
                if (await canLaunch(baseConfig!.privacyPolicyUrl)) {
                  await launch(baseConfig!.privacyPolicyUrl);
                } else {
                  throw 'Could not launch ${baseConfig!.privacyPolicyUrl}';
                }
              }
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}