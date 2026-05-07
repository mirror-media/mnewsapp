import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tv/bindings/tag_binding.dart';
import 'package:tv/controller/tag_controller.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/tag.dart';
import 'package:tv/pages/tag/tag_widget.dart';

class TagPage extends StatefulWidget {
  final Tag tag;
  const TagPage({
    required this.tag,
  });

  @override
  _TagPageState createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  late Tag _tag;
  late final String _tagControllerTag;

  @override
  void initState() {
    _tag = widget.tag;
    _tagControllerTag = _tag.slug;
    final binding = TagBinding();
    binding.dependencies();
    binding.bindTagController(_tagControllerTag);
    super.initState();
  }

  @override
  void dispose() {
    if (Get.isRegistered<TagController>(tag: _tagControllerTag)) {
      Get.delete<TagController>(tag: _tagControllerTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: TagWidget(_tag),
      ),
    );
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
        onPressed: Get.back,
      ),
      backgroundColor: appBarColor,
      centerTitle: true,
      title: Text(
        _tag.name,
        style: const TextStyle(color: Colors.white, fontSize: 17),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
