import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    runApp(const AzadPanelApp());
  } catch (e) {
    runApp(FirebaseErrorApp(error: e.toString()));
  }
}

// =====================================================
// FIREBASE ERROR SCREEN
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
        body: SafeArea(
          child: Center(
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
                      fontSize: 20,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    error,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Please check google-services.json',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
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
      showMessage(
        e.message ?? 'Login failed',
      );
    } catch (e) {
      showMessage(
        'Login failed: $e',
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
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
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
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
                    keyboardType:
                        TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Customer Email',
                      prefixIcon:
                          Icon(Icons.email),
                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon:
                          const Icon(Icons.lock),
                      border:
                          const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            hidePassword =
                                !hidePassword;
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
                      onPressed:
                          loading ? null : login,
                      child: loading
                          ? const SizedBox(
                              height: 25,
                              width: 25,
                              child:
                                  CircularProgressIndicator(),
                            )
                          : const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
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
    return FirebaseAuth
        .instance
        .currentUser!
        .uid;
  }

  DocumentReference<Map<String, dynamic>>
      get panelRef {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid);
  }

  Future<void> setMotor(
    String motorName,
    bool value,
  ) async {
    try {
      await panelRef.set(
        {
          'motors': {
            motorName: value,
          },
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint(
        'Motor update error: $e',
      );
    }
  }

  Future<void> logout(
    BuildContext context,
  ) async {
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
            onPressed: () =>
                logout(context),
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      body: StreamBuilder<
          DocumentSnapshot<
              Map<String, dynamic>>>(
        stream: panelRef.snapshots(),

        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Text(
                  'Firebase error:\n\n${snapshot.error}',
                  textAlign:
                      TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            );
          }

          final data =
              snapshot.data?.data() ?? {};

          final motors =
              Map<String, dynamic>.from(
            (data['motors'] as Map?) ?? {},
          );

          final faults =
              Map<String, dynamic>.from(
            (data['faults'] as Map?) ?? {},
          );

          final currents =
              Map<String, dynamic>.from(
            (data['currents'] as Map?) ?? {},
          );

          return ListView(
            padding:
                const EdgeInsets.all(16),
            children: [
              MotorCard(
                title: 'MOTOR 1',
                isOn:
                    motors['motor1'] == true,
                onChanged: (value) {
                  setMotor(
                    'motor1',
                    value,
                  );
                },
              ),

              const SizedBox(height: 16),

              MotorCard(
                title: 'MOTOR 2',
                isOn:
                    motors['motor2'] == true,
                onChanged: (value) {
                  setMotor(
                    'motor2',
                    value,
                  );
                },
              ),

              const SizedBox(height: 28),

              const Text(
                'Fault Indicators',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                '8 live feedback inputs',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 15),

              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: 8,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                ),
                itemBuilder:
                    (context, index) {
                  final faultKey =
                      'fault${index + 1}';

                  final currentKey =
                      'current${index + 1}';

                  final fault =
                      faults[faultKey] == true;

                  final current =
                      currents[currentKey];

                  return FaultCard(
                    number: index + 1,
                    fault: fault,
                    current: current,
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
// MOTOR CARD
// =====================================================

class MotorCard extends StatelessWidget {
  final String title;
  final bool isOn;
  final ValueChanged<bool> onChanged;

  const MotorCard({
    super.key,
    required this.title,
    required this.isOn,
    required this.onChanged,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding:
            const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              child: Icon(
                Icons.settings,
                size: 40,
                color: isOn
                    ? Colors.green
                    : Colors.grey,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 25,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    isOn
                        ? 'RUNNING'
                        : 'STOPPED',
                    style: TextStyle(
                      color: isOn
                          ? Colors.green
                          : Colors.red,
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Switch(
              value: isOn,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// FAULT CARD
// =====================================================

class FaultCard extends StatelessWidget {
  final int number;
  final bool fault;
  final dynamic current;

  const FaultCard({
    super.key,
    required this.number,
    required this.fault,
    required this.current,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      elevation: 3,
      child: Padding(
        padding:
            const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              fault
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle,
              size: 40,
              color: fault
                  ? Colors.red
                  : Colors.green,
            ),

            const SizedBox(height: 5),

            Text(
              'FAULT $number',
              style:
                  const TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Text(
              fault
                  ? 'FAULT'
                  : 'NORMAL',
              style: TextStyle(
                color: fault
                    ? Colors.red
                    : Colors.green,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            if (current != null)
              Text(
                'Current: $current A',
                style:
                    const TextStyle(
                  color: Colors.orange,
                ),
              ),
          ],
        ),
      ),
    );
  }
}