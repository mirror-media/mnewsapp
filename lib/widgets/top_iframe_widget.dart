import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tv/controller/top_iframe_controller.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/top_iframe_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class TopIframeWidget extends StatefulWidget {
  const TopIframeWidget({Key? key}) : super(key: key);

  @override
  State<TopIframeWidget> createState() => _TopIframeWidgetState();
}

class _TopIframeWidgetState extends State<TopIframeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _refreshAnimationController;
  late Animation<double> _refreshAnimation;

  @override
  void initState() {
    super.initState();
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _refreshAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _refreshAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _refreshAnimationController.dispose();
    super.dispose();
  }

  void _onRefreshTap(TopIframeController controller) {
    _refreshAnimationController.forward().then((_) {
      _refreshAnimationController.reset();
    });
    controller.manualRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final TopIframeController controller = Get.put(TopIframeController());

    return Obx(() {
      if (!controller.isVisible.value || controller.currentUrl.value == null) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          if (controller.title.value != null)
            Container(
              width: double.infinity,
              color: themeColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                controller.title.value!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      height: controller.currentHeight.value,
                      width: double.infinity,
                      margin: const EdgeInsets.all(20),
                      child: Stack(
                        children: [
                          if (controller.isLoading.value) ...[
                            _buildSkeletonLoading(),
                          ],

                          // Error State
                          if (controller.hasError.value) ...[
                            Container(
                              height: controller.currentHeight.value,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.grey[600], size: 32),
                                  const SizedBox(height: 8),
                                  Text(
                                    '載入失敗',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  if (controller.errorMessage.value != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        controller.errorMessage.value!,
                                        style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],

                          // WebView
                          if (!controller.hasError.value) ...[
                            AnimatedOpacity(
                              opacity: controller.isLoading.value ? 0 : 1,
                              duration: const Duration(milliseconds: 300),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: InAppWebView(
                                  key: ValueKey(controller.webViewKey.value),
                                  initialUrlRequest: URLRequest(
                                    url:
                                        Uri.parse(controller.currentUrl.value!),
                                  ),
                                  initialOptions:
                                      TopIframeHelper.createWebViewSettings(),
                                  onWebViewCreated: (webController) {
                                    controller.onWebViewCreated(webController);
                                  },
                                  onLoadStart: (webController, url) {
                                    controller.onLoadStart();
                                  },
                                  onLoadStop: (webController, url) async {
                                    await controller.onLoadStop();

                                    // 互動修正
                                    webController.evaluateJavascript(source: '''
                                      document.body.style.pointerEvents = 'auto';
                                      document.body.style.touchAction = 'auto';
                                      document.body.style.userSelect = 'none';
                                      document.body.style.webkitUserSelect = 'none';
                                      document.body.style.webkitTouchCallout = 'none';
                                      var clickableElements = document.querySelectorAll('a, button, [onclick], [role="button"]');
                                      clickableElements.forEach(function(element) {
                                        element.style.pointerEvents = 'auto';
                                        element.style.touchAction = 'auto';
                                      });
                                    ''');
                                  },
                                  onLoadError:
                                      (webController, url, code, message) {
                                    controller.onLoadError(message);
                                  },
                                  shouldOverrideUrlLoading:
                                      (webController, navigationAction) async {
                                    return NavigationActionPolicy.ALLOW;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (controller.showMoreUrl.value != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () =>
                              _launchUrl(controller.showMoreUrl.value!),
                          child: const Text(
                            '查看更多',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                              decoration: TextDecoration.underline,
                              decorationColor: themeColor,
                              decorationThickness: 2.0,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                bottom: 24,
                right: 24,
                child: GestureDetector(
                  onTap: () {
                    _onRefreshTap(controller);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: RotationTransition(
                      turns: _refreshAnimation,
                      child: Icon(
                        Icons.refresh_rounded,
                        color: themeColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildSkeletonLoading() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 20,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 14,
            width: double.infinity * 0.6,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('Could not launch $url');
    }
  }
}
