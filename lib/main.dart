import 'package:flutter/material.dart';
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:surf_mobile/providers/class_pack_provider.dart';
import 'package:surf_mobile/providers/navigation_provider.dart';
import 'package:surf_mobile/services/api_service.dart';
import 'package:surf_mobile/services/auth_service.dart';
import 'package:surf_mobile/services/navigation_service.dart';
import 'package:surf_mobile/services/stripe_service.dart';
import 'package:surf_mobile/screens/login_screen.dart';
import 'package:surf_mobile/screens/main_screen.dart';
import 'package:surf_mobile/screens/registration_screen.dart';
import 'package:surf_mobile/screens/school_selection_screen.dart';
import 'package:surf_mobile/theme/app_theme.dart';
import 'package:surf_mobile/services/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables.
  await dotenv.load(fileName: '.env');

  // Initialize Firebase.
  await Firebase.initializeApp();

  runApp(const MyApp());
  // runApp(
  //   const MaterialApp(
  //     debugShowCheckedModeBanner: false,
  //     home: Scaffold(
  //       backgroundColor: Colors.white,
  //       body: Center(
  //         child: Text(
  //           'OceanDojo',
  //           style: TextStyle(
  //             fontSize: 32,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ),
  //     ),
  //   ),
  // );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => apiService),
        ChangeNotifierProvider(
          create: (_) => AuthService(apiService),
        ),
        Provider<StripeService>(create: (_) => StripeService()),
        ChangeNotifierProxyProvider<AuthService, UserProvider>(
          create: (_) => UserProvider(),
          update: (_, auth, user) {
            user ??= UserProvider();
            user.updateDependencies(auth, apiService);
            return user;
          },
        ),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProxyProvider2<ApiService, UserProvider,
            ClassPackProvider>(
          create: (context) => ClassPackProvider(
            Provider.of<ApiService>(context, listen: false),
            Provider.of<UserProvider>(context, listen: false),
          ),
          update: (context, api, user, packProvider) {
            // Se o packProvider ainda não existe, cria.
            // Se já existe, as instâncias de api e user já são atualizadas pelo proxy
            return packProvider ?? ClassPackProvider(api, user);
          },
        ),
      ],
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        routes: {
          '/registration': (_) => const RegistrationScreen(),
        },
        title: 'OceanDojo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themeData,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (_, authService, __) {
        debugPrint('🧭 AuthWrapper: loading=${authService.isLoading}, '
            'token=${authService.cachedToken != null}, '
            'session=${authService.session != null}');

        if (authService.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authService.cachedToken == null || authService.session == null) {
          return const LoginScreen();
        }
        // If backend required additional registration fields, show RegistrationScreen.
        // if (authService.pendingRegistration) {
        //   return const RegistrationScreen();
        // }

        // final bool isAuthenticated =
        //     authService.cachedToken != null || authService.currentUser != null;

        return const HomeRouter();
      },
    );
  }
}

class HomeRouter extends StatefulWidget {
  const HomeRouter({super.key});

  @override
  State<HomeRouter> createState() => _HomeRouterState();
}

class _HomeRouterState extends State<HomeRouter> {
  // @override
  // void initState() {
  //   print('🏠 HomeRouter initState');
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<UserProvider>().ensureProfileLoaded();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (_, user, __) {
        if (user.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (user.loadError != null) {
          return Scaffold(
            body: Center(
              child: Text(user.loadError!),
            ),
          );
        }

        if (user.profile == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // if (user.school == null) {
        //   return const Scaffold(
        //     body: Center(child: CircularProgressIndicator()),
        //   );
        // }

        // if (user.loadError != null) {
        //   return ErrorScreen(
        //     message: user.loadError!,
        //     onRetry: user.ensureProfileLoaded,
        //   );
        // }

        if (user.requiresSchoolSelection) {
          return const SchoolSelectionScreen();
        }

        return const MainScreen();
      },
    );
  }
}
