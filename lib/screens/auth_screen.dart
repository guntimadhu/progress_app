import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignIn = true;
  bool _loading = false;
  String _fbStatus = '⏳ Connecting to Firebase…';
  String _error = '';
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkFirebase();
  }

  Future<void> _checkFirebase() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      FirebaseAuth.instance.authStateChanges().first.timeout(
        const Duration(seconds: 8),
        onTimeout: () => null,
      );
      if (mounted) {
        setState(
            () => _fbStatus = '✅ Firebase connected — ready to sign in');
      }
    } catch (e) {
      if (mounted) {
        setState(() =>
            _fbStatus = '❌ Firebase unavailable — open in a real device');
      }
    }
    // Auto-timeout message
    await Future.delayed(const Duration(seconds: 10));
    if (mounted && _fbStatus.startsWith('⏳')) {
      setState(
          () => _fbStatus = '❌ Firebase timed out — open in Chrome/device');
    }
  }

  void _go(User user) {
    context.read<AppProvider>().setUser(
          email: user.email ?? '',
          name: user.displayName ?? '',
          guest: false,
        );
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()));
  }

  void _skip() {
    context.read<AppProvider>().setUser(
        email: 'guest@progress.app', name: '', guest: true);
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()));
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final user = await AuthService.signInWithGoogle();
      if (user != null && mounted) _go(user);
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = AuthService.friendlyError(e.code));
    } catch (e) {
      if (mounted) setState(() => _error = 'Sign-in failed. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _emailAuth() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Enter email and password.');
      return;
    }
    if (!_isSignIn) {
      if (pass.length < 6) {
        setState(() => _error = 'Password must be at least 6 characters.');
        return;
      }
      if (pass != confirm) {
        setState(() => _error = 'Passwords do not match.');
        return;
      }
    }
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final user = _isSignIn
          ? await AuthService.signInWithEmail(email, pass)
          : await AuthService.signUpWithEmail(email, pass);
      if (user != null && mounted) _go(user);
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = AuthService.friendlyError(e.code));
    } catch (e) {
      if (mounted) setState(() => _error = 'Sign-in failed. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Brand
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'PROgress',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text('⬆️', style: TextStyle(fontSize: 26)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Level up everyday',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 28),

                  // Google Button
                  _AuthButton(
                    onTap: _loading ? null : _googleSignIn,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        _GoogleIcon(),
                        SizedBox(width: 8),
                        Text(
                          'Continue with Google',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.25))),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('or',
                            style: TextStyle(
                                color: Colors.white60, fontSize: 13)),
                      ),
                      Expanded(
                          child: Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.25))),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4), width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _Tab(
                            label: 'Sign In',
                            active: _isSignIn,
                            onTap: () => setState(() => _isSignIn = true)),
                        _Tab(
                            label: 'Sign Up',
                            active: !_isSignIn,
                            onTap: () => setState(() => _isSignIn = false)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Error
                  if (_error.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.25),
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_error,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13)),
                    ),

                  // Fields
                  _AuthField(
                    controller: _emailCtrl,
                    hint: 'Email address',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 11),
                  _AuthField(
                    controller: _passCtrl,
                    hint: 'Password',
                    obscure: true,
                  ),
                  if (!_isSignIn) ...[
                    const SizedBox(height: 11),
                    _AuthField(
                      controller: _confirmCtrl,
                      hint: 'Confirm password',
                      obscure: true,
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Loading or Email Auth Button
                  if (_loading)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        ),
                        SizedBox(width: 10),
                        Text('Please wait…',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    )
                  else
                    _AuthButton(
                      onTap: _emailAuth,
                      child: Text(
                        _isSignIn ? 'Sign In' : 'Create Account',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            fontSize: 14),
                      ),
                    ),
                  const SizedBox(height: 12),
                  _AuthButton(
                    secondary: true,
                    onTap: _skip,
                    child: const Text(
                      'Skip for Now',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    _fbStatus,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool secondary;
  const _AuthButton(
      {required this.child, this.onTap, this.secondary = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: secondary ? Colors.white.withOpacity(0.2) : Colors.white,
            border: secondary
                ? Border.all(color: Colors.white, width: 2)
                : null,
            borderRadius: BorderRadius.circular(10),
            boxShadow: secondary
                ? null
                : [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 4))
                  ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  const _AuthField(
      {required this.controller,
      required this.hint,
      this.obscure = false,
      this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.4), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Tab(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: active ? AppColors.primary : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..style = PaintingStyle.fill;
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    p.color = const Color(0xFFEA4335);
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r), -1.57, 3.14, true, p);
    p.color = const Color(0xFF34A853);
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r), 1.57, 3.14, true, p);
    p.color = const Color(0xFF4285F4);
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r), 3.14, 1.57, true, p);
    p.color = const Color(0xFFFBBC05);
    canvas.drawArc(
        Rect.fromCircle(center: c, radius: r), 4.71, 1.57, true, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
