import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mu_study/components/layouts/app_shell.dart';
import 'package:mu_study/l10n/app_localizations.dart';
import 'package:mu_study/models/models.dart';
import 'package:mu_study/providers/notifications/notification_providers.dart';

const List<ShellDestination> _destinations = [
  ShellDestination(
    labelKey: 'navDashboard',
    icon: Icons.dashboard_outlined,
    path: '/dashboard',
  ),
  ShellDestination(
    labelKey: 'navMarks',
    icon: Icons.grade_outlined,
    path: '/marks',
  ),
  ShellDestination(
    labelKey: 'navProfile',
    icon: Icons.person_outline,
    path: '/profile',
  ),
];

/// Stands in for the screens inside the shell: its own [Scaffold] with a
/// floating action button, exactly as the teacher and admin screens are built.
class _ShellScreen extends StatelessWidget {
  const _ShellScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen')),
      floatingActionButtonLocation: shellFabLocation(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          bottom: shellContentBottomPadding(context, hasFab: true),
        ),
        children: [
          for (var i = 0; i < 30; i++)
            ListTile(key: ValueKey('row-$i'), title: Text('Row $i')),
        ],
      ),
    );
  }
}

Widget _app() {
  final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (_, _, child) => AppShell(
          role: UserRole.student,
          destinations: _destinations,
          child: child,
        ),
        routes: [
          for (final ShellDestination d in _destinations)
            GoRoute(path: d.path, builder: (_, _) => const _ShellScreen()),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [unreadNotificationsCountProvider.overrideWithValue(0)],
    child: MaterialApp.router(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    ),
  );
}

/// Configures the test view as a device of [size] logical pixels with the
/// given safe area and keyboard insets.
void _useDevice(
  WidgetTester tester, {
  required Size size,
  double bottom = 0,
  double left = 0,
  double right = 0,
  double keyboard = 0,
}) {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size
    ..viewPadding = FakeViewPadding(bottom: bottom, left: left, right: right)
    ..padding = FakeViewPadding(
      bottom: keyboard > 0 ? 0 : bottom,
      left: left,
      right: right,
    )
    ..viewInsets = FakeViewPadding(bottom: keyboard);
  addTearDown(tester.view.reset);
}

Rect _navBar(WidgetTester tester) =>
    tester.getRect(find.byKey(ShellNavBar.pillKey));

Rect _fab(WidgetTester tester) =>
    tester.getRect(find.byType(FloatingActionButton));

void main() {
  group('mobile shell', () {
    testWidgets('FAB floats clear of the nav bar on a home indicator device', (
      tester,
    ) async {
      const Size size = Size(393, 852); // iPhone 16 Pro
      _useDevice(tester, size: size, bottom: 34);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final Rect navBar = _navBar(tester);
      final Rect fab = _fab(tester);

      expect(fab.bottom, moreOrLessEquals(navBar.top - kShellFabGap));
      expect(fab.right, lessThanOrEqualTo(size.width - 16));
      // The pill stops at the home indicator instead of sitting inside it.
      expect(navBar.bottom, moreOrLessEquals(size.height - 34));
      expect(navBar.left, moreOrLessEquals(kShellNavBarSideMargin));
    });

    testWidgets('reserved inset matches the space the nav bar really takes', (
      tester,
    ) async {
      const Size size = Size(393, 852);
      _useDevice(tester, size: size, bottom: 34);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(_ShellScreen));
      expect(
        shellBottomInset(context),
        moreOrLessEquals(size.height - _navBar(tester).top),
      );
    });

    testWidgets('nav bar keeps a gap from the edge without a home indicator', (
      tester,
    ) async {
      const Size size = Size(360, 640); // small Android phone, button nav
      _useDevice(tester, size: size);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final Rect navBar = _navBar(tester);
      expect(navBar.bottom, moreOrLessEquals(size.height - 16));
      expect(_fab(tester).bottom, moreOrLessEquals(navBar.top - kShellFabGap));
    });

    testWidgets('nav bar grows with an Android gesture inset', (tester) async {
      const Size size = Size(412, 915);
      _useDevice(tester, size: size, bottom: 24);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final Rect navBar = _navBar(tester);
      expect(navBar.height, moreOrLessEquals(kShellNavBarHeight));
      expect(navBar.bottom, moreOrLessEquals(size.height - 24));
      expect(_fab(tester).bottom, moreOrLessEquals(navBar.top - kShellFabGap));
    });

    testWidgets('icons stay vertically centred in the pill', (tester) async {
      _useDevice(tester, size: const Size(393, 852), bottom: 34);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final Rect navBar = _navBar(tester);
      final Finder icons = find.descendant(
        of: find.byKey(ShellNavBar.pillKey),
        matching: find.byType(Icon),
      );
      expect(icons, findsNWidgets(_destinations.length));

      for (final Element icon in icons.evaluate()) {
        expect(
          tester.getRect(find.byWidget(icon.widget)).center.dy,
          moreOrLessEquals(navBar.center.dy, epsilon: 0.5),
        );
      }
    });

    testWidgets('scrolled content stops above the FAB', (tester) async {
      _useDevice(tester, size: const Size(393, 852), bottom: 34);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();

      expect(
        tester.getRect(find.byKey(const ValueKey('row-29'))).bottom,
        lessThanOrEqualTo(_fab(tester).top),
      );
    });

    testWidgets('FAB rides above the keyboard and the bar stays put', (
      tester,
    ) async {
      const Size size = Size(393, 852);
      _useDevice(tester, size: size, bottom: 34);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final Rect restingBar = _navBar(tester);
      final Rect restingFab = _fab(tester);

      // A keyboard shorter than the space under the button leaves it alone.
      _useDevice(tester, size: size, bottom: 34, keyboard: 60);
      await tester.pumpAndSettle();
      expect(_fab(tester), restingFab);

      _useDevice(tester, size: size, bottom: 34, keyboard: 336);
      await tester.pumpAndSettle();
      expect(
        _fab(tester).bottom,
        moreOrLessEquals(size.height - 336 - kFloatingActionButtonMargin),
      );
      // The bar is covered by the keyboard, not pushed around by it.
      expect(_navBar(tester), restingBar);
    });
  });

  group('rail shell', () {
    testWidgets('tablets drop the nav bar but keep the FAB in the safe area', (
      tester,
    ) async {
      const Size size = Size(834, 1194); // iPad Air
      _useDevice(tester, size: size, bottom: 20);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.byKey(ShellNavBar.pillKey), findsNothing);
      expect(
        _fab(tester).bottom,
        moreOrLessEquals(size.height - 20 - kShellFabGap),
      );
    });

    testWidgets('FAB stays on screen in landscape', (tester) async {
      const Size size = Size(852, 393); // iPhone 16 Pro, landscape
      _useDevice(tester, size: size, bottom: 21, left: 47, right: 47);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final Rect fab = _fab(tester);
      expect(fab.bottom, lessThanOrEqualTo(size.height - 21));
      expect(fab.right, lessThanOrEqualTo(size.width - 47));
      expect(fab.top, greaterThan(0));
    });
  });
}
