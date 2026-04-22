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
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'TimesNewRoman',
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.amber[50],
      ),
      home: const LoginPage(),
    ),
  );
}

const String apiUrl = "https://honey-classifier.islanddigitalguide.com/api.php";
class HoneyDeepDiveScreen extends StatelessWidget {
  const HoneyDeepDiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Honey Science & Knowledge"),
        backgroundColor: Colors.amber.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("How Honey is Produced"),
            const Text(
              "Honey production starts with bees collecting nectar. Through enzymatic activity and water evaporation, bees transform thin nectar into thick, pure honey stored in wax honeycombs.",
              style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 15),
            _buildLocalImage('assets/images/production_process.png'),
            
            const SizedBox(height: 30),

            _sectionTitle("Why Colors Differ?"),
            const Text(
              "The color of honey is naturally determined by the floral source. Minerals, pollen, and antioxidants play a huge role in the final shade.",
              style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 15),
            _infoBox("Color Rule:", "Light honey is usually mild and floral, while Dark honey is bold, earthy, and mineral-rich.", Colors.amber.shade50),
            
            const SizedBox(height: 30),

            _sectionTitle("Health Benefits"),
            _benefitRow(Icons.health_and_safety, "Natural Antioxidant", "Protects your body from cell damage."),
            _benefitRow(Icons.healing, "Wound Healing", "Medical-grade honey is used to treat burns and infections."),
            _benefitRow(Icons.record_voice_over, "Cough Suppressant", "A natural remedy for soothing sore throats."),
            
            const SizedBox(height: 30),

            _sectionTitle("Chemical Composition"),
            Table(
              border: TableBorder.all(color: Colors.amber.shade200, width: 1, borderRadius: BorderRadius.circular(8)),
              children: [
                _buildTableRow("Component", "Percentage", isHeader: true),
                _buildTableRow("Fructose", "38.2%"),
                _buildTableRow("Glucose", "31.3%"),
                _buildTableRow("Water", "17.2%"),
                _buildTableRow("Minerals & Vitamins", "13.3%"),
              ],
            ),
            
            const SizedBox(height: 30),

            _sectionTitle("Honey Crystallization"),
            const Text(
              "Crystallization is a natural process and a sign of high-quality, pure honey. It doesn't mean the honey is spoiled.",
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 10),
            _infoBox("Tip:", "To liquify crystallized honey, place the jar in warm water (max 40°C).", Colors.blue.shade50),

            const SizedBox(height: 30),

            _sectionTitle("Proper Storage"),
            _benefitRow(Icons.thermostat, "Keep at Room Temp", "Avoid direct sunlight and keep it in a cool, dry place."),
            _benefitRow(Icons.inventory_2, "Airtight Container", "Honey absorbs moisture from the air, so keep the lid tight."),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
  );

  Widget _benefitRow(IconData icon, String title, String desc) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(backgroundColor: Colors.amber.shade100, radius: 18, child: Icon(icon, size: 20, color: Colors.amber.shade900)),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(desc, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _infoBox(String label, String value, Color color) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4),
        children: [
          TextSpan(text: "$label ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          TextSpan(text: value),
        ],
      ),
    ),
  );

  Widget _buildLocalImage(String assetPath) => ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child: Image.asset(assetPath, height: 200, width: double.infinity, fit: BoxFit.cover, 
    errorBuilder: (c, e, s) => Container(height: 200, color: Colors.grey.shade200, child: const Icon(Icons.image))),
  );

  TableRow _buildTableRow(String col1, String col2, {bool isHeader = false}) => TableRow(
    decoration: BoxDecoration(color: isHeader ? Colors.amber.shade100 : Colors.transparent),
    children: [
      Padding(padding: const EdgeInsets.all(12), child: Text(col1, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal))),
      Padding(padding: const EdgeInsets.all(12), child: Text(col2, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal))),
    ],
  );
}
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
      final response = await http
          .post(
            Uri.parse("$apiUrl?action=login"),
            body: {"username": _user.text, "password": _pass.text},
          )
          .timeout(const Duration(seconds: 15));

      final res = jsonDecode(response.body);

      if (res['status'] == 'success') {
        final userData = res['user'];
        String role = userData['role'].toString();

        if (!mounted) return;
        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserDashboard(
                userId: userData['id'].toString(),
                name: userData['fullname'],
                profilePic: userData['profile_pic'] ?? "",
              ),
            ),
          );
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.bakery_dining,
                        size: 100,
                        color: Colors.amber,
                      ),
                    ),
                    const Text(
                      "Honey Classifier",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _user,
                      decoration: InputDecoration(
                        labelText: "Username",
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _pass,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "LOGIN",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      ),
                      child: const Text("Don't have an account? Create one"),
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
      final response = await http.post(
        Uri.parse("$apiUrl?action=register"),
        body: {
          "fullname": _name.text,
          "username": _user.text,
          "password": _pass.text,
        },
      );
      if (jsonDecode(response.body)['status'] == 'success') {
        if (!mounted) return;
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: 'Registration Success!',
          desc: 'You can now login with your account.',
          btnOkOnPress: () {
            Navigator.pop(context);
          },
        ).show();
      }
    } catch (e) {
      debugPrint(e.toString());
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_add, size: 80, color: Colors.amber),
                    const SizedBox(height: 10),
                    const Text(
                      "Register Account",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _name,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        prefixIcon: const Icon(Icons.badge),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _user,
                      decoration: InputDecoration(
                        labelText: "Username",
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _pass,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "SUBMIT REGISTRATION",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Already have an account? Login"),
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
  List? _recognitions;
  File? _newProfilePic;
  String _result = "Ready to scan honey";
  String _currentName = "";
  String _currentProfilePic = "";
  double _confidence = 0.0;
  bool isLoading = false;

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

  // Sa loob ng iyong classification service o state class
  Future loadModel() async {
    String? res = await Tflite.loadModel(
      model: "assets/honey_model.tflite",
      labels: "assets/labels.txt",
      numThreads: 1, // mas stable sa mobile
      isAsset: true,
      useGpuDelegate:
          false, // set to false muna para iwas crash sa ibang android
    );
    print("Model loaded: $res");
  }

  Future<void> fetchMyHistory() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final url = Uri.parse(
        "$apiUrl?action=user_history&user_id=${widget.userId}",
      );
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

  String getResultMessage() {
    if (_recognitions == null || _recognitions!.isEmpty) {
      return "Ready to Scan";
    }

    if (_result.toLowerCase().contains("not")) {
      return "Invalid Sample: This is not recognized as honey.";
    } else {
      return "Result: $_result (${_confidence.toStringAsFixed(0)}%)";
    }
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
          (route) => false,
        );
      },
    ).show();
  }

  Future<void> _updateProfileInDatabase(String newName) async {
    setState(() => isLoading = true);
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$apiUrl?action=update_profile"),
      );
      request.fields['id'] = widget.userId;
      request.fields['fullname'] = newName;

      if (_newProfilePic != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_pic',
            _newProfilePic!.path,
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          setState(() {
            _currentName = data['user']['fullname'];
            _currentProfilePic =
                data['user']['profile_pic'] ?? _currentProfilePic;
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

  Future<void> _saveScanWithFeedback(
    String res,
    double conf,
    String pfund,
    String rate,
    String comm,
    File img,
  ) async {
    setState(() => isLoading = true);

    // OPTIONAL: Gawing readable ang label bago i-save
    String formattedRes = res;
    if (res == 'Extralightamber') formattedRes = 'Extra Light Amber';
    if (res == 'LightAmber') formattedRes = 'Light Amber';

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$apiUrl?action=save_scan_feedback"),
      );

      request.fields['user_id'] = widget.userId;
      request.fields['color_result'] =
          formattedRes; // Ginamit ang formatted label
      request.fields['confidence'] =
          "${conf.clamp(0.0, 100.0).toStringAsFixed(1)}%";
      request.fields['pfund_value'] = pfund;
      request.fields['rating'] = rate;
      request.fields['comment'] = comm;

      // Pag-attach ng image
      request.files.add(await http.MultipartFile.fromPath('image', img.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        // Kunin ang response body kung kailangan i-debug
        // var responseData = await response.stream.bytesToString();

        await fetchMyHistory(); // Refresh history list

        if (!mounted) return;

        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: 'Analysis Saved!',
          desc: 'Thank you for your feedback.',
          btnOkOnPress: () {},
        ).show();
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error saving scan: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save. Please check your internet."),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================= LOGIC & UI HELPERS =================

  String _getPfundValue(String result) {
  // Ginagamit natin ang .toLowerCase() at .contains() para mas madaling mahuli ang "Negative"
  if (result.toLowerCase().contains('negative')) {
    return 'N/A (Adulterated/Fake)';
  }

  switch (result) {
    case 'Extralightamber': 
      return '17mm - 34mm';
    case 'LightAmber': 
      return '51mm - 85mm';
    case 'Amber':
      return '86mm - 114mm';
    default:
      return 'Unknown';
  }
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
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    setDialogState(() => _newProfilePic = File(picked.path));
                  }
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.amber,
                  backgroundImage: _newProfilePic != null
                      ? FileImage(_newProfilePic!)
                      : (_currentProfilePic.isNotEmpty
                                ? NetworkImage(_currentProfilePic)
                                : null)
                            as ImageProvider?,
                  child: (_newProfilePic == null && _currentProfilePic.isEmpty)
                      ? const Icon(
                          Icons.camera_alt,
                          size: 30,
                          color: Colors.white,
                        )
                      : null,
                ),
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateProfileInDatabase(nameController.text.trim());
              },
              child: const Text("Save Changes"),
            ),
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
            Text(
              scan['color_result']?.toUpperCase() ?? "SCAN REPORT",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 15),
            if (scan['image_url'] != null && scan['image_url'] != "")
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  scan['image_url'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      const Icon(Icons.broken_image, size: 50),
                ),
              ),
            const SizedBox(height: 15),
            _detailRow("Date Scanned:", scan['created_at'] ?? "N/A"),
            _detailRow("Confidence:", scan['confidence'] ?? "0%"),
            _detailRow("Pfund Value:", scan['pfund_value'] ?? "N/A"),
            const Divider(),
            const Text(
              "Your Feedback",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            _buildStarRating(scan['rating']?.toString() ?? "0"),
            const SizedBox(height: 8),
            Text(
              "\"${scan['comment'] ?? "No comment provided."}\"",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      btnOkOnPress: () {},
      btnOkColor: Colors.amber,
      btnOkText: "Close Report",
    ).show();
  }

 // 1. HELPER FUNCTION PARA SA DESCRIPTION
  // Ipinapakita ang maikling detalye base sa naging resulta ng scan
  String _getHoneyDescription(String label) {
    String lowerLabel = label.toLowerCase();
    if (lowerLabel.contains('negative')) {
      return "This sample shows abnormal characteristics. It may contain excessive sugar syrup, additives, or is not pure honey.";
    }
    if (lowerLabel.contains('extra light')) {
      return "Very mild in flavor and light in color. Common in early spring flowers, highly prized for its delicate sweetness.";
    }
    if (lowerLabel.contains('light amber')) {
      return "The most popular honey grade. It has a characteristic mild floral taste, perfect for everyday use and table honey.";
    }
    if (lowerLabel.contains('amber')) {
      return "Rich and full-bodied flavor. Darker honey usually contains more antioxidants and minerals than lighter varieties.";
    }
    return "Analyzing sample characteristics based on color intensity and light transmittance.";
  }

  // 2. MAIN DIALOG FUNCTION
  // Ito ang lalabas pagkatapos ng scanning process
  void _showFeedbackDialog(
    String label,
    double conf,
    String pfund,
    File imageFile,
  ) {
    String displayLabel = label;
    
    // Mapping para sa readable version ng labels sa UI
    if (label == 'Extralightamber') displayLabel = 'Extra Light Amber';
    else if (label == 'LightAmber') displayLabel = 'Light Amber';
    else if (label == 'Amber') displayLabel = 'Amber';
    else if (label.toLowerCase().contains('negative amber')) displayLabel = 'Fake: Amber Style';
    else if (label.toLowerCase().contains('negative extra light')) displayLabel = 'Fake: Extra Light Style';
    else if (label.toLowerCase().contains('negative light')) displayLabel = 'Fake: Light Amber Style';

    // Check kung ang sample ay Fake (Negative) o legit honey
    bool isNotHoney = label.toLowerCase().contains("not") || 
                      label.toLowerCase().contains("negative");

    String selectedRating = "5";
    
    // Default comment depende sa result
    String selectedComment = isNotHoney
        ? "Correctly identified as invalid."
        : "Legit! Accurate result.";

    String honeyDesc = _getHoneyDescription(label);

    AwesomeDialog(
      context: context,
      // Pula ang icon pag Fake, Gold/Amber pag Legit
      dialogType: isNotHoney ? DialogType.warning : DialogType.info,
      animType: AnimType.scale,
      headerAnimationLoop: false, 
      title: 'Scan Result',
      body: StatefulBuilder(
        builder: (context, setStateSB) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Text(
                displayLabel, 
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: isNotHoney ? Colors.red.shade900 : Colors.amber.shade700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Confidence: ${conf.clamp(0.0, 100.0).toStringAsFixed(1)}%",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 15),

              // --- DESCRIPTION BOX ---
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isNotHoney ? Colors.red.shade50 : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isNotHoney ? Colors.red.shade200 : Colors.amber.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      isNotHoney ? "PRODUCT ALERT" : "GRADE DESCRIPTION",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isNotHoney ? Colors.red.shade800 : Colors.amber.shade900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      honeyDesc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              Text(
                isNotHoney
                    ? "Sample does not match pure honey standards."
                    : "Pfund Value: $pfund",
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 30),

              const Text(
                "How accurate was the result?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Dropdown para sa Rating (Accuracy)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedRating,
                    isExpanded: true,
                    items: ["5", "4", "3", "2", "1"]
                        .map((s) => DropdownMenuItem(value: s, child: Text("$s Stars")))
                        .toList(),
                    onChanged: (v) => setStateSB(() => selectedRating = v!),
                  ),
                ),
              ),

              const SizedBox(height: 15),
              const Text(
                "Quick Comment:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),

              // Dropdown para sa Quick Comment (Feedback)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedComment,
                    isExpanded: true,
                    items: (isNotHoney
                            ? [
                                "Correctly identified as invalid.",
                                "Accurate detection.",
                                "Not sure.",
                                "Should be honey.",
                              ]
                            : [
                                "Legit! Accurate result.",
                                "Matched expectations.",
                                "Slightly different.",
                                "Inaccurate.",
                                "Helpful App!",
                              ])
                        .map((s) => DropdownMenuItem<String>(
                              value: s,
                              child: Text(s, style: const TextStyle(fontSize: 13)),
                            ))
                        .toList(),
                    onChanged: (v) => setStateSB(() => selectedComment = v!),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      btnOkText: "SAVE SCAN",
      btnOkColor: isNotHoney ? Colors.red : Colors.amber,
      btnOkOnPress: () => _saveScanWithFeedback(
        label,
        conf,
        pfund,
        selectedRating,
        selectedComment,
        imageFile,
      ),
      btnCancelOnPress: () {},
      btnCancelText: "DISCARD",
    ).show();
  }
  // Ginagamit sa Scan Report modal para sa malinis na presentation ng data
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // Visual representation ng user rating (stars) sa Admin/History panel
  Widget _buildStarRating(String rating) {
    int r = int.tryParse(rating) ?? 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) => Icon(
          index < r ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 24,
        ),
      ),
    );
  }
  // ================= CLASSIFICATION =================

  Future<void> _classifyHoney(File image) async {
    setState(() => isLoading = true);

    try {
      // Siguraduhin na ang imageMean at imageStd ay tugma sa training settings mo
      var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 1,
        threshold: 0.3, // Minimum confidence para pansinin ang result
        imageMean: 127.5,
        imageStd: 127.5,
      );

      if (output != null && output.isNotEmpty) {
        setState(() {
          _recognitions = output;
          String rawLabel =
              output[0]['label']; // Halimbawa: "0 Amber" o "3 Not Honey"
          double confidenceScore = (output[0]['confidence'] * 100);

          // 1. Linisin ang label (Tinatanggal ang numero at extra spaces)
          String cleanedLabel = rawLabel
              .replaceFirst(RegExp(r'^\d+\s+'), '')
              .trim();

          // 2. CHECKING LOGIC: "Real Honey" vs "Not Honey"
          // Force "Not Honey" kung:
          // - Ang label mismo ay "Not Honey"
          // - O kung mababa ang confidence (hindi sigurado ang AI)
          if (cleanedLabel.toLowerCase().contains("not") ||
              confidenceScore < 70) {
            _result = "Not Honey";
            _confidence = confidenceScore;
          } else {
            // Dito papasok ang Amber, Extralightamber, at LightAmber
            _result = cleanedLabel;
            _confidence = confidenceScore;
          }
        });

        // 3. Kunin ang Pfund Value base sa _result
        String pfund = _getPfundValue(_result);

        // 4. Ipakita ang Result/Feedback Dialog
        _showFeedbackDialog(_result, _confidence, pfund, image);
      } else {
        // Kapag walang ma-detect (sobrang dilim o labo)
        setState(() {
          _result = "Not Honey";
          _confidence = 0.0;
        });
        _showFeedbackDialog("Not Honey", 0.0, "N/A", image);
      }
    } catch (e) {
      debugPrint("Error sa classification: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Detection failed. Please try again.")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Function para sa pagkuha ng litrato (Camera o Gallery)
  // Function para sa pagkuha ng litrato (Camera o Gallery) - No Modal Version
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Direkta na nating tatawagin ang ImagePicker nang walang AwesomeDialog
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _result = "Analyzing...";
          _confidence = 0.0;
        });

        // Simulan ang classification
        await _classifyHoney(_image!);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // Function para sa maayos na format ng petsa sa History
  String formatDateTime(String rawDate) {
    if (rawDate == "N/A" || rawDate.isEmpty) return "N/A";
    try {
      // Kinokonvert ang String date galing database (MySQL format) patungong Readable format
      DateTime dateTime = DateTime.parse(rawDate);
      return DateFormat('MMMM dd, yyyy - hh:mm a').format(dateTime);
    } catch (e) {
      // Kung sakaling may error sa parsing, ibalik ang original string
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
          Text(
            "Page $currentPage of $totalPages",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 1
                    ? () => setState(() => currentPage--)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages
                    ? () => setState(() => currentPage++)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- PAGINATION LOGIC ---
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > filteredScans.length) endIndex = filteredScans.length;

    List currentScans =
        filteredScans.isEmpty || startIndex >= filteredScans.length
        ? []
        : filteredScans.sublist(startIndex, endIndex);

    return DefaultTabController(
      length: 3, // Siguraduhining 3 ang length
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Honey Quality Analyst"),
          backgroundColor: Colors.amber,
          bottom: const TabBar(
            indicatorColor: Colors.black,
            tabs: [
              Tab(icon: Icon(Icons.camera_alt), text: "Scanner"),
              Tab(
                icon: Icon(Icons.info_outline),
                text: "Honey Info",
              ), // Bagong Tab 2
              Tab(icon: Icon(Icons.history), text: "History"), // Naging Tab 3
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.amber),
                accountName: Text(
                  _currentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                accountEmail: const Text(
                  "Verified User",
                  style: TextStyle(color: Colors.black87),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: _currentProfilePic.isNotEmpty
                      ? NetworkImage(_currentProfilePic)
                      : null,
                  child: _currentProfilePic.isEmpty
                      ? const Icon(Icons.person, color: Colors.amber)
                      : null,
                ),
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
                onTap: _handleLogout,
              ),
            ],
          ),
        ),

        //part 4
        body: isLoading && myScans.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              )
            : TabBarView(
                children: [
                  // --- TAB 1: SCANNER ---
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.amber, width: 2),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 5),
                              ],
                            ),
                            child: _image == null
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_search,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                      Text("No Image Captured"),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(13),
                                    child: Image.file(
                                      _image!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              children: [
                                Text(
                                  _confidence > 0
                                      ? "Result: $_result"
                                      : _result,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_confidence > 0) ...[
                                  Text(
                                    "Confidence: ${_confidence.toStringAsFixed(1)}%",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _pickImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt),
                                label: const Text("SCAN"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  foregroundColor: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _pickImage(ImageSource.gallery),
                                icon: const Icon(Icons.upload_file),
                                label: const Text("GALLERY"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

            // --- TAB: HONEY INFO ---
SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // --- MODERN HEADER ---
      Container(
        padding: const EdgeInsets.only(bottom: 10),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.amber.shade700,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.bakery_dining, color: Colors.amber.shade900, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Honey Classification in Catanduanes",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),

      // --- 1. EXTRA LIGHT AMBER SECTION ---
      _buildHoneyCard(
        title: "Extra Light Amber Honey",
        areas: "Viga, Bagamanoc, Panganiban",
        species: "Apis cerana, Tetragonula biroi",
        sources: "Coconut, Acacia, Guava",
        desc: "Very light golden color, mild taste",
        cardColor: Colors.orange.shade50,
        accentColor: Colors.orange.shade300,
        icon: Icons.brightness_high_outlined,
      ),
      _buildImagePreview('assets/images/extra_light.png'),

      const SizedBox(height: 24),

      // --- 2. LIGHT AMBER SECTION ---
      _buildHoneyCard(
        title: "Light Amber Honey",
        areas: "Pandan, Viga",
        species: "Apis cerana",
        sources: "Mango, Banana, Papaya",
        desc: "Golden amber color, balanced sweetness",
        cardColor: Colors.amber.shade50,
        accentColor: Colors.amber.shade400,
        icon: Icons.wb_sunny_outlined,
      ),
      _buildImagePreview('assets/images/light_amber.png'),

      const SizedBox(height: 24),

      // --- 3. AMBER SECTION ---
      _buildHoneyCard(
        title: "Amber Honey",
        areas: "Caramoran, Viga",
        species: "Apis dorsata",
        sources: "Wild forest flowers, Duhat, Narra",
        desc: "Darker amber color, stronger flavor",
        cardColor: Colors.brown.shade50,
        accentColor: Colors.brown.shade400,
        icon: Icons.eco_outlined,
      ),
      _buildImagePreview('assets/images/amber.png'),

      const SizedBox(height: 32),

      // --- INTERACTIVE IMAGE BUTTON ---
      const Text(
        "Learn More About Honey",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HoneyDeepDiveScreen()),
          );
        },
        child: _buildLocalHeroImage('assets/images/learn_more_hero.png'),
      ),
      const SizedBox(height: 30),
    ],
  ),
),
                  // --- TAB 3: HISTORY ---
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextField(
                          controller: searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: "Search results...",
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.amber,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: fetchMyHistory,
                          child: currentScans.isEmpty
                              ? ListView(
                                  children: const [
                                    SizedBox(height: 100),
                                    Center(child: Text("No records found.")),
                                  ],
                                )
                              : ListView.builder(
                                  itemCount: currentScans.length,
                                  itemBuilder: (context, i) => Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    child: ListTile(
                                      onTap: () =>
                                          _showDetailsDialog(currentScans[i]),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.amber.shade100,
                                        backgroundImage:
                                            currentScans[i]['image_url'] !=
                                                    null &&
                                                currentScans[i]['image_url'] !=
                                                    ""
                                            ? NetworkImage(
                                                currentScans[i]['image_url'],
                                              )
                                            : null,
                                        child:
                                            currentScans[i]['image_url'] ==
                                                    null ||
                                                currentScans[i]['image_url'] ==
                                                    ""
                                            ? const Icon(
                                                Icons.history,
                                                color: Colors.amber,
                                              )
                                            : null,
                                      ),
                                      title: Text(
                                        currentScans[i]['color_result'] ??
                                            "Unknown",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        formatDateTime(
                                          currentScans[i]['created_at'] ?? "",
                                        ),
                                      ),
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      _buildPaginationFooter(),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
  // SECTION TITLE
Widget _sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

// LOCAL IMAGE
Widget _buildLocalImage(String path) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Image.asset(
      path,
      fit: BoxFit.cover,
    ),
  );
}

// INFO BOX
Widget _infoBox(String title, String text, Color color) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black),
        children: [
          TextSpan(
            text: "$title ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: text),
        ],
      ),
    ),
  );
}

// TABLE ROW
TableRow _buildTableRow(String a, String b, {bool isHeader = false}) {
  return TableRow(
    decoration: isHeader
        ? const BoxDecoration(color: Color(0xFFFFF3CD))
        : null,
    children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          a,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          b,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    ],
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

  final String apiUrl =
      "https://honey-classifier.islanddigitalguide.com/api.php";

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
        SnackBar(content: Text("Error: Data fetch failed. Please try again.")),
      );
    }
  }
//part 5
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
        return name.contains(query.toLowerCase()) ||
            result.contains(query.toLowerCase());
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
    int extraLight = scans
        .where(
          (s) => s['color_result'].toString().toLowerCase().contains('extra'),
        )
        .length;
    int light = scans.where((s) {
      String res = s['color_result'].toString().toLowerCase();
      return res.contains('light') && !res.contains('extra');
    }).length;
    int amber = scans.where((s) {
      String res = s['color_result'].toString().toLowerCase();
      return res.contains('amber') && !res.contains('light');
    }).length;

    // BAGONG ADDITION: Bilangin ang Not Honey
    int invalid = scans
        .where(
          (s) => s['color_result'].toString().toLowerCase().contains('not'),
        )
        .length;

    int total = amber + extraLight + light + invalid;

    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Honey Quality Distribution",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            SizedBox(
              height: 180, // Fixed height para sa chart
              child: total == 0
                  ? const Center(child: Text("No scan data available"))
                  : PieChart(
                      PieChartData(
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2, // Space sa pagitan ng slices
                        centerSpaceRadius:
                            40, // Ginagawa itong Donut chart (mas modern tignan)
                        sections: [
                          if (amber > 0)
                            PieChartSectionData(
                              color: Colors.brown,
                              value: amber.toDouble(),
                              title:
                                  '${((amber / total) * 100).toStringAsFixed(0)}%',
                              radius: 50,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (extraLight > 0)
                            PieChartSectionData(
                              color: Colors.orange,
                              value: extraLight.toDouble(),
                              title:
                                  '${((extraLight / total) * 100).toStringAsFixed(0)}%',
                              radius: 50,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (light > 0)
                            PieChartSectionData(
                              color: Colors.amber,
                              value: light.toDouble(),
                              title:
                                  '${((light / total) * 100).toStringAsFixed(0)}%',
                              radius: 50,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (invalid > 0)
                            PieChartSectionData(
                              color: Colors.grey,
                              value: invalid.toDouble(),
                              title:
                                  '${((invalid / total) * 100).toStringAsFixed(0)}%', // <--- Dynamic percentage
                              radius: 50,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            // Legend layout using Wrap
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 10,
              children: [
                _legendItem("Amber", Colors.brown),
                _legendItem("Ex Light", Colors.orange),
                _legendItem("Light", Colors.amber),
                _legendItem("Invalid", Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(String name, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(name, style: const TextStyle(fontSize: 12)),
      ],
    );
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
            const Text(
              "SCAN REPORT",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
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
                    height: 180,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey[400],
                      size: 50,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 15),

            _detailRow(
              "Date & Time:",
              formatDateTime(scan['created_at'] ?? "N/A"),
            ),
            _detailRow("User:", scan['fullname'] ?? "N/A"),
            _detailRow("Result:", scan['color_result'] ?? "N/A"),
            _detailRow("Confidence:", scan['confidence'] ?? "0%"),
            _detailRow("Pfund Value:", scan['pfund_value'] ?? "N/A"),

            const Divider(height: 30),

            const Text(
              "User Feedback",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStarRating(scan['rating']?.toString() ?? "0"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                scan['comment'] != null && scan['comment'] != ""
                    ? scan['comment']
                    : "No comment provided.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
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
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.right,
            ),
          ),
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
    int endEntry = (currentPage * itemsPerPage) > totalItems
        ? totalItems
        : (currentPage * itemsPerPage);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Showing $startEntry-$endEntry of $totalItems",
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 1
                    ? () => setState(() => currentPage--)
                    : null,
              ),
              Text(
                "$currentPage / $totalPages",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages
                    ? () => setState(() => currentPage++)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= MAIN BUILD =================
  @override
  Widget build(BuildContext context) {
    // Logic para sa Pagination: Kinakalkula ang range ng items na ipapakita
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > filteredScans.length) endIndex = filteredScans.length;

    // Ang subset ng scans na ipapakita sa kasalukuyang page
    List currentScans =
        filteredScans.isEmpty || startIndex >= filteredScans.length
        ? []
        : filteredScans.sublist(startIndex, endIndex);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Monitoring"),
          backgroundColor: Colors.amber,
          bottom: const TabBar(
            indicatorColor: Colors.black,
            tabs: [
              Tab(icon: Icon(Icons.analytics), text: "Analytics"),
              Tab(icon: Icon(Icons.info), text: "Amber Info"),
              Tab(icon: Icon(Icons.history), text: "History"),
            ],
          ),
          actions: [
            IconButton(
              onPressed: fetchAdminData,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.refresh),
            ),
            IconButton(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: isLoading && scans.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              )
            : TabBarView(
                children: [
                  // ================= TAB 1: ANALYTICS =================
                  RefreshIndicator(
                    onRefresh: fetchAdminData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- 1. STAT CARDS ---
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    "Users",
                                    users.length.toString(),
                                    Icons.people,
                                    Colors.blue,
                                  ),
                                ),
                                Expanded(
                                  child: _buildStatCard(
                                    "Scans",
                                    scans.length.toString(),
                                    Icons.insert_chart,
                                    Colors.orange,
                                  ),
                                ),
                                Expanded(
                                  child: _buildStatCard(
                                    "Amber",
                                    scans
                                        .where(
                                          (s) => s['color_result']
                                              .toString()
                                              .toLowerCase()
                                              .contains('amber'),
                                        )
                                        .length
                                        .toString(),
                                    Icons.opacity,
                                    Colors.brown,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Divider(
                            height: 30,
                            thickness: 1,
                            indent: 20,
                            endIndent: 20,
                          ),

                          // --- 2. DATA VISUALIZATION SECTION ---
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.pie_chart,
                                  color: Colors.blueGrey,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Classification Overview",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          _buildPieChart(), // Siguraduhin na ang widget na ito ay gumagamit din ng 'scans' list

                          const SizedBox(height: 25),

                          // --- 3. DETAILED COLOR BREAKDOWN ---
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Text(
                              "Color Breakdown Details",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey.shade800,
                              ),
                            ),
                          ),
                          _buildColorBreakdownList(
                            scans,
                          ), // Ipinasa ang 'scans' list dito

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  // ================= TAB 2: AMBER INFORMATION =================
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- MODERN HEADER ---
                        Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.amber.shade700,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.bakery_dining,
                                color: Colors.amber.shade900,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "Honey Classification in Catanduanes",
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- 1. EXTRA LIGHT AMBER SECTION ---
                        _buildHoneyCard(
                          title: "Extra Light Amber Honey",
                          areas: "Viga, Bagamanoc, Panganiban",
                          species: "Apis cerana, Tetragonula biroi",
                          sources: "Coconut, Acacia, Guava",
                          desc: "Very light golden color, mild taste",
                          cardColor: Colors.orange.shade50,
                          accentColor: Colors.orange.shade300,
                          icon: Icons.brightness_high_outlined,
                        ),
                        _buildImagePreview(
                          'assets/images/extra_light.png',
                        ), // PNG Image dito

                        const SizedBox(height: 24),

                        // --- 2. LIGHT AMBER SECTION ---
                        _buildHoneyCard(
                          title: "Light Amber Honey",
                          areas: "Pandan, Viga",
                          species: "Apis cerana",
                          sources: "Mango, Banana, Papaya",
                          desc: "Golden amber color, balanced sweetness",
                          cardColor: Colors.amber.shade50,
                          accentColor: Colors.amber.shade400,
                          icon: Icons.wb_sunny_outlined,
                        ),
                        _buildImagePreview(
                          'assets/images/light_amber.png',
                        ), // PNG Image dito

                        const SizedBox(height: 24),

                        // --- 3. AMBER SECTION ---
                        _buildHoneyCard(
                          title: "Amber Honey",
                          areas: "Caramoran, Viga",
                          species: "Apis dorsata",
                          sources: "Wild forest flowers, Duhat, Narra",
                          desc: "Darker amber color, stronger flavor",
                          cardColor: Colors.brown.shade50,
                          accentColor: Colors.brown.shade400,
                          icon: Icons.eco_outlined,
                        ),
                        _buildImagePreview(
                          'assets/images/amber.png',
                        ), // PNG Image dito

                        const SizedBox(height: 32),

                        // --- INTERACTIVE IMAGE BUTTON ---
                        const Text(
                          "Learn More About Honey",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const HoneyDeepDiveScreen(),
                              ),
                            );
                          },
                          child: _buildLocalHeroImage(
                            'assets/images/learn_more_hero.png',
                          ), // Main Hero Image
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                  // ================= TAB 3: HISTORY =================
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          controller: searchController,
                          onChanged: filterScans,
                          decoration: InputDecoration(
                            hintText: "Search name or result...",
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: currentScans.isEmpty
                            ? const Center(child: Text("No records found."))
                            : ListView.builder(
                                itemCount: currentScans.length,
                                itemBuilder: (context, i) => Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      currentScans[i]['fullname'] ?? "User",
                                    ),
                                    subtitle: Text(
                                      "${currentScans[i]['color_result']}",
                                    ),
                                    onTap: () =>
                                        _showScanDetails(currentScans[i]),
                                  ),
                                ),
                              ),
                      ),
                      _buildPaginationFooter(),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}// --- HELPER: HONEY CARD ---
Widget _buildHoneyCard({
  required String title,
  required String areas,
  required String species,
  required String sources,
  required String desc,
  required Color cardColor,
  required Color accentColor,
  required IconData icon,
}) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
    ),
    child: IntrinsicHeight(
      child: Row(
        children: [
          Container(color: accentColor, width: 6),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.brown.shade900)),
                      Icon(icon, color: accentColor, size: 20),
                    ],
                  ),
                  const Divider(height: 20),
                  _infoLine(Icons.location_on, "Areas", areas),
                  _infoLine(Icons.bug_report, "Species", species),
                  _infoLine(Icons.local_florist, "Nectar", sources),
                  const SizedBox(height: 10),
                  Text("✨ $desc", style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _infoLine(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, fontSize: 13),
              children: [
                TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildImagePreview(String assetPath) {
  return Container(
    width: double.infinity,
    height: 160,
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
    ),
    child: ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
      child: Image.asset(assetPath, fit: BoxFit.cover, 
      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported))),
    ),
  );
}

Widget _buildLocalHeroImage(String assetPath) {
  return Container(
    width: double.infinity,
    height: 200,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), 
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6))]),
    child: Stack(
      children: [
        Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(15), 
        child: Image.asset(assetPath, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.amber)))),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.1)]),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("The Science of Amber", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("Tap to explore how honey is made and the differences in purity.", style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
      ],
    ),
  );
}
Widget _buildColorBreakdownList(List scans) {
  // Nagbibilang ng scans bawat color result
  Map<String, int> counts = {};
  for (var scan in scans) {
    String res = scan['color_result'] ?? "Unknown";
    counts[res] = (counts[res] ?? 0) + 1;
  }

  if (counts.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(child: Text("No data available yet.")),
    );
  }

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Color Classification Summary",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 15),
        ...counts.entries.map((e) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lens,
                        size: 12,
                        color: _getColorForClassification(e.key),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        e.key,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      e.value.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ],
              ),
              if (e.key != counts.keys.last) const Divider(height: 20),
            ],
          );
        }).toList(),
      ],
    ),
  );
}
Color _getColorForClassification(String label) {
  String lowerLabel = label.toLowerCase();

  // Unahin ang check para sa Negative
  if (lowerLabel.contains('negative')) {
    return Colors.red.shade900; // Dark red para sa fake
  }

  if (lowerLabel.contains('extra light')) return Colors.orange.shade200;
  if (lowerLabel.contains('light amber')) return Colors.amber;
  if (lowerLabel.contains('amber')) return Colors.brown;
  
  return Colors.grey;
}