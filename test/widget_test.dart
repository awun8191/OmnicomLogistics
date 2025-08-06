// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logistics/app_main.dart';
import 'package:logistics/repository/dashboard_repository/dashboard_repo.dart';
import 'package:get/get.dart';
import 'package:logistics/core/services/firestore_service.dart';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late DashboardRepo dashboardRepo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    Get.put<FirebaseFirestore>(firestore);
    Get.put(FireStoreServices(firestore));
    dashboardRepo = DashboardRepo(Get.find());
    Get.put(dashboardRepo);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Dashboard Renders Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: AppMain()));

    // Wait for widgets to settle.
    await tester.pumpAndSettle();

    // Verify that the dashboard title is found.
    expect(find.text('Logistics Dashboard'), findsOneWidget);
  });

  testWidgets('Item filtering works correctly', (WidgetTester tester) async {
    // Add dummy data.
    final orderId = 'test-order';
    await firestore.collection('orders').doc(orderId).set({
      'orderNumber': '123',
      'orderStatus': 0,
      'orderDate': Timestamp.now(),
    });
    await firestore
        .collection('orders')
        .doc(orderId)
        .collection('items')
        .add({'itemNo': 'A', 'description': 'Item A', 'serialized': true, 'orderedNo': 1, 'uom': 'pcs'});
    await firestore
        .collection('orders')
        .doc(orderId)
        .collection('items')
        .add({'itemNo': 'B', 'description': 'Item B', 'serialized': false, 'orderedNo': 1, 'uom': 'pcs'});

    // Build our app and trigger a frame.
    await tester.pumpWidget(AppMain());
    await tester.pumpAndSettle();

    // Select the order.
    await dashboardRepo.loadOrderItems(orderId);
    await tester.pump();
    await tester.pump();
    await tester.pump();

    // Verify that both items are initially visible.
    expect(dashboardRepo.selectedOrderItems.length, 2);
    await tester.pumpAndSettle();
    expect(find.text('Item A'), findsOneWidget);
    expect(find.text('Item B'), findsOneWidget);
  });
}
