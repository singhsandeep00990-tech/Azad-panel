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
        scaffoldBackgroundColor: const Color(0xFF0B0F14),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
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
  final TextEditingController userController =
      TextEditingController(text: 'customer');

  final TextEditingController passwordController =
      TextEditingController(text: '1234');

  bool hidePassword = true;

  void login() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const DashboardPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.electrical_services,
                  size: 80,
                  color: Colors.blue,
                ),

                const SizedBox(height: 20),

                const Text(
                  'SMART PANEL',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  '8 Channel Motor Control System',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: userController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
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

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: login,
                    icon: const Icon(Icons.login),
                    label: const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Demo Login: customer / 1234',
                  style: TextStyle(
                    color: Colors.grey,
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

// ================= DASHBOARD =================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<bool> relayState = List<bool>.filled(8, false);

  final List<bool> feedbackState = List<bool>.filled(8, false);

  final List<double> currentValues = [
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
  ];

  void toggleRelay(int index) {
    setState(() {
      relayState[index] = !relayState[index];

      // Demo feedback
      feedbackState[index] = relayState[index];

      // Demo current
      currentValues[index] =
          relayState[index] ? 5.0 + index.toDouble() * 0.5 : 0.0;
    });
  }

  void allOn() {
    setState(() {
      for (int i = 0; i < 8; i++) {
        relayState[i] = true;
        feedbackState[i] = true;
        currentValues[i] = 5.0 + i * 0.5;
      }
    });
  }

  void allOff() {
    setState(() {
      for (int i = 0; i < 8; i++) {
        relayState[i] = false;
        feedbackState[i] = false;
        currentValues[i] = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int running = relayState.where((x) => x).length;

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
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF182A45),
                      Color(0xFF101722),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AZAD SMART PANEL',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '8 Channel Motor Control System',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ================= STATUS =================

              Row(
                children: [
                  Expanded(
                    child: statusCard(
                      'ONLINE',
                      Icons.wifi,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: statusCard(
                      '$running RUNNING',
                      Icons.electric_bolt,
                      Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // ================= CONTROL =================

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: allOn,
                      icon: const Icon(Icons.power),
                      label: const Text('ALL ON'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: allOff,
                      icon: const Icon(Icons.power_off),
                      label: const Text('ALL OFF'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'RELAY CONTROL',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // ================= RELAYS =================

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 8,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.90,
                ),
                itemBuilder: (context, index) {
                  return relayCard(index);
                },
              ),

              const SizedBox(height: 20),

              // ================= MOTOR SUMMARY =================

              const Text(
                'SYSTEM INFORMATION',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF121821),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    infoRow(
                      'Controller',
                      'ESP32',
                      Icons.memory,
                    ),
                    infoRow(
                      'Channels',
                      '8 Relay',
                      Icons.settings_input_component,
                    ),
                    infoRow(
                      'Feedback',
                      '8 Input',
                      Icons.feedback,
                    ),
                    infoRow(
                      'Current',
                      '8 Channel',
                      Icons.bolt,
                    ),
                    infoRow(
                      'Connection',
                      'WiFi',
                      Icons.wifi,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  'SMART PANEL • DEMO VERSION',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ================= STATUS CARD =================

  Widget statusCard(
    String title,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF121821),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= RELAY CARD =================

  Widget relayCard(int index) {
    bool isOn = relayState[index];
    bool feedback = feedbackState[index];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF121821),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOn
              ? Colors.green.withOpacity(0.6)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.power_settings_new,
                color: isOn ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'RELAY ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Current
          Text(
            '${currentValues[index].toStringAsFixed(1)} A',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Text(
            'CURRENT',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 8),

          // Feedback
          Row(
            children: [
              Icon(
                feedback
                    ? Icons.check_circle
                    : Icons.cancel,
                size: 16,
                color: feedback
                    ? Colors.green
                    : Colors.red,
              ),
              const SizedBox(width: 5),
              Text(
                feedback ? 'FEEDBACK ON' : 'FEEDBACK OFF',
                style: TextStyle(
                  fontSize: 11,
                  color: feedback
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => toggleRelay(index),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isOn ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(
                isOn ? 'TURN OFF' : 'TURN ON',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= INFO ROW =================

  Widget infoRow(
    String title,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
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
