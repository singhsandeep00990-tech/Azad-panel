import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBlOKdcXznSq7pTHgEsD_j54iSB1zHf0dU',
        appId: '1:1091687452473:android:c6a875b4232d19b568a2e8',
        messagingSenderId: '1091687452473',
        projectId: 'azad-panel',
        storageBucket: 'azad-panel.firebasestorage.app',
      ),
    );

    runApp(const AzadPanelApp());
  } catch (e) {
    runApp(FirebaseErrorApp(error: e.toString()));
  }
}

// =====================================================
// APP
// =====================================================

class AzadPanelApp extends StatelessWidget {
  const AzadPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AZAD SMART PANEL',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.orange,
        useMaterial3: true,
      ),
      home: FirebaseAuth.instance.currentUser == null
          ? const LoginPage()
          : const DashboardPage(),
    );
  }
}

// =====================================================
// FIREBASE ERROR
// =====================================================

class FirebaseErrorApp extends StatelessWidget {
  final String error;

  const FirebaseErrorApp({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: const Color(0xFF101318),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  'AZAD SMART PANEL',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Firebase connection error',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// LOGIN
// =====================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool hidePassword = true;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage('Email aur password enter karo');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? 'Login failed');
    } catch (e) {
      showMessage('Login failed: $e');
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101318),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                children: [
                  const Icon(
                    Icons.electrical_services,
                    size: 80,
                    color: Colors.orange,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'AZAD SMART PANEL',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Customer Login',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 35),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Customer Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: loading ? null : login,
                      child: loading
                          ? const SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(),
                            )
                          : const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Secure customer access',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// DASHBOARD
// =====================================================

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  String get uid {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  DocumentReference<Map<String, dynamic>> get panelRef {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid);
  }

  // ===================================================
  // START MOTOR
  // ===================================================

  Future<void> startMotor() async {
    try {
      await panelRef.set(
        {
          'commands': {
            'motor': 'START',
          },
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('START error: $e');
    }
  }

  // ===================================================
  // STOP MOTOR
  // ===================================================

  Future<void> stopMotor() async {
    try {
      await panelRef.set(
        {
          'commands': {
            'motor': 'STOP',
          },
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('STOP error: $e');
    }
  }

  // ===================================================
  // LOGOUT
  // ===================================================

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AZAD SMART PANEL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: panelRef.snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Firebase error:\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            );
          }

          final data = snapshot.data?.data() ?? {};

          final indicators = Map<String, dynamic>.from(
            (data['indicators'] as Map?) ?? {},
          );

          final current = data['motorCurrent'];

          final motorRunning =
              data['motorRunning'] == true;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              // =================================================
              // MOTOR CONTROL
              // =================================================

              const Text(
                'MOTOR CONTROL',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              MotorControlCard(
                running: motorRunning,
                onStart: startMotor,
                onStop: stopMotor,
              ),

              const SizedBox(height: 25),

              // =================================================
              // 8 INDICATORS
              // =================================================

              const Text(
                'PANEL INDICATORS',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              IndicatorCard(
                title: 'R PHASE',
                active: indicators['rPhase'] == true,
                normalText: 'OK',
                faultText: 'FAULT',
              ),

              IndicatorCard(
                title: 'Y PHASE',
                active: indicators['yPhase'] == true,
                normalText: 'OK',
                faultText: 'FAULT',
              ),

              IndicatorCard(
                title: 'B PHASE',
                active: indicators['bPhase'] == true,
                normalText: 'OK',
                faultText: 'FAULT',
              ),

              IndicatorCard(
                title: 'OVERLOAD TRIP',
                active: indicators['overloadTrip'] != true,
                normalText: 'NORMAL',
                faultText: 'TRIP',
              ),

              IndicatorCard(
                title: 'DRY RUN TRIP',
                active: indicators['dryRunTrip'] != true,
                normalText: 'NORMAL',
                faultText: 'TRIP',
              ),

              IndicatorCard(
                title: 'MOTOR WIRING FAULT',
                active: indicators['motorWiringFault'] != true,
                normalText: 'NORMAL',
                faultText: 'FAULT',
              ),

              IndicatorCard(
                title: 'WIFI STATUS',
                active: indicators['wifiStatus'] == true,
                normalText: 'CONNECTED',
                faultText: 'DISCONNECTED',
              ),

              IndicatorCard(
                title: 'MAIN STATUS',
                active: indicators['mainStatus'] == true,
                normalText: 'ON',
                faultText: 'OFF',
              ),

              const SizedBox(height: 25),

              // =================================================
              // CURRENT
              // =================================================

              const Text(
                'MOTOR CURRENT',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              CurrentCard(
                value: current,
              ),
            ],
          );
        },
      ),
    );
  }
}

// =====================================================
// MOTOR CONTROL
// =====================================================

class MotorControlCard extends StatelessWidget {
  final bool running;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const MotorControlCard({
    super.key,
    required this.running,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Icon(
                    Icons.settings,
                    size: 34,
                    color: running
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),

                const SizedBox(width: 15),

                const Expanded(
                  child: Text(
                    'MOTOR',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Text(
                  running
                      ? 'RUNNING'
                      : 'STOPPED',
                  style: TextStyle(
                    color: running
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [

                // START NO PUSH BUTTON
                Expanded(
                  child: PushButton(
                    text: 'START',
                    icon: Icons.play_arrow,
                    color: Colors.green,
                    onPressed: onStart,
                  ),
                ),

                const SizedBox(width: 14),

                // STOP NO PUSH BUTTON
                Expanded(
                  child: PushButton(
                    text: 'STOP',
                    icon: Icons.stop,
                    color: Colors.red,
                    onPressed: onStop,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// PUSH BUTTON
// =====================================================

class PushButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const PushButton({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// INDICATOR CARD
// =====================================================

class IndicatorCard extends StatelessWidget {
  final String title;
  final bool active;
  final String normalText;
  final String faultText;

  const IndicatorCard({
    super.key,
    required this.title,
    required this.active,
    required this.normalText,
    required this.faultText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? Colors.green
                : Colors.red,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        trailing: Text(
          active
              ? normalText
              : faultText,
          style: TextStyle(
            color: active
                ? Colors.green
                : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// =====================================================
// CURRENT CARD
// =====================================================

class CurrentCard extends StatelessWidget {
  final dynamic value;

  const CurrentCard({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [

            const Icon(
              Icons.electric_bolt,
              color: Colors.orange,
              size: 55,
            ),

            const SizedBox(height: 10),

            const Text(
              'MOTOR CURRENT',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              value == null
                  ? '-- A'
                  : '${value.toString()} A',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}