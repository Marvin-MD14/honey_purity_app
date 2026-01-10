import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:tflite_v2/tflite_v2.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'TimesNewRoman',
      primarySwatch: Colors.amber,
      scaffoldBackgroundColor: Colors.amber[50],
    ),
    home: const LoginPage(),
  ));
}

const String apiUrl = "https://honey-classifier.islanddigitalguide.com/api.php";

// ================= LOGIN PAGE =================
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
              builder: (context) => UserDashboard(
                userId: userData['id'].toString(), 
                name: userData['fullname'],
                profilePic: userData['profile_pic'] ?? ""
              )
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber.shade300, Colors.amber.shade50],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                    fit: BoxFit.contain,
                    // DITO ANG FIX: Pinalitan ang Icons.honey_pod ng Icons.bakery_dining
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.bakery_dining, size: 100, color: Colors.amber),
                  ),
                  const Text("Honey Classifier", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  TextField(controller: _user, decoration: InputDecoration(labelText: "Username", prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
                  const SizedBox(height: 15),
                  TextField(controller: _pass, obscureText: true, decoration: InputDecoration(labelText: "Password", prefixIcon: const Icon(Icons.lock), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: const Text("LOGIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
                      child: const Text("Don't have an account? Create one")
                  )
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
} // <--- DITO NAGSASARA ANG LOGIN PAGE STATE

// ================= REGISTER PAGE =================
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber.shade300, Colors.amber.shade50],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.person_add, size: 80, color: Colors.amber),
                    ),
                    const SizedBox(height: 10),
                    const Text("Register Account", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _name, 
                      decoration: InputDecoration(
                        labelText: "Full Name", 
                        prefixIcon: const Icon(Icons.badge), 
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))
                      )
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _user, 
                      decoration: InputDecoration(
                        labelText: "Username", 
                        prefixIcon: const Icon(Icons.person), 
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))
                      )
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _pass, 
                      obscureText: true, 
                      decoration: InputDecoration(
                        labelText: "Password", 
                        prefixIcon: const Icon(Icons.lock), 
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))
                      )
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: _register, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber, 
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                      ),
                      child: const Text("SUBMIT REGISTRATION", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Already have an account? Login")
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} // <--- DITO NAGSASARA ANG REGISTER PAGE STATE

// ================= USER DASHBOARD =================
class UserDashboard extends StatefulWidget {
  final String userId;
  final String name;
  final String profilePic;
  const UserDashboard({super.key, required this.userId, required this.name, this.profilePic = ""});
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
      await Tflite.loadModel(
        model: "assets/honey_model_v2.tflite",
        labels: "assets/labels.txt",
      );
    } catch (e) { print(e); }
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

  // UPDATED: TINANGGAL ANG IMAGE PICKER SA EDIT PROFILE
  void _showEditProfile() {
    final nameController = TextEditingController(text: _currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.amber,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: nameController, 
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() { _currentName = nameController.text; });
              Navigator.pop(context);
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }

  Future<void> _classifyHoney(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 3, 
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    if (output != null && output.isNotEmpty) {
      String rawLabel = output[0]['label'];
      String detectedLabel = rawLabel.replaceAll(RegExp(r'[0-9]'), '').trim();
      double detectedConfidence = output[0]['confidence'] * 100;
      String pfund = _getPfundValue(detectedLabel);

      setState(() {
        _result = detectedLabel;
        _confidence = detectedConfidence;
      });

      _showFeedbackDialog(detectedLabel, detectedConfidence, pfund, image);
    }
  }

  void _showFeedbackDialog(String label, double conf, String pfund, File imageFile) {
    String selectedRating = "5";
    String selectedComment = "Legit! Accurate result.";

    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'Scan Successful!',
      body: StatefulBuilder(
        builder: (context, setStateSB) {
          return Column(
            children: [
              Text("Detected: $label", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Divider(),
              const Text("Rate Accuracy (1-5 Stars):"),
              DropdownButton<String>(
                value: selectedRating,
                isExpanded: true,
                items: ["5", "4", "3", "2", "1"].map((s) => DropdownMenuItem(value: s, child: Text("$s Stars"))).toList(),
                onChanged: (v) => setStateSB(() => selectedRating = v!),
              ),
              const SizedBox(height: 10),
              const Text("Select Feedback:"),
              DropdownButton<String>(
                value: selectedComment,
                isExpanded: true,
                items: ["Legit! Accurate result.", "Matched expectations.", "Slightly different.", "Inaccurate.", "Helpful App!"]
                  .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setStateSB(() => selectedComment = v!),
              ),
            ],
          );
        },
      ),
      btnOkText: "SUBMIT",
      btnOkOnPress: () {
        _saveScanWithFeedback(label, conf, pfund, selectedRating, selectedComment, imageFile);
      },
    ).show();
  }

  Future<void> _saveScanWithFeedback(String res, double conf, String pfund, String rate, String comm, File img) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$apiUrl?action=save_scan_feedback"));
      request.fields['user_id'] = widget.userId;
      request.fields['color_result'] = res;
      request.fields['confidence'] = "${conf.toStringAsFixed(1)}%";
      request.fields['pfund_value'] = pfund;
      request.fields['rating'] = rate;
      request.fields['comment'] = comm;
      request.files.add(await http.MultipartFile.fromPath('image', img.path));
      await request.send();

      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: 'Thank You!',
        desc: 'your ratings was sent successfully thanks for using application',
        btnOkOnPress: () {},
      ).show();
    } catch (e) { print(e); }
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
          ListTile(leading: const Icon(Icons.edit), title: const Text("Edit Profile"), onTap: () { Navigator.pop(context); _showEditProfile(); }),
          const Divider(),
          ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text("Logout"), onTap: () { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())); }),
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.amber, width: 2)),
              child: _image == null
                  ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.image_search, size: 80, color: Colors.grey), Text("No Image Captured")])
                  : ClipRRect(borderRadius: BorderRadius.circular(13), child: Image.file(_image!, fit: BoxFit.cover)),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(children: [
                Text(_confidence > 0 ? "Result: $_result" : _result, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
// ================= ADMIN DASHBOARD =================
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List users = [];
  List scans = [];
  List filteredScans = [];
  TextEditingController searchController = TextEditingController();
  int currentPage = 1;
  int itemsPerPage = 5;

  Future<void> fetchAdminData() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl?action=admin_data"));
      final res = jsonDecode(response.body);
      setState(() {
        users = res['users'] ?? [];
        scans = res['scans'] ?? [];
        filteredScans = scans;
      });
    } catch (e) { print("Error: $e"); }
  }

  void filterScans(String query) {
    setState(() {
      currentPage = 1;
      filteredScans = scans.where((s) {
        final name = s['fullname'].toString().toLowerCase();
        final result = s['color_result'].toString().toLowerCase();
        return name.contains(query.toLowerCase()) || result.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAdminData();
  }

  @override
  Widget build(BuildContext context) {
    int totalUsers = users.length;
    int totalScans = scans.length;
    
    int amberCount = scans.where((s) => s['color_result'].toString().toLowerCase().contains('amber')).length;

    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > filteredScans.length) endIndex = filteredScans.length;
    List currentScans = filteredScans.isEmpty ? [] : filteredScans.sublist(startIndex, endIndex);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Monitoring"),
          backgroundColor: Colors.amber,
          bottom: const TabBar(tabs: [Tab(icon: Icon(Icons.dashboard), text: "Analytics"), Tab(icon: Icon(Icons.history), text: "History")]),
          actions: [IconButton(onPressed: fetchAdminData, icon: const Icon(Icons.refresh)), IconButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())), icon: const Icon(Icons.logout))],
        ),
        body: TabBarView(children: [
          // TAB 1: ANALYTICS & USERS
          SingleChildScrollView(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(children: [
                  Expanded(child: _buildStatCard("Total Users", totalUsers.toString(), Icons.people, Colors.blue)),
                  Expanded(child: _buildStatCard("Total Scans", totalScans.toString(), Icons.analytics, Colors.orange)),
                  Expanded(child: _buildStatCard("Amber Detect", amberCount.toString(), Icons.opacity, Colors.brown)),
                ]),
              ),
              const Divider(),
              const Padding(padding: EdgeInsets.all(8.0), child: Text("User List", style: TextStyle(fontWeight: FontWeight.bold))),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (context, i) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(users[i]['fullname']),
                  subtitle: Text("ID: ${users[i]['id']}"),
                ),
              ),
            ]),
          ),

          // TAB 2: HISTORY WITH PAGINATION
          Column(children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: searchController,
                onChanged: filterScans,
                decoration: InputDecoration(hintText: "Search name or result...", prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), filled: true, fillColor: Colors.white),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: currentScans.length,
                itemBuilder: (context, i) => Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.amber[100], child: const Icon(Icons.bug_report, color: Colors.orange)),
                    title: Text(currentScans[i]['fullname'] ?? "User"),
                    subtitle: Text("Detected: ${currentScans[i]['color_result']} (${currentScans[i]['confidence']})"),
                    trailing: Text("${currentScans[i]['rating']}★", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                  onPressed: currentPage > 1 ? () => setState(() => currentPage--) : null,
                  child: const Text("Prev"),
                ),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: Text("Page $currentPage")),
                ElevatedButton(
                  onPressed: endIndex < filteredScans.length ? () => setState(() => currentPage++) : null,
                  child: const Text("Next"),
                ),
              ]),
            )
          ]),
        ]),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        child: Column(children: [
          Icon(icon, color: color),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}