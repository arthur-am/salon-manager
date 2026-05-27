import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salon_manager_client/src/app/salon_app.dart';

void main() {
  testWidgets('renders the client shell', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SalonManagerClientApp()),
    );

    expect(find.text('SALON.OS'), findsOneWidget);
    expect(find.text('Saloes'), findsOneWidget);
    expect(find.text('Reservas'), findsOneWidget);
    expect(find.text('Sistema'), findsOneWidget);
  });
}
