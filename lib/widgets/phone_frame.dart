import 'package:flutter/material.dart';
import '../theme.dart';

const double kPhoneWidth = 393;
const double kPhoneHeight = 852;

/// On a desktop browser the app sits inside an iPhone shell so the client
/// sees it as a phone app; on an actual phone it goes edge to edge.
class PhoneFrame extends StatelessWidget {
  final Widget child;

  const PhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final framed = size.width >= 520 && size.height >= 720;
    if (!framed) return child;

    final c = context.c;
    final scale = ((size.height - 48) / kPhoneHeight).clamp(0.0, 1.0);

    return ColoredBox(
      color: c.bg,
      child: Center(
        child: Transform.scale(
          scale: scale,
          child: Container(
            width: kPhoneWidth,
            height: kPhoneHeight,
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(54),
              border: Border.all(color: const Color(0xFF111111), width: 11),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .28),
                  blurRadius: 100,
                  offset: const Offset(0, 40),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          width: 126,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(22),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(26, 14, 26, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '9:41',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: c.t0,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.signal_cellular_alt,
                                    size: 14, color: c.t0),
                                const SizedBox(width: 4),
                                Icon(Icons.wifi, size: 14, color: c.t0),
                                const SizedBox(width: 4),
                                Icon(Icons.battery_full,
                                    size: 15, color: c.t0),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    removeBottom: true,
                    child: child,
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
