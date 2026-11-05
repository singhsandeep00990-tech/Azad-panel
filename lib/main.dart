import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

const String firebaseApiKey = 'AIzaSyBlOKdcXznSq7pTHgEsD_j54iSB1zHf0dU';
const String firebaseAppId = '1:1091687452473:android:c6a875b4232d19b568a2e8';

const String projectId = 'azad-panel';
const String databaseUrl = 'https://azad-panel-default-rtdb.firebaseio.com';
const String deviceId = 'AZAD-001';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: firebaseApiKey,
      appId: firebaseAppId,
      messagingSenderId: '1091687452473',
      projectId: projectId,
      storageBucket: 'azad-panel.firebasestorage.app',
      databaseURL: databaseUrl,
    ),
  );

  runApp(const AzadSmartPanelApp());
}

class AzadSmartPanelApp extends StatelessWidget {
  const AzadSmartPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AZAD SMART PANEL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101318),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF171B22),
          foregroundColor: Colors.white,
        ),
        cardTheme: const CardTheme(
          color: Color(0xFF1A2029),
          elevation: 2,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

DatabaseReference get deviceRef =>
    FirebaseDatabase.instance.ref('panels/$deviceId');

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
      showMessage('Email aur password dono bharein.');
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
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? 'Login nahi ho paya.');
    } catch (e) {
      showMessage('Error: $e');
    } finally {
      if (mounted) setState(() => loading = false);
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/azad_logo-3.png',
                      height: 110,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.electrical_services, size: 80),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'AZAD SMART PANEL',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: passwordController,
                      obscureText: hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => hidePassword = !hidePassword),
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : login,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: loading
                              ? const CircularProgressIndicator()
                              : const Text('LOGIN'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<void> sendCommand(String command) async {
    await deviceRef.update({'command': command});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/azad_logo.png',
              height: 34,
              width: 34,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.electrical_services),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'AZAD SMART PANEL',
                style: TextStyle(fontSize: 17),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: deviceRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Firebase error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final raw = snapshot.data!.snapshot.value;
          final data = raw is Map
              ? Map<String, dynamic>.from(raw)
              : <String, dynamic>{};

          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              Row(
                children: [
                  Expanded(
                    child: PushButtonCard(
                      title: 'MOTOR 1',
                      onStart: () => sendCommand('START'),
                      onStop: () => sendCommand('STOP'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PushButtonCard(
                      title: 'MOTOR 2',
                      onStart: () => sendCommand('START_2'),
                      onStop: () => sendCommand('STOP_2'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('TIMER / SCHEDULE'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ScheduleTimerPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'STATUS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  StatusCard(
                    title: 'Motor',
                    value: displayValue(data['motor']),
                    icon: Icons.electric_bolt,
                  ),
                  StatusCard(
                    title: 'Wi-Fi',
                    value: displayValue(data['wifi']),
                    icon: Icons.wifi,
                  ),
                  StatusCard(
                    title: 'Main',
                    value: displayValue(data['main']),
                    icon: Icons.power,
                  ),
                  StatusCard(
                    title: 'R Phase',
                    value: displayValue(data['rPhase']),
                    icon: Icons.circle,
                  ),
                  StatusCard(
                    title: 'Y Phase',
                    value: displayValue(data['yPhase']),
                    icon: Icons.circle,
                  ),
                  StatusCard(
                    title: 'B Phase',
                    value: displayValue(data['bPhase']),
                    icon: Icons.circle,
                  ),
                  StatusCard(
                    title: 'RSSI',
                    value: displayValue(data['rssi']),
                    icon: Icons.network_wifi,
                  ),
                  StatusCard(
                    title: 'IP Address',
                    value: displayValue(data['ip']),
                    icon: Icons.router,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'FAULT INDICATORS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FaultCard(title: 'Overload', value: data['overload']),
                  FaultCard(title: 'Dry Run', value: data['dryRun']),
                  FaultCard(
                    title: 'Wiring Fault',
                    value: data['wiringFault'],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'CURRENT',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  StatusCard(
                    title: 'R Current',
                    value: '${displayValue(data['rCurrent'])} A',
                    icon: Icons.bolt,
                  ),
                  StatusCard(
                    title: 'Y Current',
                    value: '${displayValue(data['yCurrent'])} A',
                    icon: Icons.bolt,
                  ),
                  StatusCard(
                    title: 'B Current',
                    value: '${displayValue(data['bCurrent'])} A',
                    icon: Icons.bolt,
                  ),
                  StatusCard(
                    title: 'Total Current',
                    value: '${displayValue(data['totalCurrent'])} A',
                    icon: Icons.electric_meter,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String displayValue(dynamic value) {
    if (value == null) return '--';
    return value.toString();
  }
}

class PushButtonCard extends StatelessWidget {
  final String title;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const PushButtonCard({
    super.key,
    required this.title,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStart,
                child: const Text('START'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onStop,
                child: const Text('STOP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: Colors.orange),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FaultCard extends StatelessWidget {
  final String title;
  final dynamic value;

  const FaultCard({
    super.key,
    required this.title,
    required this.value,
  });

  bool get isFault {
    if (value == true) return true;
    final text = value?.toString().toLowerCase();
    return text == 'true' || text == '1' || text == 'fault' || text == 'on';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 15,
                color: isFault ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$title: ${isFault ? 'FAULT' : 'OK'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScheduleTimerPage extends StatefulWidget {
  const ScheduleTimerPage({super.key});

  @override
  State<ScheduleTimerPage> createState() => _ScheduleTimerPageState();
}

class _ScheduleTimerPageState extends State<ScheduleTimerPage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay stopTime = const TimeOfDay(hour: 9, minute: 0);

  bool timerEnabled = false;
  bool repeatMonthly = false;
  bool loading = false;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadSchedule();
  }

  Future<void> loadSchedule() async {
    setState(() => loading = true);

    try {
      final snapshot = await deviceRef.child('schedule').get();
      final raw = snapshot.value;

      if (raw is Map) {
        final schedule = Map<String, dynamic>.from(raw);

        final dateText = schedule['date']?.toString();
        final startText = schedule['startTime']?.toString();
        final stopText = schedule['stopTime']?.toString();

        if (dateText != null) {
          selectedDate = DateTime.tryParse(dateText) ?? selectedDate;
        }
        if (startText != null) startTime = parseTime(startText, startTime);
        if (stopText != null) stopTime = parseTime(stopText, stopTime);

        timerEnabled = schedule['enabled'] == true;
        repeatMonthly = schedule['repeatMonthly'] == true;
      }
    } catch (e) {
      if (mounted) showMessage('Schedule load nahi hua: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  TimeOfDay parseTime(String value, TimeOfDay fallback) {
    final parts = value.split(':');
    if (parts.length != 2) return fallback;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return fallback;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> chooseStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: startTime,
    );

    if (picked != null) setState(() => startTime = picked);
  }

  Future<void> chooseStopTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: stopTime,
    );

    if (picked != null) setState(() => stopTime = picked);
  }

  Future<void> saveSchedule() async {
    if (formatTime(startTime) == formatTime(stopTime)) {
      showMessage('Start aur stop time alag rakhein.');
      return;
    }

    setState(() => saving = true);

    try {
      await deviceRef.child('schedule').set({
        'enabled': timerEnabled,
        'date':
            '${selectedDate.year.toString().padLeft(4, '0')}-'
            '${selectedDate.month.toString().padLeft(2, '0')}-'
            '${selectedDate.day.toString().padLeft(2, '0')}',
        'startTime': formatTime(startTime),
        'stopTime': formatTime(stopTime),
        'repeatMonthly': repeatMonthly,
        'timeZone': 'Asia/Kolkata',
        'updatedAt': ServerValue.timestamp,
      });

      if (!mounted) return;
      showMessage('Timer schedule Firebase mein save ho gaya.');
    } catch (e) {
      showMessage('Schedule save nahi hua: $e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${selectedDate.day.toString().padLeft(2, '0')}/'
        '${selectedDate.month.toString().padLeft(2, '0')}/'
        '${selectedDate.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Timer / Schedule')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  title: const Text('Timer Enable'),
                  subtitle: const Text('Schedule ko on/off karein'),
                  value: timerEnabled,
                  onChanged: (value) =>
                      setState(() => timerEnabled = value),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Date'),
                  subtitle: Text(dateLabel),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: chooseDate,
                ),
                ListTile(
                  leading: const Icon(Icons.play_arrow),
                  title: const Text('Start Time'),
                  subtitle: Text(startTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: chooseStartTime,
                ),
                ListTile(
                  leading: const Icon(Icons.stop),
                  title: const Text('Stop Time'),
                  subtitle: Text(stopTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: chooseStopTime,
                ),
                SwitchListTile(
                  title: const Text('Har mahine repeat'),
                  subtitle: const Text(
                    'Selected date ke day par schedule repeat hoga',
                  ),
                  value: repeatMonthly,
                  onChanged: (value) =>
                      setState(() => repeatMonthly = value),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: saving ? null : saveSchedule,
                    icon: const Icon(Icons.save),
                    label: Padding(
                      padding: const EdgeInsets.all(12),
                      child: saving
                          ? const CircularProgressIndicator()
                          : const Text('SAVE SCHEDULE'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
