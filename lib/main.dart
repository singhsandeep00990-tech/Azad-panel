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
                    style: TextStyle(color: Colors.grey),
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
  // MOTOR START
  // ===================================================

  Future<void> startMotor(String motor) async {
    await panelRef.set(
      {
        'commands': {
          motor: 'START',
        },
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ===================================================
  // MOTOR STOP
  // ===================================================

  Future<void> stopMotor(String motor) async {
    await panelRef.set(
      {
        'commands': {
          motor: 'STOP',
        },
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
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
              child: Text(
                'Firebase error:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            );
          }

          final data = snapshot.data?.data() ?? {};

          final faults = Map<String, dynamic>.from(
            (data['faults'] as Map?) ?? {},
          );

          final currents = Map<String, dynamic>.from(
            (data['currents'] as Map?) ?? {},
          );

          final status = Map<String, dynamic>.from(
            (data['status'] as Map?) ?? {},
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // =========================================
              // MOTOR 1
              // =========================================

              MotorControlCard(
                title: 'MOTOR 1',
                running: status['motor1Running'] == true,
                onStart: () => startMotor('motor1'),
                onStop: () => stopMotor('motor1'),
              ),

              const SizedBox(height: 18),

              // =========================================
              // MOTOR 2
              // =========================================

              MotorControlCard(
                title: 'MOTOR 2',
                running: status['motor2Running'] == true,
                onStart: () => startMotor('motor2'),
                onStop: () => stopMotor('motor2'),
              ),

              const SizedBox(height: 28),

              const Text(
                'PANEL STATUS',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              // =========================================
              // 8 INDICATORS
              // =========================================

              StatusCard(
                title: 'R-Y-B PHASE',
                active: faults['phaseOk'] == true,
                normalText: 'OK',
                faultText: 'PHASE FAULT',
              ),

              StatusCard(
                title: 'OVERLOAD TRIP',
                active: faults['overload'] != true,
                normalText: 'NORMAL',
                faultText: 'TRIP',
              ),

              StatusCard(
                title: 'DRY RUN TRIP',
                active: faults['dryRun'] != true,
                normalText: 'NORMAL',
                faultText: 'TRIP',
              ),

              StatusCard(
                title: 'MOTOR WIRING FAULT',
                active: faults['wiringFault'] != true,
                normalText: 'NORMAL',
                faultText: 'FAULT',
              ),

              StatusCard(
                title: 'WIFI STATUS',
                active: status['wifiConnected'] == true,
                normalText: 'CONNECTED',
                faultText: 'DISCONNECTED',
              ),

              StatusCard(
                title: 'MAIN STATUS',
                active: status['mainOn'] == true,
                normalText: 'ON',
                faultText: 'OFF',
              ),

              StatusCard(
                title: 'MOTOR 1 STATUS',
                active: status['motor1Running'] == true,
                normalText: 'RUNNING',
                faultText: 'STOPPED',
              ),

              StatusCard(
                title: 'MOTOR 2 STATUS',
                active: status['motor2Running'] == true,
                normalText: 'RUNNING',
                faultText: 'STOPPED',
              ),

              const SizedBox(height: 25),

              const Text(
                'CURRENT',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // =========================================
              // CURRENT 1-8
              // =========================================

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 8,

                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),

                itemBuilder: (context, index) {
                  final key = 'current${index + 1}';

                  return CurrentCard(
                    number: index + 1,
                    value: currents[key],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// =====================================================
// MOTOR CONTROL CARD
// =====================================================

class MotorControlCard extends StatelessWidget {
  final String title;
  final bool running;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const MotorControlCard({
    super.key,
    required this.title,
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
                Icon(
                  Icons.settings,
                  size: 42,
                  color: running ? Colors.green : Colors.grey,
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Text(
                  running ? 'RUNNING' : 'STOPPED',
                  style: TextStyle(
                    color: running ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onStart,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      'START',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 55),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onStop,
                    icon: const Icon(Icons.stop),
                    label: const Text(
                      'STOP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 55),
                    ),
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
// STATUS CARD
// =====================================================

class StatusCard extends StatelessWidget {
  final String title;
  final bool active;
  final String normalText;
  final String faultText;

  const StatusCard({
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
        leading: Icon(
          active
              ? Icons.check_circle
              : Icons.warning_amber_rounded,
          color: active ? Colors.green : Colors.red,
          size: 35,
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        trailing: Text(
          active ? normalText : faultText,
          style: TextStyle(
            color: active ? Colors.green : Colors.red,
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
  final int number;
  final dynamic value;

  const CurrentCard({
    super.key,
    required this.number,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.electric_bolt,
              color: Colors.orange,
              size: 30,
            ),

            const SizedBox(height: 5),

            Text(
              'CURRENT $number',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              value == null ? '-- A' : '$value A',
              style: const TextStyle(
                color: Colors.orange,
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