import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/neon_button.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

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
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(RegisterWithEmail(
          email: _emailCtrl.text,
          password: _passCtrl.text,
          displayName: _nameCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegistered) {
          // Show success and go to Login — user must sign in manually
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('ACCOUNT CREATED — PLEASE SIGN IN',
                      style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.w700,
                          fontSize: 11)),
                ],
              ),
              backgroundColor: AppColors.neonGreen.withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
          context.go(AppRoutes.login);
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
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.neonBlue.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, top: 16),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.neonCyan),
                          onPressed: () => context.go(AppRoutes.login),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Icon(Icons.hub_rounded, size: 54, color: AppColors.neonBlue),
                              const SizedBox(height: 16),
                              ShaderMask(
                                shaderCallback: (b) => const LinearGradient(
                                  colors: [AppColors.neonBlue, AppColors.neonCyan],
                                ).createShader(b),
                                child: const Text(
                                  'NEW CLEARANCE',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'REGISTER OPERATOR ID',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Rajdhani',
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 36),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _SciFiTextField(
                                      controller: _nameCtrl,
                                      label: 'CODENAME (DISPLAY NAME)',
                                      icon: Icons.person_outline_rounded,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) return 'REQUIRED';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _SciFiTextField(
                                      controller: _emailCtrl,
                                      label: 'CONTACT NODE (EMAIL)',
                                      icon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (v) {
                                        if (v == null || v.isEmpty) return 'REQUIRED';
                                        if (!v.contains('@')) return 'INVALID FORMAT';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _SciFiTextField(
                                      controller: _passCtrl,
                                      label: 'ENCRYPTION KEY (PASSWORD)',
                                      icon: Icons.lock_outline_rounded,
                                      obscureText: _obscurePass,
                                      suffix: GestureDetector(
                                        onTap: () => setState(() => _obscurePass = !_obscurePass),
                                        child: Icon(
                                          _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                          color: AppColors.neonBlue,
                                          size: 18,
                                        ),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) return 'REQUIRED';
                                        if (v.length < 6) return 'MIN 6 CHARACTERS';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _SciFiTextField(
                                      controller: _confirmCtrl,
                                      label: 'VERIFY KEY',
                                      icon: Icons.verified_user_outlined,
                                      obscureText: _obscureConfirm,
                                      suffix: GestureDetector(
                                        onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                        child: Icon(
                                          _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                          color: AppColors.neonBlue,
                                          size: 18,
                                        ),
                                      ),
                                      validator: (v) {
                                        if (v != _passCtrl.text) return 'KEYS DO NOT MATCH';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 40),
                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, state) => NeonButton(
                                        label: 'INITIALIZE',
                                        icon: Icons.power_settings_new_rounded,
                                        color: AppColors.neonBlue,
                                        isLoading: state is AuthLoading,
                                        onPressed: _submit,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
      ..color = AppColors.neonBlue.withOpacity(0.03)
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
    final color = _focused ? AppColors.neonBlue : AppColors.glassBorder;

    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: color, width: _focused ? 2 : 1),
            left: BorderSide(color: color.withOpacity(0.3), width: 1),
          ),
          color: _focused ? AppColors.neonBlue.withOpacity(0.05) : Colors.transparent,
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
                color: _focused ? AppColors.neonBlue : AppColors.textMuted,
                letterSpacing: 2),
            prefixIcon: Icon(widget.icon,
                color: _focused ? AppColors.neonBlue : AppColors.textMuted,
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
