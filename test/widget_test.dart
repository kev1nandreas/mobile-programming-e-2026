import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/app/app.dart';

void main() {
  testWidgets('shows the dashboard tiles', (WidgetTester tester) async {
    await tester.pumpWidget(const DeviceAccessApp(cameras: []));

    expect(find.text('Main Dashboard'), findsOneWidget);
    expect(find.text('GPS'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('File'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
  });
}
