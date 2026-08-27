import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
      databaseURL:
          'https://azad-panel-default-rtdb.firebaseio.com',
    ),
  );

  runApp(const AzadPanelApp());
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
// LOGIN PAGE
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
    final password = passwordController.text.trim();

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
      String message = 'Login failed';

      if (e.code == 'invalid-credential') {
        message = 'Email ya password galat hai';
      } else if (e.code == 'user-not-found') {
        message = 'User Firebase Authentication mein nahi mila';
      } else if (e.code == 'wrong-password') {
        message = 'Password galat hai';
      } else if (e.code == 'too-many-requests') {
        message = 'Bahut attempts ho gaye. Thodi der baad try karo';
      } else if (e.message != null) {
        message = e.message!;
      }

      showMessage(message);
    } catch (e) {
      showMessage('Login error: $e');
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void showMessage(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
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

                  // =================================================
                  // AZAD LOGO
                  // =================================================

                  Image.asset(
                    'assets/azad_logo.png',
                    width: 190,
                    height: 190,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'AZAD SMART PANEL',
                    textAlign: TextAlign.center,
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

                  // =================================================
                  // EMAIL
                  // =================================================

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

                  // =================================================
                  // PASSWORD
                  // =================================================

                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,

                    decoration: InputDecoration(
                      labelText: 'Password',

                      prefixIcon: const Icon(
                        Icons.lock,
                      ),

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

                  // =================================================
                  // LOGIN BUTTON
                  // =================================================

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

  // =================================================
  // DEVICE ID
  // =================================================

  static const String deviceId = 'AZAD-001';

  // =================================================
  // FIREBASE DATABASE
  // =================================================

  final DatabaseReference deviceRef =
      FirebaseDatabase.instance.ref(
    'panels/$deviceId',
  );

  // =================================================
  // START MOTOR
  // =================================================

  Future<void> startMotor() async {
    try {
      await deviceRef.child('command').set('START');

      showMessage('START command sent');
    } catch (e) {
      showMessage('START error: $e');
    }
  }

  // =================================================
  // STOP MOTOR
  // =================================================

  Future<void> stopMotor() async {
    try {
      await deviceRef.child('command').set('STOP');

      showMessage('STOP command sent');
    } catch (e) {
      showMessage('STOP error: $e');
    }
  }

  // =================================================
  // LOGOUT
  // =================================================

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

  // =================================================
  // MESSAGE
  // =================================================

  void showMessage(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  // =================================================
  // BUILD
  // =================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // =================================================
      // APP BAR
      // =================================================

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
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      // =================================================
      // FIREBASE LISTENER
      // =================================================

      body: StreamBuilder<DatabaseEvent>(
        stream: deviceRef.onValue,

        builder: (context, snapshot) {

          // =================================================
          // ERROR
          // =================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Text(
                  'Firebase error:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // =================================================
          // LOADING
          // =================================================

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // =================================================
          // DATA
          // =================================================

          final rawData =
              snapshot.data!.snapshot.value;

          Map<String, dynamic> data = {};

          if (rawData is Map) {
            data = Map<String, dynamic>.from(rawData);
          }

          // =================================================
          // STATUS
          // =================================================

          final bool motor =
              data['motor'] == true;

          final bool wifi =
              data['wifi'] == true;

          final bool main =
              data['main'] == true;

          final bool rPhase =
              data['rPhase'] == true;

          final bool yPhase =
              data['yPhase'] == true;

          final bool bPhase =
              data['bPhase'] == true;

          final bool overload =
              data['overload'] == true;

          final bool dryRun =
              data['dryRun'] == true;

          final bool wiringFault =
              data['wiringFault'] == true;

          // =================================================
          // CURRENT
          // =================================================

          final double rCurrent =
              _toDouble(data['rCurrent']);

          final double yCurrent =
              _toDouble(data['yCurrent']);

          final double bCurrent =
              _toDouble(data['bCurrent']);

          final double totalCurrent =
              _toDouble(data['totalCurrent']);

          // =================================================
          // WIFI
          // =================================================

          final int rssi =
              _toInt(data['rssi']);

          final String ip =
              data['ip']?.toString() ?? '--';

          final String command =
              data['command']?.toString() ?? 'IDLE';

          // =================================================
          // UI
          // =================================================

          return ListView(
            padding: const EdgeInsets.all(16),

            children: [

              // =================================================
              // DEVICE
              // =================================================

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.developer_board,
                    color: Colors.orange,
                    size: 35,
                  ),

                  title: const Text(
                    'DEVICE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: const Text(
                    deviceId,
                  ),

                  trailing: Text(
                    command,

                    style: TextStyle(
                      color: command == 'IDLE'
                          ? Colors.grey
                          : Colors.orange,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // =================================================
              // MOTOR CONTROL
              // =================================================

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

                  Expanded(
                    child: PushButtonCard(
                      title: 'START',
                      icon: Icons.play_arrow,
                      color: Colors.green,
                      onPressed: startMotor,
                    ),
                  ),

                  const SizedBox(width: 12),

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

              // =================================================
              // MOTOR STATUS
              // =================================================

              StatusCard(
                title: 'MOTOR STATUS',

                value: motor
                    ? 'RUNNING'
                    : 'STOPPED',

                active: motor,
              ),

              const SizedBox(height: 10),

              // =================================================
              // WIFI STATUS
              // =================================================

              StatusCard(
                title: 'WIFI STATUS',

                value: wifi
                    ? 'CONNECTED'
                    : 'DISCONNECTED',

                active: wifi,
              ),

              const SizedBox(height: 10),

              // =================================================
              // MAIN STATUS
              // =================================================

              StatusCard(
                title: 'MAIN STATUS',

                value: main
                    ? 'MAIN ON'
                    : 'MAIN OFF',

                active: main,
              ),

              const SizedBox(height: 25),

              // =================================================
              // FAULT
              // =================================================

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

                physics:
                    const NeverScrollableScrollPhysics(),

                crossAxisSpacing: 12,

                mainAxisSpacing: 12,

                childAspectRatio: 1.45,

                children: [

                  FaultCard(
                    title: 'R PHASE',
                    active: rPhase,
                  ),

                  FaultCard(
                    title: 'Y PHASE',
                    active: yPhase,
                  ),

                  FaultCard(
                    title: 'B PHASE',
                    active: bPhase,
                  ),

                  FaultCard(
                    title: 'OVERLOAD TRIP',
                    active: overload,
                  ),

                  FaultCard(
                    title: 'DRY RUN TRIP',
                    active: dryRun,
                  ),

                  FaultCard(
                    title: 'MOTOR WIRING FAULT',
                    active: wiringFault,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // =================================================
              // MOTOR CURRENT
              // =================================================

              const Text(
                'MOTOR CURRENT',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              CurrentCard(
                title: 'R PHASE',
                current: rCurrent,
              ),

              const SizedBox(height: 12),

              CurrentCard(
                title: 'Y PHASE',
                current: yCurrent,
              ),

              const SizedBox(height: 12),

              CurrentCard(
                title: 'B PHASE',
                current: bCurrent,
              ),

              const SizedBox(height: 12),

              // =================================================
              // TOTAL CURRENT
              // =================================================

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Row(
                    children: [

                      const Icon(
                        Icons.bolt,
                        size: 48,
                        color: Colors.orange,
                      ),

                      const SizedBox(width: 18),

                      const Expanded(
                        child: Text(
                          'TOTAL\nCURRENT',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Text(
                        '${totalCurrent.toStringAsFixed(2)} A',

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

              const SizedBox(height: 12),

              // =================================================
              // WIFI INFORMATION
              // =================================================

              Card(
                child: Column(
                  children: [

                    ListTile(
                      leading: const Icon(
                        Icons.network_check,
                      ),

                      title: const Text(
                        'IP Address',
                      ),

                      trailing: Text(ip),
                    ),

                    ListTile(
                      leading: const Icon(
                        Icons.signal_cellular_alt,
                      ),

                      title: const Text(
                        'WiFi RSSI',
                      ),

                      trailing: Text(
                        '$rssi dBm',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  // =================================================
  // DOUBLE CONVERSION
  // =================================================

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0.0;
  }

  // =================================================
  // INT CONVERSION
  // =================================================

  int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        0;
  }
}

// =====================================================
// CURRENT CARD
// =====================================================

class CurrentCard extends StatelessWidget {
  final String title;
  final double current;

  const CurrentCard({
    super.key,
    required this.title,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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

            Expanded(
              child: Text(
                title,

                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Text(
              '${current.toStringAsFixed(2)} A',

              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
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

            Icon(
              icon,
              size: 42,
            ),

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
          active
              ? Icons.check_circle
              : Icons.cancel,

          color: active
              ? Colors.green
              : Colors.red,

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

            color: active
                ? Colors.red
                : Colors.green,
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
            active
                ? 'FAULT'
                : 'NORMAL',

            style: TextStyle(
              color: active
                  ? Colors.red
                  : Colors.green,

              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}