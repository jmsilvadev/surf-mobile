import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:surf_mobile/services/api_service.dart';
import 'package:surf_mobile/services/auth_service.dart';
import 'package:surf_mobile/services/navigation_service.dart';
import 'package:surf_mobile/screens/login_screen.dart';
import 'package:surf_mobile/screens/main_screen.dart';
import 'package:surf_mobile/screens/registration_screen.dart';
import 'package:surf_mobile/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables.
  await dotenv.load(fileName: '.env');
  
  // Initialize Firebase.
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, ApiService>(
          create: (_) => ApiService(),
          update: (_, authService, apiService) {
            apiService ??= ApiService();

            // set cached token if available
            final cached = authService.cachedToken;
            if (cached != null) {
              apiService.setAuthToken(cached);
            } else if (authService.currentUser != null) {
              authService.getIdToken().then((token) {
                apiService?.setAuthToken(token);
              }).catchError((_) {
                apiService?.setAuthToken(null);
              });
            } else {
              apiService.setAuthToken(null);
            }

            // provide a callback so ApiService can refresh token on 401
            apiService.setTokenRefreshCallback(() => authService.getIdToken(force: true));

            return apiService;
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
      builder: (context, authService, _) {
        if (authService.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // If backend required additional registration fields, show RegistrationScreen.
        if (authService.pendingRegistration) {
          return const RegistrationScreen();
        }

        // If we have a server JWT cached, treat user as authenticated.
        if (authService.cachedToken != null) {
          return const MainScreen();
        }

        return authService.currentUser != null
            ? const MainScreen()
            : const LoginScreen();
      },
    );
  }
}
