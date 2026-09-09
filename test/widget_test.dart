import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dental_record_ocr/presentation/widgets/odontogram_widget.dart';
import 'package:dental_record_ocr/presentation/widgets/category_card.dart';
import 'package:dental_record_ocr/models/tooth_procedure.dart';

void main() {
  testWidgets('OdontogramWidget renders teeth numbers correctly', (WidgetTester tester) async {
    final procedures = [
      ToothProcedure(toothNumber: '46', procedureName: 'RCT', estimatedCost: 450.0),
      ToothProcedure(toothNumber: '23', procedureName: 'Scaling', estimatedCost: 180.0),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OdontogramWidget(procedures: procedures),
        ),
      ),
    );

    expect(find.text('Interactive Odontogram'), findsOneWidget);
    expect(find.text('46'), findsOneWidget);
    expect(find.text('23'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
  });

  testWidgets('CategoryCard renders title and warning state', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryCard(
            title: 'Test Category',
            icon: Icons.favorite,
            hasWarning: true,
            warningMessage: 'Attention Needed',
            child: const Text('Child Content'),
          ),
        ),
      ),
    );

    expect(find.text('Test Category'), findsOneWidget);
    expect(find.text('Attention Needed'), findsOneWidget);
    expect(find.text('Child Content'), findsOneWidget);
  });
}
