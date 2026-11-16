import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

/// 空欄の入力欄が、読み上げへ名前を渡しているかを固定する。
///
/// 実機の監査（`scripts/a11y_device_audit.py`）は `uiautomator dump` で
/// アクセシビリティノードツリーを取るが、**dump の XML は `hintText` を出さない**。
/// そのため空欄の入力欄は content-desc も text も空に見え、実機側では
/// 「判定保留」にするしかない。ここで Flutter が何を渡しているかを決める。
///
/// このアプリの入力欄は 3 つ（書くの本文・タグ、さがすのキーワード / タグ）で、
/// どれも `labelText` を持たず `hintText` だけを指定している（見た目の都合）。
/// その形のまま読み上げに名前が渡ることを、ここで担保する。
const bodyHint = 'きょうは どんな 日でしたか？';
const tagHint = 'タグ（カンマ区切り）';
const tagHelper = 'あとで さがしやすく なります';

void main() {
  testWidgets('hintText だけの入力欄でも 読み上げへ名前が渡る', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: TextField(decoration: InputDecoration(hintText: bodyHint)),
      ),
    ));

    final node = tester.getSemantics(find.byType(EditableText));
    debugPrint('入力欄が読み上げへ渡している中身: '
        'label="${node.label}" hint="${node.hint}" value="${node.value}"');
    expect(
      node.hint.isNotEmpty || node.label.isNotEmpty,
      isTrue,
      reason: '空欄の入力欄が読み上げへ何も渡していない: $node',
    );
    handle.dispose();
  });

  testWidgets('icon と helperText を足しても 名前は消えない', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: TextField(
          decoration: InputDecoration(
            icon: Text('🏷️'),
            hintText: tagHint,
            helperText: tagHelper,
          ),
        ),
      ),
    ));

    final node = tester.getSemantics(find.byType(EditableText));
    expect(
      node.hint.isNotEmpty || node.label.isNotEmpty,
      isTrue,
      reason: '空欄の入力欄が読み上げへ何も渡していない: $node',
    );
    handle.dispose();
  });
}
