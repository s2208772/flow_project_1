import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'dart:math' as math;
import 'my_projects.dart';
import 'summary.dart';
import 'my_tasks.dart';
import 'plan.dart';
import 'schedule.dart';
import 'risks.dart';
import 'gantt_chart.dart';
import 'dependencies.dart';
import 'create_new_project.dart';
import 'header.dart';
import 'auth_service.dart' show SignUpSignIn;
import 'models/project.dart';

class WavyPainter extends CustomPainter {
  final double progress;
  final Color color;

  WavyPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final waveHeight = 6.0;
    final waveWidth = size.width / 3;
    final animatedWidth = size.width * progress;

    path.moveTo(0, size.height / 2);

    for (double x = 0; x < animatedWidth; x += 5) {
      final y = size.height / 2 + math.sin((x / waveWidth) * math.pi * 2) * waveHeight;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavyPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flow Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5C5C99)),
      ),
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => const MyHomePage(title: 'Flow Project Home Page'),
        '/my_projects': (context) => MyProjects(),
        '/summary': (context) => const Summary(),
        '/my_tasks': (context) => const MyTasks(),
        '/plan': (context) => const Plan(),
        '/schedule': (context) => const Schedule(),
        '/risks': (context) {
          final project = ModalRoute.of(context)?.settings.arguments as Project?;
          return Risks(project: project);
        },
        '/gantt_chart': (context) => const GanttChart(),
        '/dependencies': (context) {
          final project = ModalRoute.of(context)?.settings.arguments as Project?;
          return Dependencies(project: project);
        },
        '/create_new_project': (context) => CreateNewProject(),
        '/auth': (context) => const SignUpSignIn(),
      },
    );
  }
}

/// Set to true to skip login during development
const bool kSkipAuth = false;

/// Wrapper that listens to auth state and shows AuthPage or HomePage
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Skip authentication for development
    if (kSkipAuth) {
      return const MyHomePage(title: 'Flow Project Home Page');
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF5C5C99),
              ),
            ),
          );
        }

        // User is signed in
        if (snapshot.hasData && snapshot.data != null) {
          return const MyHomePage(title: 'Flow Project Home Page');
        }

        // User is not signed in
        return const SignUpSignIn();
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _lineAnimation;
  late Animation<double> _lineFadeAnimation;
  late Animation<double> _buttonsFadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(-0.1, 0.0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _lineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );

    _lineFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );

    _buttonsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 0.9, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: Container(
        color: const Color(0xFFF0F0EA),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Welcome to Flow Project',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: const Color(0xFF292966),
                          fontWeight: FontWeight.bold,
                          fontSize: 60,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 90),
                        child: FadeTransition(
                          opacity: _lineFadeAnimation,
                          child: ScaleTransition(
                            scale: _lineAnimation,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 400,
                              height: 2,
                              decoration: BoxDecoration(
                                color: const Color(0xFF5C5C99),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      FadeTransition(
                        opacity: _buttonsFadeAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/my_projects');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5C5C99),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'My Projects',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/create_new_project');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5C5C99),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'Create New Project',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
