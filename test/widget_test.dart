import 'package:flutter_test/flutter_test.dart';
import 'package:mu_study/screens/auth/setup_required_screen.dart';

void main() {
  testWidgets('Setup screen shows configuration hint', (tester) async {
    await tester.pumpWidget(const SetupRequiredScreen());
    expect(find.textContaining('Supabase is not configured'), findsOneWidget);
  });
}
