
import 'package:flutter_test/flutter_test.dart';
import 'package:closetly/main.dart';

void main() {
  testWidgets('Closetly app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ClosetlyApp());

    expect(find.text('CLOSETLY'), findsOneWidget);
    expect(find.text('Hello, fashion lover!'), findsOneWidget);
    expect(find.text('Explore your wardrobe'), findsOneWidget);
  });
}
