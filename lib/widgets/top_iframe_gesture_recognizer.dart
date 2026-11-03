import 'package:flutter/gestures.dart';

/// Lets an open HTML dropdown receive vertical drags ahead of the homepage.
class TopIframeVerticalDragGestureRecognizer
    extends VerticalDragGestureRecognizer {
  TopIframeVerticalDragGestureRecognizer({required this.isDropdownOpen});

  final bool Function() isDropdownOpen;

  @override
  bool isPointerAllowed(PointerEvent event) {
    // Decide once at pointer-down. Keeping the recognizer installed avoids
    // rejecting an active gesture when JavaScript opens or closes the menu.
    return isDropdownOpen() && super.isPointerAllowed(event);
  }
}
