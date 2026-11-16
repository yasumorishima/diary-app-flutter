import 'package:material_ui/material_ui.dart';
import 'package:diary_app/l10n/app_localizations.dart';

/// アプリロック画面（生体認証 / 画面ロックで解除）
///
/// 表示された時点で自動的に認証を1回試み、失敗・キャンセル時は
/// ボタンから再試行できる。
class LockScreen extends StatefulWidget {
  /// 認証を実行するコールバック（localizedReason を渡す）
  final Future<void> Function(String reason) onUnlock;

  const LockScreen({super.key, required this.onUnlock});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  @override
  void initState() {
    super.initState();
    // 表示直後に自動で認証を試みる
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      if (l10n != null) {
        widget.onUnlock(l10n.appLockReason);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF2c3e50), const Color(0xFF34495e)]
                : [const Color(0xFF667eea), const Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 72, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    l10n.appLockReason,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => widget.onUnlock(l10n.appLockReason),
                    icon: const Icon(Icons.fingerprint),
                    label: Text(l10n.appLockUnlock),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor:
                          isDark ? const Color(0xFF2c3e50) : const Color(0xFF667eea),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
