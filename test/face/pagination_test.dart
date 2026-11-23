import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:casa_pointage/app/data/models/team_page.dart';
import 'package:casa_pointage/core/widgets/pagination_bar.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

Widget _bar(PageInfo info, ValueChanged<int> onPage) => ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, _) => MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: PaginationBar(info: info, onPage: onPage)),
      ),
    );

void main() {
  test('page info gives the range shown', () {
    const info = PageInfo(page: 3, pageSize: 10, total: 25, totalPages: 3);
    expect(info.firstItem, 21);
    expect(info.lastItem, 25);
    expect(const PageInfo().firstItem, 0);
  });

  testWidgets('one page shows nothing', (tester) async {
    await tester.pumpWidget(
      _bar(const PageInfo(page: 1, pageSize: 10, total: 4), (_) {}),
    );
    expect(find.text('1'), findsNothing);
  });

  testWidgets('numbered pages, gap and taps', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      _bar(
        const PageInfo(page: 5, pageSize: 10, total: 200, totalPages: 20),
        (p) => tapped = p,
      ),
    );
    for (final n in ['1', '4', '5', '6', '20']) {
      expect(find.text(n), findsOneWidget, reason: 'page $n');
    }
    expect(find.text('…'), findsNWidgets(2));
    expect(find.text('41–50 sur 200'), findsOneWidget);

    await tester.tap(find.text('6'));
    expect(tapped, 6);
  });
}
