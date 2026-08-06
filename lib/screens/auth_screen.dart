import 'package:flutter/material.dart';
import '../auth.dart';
import '../models/order.dart';
import '../theme.dart';
import '../widgets/brand_mark.dart';

class AuthScreen extends StatefulWidget {
  /// Lets the shopper look around before committing to an account, the way
  /// the big grocery apps do. Null when sign-in is mandatory (at checkout).
  final VoidCallback? onBrowseAsGuest;

  const AuthScreen({super.key, this.onBrowseAsGuest});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignUp = false;
  bool _busy = false;
  String? _error;
  String? _notice;

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      await action();
      if (!mounted) return;
      setState(() => _busy = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = _friendlyError(e);
      });
    }
  }

  String _friendlyError(Object e) {
    final raw = e.toString();
    if (raw.contains('Invalid login credentials')) {
      return 'That email and password do not match an account.';
    }
    if (raw.contains('already registered') ||
        raw.contains('User already registered')) {
      return 'An account already exists for this email. Try signing in.';
    }
    if (raw.contains('Password should be')) {
      return 'Password must be at least 6 characters.';
    }
    if (raw.contains('email_address_invalid')) {
      return 'That email address was rejected. Use a real address such as '
          'name@gmail.com.';
    }
    if (raw.contains('over_email_send_rate_limit') ||
        raw.contains('rate limit')) {
      return 'Too many attempts just now. Wait a minute and try again.';
    }
    if (raw.contains('provider is not enabled') ||
        raw.contains('Unsupported provider') ||
        raw.contains('validation_failed')) {
      return 'That sign-in method is not switched on for this app yet.';
    }
    // Fall back to the server's own sentence rather than the whole wrapped
    // exception, which is unreadable in a form.
    final message = RegExp(r'message:\s*(.+?),\s*statusCode:').firstMatch(raw);
    if (message != null) return message.group(1)!;
    return raw.replaceFirst(RegExp(r'^\w+Exception:?\s*'), '');
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (_isSignUp && _name.text.trim().isEmpty) {
      setState(() => _error = 'Enter your name.');
      return;
    }
    if (_isSignUp && _phone.text.replaceAll(RegExp(r'\D'), '').length < 10) {
      setState(() => _error = 'Enter a valid 10-digit phone number.');
      return;
    }

    await _run(() async {
      if (_isSignUp) {
        await auth.signUp(
          email: email,
          password: password,
          fullName: _name.text.trim(),
          phone: _phone.text.trim(),
        );
        if (!auth.isSignedIn && mounted) {
          setState(() => _notice =
              'Account created. Check your inbox to confirm the email, then sign in.');
        }
      } else {
        await auth.signIn(email: email, password: password);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [kNavyDeep, kNavy, kNavyLight],
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        const BrandMark(height: 44, color: kCream),
                        const SizedBox(height: 12),
                        const Text(
                          'Namma MahaRaja',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Groceries from $kStoreArea in minutes',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: kCream.withValues(alpha: .75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: c.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _ModeTab(
                          label: 'Sign in',
                          selected: !_isSignUp,
                          onTap: () => setState(() {
                            _isSignUp = false;
                            _error = null;
                            _notice = null;
                          }),
                        ),
                        _ModeTab(
                          label: 'Create account',
                          selected: _isSignUp,
                          onTap: () => setState(() {
                            _isSignUp = true;
                            _error = null;
                            _notice = null;
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isSignUp) ...[
                    _AuthField(
                      label: 'Full name',
                      controller: _name,
                      icon: Icons.person_outline,
                    ),
                    _AuthField(
                      label: 'Phone number',
                      controller: _phone,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                  _AuthField(
                    label: 'Email',
                    controller: _email,
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _AuthField(
                    label: 'Password',
                    controller: _password,
                    icon: Icons.lock_outline,
                    obscure: true,
                    onSubmitted: (_) => _submit(),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, size: 15, color: c.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _error!,
                              style:
                                  TextStyle(fontSize: 12, color: c.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_notice != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: c.greenBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _notice!,
                          style: TextStyle(fontSize: 12, color: c.green),
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: _busy ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: c.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              _isSignUp ? 'Create account' : 'Sign in',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: Divider(color: c.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or continue with',
                          style: TextStyle(fontSize: 11.5, color: c.t2),
                        ),
                      ),
                      Expanded(child: Divider(color: c.border)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          label: 'Google',
                          logo: const _GoogleLogo(),
                          onTap: _busy
                              ? null
                              : () => _run(auth.signInWithGoogle),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SocialButton(
                          label: 'Apple',
                          logo: Icon(Icons.apple, size: 21, color: c.t0),
                          onTap:
                              _busy ? null : () => _run(auth.signInWithApple),
                        ),
                      ),
                    ],
                  ),
                  if (widget.onBrowseAsGuest != null) ...[
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: widget.onBrowseAsGuest,
                      child: Text(
                        'Browse without signing in',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: c.t1,
                        ),
                      ),
                    ),
                    Text(
                      'You will need an account to place an order.',
                      style: TextStyle(fontSize: 11, color: c.t3),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? c.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? c.t0 : c.t2,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;

  const _AuthField({
    required this.label,
    required this.controller,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
        style: const TextStyle(fontSize: 13.5),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 19, color: c.t2),
          filled: true,
          fillColor: c.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: c.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: c.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: c.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget logo;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.label,
    required this.logo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: c.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            logo,
            const SizedBox(width: 9),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: c.t0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Google's four-colour G, drawn rather than fetched so it works offline and
/// inside the artifact CSP.
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 19,
      height: 19,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final stroke = size.width * .22;
    final inner = rect.deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    void arc(double startDeg, double sweepDeg, Color color) {
      paint.color = color;
      canvas.drawArc(
        inner,
        startDeg * 3.1415926535 / 180,
        sweepDeg * 3.1415926535 / 180,
        false,
        paint,
      );
    }

    arc(-25, -128, const Color(0xFF4285F4)); // blue
    arc(-153, -75, const Color(0xFFFBBC05)); // yellow
    arc(132, -75, const Color(0xFF34A853)); // green
    arc(57, -82, const Color(0xFFEA4335)); // red

    // The blue crossbar into the centre.
    final bar = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(size.width * .5, size.height * .39, size.width * .5,
          size.height * .22),
      bar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
