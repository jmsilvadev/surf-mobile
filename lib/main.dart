import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:surf_mobile/providers/class_pack_provider.dart';
import 'package:surf_mobile/services/api_service.dart';
import 'package:surf_mobile/services/auth_service.dart';
import 'package:surf_mobile/services/navigation_service.dart';
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
            apiService.setTokenRefreshCallback(
                () => authService.getIdToken(force: true));

            return apiService;
          },
        ),
        ChangeNotifierProxyProvider2<AuthService, ApiService, UserProvider>(
          create: (_) => UserProvider(),
          update: (_, authService, apiService, userProvider) {
            userProvider ??= UserProvider();
            userProvider.updateDependencies(authService, apiService);
            return userProvider;
          },
        ),
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

        // final bool isAuthenticated =
        //     authService.cachedToken != null || authService.currentUser != null;
        if (authService.currentUser == null) {
          return const LoginScreen();
        }

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
  bool _requestedLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requestedLoad) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.ensureProfileLoaded();
      _requestedLoad = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.loadError != null) {
          print(
              '[AuthService] Silent Google sign-in succeeded for ${userProvider.loadError}');
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      userProvider.loadError!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => userProvider.ensureProfileLoaded(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        if (userProvider.isLoading && userProvider.profile == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (userProvider.requiresSchoolSelection) {
          return const SchoolSelectionScreen();
        }

        if (userProvider.profile == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return const MainScreen();
      },
    );
  }
}
