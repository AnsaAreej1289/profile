import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import custom files
import 'controllers/auth_controller.dart';
import 'views/signup_screen.dart';
import 'views/signin_screen.dart';
import 'views/profile_screen.dart';
import 'views/edit_profile_screen.dart';
import 'views/forgot_password_screen.dart';
import 'views/updated_profile_screen.dart'; // ✅ Import your updated screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully!');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: MaterialApp(
        title: 'Profile App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashRedirector(),
          '/signup': (context) => const SignUpScreen(),
          '/signin': (context) => const SignInScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/edit_profile': (context) => const EditProfileScreen(),
          '/forgot': (context) => const ForgotPasswordScreen(),
          '/updatedProfile': (context) => const UpdatedProfileScreen(), // ✅ Route for updated profile screen
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('404 - Page Not Found')),
          ),
        ),
      ),
    );
  }
}

// ✅ Splash screen that redirects based on authentication state
class SplashRedirector extends StatefulWidget {
  const SplashRedirector({super.key});

  @override
  State<SplashRedirector> createState() => _SplashRedirectorState();
}

class _SplashRedirectorState extends State<SplashRedirector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Provider.of<AuthController>(context, listen: false);

      if (authController.firebaseUser != null) {
        debugPrint('➡️ User found. Redirecting to Profile...');
        Navigator.pushReplacementNamed(context, '/profile');
      } else {
        debugPrint('➡️ No user. Redirecting to SignIn...');
        Navigator.pushReplacementNamed(context, '/signin');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
