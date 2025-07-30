import 'package:get/get.dart';
import 'package:wordle/controller/wordle_controller.dart';
import 'package:wordle/routes/app_routes.dart';
import 'package:wordle/views/wordle_view.dart';

class AppPages {
  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.WORDLE,
      page: () => WordleView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<WordleController>(() => WordleController());
      }),
    ),
  ];
}
