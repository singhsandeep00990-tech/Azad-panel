import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
}

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
      message('Email aur password enter karo');
      return;
    }

    setState(() => loading = true);

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
      message(e.message ?? 'Login failed');
    } catch (e) {
      message('Login failed: $e');
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  void message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
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

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DocumentReference<Map<String, dynamic>> get userRef {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid);
  }

  // ===================================================
  // START NO PUSH BUTTON
  // ===================================================

  Future<void> startMotor() async {
    try {
      await userRef.set({
        'commands': {
          'start': true,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Momentary START pulse
      await Future.delayed(const Duration(milliseconds: 500));

      await userRef.set({
        'commands': {
          'start': false,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      showMessage('START command sent');
    } catch (e) {
      showMessage('START error: $e');
    }
  }

  // ===================================================
  // STOP NC PUSH BUTTON
  // ===================================================

  Future<void> stopMotor() async {
    try {
      await userRef.set({
        'commands': {
          'stop': true,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Momentary STOP pulse
      await Future.delayed(const Duration(milliseconds: 500));

      await userRef.set({
        'commands': {
          'stop': false,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      showMessage('STOP command sent');
    } catch (e) {
      showMessage('STOP error: $e');
    }
  }

  void showMessage(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

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
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Firebase error:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final data = snapshot.data?.data() ?? {};

          final faults = Map<String, dynamic>.from(
            (data['faults'] as Map?) ?? {},
          );

          final status = Map<String, dynamic>.from(
            (data['status'] as Map?) ?? {},
          );

          final currents = Map<String, dynamic>.from(
            (data['currents'] as Map?) ?? {},
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              // =========================================
              // MOTOR CONTROL
              // =========================================

              const Text(
                'MOTOR CONTROL',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [

                  // START NO
                  Expanded(
                    child: PushButtonCard(
                      title: 'START',
                      icon: Icons.play_arrow,
                      color: Colors.green,
                      onPressed: startMotor,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // STOP NC
                  Expanded(
                    child: PushButtonCard(
                      title: 'STOP',
                      icon: Icons.stop,
                      color: Colors.red,
                      onPressed: stopMotor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // =========================================
              // MOTOR STATUS
              // =========================================

              StatusCard(
                title: 'MOTOR STATUS',
                value: status['motor'] == true
                    ? 'RUNNING'
                    : 'STOPPED',
                active: status['motor'] == true,
              ),

              const SizedBox(height: 10),

              StatusCard(
                title: 'WIFI STATUS',
                value: status['wifi'] == true
                    ? 'CONNECTED'
                    : 'DISCONNECTED',
                active: status['wifi'] == true,
              ),

              const SizedBox(height: 10),

              StatusCard(
                title: 'MAIN STATUS',
                value: status['main'] == true
                    ? 'MAIN ON'
                    : 'MAIN OFF',
                active: status['main'] == true,
              ),

              const SizedBox(height: 25),

              // =========================================
              // FAULT INDICATORS
              // =========================================

              const Text(
                'FAULT / PROTECTION',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [

                  FaultCard(
                    title: 'R PHASE',
                    active: faults['rPhase'] == true,
                  ),

                  FaultCard(
                    title: 'Y PHASE',
                    active: faults['yPhase'] == true,
                  ),

                  FaultCard(
                    title: 'B PHASE',
                    active: faults['bPhase'] == true,
                  ),

                  FaultCard(
                    title: 'OVERLOAD TRIP',
                    active: faults['overload'] == true,
                  ),

                  FaultCard(
                    title: 'DRY RUN TRIP',
                    active: faults['dryRun'] == true,
                  ),

                  FaultCard(
                    title: 'MOTOR WIRING FAULT',
                    active: faults['wiring'] == true,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // =========================================
              // MOTOR CURRENT
              // =========================================

              const Text(
                'MOTOR CURRENT',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.electric_bolt,
                        size: 45,
                        color: Colors.orange,
                      ),

                      const SizedBox(width: 18),

                      const Expanded(
                        child: Text(
                          'Current',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Text(
                        '${currents['motor'] ?? 0} A',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// =====================================================
// PUSH BUTTON CARD
// =====================================================

class PushButtonCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const PushButtonCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
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
// STATUS CARD
// =====================================================

class StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final bool active;

  const StatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          active ? Icons.check_circle : Icons.cancel,
          color: active ? Colors.green : Colors.red,
          size: 32,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Text(
          value,
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
// FAULT CARD
// =====================================================

class FaultCard extends StatelessWidget {
  final String title;
  final bool active;

  const FaultCard({
    super.key,
    required this.title,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            active
                ? Icons.warning_amber_rounded
                : Icons.check_circle,
            size: 38,
            color: active ? Colors.red : Colors.green,
          ),

          const SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            active ? 'FAULT' : 'NORMAL',
            style: TextStyle(
              color: active ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}