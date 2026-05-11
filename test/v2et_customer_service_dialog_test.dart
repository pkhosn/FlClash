import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_clash/provider_client/pages/dashboard/customer_service_dialog.dart';

void main() {
  test('supported support uri validation', () {
    expect(isSupportedSupportUri(Uri.tryParse('https://example.com')), isTrue);
    expect(isSupportedSupportUri(Uri.tryParse('http://example.com')), isTrue);
    expect(isSupportedSupportUri(Uri.tryParse('ftp://example.com')), isFalse);
    expect(isSupportedSupportUri(Uri.tryParse('example.com')), isFalse);
    expect(isSupportedSupportUri(null), isFalse);
  });

  testWidgets('customer service dialog renders fallback when config empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: V2ETCustomerServiceDialog(crispWebsiteId: '', supportUrl: ''),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('暂无客服信息'), findsOneWidget);
  });
}
