import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tv/bindings/news_category_binding.dart';
import 'package:tv/blocs/election/election_cubit.dart';
import 'package:tv/controller/news_category_controller.dart';
import 'package:tv/pages/section/news/newsCategoryTab.dart';
import 'package:tv/services/electionService.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  void initState() {
    super.initState();
    NewsCategoryBinding().dependencies();
  }

  @override
  void dispose() {
    if (Get.isRegistered<NewsCategoryController>()) {
      Get.delete<NewsCategoryController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ElectionCubit(
        repos: ElectionService(),
      ),
      child: const NewsCategoryTab(),
    );
  }
}
