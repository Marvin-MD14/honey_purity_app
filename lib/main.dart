import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:tflite_v2/tflite_v2.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginPage(),
  ));
}

const String apiUrl = "https://honey-classifier.islanddigitalguide.com/api.php";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _user = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  Future<void> _login() async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl?action=login"),
        body: {"username": _user.text, "password": _pass.text},
      ).timeout(const Duration(seconds: 15));

      final res = jsonDecode(response.body);

      if (res['status'] == 'success') {
        final userData = res['user'];
        String role = userData['role'].toString();

        if (!mounted) return;
        if (role == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => UserDashboard(userId: userData['id'].toString(), name: userData['fullname'])
          ));
        }
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Login Failed',
          desc: res['message'] ?? 'Invalid username or password.',
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        title: 'Connection Error',
        desc: 'Please check your internet or server configuration.',
        btnOkOnPress: () {},
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(children: [
            const Icon(Icons.bakery_dining, size: 100, color: Colors.amber),
            const Text("Honey Purity System", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(controller: _user, decoration: const InputDecoration(labelText: "Username", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder())),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: const Size(double.infinity, 50)),
              child: const Text("LOGIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
                child: const Text("Create an Account")
            )
          ]),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _user = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  Future<void> _register() async {
    try {
      final response = await http.post(Uri.parse("$apiUrl?action=register"), body: {
        "fullname": _name.text, 
        "username": _user.text, 
        "password": _pass.text
      });
      if (jsonDecode(response.body)['status'] == 'success') {
        if (!mounted) return;
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: 'Registration Success!',
          desc: 'You can now login with your account.',
          btnOkOnPress: () { Navigator.pop(context); },
        ).show();
      }
    } catch (e) { print(e); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register"), backgroundColor: Colors.amber),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        TextField(controller: _name, decoration: const InputDecoration(labelText: "Full Name")),
        TextField(controller: _user, decoration: const InputDecoration(labelText: "Username")),
        TextField(controller: _pass, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _register, 
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
          child: const Text("SUBMIT", style: TextStyle(color: Colors.black)),
        ),
      ])),
    );
  }
}

class UserDashboard extends StatefulWidget {
  final String userId;
  final String name;
  const UserDashboard({super.key, required this.userId, required this.name});
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  File? _image;
  String _result = "Ready to scan honey";
  String _currentName = "";
  double _confidence = 0.0;

  @override
  void initState() {
    super.initState();
    _currentName = widget.name;
    loadModel();
  }

  Future loadModel() async {
    try {
      // IN-UPDATE: Gamit na ang bagong model filename v2
      await Tflite.loadModel(
        model: "assets/honey_model_v2.tflite",
        labels: "assets/labels.txt",
      );
      print("New Model Loaded: honey_model_v2.tflite");
    } catch (e) {
      print("Failed to load model: $e");
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  String _getPfundValue(String label) {
    String lowerLabel = label.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    if (lowerLabel.contains("extralightamber")) return "34-50 mm";
    if (lowerLabel.contains("lightamber")) return "50-85 mm";
    if (lowerLabel.contains("amber")) return "85-114 mm";
    return "N/A";
  }

  Future<void> _classifyHoney(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 3, 
      threshold: 0.05, // Threshold adjustment for better sensitivity
      imageMean: 127.5,
      imageStd: 127.5,
    );

    print("----------------------------");
    print("AI RAW OUTPUT: $output");
    print("----------------------------");

    if (output != null && output.isNotEmpty) {
      String rawLabel = output[0]['label'];
      // Alisin ang index numbers (e.g., "0 Amber" -> "Amber")
      String detectedLabel = rawLabel.replaceAll(RegExp(r'[0-9]'), '').trim();
      double detectedConfidence = output[0]['confidence'] * 100;
      String pfund = _getPfundValue(detectedLabel);

      setState(() {
        _result = detectedLabel;
        _confidence = detectedConfidence;
      });

      _saveScanResult(detectedLabel, detectedConfidence, pfund);
    } else {
      setState(() {
        _result = "No Match Found";
        _confidence = 0.0;
      });
    }
  }

  Future<void> _saveScanResult(String honeyColor, double confidence, String pfund) async {
    try {
      final response = await http.post(Uri.parse("$apiUrl?action=save_scan"), body: {
        "user_id": widget.userId,
        "color_result": honeyColor,
        "confidence": "${confidence.toStringAsFixed(1)}%",
        "pfund_value": pfund,
      });
      print("Database sync response: ${response.body}");
    } catch (e) { 
      print("Error saving scan: $e"); 
    }
  }

  void _showEditProfile() {
    final nameController = TextEditingController(text: _currentName);
    final passController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Profile"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: "Full Name")),
          TextField(controller: passController, decoration: const InputDecoration(labelText: "New Password"), obscureText: true),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final response = await http.post(Uri.parse("$apiUrl?action=update_profile"), body: {
                "id": widget.userId, "fullname": nameController.text, "password": passController.text,
              });
              if (jsonDecode(response.body)['status'] == 'success') {
                setState(() { _currentName = nameController.text; });
                if (!mounted) return;
                Navigator.pop(context);
                AwesomeDialog(context: context, dialogType: DialogType.success, title: 'Updated!', desc: 'Profile saved successfully.').show();
              }
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = "Analyzing...";
        _confidence = 0.0;
      });
      _classifyHoney(_image!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Dashboard"), backgroundColor: Colors.amber),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.amber),
            accountName: Text(_currentName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            accountEmail: const Text("Honey Quality Analyst", style: TextStyle(color: Colors.black87)),
            currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: Colors.amber)),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit Profile"),
            onTap: () {
              Navigator.pop(context);
              _showEditProfile();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
            },
          ),
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.amber, width: 2)
              ),
              child: _image == null
                  ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.image_search, size: 80, color: Colors.grey),
                Text("No Image Captured", style: TextStyle(color: Colors.grey))
              ])
                  : ClipRRect(borderRadius: BorderRadius.circular(13), child: Image.file(_image!, fit: BoxFit.cover)),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(children: [
                Text(
                    _confidence > 0 ? "Result: $_result" : _result,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                ),
                if (_confidence > 0) ...[
                  Text("Confidence: ${_confidence.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Text("Pfund Scale: ${_getPfundValue(_result)}", style: const TextStyle(color: Colors.brown)),
                ]
              ]),
            ),
          ),
          const SizedBox(height: 30),
          Row(children: [
            Expanded(child: ElevatedButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text("SCAN"), style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.upload_file), label: const Text("UPLOAD"), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black))),
          ]),
        ]),
      ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List users = [];
  List scans = [];

  Future<void> fetchAdminData() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl?action=admin_data"));
      final res = jsonDecode(response.body);
      setState(() {
        users = res['users'] ?? [];
        scans = res['scans'] ?? [];
      });
    } catch (e) { print("Error fetching admin data: $e"); }
  }

  @override
  void initState() {
    super.initState();
    fetchAdminData();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Monitoring"),
          backgroundColor: Colors.brown,
          bottom: const TabBar(tabs: [Tab(text: "Users"), Tab(text: "Scan History")]),
          actions: [IconButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())), icon: const Icon(Icons.logout))],
        ),
        body: TabBarView(children: [
          ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, i) => ListTile(
                leading: const Icon(Icons.person),
                title: Text(users[i]['fullname']),
                subtitle: Text("Username: ${users[i]['username']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final response = await http.post(Uri.parse("$apiUrl?action=delete_user"), body: {"id": users[i]['id'].toString()});
                    if (jsonDecode(response.body)['status'] == 'success') { fetchAdminData(); }
                  },
                ),
              )
          ),
          ListView.builder(
              itemCount: scans.length,
              itemBuilder: (context, i) => ListTile(
                leading: const Icon(Icons.history, color: Colors.amber),
                title: Text(scans[i]['fullname'] ?? "Unknown User"),
                subtitle: Text("Result: ${scans[i]['color_result']} (${scans[i]['confidence'] ?? '0%'})"),
                trailing: Text(scans[i]['created_at']?.split(' ')[0] ?? "", style: const TextStyle(fontSize: 12)),
              )
          ),
        ]),
      ),
    );
  }
}