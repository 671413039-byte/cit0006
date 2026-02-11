import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'internship_form.dart';

class InternshipDetailPage extends StatefulWidget {
  const InternshipDetailPage({super.key});

  @override
  State<InternshipDetailPage> createState() => _InternshipDetailPageState();
}

class _InternshipDetailPageState extends State<InternshipDetailPage> {
  List<Map<String, dynamic>> internshipList = [];
  List<Map<String, dynamic>> filteredList = [];
  List<Map<String, dynamic>> termsList = [];
  Timer? timer;
  bool isLoading = true;
  String? error;
  String? selectedTerm;
  int? selectedTypeIntern; // type_intern เป็น int จาก database

  final String _baseUrl = "http://192.168.1.228/api_copy/internship_api.php";

  @override
  void initState() {
    super.initState();
    fetchTermsData();
    fetchInternshipData();
    timer = Timer.periodic(const Duration(seconds: 10), (_) => fetchInternshipData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchTermsData() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl?action=terms"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          termsList = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      debugPrint("Error fetching terms: $e");
    }
  }

  Future<void> fetchInternshipData() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl?action=intern_company"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          internshipList = List<Map<String, dynamic>>.from(data);
          isLoading = false;
          error = null;
          applyFilters();
        });
      } else {
        setState(() {
          error = "Failed to load internship data";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Error: $e";
        isLoading = false;
      });
    }
  }

  void applyFilters() {
    filteredList = internshipList.where((item) {
      // Filter by void status - ensure type safety
      final voidValue = item['void'];
      if (voidValue != null && voidValue.toString() != '0') return false;
      
      // Filter by term
      if (selectedTerm != null && item['term']?.toString() != selectedTerm) return false;
      
      // Filter by type_intern
      if (selectedTypeIntern != null && item['type_intern'] != selectedTypeIntern) return false;
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ข้อมูลฝึกประสบการณ์"),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const InternshipFormPage(),
                      ),
                    ).then((_) => fetchInternshipData());
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("เพิ่ม"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchInternshipData,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Filters
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          // Term Dropdown
                          DropdownButtonFormField<String?>(
                            value: selectedTerm,
                            hint: const Text("เลือกภาคการศึกษา"),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text("ภาคการศึกษาทั้งหมด"),
                              ),
                              ...termsList.map((term) {
                                return DropdownMenuItem(
                                  value: term['term']?.toString(),
                                  child: Text(term['term']?.toString() ?? 'N/A'),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedTerm = value;
                                applyFilters();
                              });
                            },
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Type Intern Filter
                          DropdownButtonFormField<int?>(
                            value: selectedTypeIntern,
                            hint: const Text("เลือกประเภทการฝึก"),
                            items: const [
                              DropdownMenuItem(
                                value: null,
                                child: Text("ประเภทการฝึกทั้งหมด"),
                              ),
                              DropdownMenuItem(
                                value: 1,
                                child: Text("เตรียมฝึก"),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text("ฝึกประสบการณ์"),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedTypeIntern = value;
                                applyFilters();
                              });
                            },
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // List
                    Expanded(
                      child: filteredList.isEmpty
                          ? const Center(child: Text("ไม่มีข้อมูลฝึกประสบการณ์"))
                          : ListView.builder(
                              padding: const EdgeInsets.all(10),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final item = filteredList[index];
                                return Card(
                                  elevation: 0,
                                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                                  color: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['std_name'] ?? item['student_name'] ?? item['std_id'] ?? 'N/A',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'สถานประกอบการ: ${item['company_name'] ?? item['company_id'] ?? 'N/A'}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                ),
                                              ),
                                              Text(
                                                'ประเภทการฝึก: ${item['type_intern'] == 1 ? "เตรียมฝึก" : "ฝึกประสบการณ์"}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 70,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          InternshipFormPage(internship: item),
                                                    ),
                                                  ).then((_) => fetchInternshipData());
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                                ),
                                                child: const Text(
                                                  "แก้ไข",
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            SizedBox(
                                              width: 70,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  showCancelDialog(context, item);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                                ),
                                                child: const Text(
                                                  "ลบ",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  void showCancelDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("ยกเลิกข้อมูล"),
          content: const Text("คุณต้องการยกเลิกข้อมูลฝึกประสบการณ์นี้หรือไม่?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("ยกเลิก"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await cancelInternship(item);
              },
              child: const Text("ยืนยัน"),
            ),
          ],
        );
      },
    );
  }

  Future<void> cancelInternship(Map<String, dynamic> item) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl?action=cancel"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"std_id": item['std_id'], "term": item['term']}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ยกเลิกข้อมูลเรียบร้อย")),
        );
        fetchInternshipData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("เกิดข้อผิดพลาดในการยกเลิก")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}
