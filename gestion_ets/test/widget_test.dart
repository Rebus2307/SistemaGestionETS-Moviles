import 'package:flutter_test/flutter_test.dart';

import 'package:gestion_ets/main.dart'; // Asegúrate de que el nombre del paquete coincida

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Aquí mandamos a llamar a nuestra clase real
    await tester.pumpWidget(const GestionEtsApp());

    // Como borramos el contador por defecto de Flutter,
    // podemos simplemente verificar que nuestra app carga el texto inicial.
    expect(find.text('Sistema de Gestión de ETS - ESCOM'), findsOneWidget);
  });
}
