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

// ============================================================
// LOGIN PAGE
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool hidePassword = true;

  void login() {
    if (usernameController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username aur password bharo'),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardPage(),
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
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.electrical_services,
                    size: 52,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'SMART PANEL',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Smart Motor Control System',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: login,
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Powered by Smart Panel Technology',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
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

// ============================================================
// DASHBOARD
// ============================================================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<bool> relayState = List<bool>.filled(8, false);

  final List<bool> feedbackState = List<bool>.filled(8, false);

  final List<double> currentValues =
      List<double>.filled(8, 0.0);

  bool deviceOnline = true;

  int selectedChannel = 0;

  void toggleRelay(int index) {
    setState(() {
      relayState[index] = !relayState[index];

      // Demo feedback.
      // ESP32 se real feedback baad me connect kiya ja sakta hai.
      feedbackState[index] = relayState[index];

      if (relayState[index]) {
        currentValues[index] = 4.5;
      } else {
        currentValues[index] = 0.0;
      }
    });
  }

  void allOn() {
    setState(() {
      for (int i = 0; i < 8; i++) {
        relayState[i] = true;
        feedbackState[i] = true;
        currentValues[i] = 4.5;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Panel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // DEVICE STATUS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: deviceOnline
                      ? Colors.green
                      : Colors.red,
                ),
                color: deviceOnline
                    ? Colors.green.withOpacity(.08)
                    : Colors.red.withOpacity(.08),
              ),
              child: Row(
                children: [
                  Icon(
                    deviceOnline
                        ? Icons.wifi
                        : Icons.wifi_off,
                    color: deviceOnline
                        ? Colors.green
                        : Colors.red,
                    size: 32,
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AZAD SMART PANEL',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'ESP32 Controller',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: deviceOnline
                          ? Colors.green.withOpacity(.15)
                          : Colors.red.withOpacity(.15),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      deviceOnline
                          ? 'ONLINE'
                          : 'OFFLINE',
                      style: TextStyle(
                        color: deviceOnline
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // MOTOR SUMMARY
            Row(
              children: [
                Expanded(
                  child: statusCard(
                    'Motor',
                    relayState.contains(true)
                        ? 'RUNNING'
                        : 'STOPPED',
                    relayState.contains(true)
                        ? Colors.green
                        : Colors.red,
                    Icons.settings,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: statusCard(
                    'Channels',
                    '8',
                    Colors.blue,
                    Icons.memory,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ALL CONTROL
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: allOn,
                    icon: const Icon(
                      Icons.power,
                    ),
                    label: const Text('ALL ON'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: allOff,
                    icon: const Icon(
                      Icons.power_off,
                    ),
                    label: const Text('ALL OFF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Relay Channels',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            const SizedBox(height: 10),

            // RELAY LIST
            GridView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount: 8,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (context, index) {
                return relayCard(index);
              },
            ),

            const SizedBox(height: 20),

            // SELECTED CHANNEL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.blue.withOpacity(.08),
                border: Border.all(
                  color: Colors.blue.withOpacity(.5),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Channel ${selectedChannel + 1}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: infoItem(
                          'Feedback',
                          feedbackState[
                                  selectedChannel]
                              ? 'ON'
                              : 'OFF',
                          feedbackState[
                                  selectedChannel]
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),

                      Expanded(
                        child: infoItem(
                          'Current',
                          '${currentValues[selectedChannel].toStringAsFixed(1)} A',
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SERVICE INFORMATION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.grey.withOpacity(.08),
              ),
              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text('Service Hours: 0.0 Hours'),
                  SizedBox(height: 7),
                  Text('Next Service: 100 Hours'),
                  SizedBox(height: 7),
                  Text('Controller: ESP32'),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'AZAD SMART PANEL',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Powered by Microcontroller',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget statusCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(.08),
        border: Border.all(
          color: color.withOpacity(.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget relayCard(int index) {
    final bool isOn = relayState[index];

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        setState(() {
          selectedChannel = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isOn
              ? Colors.green.withOpacity(.10)
              : Colors.grey.withOpacity(.06),
          border: Border.all(
            color: isOn
                ? Colors.green
                : Colors.grey.withOpacity(.4),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.power,
                  color: isOn
                      ? Colors.green
                      : Colors.grey,
                  size: 25,
                ),
                const Spacer(),
                Text(
                  'CH ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Spacer(),

            Text(
              isOn ? 'ON' : 'OFF',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isOn
                    ? Colors.green
                    : Colors.red,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Feedback: ${feedbackState[index] ? "OK" : "OFF"}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => toggleRelay(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOn
                      ? Colors.red
                      : Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  isOn ? 'TURN OFF' : 'TURN ON',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoItem(
    String title,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}