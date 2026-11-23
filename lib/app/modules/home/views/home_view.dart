import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:casa_pointage/app/modules/enrolment/views/enrolment_view.dart';
import 'package:casa_pointage/app/modules/history/views/history_view.dart';
import 'package:casa_pointage/app/modules/profile/views/profile_view.dart';
import 'package:casa_pointage/app/modules/team/views/team_view.dart';
import 'package:casa_pointage/app/data/repo/face_recognizer.dart';
import 'package:casa_pointage/app/routes/app_pages.dart';

import '../controllers/home_controller.dart';
import '../widgets/app_tab_bar.dart';

/// Shell of the signed-in app: the four tabs and the bottom bar.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tab = controller.tab.value;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        // The team tab starts with a dark green header.
        value: tab == HomeTab.team
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: IndexedStack(
                  index: tab.index,
                  children: const [
                    TeamView(),
                    EnrolmentView(),
                    HistoryView(),
                    ProfileView(),
                  ],
                ),
              ),
              // Hidden while the keyboard is open (e.g. when searching).
              if (MediaQuery.viewInsetsOf(context).bottom == 0)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AppTabBar(
                    selected: tab,
                    onSelect: controller.selectTab,
                    onClockIn: () =>
                        Get.toNamed(Routes.SCAN, arguments: ScanMode.team),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
