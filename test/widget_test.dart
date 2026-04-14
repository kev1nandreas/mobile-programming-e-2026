import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('renders firebase CRUD home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Firebase CRUD'), findsOneWidget);
    expect(find.text('Users'), findsOneWidget);
    expect(find.text('Posts'), findsOneWidget);
  });
}
