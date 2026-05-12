import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/neon_button.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(SignInWithEmail(
          email: _emailCtrl.text,
          password: _passCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home); // Direct to home page
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: const TextStyle(fontFamily: 'Rajdhani')),
              backgroundColor: AppColors.neonRed.withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: Stack(
          children: [
            // Sci-Fi grid background
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),
            // Glowing core
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.neonCyan.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.precision_manufacturing_rounded, size: 64, color: AppColors.neonCyan),
                        const SizedBox(height: 16),
                        ShaderMask(
                          shaderCallback: (b) => const LinearGradient(
                            colors: [AppColors.neonCyan, AppColors.neonBlue],
                          ).createShader(b),
                          child: const Text(
                            'SYSTEM ACCESS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'AUTHENTICATE TO INITIALIZE ROBOARM CORE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Rajdhani',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _SciFiTextField(
                                controller: _emailCtrl,
                                label: '(EMAIL)',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'REQUIRED';
                                  if (!v.contains('@')) return 'INVALID FORMAT';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              _SciFiTextField(
                                controller: _passCtrl,
                                label: '(PASSWORD)',
                                icon: Icons.lock_outline_rounded,
                                obscureText: _obscurePass,
                                suffix: GestureDetector(
                                  onTap: () => setState(() => _obscurePass = !_obscurePass),
                                  child: Icon(
                                    _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: AppColors.neonCyan,
                                    size: 18,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'REQUIRED';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 40),
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) => NeonButton(
                                  label: 'AUTHORIZE',
                                  icon: Icons.fingerprint_rounded,
                                  color: AppColors.neonCyan,
                                  isLoading: state is AuthLoading,
                                  onPressed: _submit,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('NO CLEARANCE? ',
                                      style: TextStyle(
                                          fontFamily: 'Rajdhani',
                                          fontSize: 13,
                                          color: AppColors.textSecondary)),
                                  GestureDetector(
                                    onTap: () => context.go(AppRoutes.register),
                                    child: const Text('REQUEST ACCESS',
                                        style: TextStyle(
                                            fontFamily: 'Orbitron',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.neonBlue,
                                            letterSpacing: 1.5)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neonCyan.withOpacity(0.03)
      ..strokeWidth = 1.0;

    const spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SciFiTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _SciFiTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.validator,
  });

  @override
  State<_SciFiTextField> createState() => _SciFiTextFieldState();
}

class _SciFiTextFieldState extends State<_SciFiTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final color = _focused ? AppColors.neonCyan : AppColors.glassBorder;

    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: color, width: _focused ? 2 : 1),
            left: BorderSide(color: color.withOpacity(0.3), width: 1),
          ),
          color: _focused ? AppColors.neonCyan.withOpacity(0.05) : Colors.transparent,
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 14,
              color: Colors.white,
              letterSpacing: 2),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 12,
                color: _focused ? AppColors.neonCyan : AppColors.textMuted,
                letterSpacing: 2),
            prefixIcon: Icon(widget.icon,
                color: _focused ? AppColors.neonCyan : AppColors.textMuted,
                size: 20),
            suffixIcon: widget.suffix,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            errorStyle: const TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 9,
                color: AppColors.neonRed),
          ),
        ),
      ),
    );
  }
}
