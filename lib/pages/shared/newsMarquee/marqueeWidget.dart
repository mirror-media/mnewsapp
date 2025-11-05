import 'package:flutter/material.dart';

class MarqueeWidget extends StatefulWidget {
  final Widget child;
  final Axis direction;
  final Duration animationDuration;
  final Duration backDuration;
  final Duration pauseDuration;

  const MarqueeWidget({
    super.key,
    required this.child,
    this.direction = Axis.horizontal,
    this.animationDuration = const Duration(milliseconds: 10000),
    this.backDuration = const Duration(milliseconds: 800),
    this.pauseDuration = const Duration(milliseconds: 800),
  });

  @override
  State<MarqueeWidget> createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scroll();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: widget.child,
      scrollDirection: widget.direction,
      controller: _scrollController,
    );
  }

  Future<void> _scroll() async {
    await Future.delayed(widget.pauseDuration);
    if (!mounted) return;

    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: widget.animationDuration,
        curve: Curves.easeIn,
      );
    }
  }
}
