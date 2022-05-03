import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/downloadFile.dart';
import 'package:url_launcher/url_launcher.dart';

class FileDownloadWidget extends StatelessWidget {
  final double textSize;
  final List<DownloadFile> downloadFileList;
  const FileDownloadWidget(
    this.downloadFileList, {
    Key? key,
    this.textSize = 17,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(67.5, 32, 67.5, 24),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Center(
              child: Text(
                '相關文件下載',
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(0, 77, 188, 1),
                ),
              ),
            );
          }
          return InkWell(
            onTap: () async {
              Uri? uri = Uri.tryParse(downloadFileList[index - 1].url);
              if (uri != null) {
                await launchUrl(
                  uri,
                  mode: Platform.isIOS
                      ? LaunchMode.platformDefault
                      : LaunchMode.externalApplication,
                );
              }
            },
            child: Card(
              elevation: 5,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 21, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        downloadFileList[index - 1].title,
                        style: TextStyle(
                          fontSize: textSize - 1,
                          fontWeight: FontWeight.w300,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    SvgPicture.asset(downloadSvg)
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(
          height: 24,
        ),
        itemCount: downloadFileList.length + 1,
      ),
    );
  }
}
