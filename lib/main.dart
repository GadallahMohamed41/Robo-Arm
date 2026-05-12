import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:robotic_arm_app/features/control/presentation/bloc/control_bloc.dart';
import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/connection/presentation/bloc/connection_bloc.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? firebaseInitError;
  try {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    firebaseInitError = e;
  }

  // Portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bgDeep,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(RoboticArmApp(firebaseInitError: firebaseInitError));
}

// Global theme notifier
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

class RoboticArmApp extends StatelessWidget {
  final Object? firebaseInitError;
  const RoboticArmApp({super.key, this.firebaseInitError});

  @override
  Widget build(BuildContext context) {
    if (firebaseInitError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: _FirebaseInitErrorPage(error: firebaseInitError.toString()),
      );
    }

    return MultiBlocProvider(
      providers: [
        // Auth — must be first so router redirect can use it
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc()..add(const AuthCheckRequested()),
        ),
        BlocProvider<ConnectionBloc>(create: (_) => ConnectionBloc()),
        BlocProvider<ControlBloc>(
          create: (context) => ControlBloc(
            connectionBloc: context.read<ConnectionBloc>(),
          ),
        ),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, ThemeMode currentMode, __) {
          return MaterialApp.router(
            title: 'RoboArm PRO',
            debugShowCheckedModeBanner: false,
            themeMode: currentMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}

class _FirebaseInitErrorPage extends StatelessWidget {
  final String error;
  const _FirebaseInitErrorPage({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Firebase غير متصل',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'لازم تكوّن Firebase للأندرويد (flutterfire configure + google-services.json) وبعدين تشغّل التطبيق تاني.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Error:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    error,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
