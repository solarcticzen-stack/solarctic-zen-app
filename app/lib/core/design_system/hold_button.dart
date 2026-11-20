import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'app_theme.dart';
import 'tokens.dart';

/// Button, der gedrückt gehalten werden muss («Halten zum Beenden»).
///
/// Verhindert versehentliches Beenden mit nassen oder kalten Fingern.
/// Ein Ring zeigt den Fortschritt; Loslassen vor Ablauf bricht ab.
class SzHoldButton extends StatefulWidget {
  const SzHoldButton({
    required this.label,
    required this.onConfirmed,
    this.holdDuration = const Duration(milliseconds: 1200),
    super.key,
  });

  final String label;
  final VoidCallback onConfirmed;
  final Duration holdDuration;

  @override
  State<SzHoldButton> createState() => _SzHoldButtonState();
}

class _SzHoldButtonState extends State<SzHoldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: widget.holdDuration,
  )..addStatusListener(_onStatus);

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      HapticFeedback.heavyImpact();
      _progress.value = 0;
      widget.onConfirmed();
    }
  }

  void _start() {
    HapticFeedback.selectionClick();
    _progress.forward();
  }

  void _cancel() {
    if (_progress.isAnimating) _progress.reverse();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    return Semantics(
      button: true,
      label: widget.label,
      hint: 'Gedrückt halten',
      onLongPress: widget.onConfirmed,
      child: GestureDetector(
        onTapDown: (_) => _start(),
        onTapUp: (_) => _cancel(),
        onTapCancel: _cancel,
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, _) => Container(
            constraints: const BoxConstraints(minHeight: SzTouch.session),
            padding: const EdgeInsets.symmetric(horizontal: SzSpacing.l),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SzRadius.full),
              color: p.bgElevated,
              border: Border.all(color: p.borderSubtle),
              gradient: LinearGradient(
                colors: [
                  p.accentIceDeep,
                  p.accentIceDeep,
                  p.bgElevated,
                  p.bgElevated,
                ],
                stops: [0, _progress.value, _progress.value, 1],
              ),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stop_rounded, color: p.textPrimary),
                const SizedBox(width: SzSpacing.s),
                // Zweizeilig und schrumpfbar: passt auch auf schmale Geräte
                // und bei grosser Systemschrift.
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style: TextStyle(
                            color: p.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'gedrückt halten',
                          style: TextStyle(
                            color: p.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
