import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:tv/controller/top_iframe_controller.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/top_iframe_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class TopIframeWidget extends StatelessWidget {
  const TopIframeWidget({super.key});

  static const double _sectionSpacing = 16;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TopIframeController());

    return Obx(() {
      final url = controller.currentUrl.value;
      if (!controller.isVisible.value || url == null) {
        return const SizedBox.shrink();
      }

      final contentWidth = controller.currentWidth.value;
      final contentHeight = controller.currentHeight.value;
      final instanceKey = controller.webViewKey.value;
      final isLoading = controller.isLoading.value;
      final hasError = controller.hasError.value;
      final errorMessage = controller.errorMessage.value;
      final title = controller.title.value;
      final showMoreUrl = controller.showMoreUrl.value;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                color: themeColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final width =
                  (contentWidth ?? availableWidth)
                      .clamp(0.0, availableWidth)
                      .toDouble();

              return Center(
                child: SizedBox(
                  width: width,
                  height: contentHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (!hasError)
                        Opacity(
                          opacity: isLoading ? 0 : 1,
                          child: ClipRect(
                            child: InAppWebView(
                              key: ValueKey(instanceKey),
                              initialUrlRequest: URLRequest(url: WebUri(url)),
                              initialOptions:
                                  TopIframeHelper.createWebViewSettings(),
                              onWebViewCreated: (webController) {
                                controller.onWebViewCreated(
                                  webController,
                                  instanceKey: instanceKey,
                                );
                              },
                              onLoadStart: (webController, url) {
                                controller.onLoadStart(
                                  webController: webController,
                                  instanceKey: instanceKey,
                                );
                              },
                              onLoadStop: (webController, url) async {
                                await controller.onLoadStop(
                                  webController: webController,
                                  instanceKey: instanceKey,
                                );
                              },
                              onLoadError: (webController, url, code, message) {
                                controller.onLoadError(
                                  message,
                                  webController: webController,
                                  instanceKey: instanceKey,
                                );
                              },
                              shouldOverrideUrlLoading:
                                  (webController, navigationAction) async =>
                                      NavigationActionPolicy.ALLOW,
                            ),
                          ),
                        ),
                      if (isLoading && !hasError)
                        const Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      if (hasError)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline, size: 32),
                                const SizedBox(height: 8),
                                const Text('載入失敗'),
                                if (errorMessage != null)
                                  Text(
                                    errorMessage,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: controller.manualRefresh,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('重試'),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (showMoreUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () => _launchUrl(showMoreUrl),
                child: const Text(
                  '查看更多',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
              ),
            ),
          const SizedBox(height: _sectionSpacing),
        ],
      );
    });
  }

  Future<void> _launchUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
