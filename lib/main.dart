import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const SmartPanelApp());
}

class SmartPanelApp extends StatelessWidget {
  const SmartPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Panel',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

// ================= LOGIN PAGE =================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  String error = '';

  // Demo login
  // Baad mein Firebase se customer-wise ID/password banayenge.
  final String demoUser = 'customer01';
  final String demoPassword = '123456';

  void login() {
    if (userController.text.trim() == demoUser &&
        passwordController.text == demoPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardPage(),
        ),
      );
    } else {
      setState(() {
        error = 'Invalid User ID or Password';
      });
    }
  }

  @override
  void dispose() {
    userController.dispose();
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
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                children: [
                  const Icon(
                    Icons.electrical_services,
                    size: 80,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'SMART PANEL',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    '8 Channel Motor Controller',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 40),

                  TextField(
                    controller: userController,
                    decoration: const InputDecoration(
                      labelText: 'User ID',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  if (error.isNotEmpty)
                    Text(
                      error,
                      style: const TextStyle(
                        color: Colors.redAccent,
                      ),
                    ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: login,
                      icon: const Icon(Icons.login),
                      label: const Text(
                        'LOGIN',
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Demo ID: customer01\nDemo Password: 123456',
                    textAlign: TextAlign.center,
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

// ================= DASHBOARD =================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<bool> relayState = List<bool>.filled(8, false);
  final List<bool> motorFeedback = List<bool>.filled(8, false);

  final List<double> current = List<double>.filled(8, 0.0);

  Timer? timer;

  @override
  void initState() {
    super.initState();

    // Demo sensor simulation.
    // Baad mein yahi data Firebase/ESP32 se aayega.
    timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) {
        setState(() {
          for (int i = 0; i < 8; i++) {
            if (relayState[i]) {
              motorFeedback[i] = true;
              current[i] = 4.5 + (i * 0.35);
            } else {
              motorFeedback[i] = false;
              current[i] = 0.0;
            }
          }
        });
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void setRelay(int index, bool value) {
    setState(() {
      relayState[index] = value;
    });

    // IMPORTANT:
    // Yahan baad mein Firebase/ESP32 command jayegi.
  }

  void logout() {
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
    int runningCount = motorFeedback.where((e) => e).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SMART PANEL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(
            const Duration(milliseconds: 500),
          );
          setState(() {});
        },

        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // ================= HEADER =================

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      child: Icon(
                        Icons.electrical_services,
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 15),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Panel',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'ESP32 Smart Motor Controller',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.green.withOpacity(0.15),
                      ),
                      child: const Text(
                        'ONLINE',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ================= SUMMARY =================

            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    'RELAYS ON',
                    relayState.where((e) => e).length.toString(),
                    Icons.power,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _summaryCard(
                    'MOTORS RUN',
                    runningCount.toString(),
                    Icons.electric_bolt,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'MOTOR CONTROL',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // ================= 8 CHANNELS =================

            for (int i = 0; i < 8; i++)
              _motorCard(i),

            const SizedBox(height: 20),

            // ================= INFO =================

            Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SYSTEM INFORMATION',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _infoRow(
                      Icons.memory,
                      'Controller',
                      'ESP32',
                    ),

                    _infoRow(
                      Icons.settings_remote,
                      'Channels',
                      '8 Relay',
                    ),

                    _infoRow(
                      Icons.sensors,
                      'Feedback',
                      '8 Current Sensors',
                    ),

                    _infoRow(
                      Icons.cloud,
                      'Connection',
                      'Demo Mode',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Center(
              child: Text(
                'SMART PANEL ENGINEERING',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ================= MOTOR CARD =================

  Widget _motorCard(int index) {
    bool relayOn = relayState[index];
    bool feedbackOn = motorFeedback[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [

            Row(
              children: [
                CircleAvatar(
                  child: Text('${index + 1}'),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MOTOR ${index + 1}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        feedbackOn
                            ? 'Motor Running'
                            : 'Motor Stopped',
                        style: TextStyle(
                          color: feedbackOn
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                Switch(
                  value: relayOn,
                  onChanged: (value) {
                    setRelay(index, value);
                  },
                ),
              ],
            ),

            const Divider(),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [

                Row(
                  children: [
                    Icon(
                      feedbackOn
                          ? Icons.circle
                          : Icons.circle_outlined,
                      size: 14,
                      color: feedbackOn
                          ? Colors.green
                          : Colors.grey,
                    ),

                    const SizedBox(width: 7),

                    Text(
                      feedbackOn
                          ? 'FEEDBACK ON'
                          : 'FEEDBACK OFF',
                      style: TextStyle(
                        color: feedbackOn
                            ? Colors.green
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    const Icon(
                      Icons.speed,
                      size: 18,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      '${current[index].toStringAsFixed(1)} A',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= SUMMARY CARD =================

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: Colors.blue,
            ),

            const SizedBox(height: 7),

            Text(
              value,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= INFO ROW =================

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 21,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(title),
          ),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
