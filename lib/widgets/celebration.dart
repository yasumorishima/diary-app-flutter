import 'dart:async';
import 'dart:math';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart';
import '../utils/theme.dart';

/// 保存後のお祝いオーバーレイを表示し、約1.8秒後に自動で閉じる。
/// 完了する Future を返すので、呼び出し側は await してから pop できる。
Future<void> showCelebration(
  BuildContext context, {
  required String title,
  required String streakLine,
  String? stampLine,
}) {
  final overlay = Overlay.of(context);
  final completer = Completer<void>();
  final spoken = <String>[title, streakLine];
  if (stampLine != null) spoken.add(stampLine);
  final message = spoken.join(' ');
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _CelebrationView(
      title: title,
      streakLine: streakLine,
      stampLine: stampLine,
      message: message,
      onDone: () {
        if (entry.mounted) entry.remove();
        if (!completer.isCompleted) completer.complete();
      },
    ),
  );
  overlay.insert(entry);

  // お祝いは 1.8 秒で消えるので、読み上げには自分から知らせる。
  // 主役はカード側の liveRegion（Android は announceForAccessibility を
  // 非推奨にしており、TalkBack は明示の読み上げを無視することがある）。
  // 明示の読み上げに対応している OS（iOS 等）へだけ、あわせて送る。
  if (MediaQuery.supportsAnnounceOf(context)) {
    SemanticsService.sendAnnouncement(
        View.of(context), message, Directionality.of(context));
  }

  return completer.future;
}

class _CelebrationView extends StatefulWidget {
  final String title;
  final String streakLine;
  final String? stampLine;

  /// 読み上げに渡す 1 文（見出し・連続日数・スタンプをつないだもの）
  final String message;
  final VoidCallback onDone;

  const _CelebrationView({
    required this.title,
    required this.streakLine,
    required this.stampLine,
    required this.message,
    required this.onDone,
  });

  @override
  State<_CelebrationView> createState() => _CelebrationViewState();
}

class _CelebrationViewState extends State<_CelebrationView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Piece> _pieces;

  static const _confettiEmojis = ['🎈', '⭐', '🌈', '🍰', '🎉', '🎊', '✨', '🎁'];

  @override
  void initState() {
    super.initState();
    final rnd = Random();
    _pieces = List.generate(18, (i) {
      return _Piece(
        x: rnd.nextDouble(),
        emoji: _confettiEmojis[rnd.nextInt(_confettiEmojis.length)],
        delay: rnd.nextDouble() * 0.35,
        drift: (rnd.nextDouble() - 0.5) * 0.25,
        size: 20 + rnd.nextDouble() * 18,
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.25),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            return Stack(
              children: [
                for (final p in _pieces) _buildPiece(p, t, size),
                Center(
                  child: Transform.scale(
                    scale: Curves.elasticOut.transform(
                      (t / 0.4).clamp(0.0, 1.0),
                    ),
                    child: child,
                  ),
                ),
              ],
            );
          },
          // liveRegion ＝「出たら読む」印。見出し・連続日数・スタンプを
          // 1 文にまとめて渡す（中の Text は読ませない）
          child: Semantics(
            liveRegion: true,
            label: widget.message,
            excludeSemantics: true,
            child: _buildCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildPiece(_Piece p, double t, Size size) {
    final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
    final top = -60.0 + local * (size.height + 80);
    final left = (p.x + p.drift * local) * size.width;
    final opacity = local < 0.85 ? 1.0 : (1 - (local - 0.85) / 0.15);
    return Positioned(
      top: top,
      left: left,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: local * 6.28 * 2,
          child: ExcludeSemantics(
            child: Text(p.emoji, style: TextStyle(fontSize: p.size)),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.popYellow, width: 3),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0xFFFFE6A3), offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ExcludeSemantics(
              child: Text('🎉🎊✨', style: TextStyle(fontSize: 40))),
          const SizedBox(height: 8),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.popPinkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.streakLine,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightSubText,
            ),
          ),
          if (widget.stampLine != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.stampLine!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppTheme.popGrape,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Piece {
  final double x;
  final String emoji;
  final double delay;
  final double drift;
  final double size;
  const _Piece({
    required this.x,
    required this.emoji,
    required this.delay,
    required this.drift,
    required this.size,
  });
}
