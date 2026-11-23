import 'package:get/get.dart';

enum HomeTab { team, enrolment, history, profile }

/// Holds the selected tab of the main navigation.
class HomeController extends GetxController {
  final tab = HomeTab.team.obs;

  void selectTab(HomeTab value) => tab.value = value;
}
