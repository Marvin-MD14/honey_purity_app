import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; 

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
}

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
    } catch (e) { debugPrint(e.toString()); }
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
                    const Icon(Icons.person_add, size: 80, color: Colors.amber),
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
}
// ================= USER DASHBOARD =================
class UserDashboard extends StatefulWidget {
  final String userId;
  final String name;
  final String profilePic;

  const UserDashboard({
    super.key,
    required this.userId,
    required this.name,
    this.profilePic = "",
  });

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  File? _image;
  File? _newProfilePic;
  String _result = "Ready to scan honey";
  String _currentName = "";
  String _currentProfilePic = "";
  double _confidence = 0.0;
  bool isLoading = false;

  // History, Search & Pagination State
  List myScans = [];
  List filteredScans = [];
  TextEditingController searchController = TextEditingController();
  int currentPage = 1;
  int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _currentName = widget.name;
    _currentProfilePic = widget.profilePic;
    loadModel();
    fetchMyHistory();
  }

  @override
  void dispose() {
    Tflite.close();
    searchController.dispose();
    super.dispose();
  }

  // ================= CORE FUNCTIONS =================

  Future loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/honey_model_v2.tflite",
        labels: "assets/labels.txt",
      );
    } catch (e) {
      debugPrint("Error loading model: ${e.toString()}");
    }
  }

  Future<void> fetchMyHistory() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final url = Uri.parse("$apiUrl?action=user_history&user_id=${widget.userId}");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == "success") {
          setState(() {
            myScans = data['history'] ?? [];
            filteredScans = myScans;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching history: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      filteredScans = myScans.where((scan) {
        final result = (scan['color_result'] ?? "").toString().toLowerCase();
        return result.contains(query.toLowerCase());
      }).toList();
      currentPage = 1;
    });
  }

  void _handleLogout() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      title: 'Sign Out',
      desc: 'Are you sure you want to end your session?',
      btnCancelOnPress: () {},
      btnOkColor: Colors.red,
      btnOkText: "Yes, Logout",
      btnOkOnPress: () {
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (context) => const LoginPage()), 
          (route) => false
        );
      },
    ).show();
  }

  Future<void> _updateProfileInDatabase(String newName) async {
    setState(() => isLoading = true);
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$apiUrl?action=update_profile"));
      request.fields['id'] = widget.userId;
      request.fields['fullname'] = newName;

      if (_newProfilePic != null) {
        request.files.add(await http.MultipartFile.fromPath('profile_pic', _newProfilePic!.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          setState(() {
            _currentName = data['user']['fullname'];
            _currentProfilePic = data['user']['profile_pic'] ?? _currentProfilePic;
            _newProfilePic = null;
          });
          if (!mounted) return;
          AwesomeDialog(
            context: context, 
            dialogType: DialogType.success, 
            title: 'Update Successful',
            desc: 'Your profile information has been updated successfully.',
            btnOkOnPress: () {},
          ).show();
        }
      }
    } catch (e) {
      debugPrint("Profile update error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _saveScanWithFeedback(String res, double conf, String pfund, String rate, String comm, File img) async {
    setState(() => isLoading = true);
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$apiUrl?action=save_scan_feedback"));
      request.fields['user_id'] = widget.userId;
      request.fields['color_result'] = res;
      request.fields['confidence'] = "${conf.toStringAsFixed(1)}%";
      request.fields['pfund_value'] = pfund;
      request.fields['rating'] = rate;
      request.fields['comment'] = comm;
      request.files.add(await http.MultipartFile.fromPath('image', img.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        fetchMyHistory(); 
        if (!mounted) return;
        AwesomeDialog(context: context, dialogType: DialogType.success, title: 'Analysis Saved!').show();
      }
    } catch (e) {
      debugPrint("Error saving: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================= LOGIC & UI HELPERS =================

  String _getPfundValue(String label) {
    String lowerLabel = label.toLowerCase();
    if (lowerLabel.contains("extralightamber")) return "34-50 mm";
    if (lowerLabel.contains("lightamber")) return "50-85 mm";
    if (lowerLabel.contains("amber")) return "85-114 mm";
    return "N/A";
  }

  void _showEditProfile() {
    final nameController = TextEditingController(text: _currentName);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Profile Settings"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setDialogState(() => _newProfilePic = File(picked.path));
                  }
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.amber,
                  backgroundImage: _newProfilePic != null
                      ? FileImage(_newProfilePic!)
                      : (_currentProfilePic.isNotEmpty ? NetworkImage(_currentProfilePic) : null) as ImageProvider?,
                  child: (_newProfilePic == null && _currentProfilePic.isEmpty)
                      ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder())),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateProfileInDatabase(nameController.text.trim());
              },
              child: const Text("Save Changes"),
            )
          ],
        ),
      ),
    );
  }

  void _showDetailsDialog(Map scan) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(scan['color_result']?.toUpperCase() ?? "SCAN REPORT",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
            const SizedBox(height: 15),
            if (scan['image_url'] != null && scan['image_url'] != "")
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(scan['image_url'], height: 180, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 50)),
              ),
            const SizedBox(height: 15),
            _detailRow("Date Scanned:", scan['created_at'] ?? "N/A"),
            _detailRow("Confidence:", scan['confidence'] ?? "0%"),
            _detailRow("Pfund Value:", scan['pfund_value'] ?? "N/A"),
            const Divider(),
            const Text("Your Feedback", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            _buildStarRating(scan['rating']?.toString() ?? "0"),
            const SizedBox(height: 8),
            Text(
                "\"${scan['comment'] ?? "No comment provided."}\"",
                textAlign: TextAlign.center, 
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 13)
            ),
          ],
        ),
      ),
      btnOkOnPress: () {},
      btnOkColor: Colors.amber,
      btnOkText: "Close Report",
    ).show();
  }

  void _showFeedbackDialog(String label, double conf, String pfund, File imageFile) {
    String selectedRating = "5";
    String selectedComment = "Legit! Accurate result.";
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      title: 'Scan Result',
      body: StatefulBuilder(
        builder: (context, setStateSB) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.amber)),
              Text("Confidence: ${conf.toStringAsFixed(1)}%"),
              const SizedBox(height: 15),
              const Text("Rate the accuracy:"),
              DropdownButton<String>(
                value: selectedRating,
                isExpanded: true,
                items: ["5", "4", "3", "2", "1"].map((s) => DropdownMenuItem(value: s, child: Text("$s Stars"))).toList(),
                onChanged: (v) => setStateSB(() => selectedRating = v!),
              ),
              const Text("Quick Comment:"),
              DropdownButton<String>(
                value: selectedComment,
                isExpanded: true,
                items: ["Legit! Accurate result.", "Matched expectations.", "Slightly different.", "Inaccurate.", "Helpful App!"]
                    .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setStateSB(() => selectedComment = v!),
              ),
            ],
          ),
        ),
      ),
      btnOkText: "SAVE SCAN",
      btnOkColor: Colors.amber,
      btnOkOnPress: () => _saveScanWithFeedback(label, conf, pfund, selectedRating, selectedComment, imageFile),
    ).show();
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildStarRating(String rating) {
    int r = int.tryParse(rating) ?? 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) => Icon(index < r ? Icons.star : Icons.star_border, color: Colors.amber, size: 24)),
    );
  }

  // ================= CLASSIFICATION =================

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
String formatDateTime(String rawDate) {
  if (rawDate == "N/A" || rawDate.isEmpty) return "N/A";
  try {
    DateTime dateTime = DateTime.parse(rawDate);
    return DateFormat('MMMM dd, yyyy - hh:mm a').format(dateTime);
  } catch (e) {
    return rawDate;
  }
}
  // ================= PAGINATION & UI =================

  Widget _buildPaginationFooter() {
    int totalItems = filteredScans.length;
    int totalPages = (totalItems / itemsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Page $currentPage of $totalPages", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Row(
            children: [
              IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: currentPage > 1 ? () => setState(() => currentPage--) : null),
              IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: currentPage < totalPages ? () => setState(() => currentPage++) : null),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > filteredScans.length) endIndex = filteredScans.length;

    List currentScans = filteredScans.isEmpty || startIndex >= filteredScans.length
        ? []
        : filteredScans.sublist(startIndex, endIndex);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Honey Quality Analyst"),
          backgroundColor: Colors.amber,
          bottom: const TabBar(
            indicatorColor: Colors.black,
            tabs: [Tab(icon: Icon(Icons.camera_alt), text: "Scanner"), Tab(icon: Icon(Icons.history), text: "History")],
          ),
        ),
        drawer: Drawer(
          child: ListView(padding: EdgeInsets.zero, children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.amber),
              accountName: Text(_currentName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              accountEmail: const Text("Verified User", style: TextStyle(color: Colors.black87)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: _currentProfilePic.isNotEmpty ? NetworkImage(_currentProfilePic) : null,
                child: _currentProfilePic.isEmpty ? const Icon(Icons.person, color: Colors.amber) : null,
              ),
            ),
            ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit Profile"),
                onTap: () {
                  Navigator.pop(context);
                  _showEditProfile();
                }),
            const Divider(),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text("Logout"), onTap: _handleLogout),
          ]),
        ),
        body: isLoading && myScans.isEmpty
            ? const Center(child: CircularProgressIndicator(color: Colors.amber))
            : TabBarView(children: [
                // TAB 1: SCANNER
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.amber, width: 2),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]
                        ),
                        child: _image == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [Icon(Icons.image_search, size: 80, color: Colors.grey), Text("No Image Captured")])
                            : ClipRRect(borderRadius: BorderRadius.circular(13), child: Image.file(_image!, fit: BoxFit.cover)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(children: [
                          Text(_confidence > 0 ? "Result: $_result" : _result,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          if (_confidence > 0) ...[
                            Text("Confidence: ${_confidence.toStringAsFixed(1)}%",
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ]
                        ]),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                          child: ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text("SCAN"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.upload_file),
                              label: const Text("GALLERY"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black))),
                    ])
                  ]),
                ),
                // TAB 2: HISTORY
                Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: "Search results...",
                        prefixIcon: const Icon(Icons.search, color: Colors.amber),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: fetchMyHistory,
                      child: currentScans.isEmpty
                          ? ListView(children: const [SizedBox(height: 100), Center(child: Text("No records found."))])
                          : ListView.builder(
                              itemCount: currentScans.length,
                              itemBuilder: (context, i) => Card(
                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child: ListTile(
                                  onTap: () => _showDetailsDialog(currentScans[i]),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.amber.shade100,
                                    backgroundImage: currentScans[i]['image_url'] != null && currentScans[i]['image_url'] != ""
                                        ? NetworkImage(currentScans[i]['image_url'])
                                        : null,
                                    child: currentScans[i]['image_url'] == null || currentScans[i]['image_url'] == ""
                                        ? const Icon(Icons.history, color: Colors.amber)
                                        : null,
                                  ),
                                  title: Text(currentScans[i]['color_result'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(formatDateTime(currentScans[i]['created_at'] ?? "")),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                                ),
                              ),
                            ),
                    ),
                  ),
                  _buildPaginationFooter(),
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
  List filteredScans = [];
  TextEditingController searchController = TextEditingController();
  
  bool isLoading = false;
  int currentPage = 1;
  int itemsPerPage = 10; 

  final String apiUrl = "https://honey-classifier.islanddigitalguide.com/api.php";

  @override
  void initState() {
    super.initState();
    fetchAdminData();
  }
String formatDateTime(String rawDate) {
  if (rawDate == "N/A" || rawDate.isEmpty) return "N/A";
  try {
    
    DateTime dateTime = DateTime.parse(rawDate);
    return DateFormat('MMMM dd, yyyy - hh:mm a').format(dateTime);
  } catch (e) {
    return rawDate; 
  }
}
  // ================= DATA FETCHING & REFRESH =================

  Future<void> fetchAdminData() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("$apiUrl?action=admin_data"));
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        setState(() {
          users = res['users'] ?? [];
          scans = res['scans'] ?? [];
          filteredScans = scans;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetching admin data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Hindi ma-load ang data.")),
      );
    }
  }

  // ================= LOGOUT LOGIC =================

void _handleLogout() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Admin Logout',
      desc: 'Are you sure you want to exit the Admin Monitoring panel?',
      btnCancelOnPress: () {}, 
      btnOkColor: Colors.red,
      btnOkText: "Yes, Logout",
      btnOkOnPress: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      },
    ).show();
  }
  // ================= FILTER / SEARCH =================

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

  // ================= UI HELPERS =================

  Widget _buildStarRating(String rating) {
    int r = int.tryParse(rating) ?? 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Icon(
          index < r ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 22,
        );
      }),
    );
  }

  Widget _buildPieChart() {
    int extraLight = scans.where((s) => s['color_result'].toString().toLowerCase().contains('extra')).length;
    int light = scans.where((s) {
      String res = s['color_result'].toString().toLowerCase();
      return res.contains('light') && !res.contains('extra');
    }).length;
    int amber = scans.where((s) {
      String res = s['color_result'].toString().toLowerCase();
      return res.contains('amber') && !res.contains('light');
    }).length;

    int total = amber + extraLight + light;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Honey Type Distribution", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: total == 0 
                ? const Center(child: Text("No scan data available"))
                : PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        if (amber > 0) PieChartSectionData(color: Colors.brown, value: amber.toDouble(), title: '$amber', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        if (extraLight > 0) PieChartSectionData(color: Colors.orange, value: extraLight.toDouble(), title: '$extraLight', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        if (light > 0) PieChartSectionData(color: Colors.amber, value: light.toDouble(), title: '$light', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendItem("Amber", Colors.brown),
                const SizedBox(width: 15),
                _legendItem("Ex Light", Colors.orange),
                const SizedBox(width: 15),
                _legendItem("Light", Colors.amber),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _legendItem(String name, Color color) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(name, style: const TextStyle(fontSize: 12))
    ]);
  }

  // ================= MODAL DETAILS =================

  void _showScanDetails(Map scan) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text("SCAN REPORT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
            const SizedBox(height: 15),
            if (scan['image_url'] != null && scan['image_url'] != "")
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  scan['image_url'], 
                  height: 180, 
                  width: double.infinity, 
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180, color: Colors.grey[200], child: Icon(Icons.broken_image, color: Colors.grey[400], size: 50),
                  ),
                ),
              ),
            const SizedBox(height: 15),
            
            _detailRow("Date & Time:", formatDateTime(scan['created_at'] ?? "N/A")),
            _detailRow("User:", scan['fullname'] ?? "N/A"),
            _detailRow("Result:", scan['color_result'] ?? "N/A"),
            _detailRow("Confidence:", scan['confidence'] ?? "0%"),
            _detailRow("Pfund Value:", scan['pfund_value'] ?? "N/A"),
            
            const Divider(height: 30),
            
            const Text("User Feedback", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildStarRating(scan['rating']?.toString() ?? "0"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: Text(
                scan['comment'] != null && scan['comment'] != "" ? scan['comment'] : "No comment provided.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
      btnOkOnPress: () {},
      btnOkColor: Colors.amber,
      btnOkText: "Close",
    ).show();
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  // ================= PAGINATION =================

  Widget _buildPaginationFooter() {
    int totalItems = filteredScans.length;
    int totalPages = (totalItems / itemsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;
    int startEntry = totalItems == 0 ? 0 : (currentPage - 1) * itemsPerPage + 1;
    int endEntry = (currentPage * itemsPerPage) > totalItems ? totalItems : (currentPage * itemsPerPage);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade300))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Showing $startEntry-$endEntry of $totalItems", style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: currentPage > 1 ? () => setState(() => currentPage--) : null),
              Text("$currentPage / $totalPages", style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: currentPage < totalPages ? () => setState(() => currentPage++) : null),
            ],
          ),
        ],
      ),
    );
  }

  // ================= MAIN BUILD =================

  @override
  Widget build(BuildContext context) {
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
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.analytics), text: "Analytics"), 
              Tab(icon: Icon(Icons.history), text: "History")
            ],
          ),
          actions: [
            IconButton(
              onPressed: fetchAdminData, 
              icon: isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Icon(Icons.refresh)
            ),
            IconButton(onPressed: _handleLogout, icon: const Icon(Icons.logout)),
          ],
        ),
        body: isLoading && scans.isEmpty
        ? const Center(child: CircularProgressIndicator(color: Colors.amber))
        : TabBarView(children: [
            // TAB 1: ANALYTICS
            RefreshIndicator(
              onRefresh: fetchAdminData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(children: [
                      Expanded(child: _buildStatCard("Users", users.length.toString(), Icons.people, Colors.blue)),
                      Expanded(child: _buildStatCard("Scans", scans.length.toString(), Icons.insert_chart, Colors.orange)),
                      Expanded(child: _buildStatCard("Amber", scans.where((s) => s['color_result'].toString().toLowerCase().contains('amber')).length.toString(), Icons.opacity, Colors.brown)),
                    ]),
                  ),
                  _buildPieChart(), 
                  const Divider(),
                  const Padding(padding: EdgeInsets.all(8.0), child: Text("Active Users", style: TextStyle(fontWeight: FontWeight.bold))),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: users.length > 5 ? 5 : users.length, 
                    itemBuilder: (context, i) => ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.amber, child: Icon(Icons.person, color: Colors.white)),
                      title: Text(users[i]['fullname'] ?? "Unknown"),
                      subtitle: Text("Username: ${users[i]['username']}"),
                    ),
                  ),
                ]),
              ),
            ),

            // TAB 2: HISTORY
            Column(children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: searchController,
                  onChanged: filterScans,
                  decoration: InputDecoration(
                    hintText: "Search name or result...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white
                  ),
                ),
              ),
              Expanded(
                child: currentScans.isEmpty 
                  ? const Center(child: Text("No records found."))
                  : ListView.builder(
                      itemCount: currentScans.length,
                      itemBuilder: (context, i) => Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.amber[100],
                            backgroundImage: (currentScans[i]['image_url'] != null && currentScans[i]['image_url'] != "")
                              ? NetworkImage(currentScans[i]['image_url']) : null,
                            child: (currentScans[i]['image_url'] == null || currentScans[i]['image_url'] == "")
                              ? const Icon(Icons.history, color: Colors.orange) : null
                          ),
                          title: Text(currentScans[i]['fullname'] ?? "User"),
                          subtitle: Text("${currentScans[i]['color_result']} - ${formatDateTime(currentScans[i]['created_at'])}"),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          onTap: () => _showScanDetails(currentScans[i]),
                        ),
                      ),
                    ),
              ),
              _buildPaginationFooter(), 
            ]),
          ]),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(children: [
          Icon(icon, color: color),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ]),
      ),
    );
  }
}