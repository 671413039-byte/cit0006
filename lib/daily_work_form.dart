import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DailyWorkFormPage extends StatefulWidget {
  final Map<String, dynamic>? dailyWork; // null for new, otherwise for edit

  const DailyWorkFormPage({Key? key, this.dailyWork}) : super(key: key);

  @override
  State<DailyWorkFormPage> createState() => _DailyWorkFormPageState();
}

class _DailyWorkFormPageState extends State<DailyWorkFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  late TextEditingController workDateController;
  late TextEditingController stdIdController;
  late TextEditingController termController;
  late TextEditingController typeInternController;
  late TextEditingController workDetailsController;
  late TextEditingController problemsController;
  late TextEditingController troubleshootController;

  List<Map<String, dynamic>> studentsList = [];
  List<Map<String, dynamic>> termsList = [];
  List<Map<String, dynamic>> internTypesList = [];

  String? selectedStudentId;
  String? selectedTerm;
  int selectedInternType = 1;

  DateTime? workDate;

  final String _baseUrl = "http://192.168.171.1/api_copy";

  @override
  void initState() {
    super.initState();
    workDateController = TextEditingController();
    stdIdController = TextEditingController();
    termController = TextEditingController();
    typeInternController = TextEditingController();
    workDetailsController = TextEditingController();
    problemsController = TextEditingController();
    troubleshootController = TextEditingController();

    if (widget.dailyWork != null) {
      _populateForm(widget.dailyWork!);
    }

    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    await Future.wait([
      _fetchStudents(),
      _fetchTerms(),
      _fetchInternTypes(),
    ]);
  }

  Future<void> _fetchStudents() async {
    try {
      final url = Uri.parse("$_baseUrl/getdatastudent.php");
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          if (mounted) {
            setState(() {
              studentsList = List<Map<String, dynamic>>.from(data);
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching students: $e");
    }
  }

  Future<void> _fetchTerms() async {
    try {
      final url = Uri.parse("$_baseUrl/getdataterm.php");
      print("DEBUG: Fetching terms from: $url");
      
      try {
        final response = await http.post(url).timeout(const Duration(seconds: 5));

        print("DEBUG: Terms response status: ${response.statusCode}");
        print("DEBUG: Terms response body: ${response.body}");

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print("DEBUG: Terms parsed data: $data");
          
          if (data is List && data.isNotEmpty) {
            if (mounted) {
              setState(() {
                termsList = List<Map<String, dynamic>>.from(data);
                print("DEBUG: termsList loaded with ${termsList.length} items");
              });
            }
            return;
          }
        }
      } catch (e) {
        print("DEBUG: API call failed: $e");
      }
      
      // Fallback data if API returns empty or fails
      print("DEBUG: Using fallback data for terms");
      if (mounted) {
        setState(() {
          termsList = [
            {'term': '1/1', 'start_date': '2026-01-01', 'end_date': '2026-01-31'},
            {'term': '1/2', 'start_date': '2026-02-01', 'end_date': '2026-02-28'},
            {'term': '2/1', 'start_date': '2026-03-01', 'end_date': '2026-03-31'},
            {'term': '2/2', 'start_date': '2026-04-01', 'end_date': '2026-04-30'},
          ];
        });
      }
    } catch (e) {
      print("Error in _fetchTerms: $e");
      // Use fallback even if outer exception
      if (mounted) {
        setState(() {
          termsList = [
            {'term': '1/1', 'start_date': '2026-01-01', 'end_date': '2026-01-31'},
            {'term': '1/2', 'start_date': '2026-02-01', 'end_date': '2026-02-28'},
            {'term': '2/1', 'start_date': '2026-03-01', 'end_date': '2026-03-31'},
            {'term': '2/2', 'start_date': '2026-04-01', 'end_date': '2026-04-30'},
          ];
        });
      }
    }
  }

  void _populateForm(Map<String, dynamic> data) {
    workDate = DateTime.tryParse(data['work_date'] ?? '');
    workDateController.text = data['work_date'] ?? '';
    stdIdController.text = data['std_id'] ?? '';
    selectedStudentId = data['std_id'];
    termController.text = data['term'] ?? '';
    selectedTerm = data['term'];
    typeInternController.text = data['type_intern']?.toString() ?? '1';
    selectedInternType = int.tryParse(data['type_intern']?.toString() ?? '1') ?? 1;
    workDetailsController.text = data['work_details'] ?? '';
    problemsController.text = data['problems'] ?? '';
    troubleshootController.text = data['troubleshoot'] ?? '';
  }

  Future<void> _fetchInternTypes() async {
    try {
      final url = Uri.parse("$_baseUrl/getinterntype.php");
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          if (mounted) {
            setState(() {
              internTypesList = List<Map<String, dynamic>>.from(data);
              print("DEBUG: internTypesList loaded with ${internTypesList.length} items");
            });
          }
        }
      } else {
        print("DEBUG: Error loading intern types");
      }
    } catch (e) {
      print("Error fetching intern types: $e");
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final initialDate = workDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        workDate = picked;
        workDateController.text =
            picked.toIso8601String().substring(0, 10);
      });
    }
  }

  Future<void> _saveDailyWork() async {
    if (_formKey.currentState!.validate()) {
      print("DEBUG: ===== START SAVE PROCESS =====");
      print("DEBUG: selectedStudentId = $selectedStudentId");
      print("DEBUG: selectedTerm = $selectedTerm");
      print("DEBUG: workDate = $workDate");
      print("DEBUG: selectedInternType = $selectedInternType");
      
      if (selectedStudentId == null ||
          selectedTerm == null ||
          workDate == null) {
        print("DEBUG: Validation failed - missing required fields");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("กรุณากรอกข้อมูลให้ครบถ้วน"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => isLoading = true);

      try {
        final url = Uri.parse("$_baseUrl/savedatadailywork.php");
        
        final body = {
          "work_date": workDateController.text,
          "std_id": selectedStudentId,
          "term": selectedTerm,
          "type_intern": selectedInternType.toString(),
          "work_details": workDetailsController.text,
          "problems": problemsController.text,
          "troubleshoot": troubleshootController.text,
          "xcase": widget.dailyWork == null ? "1" : "2", // 1=add, 2=edit
        };

        print("DEBUG: Saving daily work to: $url");
        print("DEBUG: Request body: $body");
        print("DEBUG: work_date length: ${workDateController.text.length}");
        print("DEBUG: std_id: ${selectedStudentId ?? 'NULL'}");
        print("DEBUG: term: ${selectedTerm ?? 'NULL'}");

        final response = await http.post(url, body: body).timeout(const Duration(seconds: 10));

        print("DEBUG: Save response status: ${response.statusCode}");
        print("DEBUG: Save response body: ${response.body}");
        print("DEBUG: Save response headers: ${response.headers}");
        print("DEBUG: Response length: ${response.body.length}");

        if (response.statusCode == 200) {
          try {
            final result = json.decode(response.body);
            print("DEBUG: Parsed result: $result");
            
            if (result['status'] == 'success' || result['status'] == 'ok') {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? "บันทึกข้อมูลสำเร็จ"),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? "ไม่สามารถบันทึกข้อมูลได้"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } catch (e) {
            print("DEBUG: JSON parse error: $e");
            // Try assuming success if response is just "1" or empty
            if (response.body.isEmpty || response.body == "1" || response.body.contains("success")) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("บันทึกข้อมูลสำเร็จ"),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("เกิดข้อผิดพลาด: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        } else {
          print("DEBUG: ERROR - Status code ${response.statusCode}");
          print("DEBUG: Error response body: ${response.body}");
          print("DEBUG: Error response body type: ${response.body.runtimeType}");
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Server error: ${response.statusCode} - ${response.body}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print("DEBUG: Exception during save: $e");
        print("DEBUG: Exception type: ${e.runtimeType}");
        print("DEBUG: Stack trace: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("เกิดข้อผิดพลาด: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        print("DEBUG: Save process completed");
        setState(() => isLoading = false);
      }
    }
  }

  void _showConfirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ยกเลิกข้อมูล"),
        content: const Text("คุณต้องการยกเลิกข้อมูลนี้หรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteDailyWork();
            },
            child: const Text("ยกเลิกข้อมูล", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDailyWork() async {
    setState(() => isLoading = true);

    try {
      final url = Uri.parse("$_baseUrl/savedatadailywork.php");
      final response = await http.post(
        url,
        body: {
          "work_date": workDateController.text,
          "std_id": selectedStudentId,
          "xcase": "3", // Delete
        },
      );

      if (response.statusCode == 200) {
        try {
          final result = json.decode(response.body);
          if (result['status'] == 'success') {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("ลบข้อมูลสำเร็จ"),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message'] ?? "ไม่สามารถลบข้อมูลได้"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("เกิดข้อผิดพลาด: $e"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.dailyWork == null ? 'เพิ่มบันทึกปฏิบัติงาน' : 'แก้ไขบันทึกปฏิบัติงาน',
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8FFF4),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Student dropdown
                const Text(
                  "นักศึกษา",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedStudentId != null
                      ? (studentsList.any((s) => s['student_id']?.toString() == selectedStudentId)
                          ? selectedStudentId
                          : null)
                      : null,
                  hint: const Text("เลือก นักศึกษา"),
                  items: studentsList.map((student) {
                    return DropdownMenuItem(
                      value: student['student_id'].toString(),
                      child: Text(
                        "${student['student_name']} (${student['student_id']})",
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStudentId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณาเลือก นักศึกษา';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Work date
                const Text(
                  "วันที่เริ่มฝึก",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: workDateController,
                  readOnly: true,
                  onTap: () => _pickDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณาเลือกวันที่';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 16),

                // Term dropdown
                const Text(
                  "เทอม",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                termsList.isEmpty
                    ? TextFormField(
                        controller: termController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: "กรุณากรอกเทอม (ไม่มีข้อมูลจากฐานข้อมูล)",
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedTerm = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณากรอก เทอม';
                          }
                          return null;
                        },
                      )
                    : DropdownButtonFormField<String>(
                        value: selectedTerm != null
                            ? (termsList.any((t) => t['term']?.toString() == selectedTerm)
                                ? selectedTerm
                                : null)
                            : null,
                        hint: const Text("เลือก เทอม"),
                        items: [
                          const DropdownMenuItem(
                            value: "",
                            child: Text("-- เลือก เทอม --"),
                          ),
                          ...termsList.map((term) {
                            return DropdownMenuItem(
                              value: term['term'].toString(),
                              child: Text(term['term']?.toString() ?? "ไม่ระบุ"),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedTerm = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณาเลือก เทอม';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                const SizedBox(height: 16),

                // Internship type
                const Text(
                  "ประเภทการฝึก",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: internTypesList.any((t) => t['type_intern'] == selectedInternType)
                      ? selectedInternType
                      : null,
                  hint: const Text("เลือก ประเภทการฝึก"),
                  items: [
                    ...internTypesList.map((type) {
                      return DropdownMenuItem(
                        value: type['type_intern'] as int,
                        child: Text(type['type_name']?.toString() ?? "ไม่ระบุ"),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedInternType = value ?? 1;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return "กรุณาเลือกประเภทการฝึก";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Work details
                const Text(
                  "รายละเอียดงานประจำวัน",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: workDetailsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: "กรุณาอธิบายรายละเอียดงาน",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกรายละเอียดงาน';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Problems
                const Text(
                  "ปัญหาที่พบ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: problemsController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: "กรุณาอธิบายปัญหาที่พบ",
                  ),
                ),
                const SizedBox(height: 16),

                // Troubleshoot
                const Text(
                  "การแก้ไขปัญหา",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: troubleshootController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: "กรุณาอธิบายการแก้ไขปัญหา",
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("ยกเลิก"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _saveDailyWork,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text("บันทึก"),
                      ),
                    ),
                  ],
                ),
                if (widget.dailyWork != null) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: isLoading ? null : _showConfirmDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("ยกเลิกข้อมูล"),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    workDateController.dispose();
    stdIdController.dispose();
    termController.dispose();
    typeInternController.dispose();
    workDetailsController.dispose();
    problemsController.dispose();
    troubleshootController.dispose();
    super.dispose();
  }
}
