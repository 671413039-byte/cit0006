import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InternEvaluationsFormPage extends StatefulWidget {
  final Map<String, dynamic>? evaluation;

  const InternEvaluationsFormPage({super.key, this.evaluation});

  @override
  State<InternEvaluationsFormPage> createState() =>
      _InternEvaluationsFormPageState();
}

class _InternEvaluationsFormPageState extends State<InternEvaluationsFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  late TextEditingController evaluateDateController;
  late TextEditingController companyIdController;
  late TextEditingController stdIdController;
  late TextEditingController termController;
  late TextEditingController detailController;
  late TextEditingController progLanguageController;
  late TextEditingController priceController;
  late TextEditingController costController;
  late TextEditingController transportController;
  late TextEditingController studentNameController;
  late TextEditingController companyNameController;
  late TextEditingController termDisplayController;

  int selectedStatus = 1;
  DateTime? evaluateDate;

  List<Map<String, dynamic>> studentsList = [];
  List<Map<String, dynamic>> companiesList = [];
  List<Map<String, dynamic>> termsList = [];

  String? selectedStudentId;
  String? selectedCompanyId;
  String? selectedTerm;
  
  // Store names from evaluation data for display
  String? selectedStudentName;
  String? selectedCompanyName;

  // Helper map to find student/company by ID
  Map<String, Map<String, dynamic>> studentMap = {};
  Map<String, Map<String, dynamic>> companyMap = {};

  final String _baseUrl = "http://192.168.171.1/api_copy";

  @override
  void initState() {
    super.initState();
    evaluateDateController = TextEditingController();
    companyIdController = TextEditingController();
    stdIdController = TextEditingController();
    termController = TextEditingController();
    detailController = TextEditingController();
    progLanguageController = TextEditingController();
    priceController = TextEditingController();
    costController = TextEditingController();
    transportController = TextEditingController();
    studentNameController = TextEditingController();
    companyNameController = TextEditingController();
    termDisplayController = TextEditingController();

    _fetchDropdownData().then((_) {
      // Populate form AFTER dropdown data is loaded
      if (widget.evaluation != null && mounted) {
        _populateForm(widget.evaluation!);
      }
    });
  }

  Future<void> _fetchDropdownData() async {
    await Future.wait([_fetchStudents(), _fetchCompanies(), _fetchTerms()]);
  }

  Future<void> _fetchStudents() async {
    try {
      final url = Uri.parse("$_baseUrl/getdatastudent.php");
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> resultList = [];

        if (data is List) {
          resultList = List<Map<String, dynamic>>.from(data);
        } else if (data is Map<String, dynamic>) {
          if (data.containsKey('data') && data['data'] is List) {
            resultList = List<Map<String, dynamic>>.from(data['data']);
          } else if (data.containsKey('result') && data['result'] is List) {
            resultList = List<Map<String, dynamic>>.from(data['result']);
          }
        }

        if (mounted) {
          setState(() {
            studentsList = resultList;
            // Build a map for quick lookup
            studentMap = {};
            for (var student in resultList) {
              final id = student['student_id'].toString();
              studentMap[id] = student;
            }
          });
        }
      }
    } catch (e) {
      print("Error fetching students: $e");
    }
  }

  Future<void> _fetchCompanies() async {
    try {
      final url = Uri.parse("$_baseUrl/getdatacompany.php");
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> resultList = [];

        if (data is List) {
          resultList = List<Map<String, dynamic>>.from(data);
        } else if (data is Map<String, dynamic>) {
          if (data.containsKey('data') && data['data'] is List) {
            resultList = List<Map<String, dynamic>>.from(data['data']);
          } else if (data.containsKey('result') && data['result'] is List) {
            resultList = List<Map<String, dynamic>>.from(data['result']);
          }
        }

        if (mounted) {
          setState(() {
            companiesList = resultList;
            // Build a map for quick lookup
            companyMap = {};
            for (var company in resultList) {
              final id = company['company_id'].toString();
              companyMap[id] = company;
            }
          });
        }
      }
    } catch (e) {
      print("Error fetching companies: $e");
    }
  }

  Future<void> _fetchTerms() async {
    try {
      final url = Uri.parse("$_baseUrl/getdataterm.php");
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> resultList = [];

        if (data is List) {
          resultList = List<Map<String, dynamic>>.from(data);
        } else if (data is Map<String, dynamic>) {
          if (data.containsKey('data') && data['data'] is List) {
            resultList = List<Map<String, dynamic>>.from(data['data']);
          } else if (data.containsKey('result') && data['result'] is List) {
            resultList = List<Map<String, dynamic>>.from(data['result']);
          }
        }

        if (mounted) {
          setState(() {
            termsList = resultList;
          });
        }
      }
    } catch (e) {
      print("Error fetching terms: $e");
    }
  }

  void _populateForm(Map<String, dynamic> data) {
    setState(() {
      evaluateDate = DateTime.tryParse(data['evaluate_date'] ?? '');
      evaluateDateController.text = data['evaluate_date'] ?? '';
      
      // Normalize IDs to match dropdown values
      final companyId = data['company_id']?.toString() ?? '0';
      final normalizedCompanyId = int.parse(companyId).toString();
      selectedCompanyId = normalizedCompanyId;
      
      // Try to get company name from data, if not found, look it up from companiesList
      selectedCompanyName = data['company_name']?.toString();
      if ((selectedCompanyName == null || selectedCompanyName!.isEmpty) && selectedCompanyId != '0') {
        final company = companiesList.firstWhere(
          (c) => c['company_id'].toString() == selectedCompanyId,
          orElse: () => {},
        );
        selectedCompanyName = company['company_name']?.toString() ?? 'company_name';
      }
      companyNameController.text = selectedCompanyName ?? 'ไม่ระบุ';
      
      final studentId = data['std_id']?.toString() ?? '0';
      final normalizedStudentId = int.parse(studentId).toString();
      selectedStudentId = normalizedStudentId;
      
      // Try to get student name from data, if not found, look it up from studentsList
      selectedStudentName = data['student_name']?.toString();
      if ((selectedStudentName == null || selectedStudentName!.isEmpty) && selectedStudentId != '0') {
        final student = studentsList.firstWhere(
          (s) => s['student_id'].toString() == selectedStudentId,
          orElse: () => {},
        );
        selectedStudentName = student['student_name']?.toString() ?? 'student_name';
      }
      studentNameController.text = selectedStudentName ?? 'ไม่ระบุ';
      
      final termValue = data['term']?.toString() ?? '';
      selectedTerm = termValue.isNotEmpty ? termValue : null;
      termController.text = termValue;
      termDisplayController.text = termValue.isNotEmpty ? termValue : 'ไม่ระบุ';
      
      selectedStatus = int.tryParse(data['status']?.toString() ?? '1') ?? 1;
      detailController.text = data['detail'] ?? '';
      progLanguageController.text = data['prog_language'] ?? '';
      priceController.text = data['price']?.toString() ?? '0.00';
      costController.text = data['cost']?.toString() ?? '0.00';
      transportController.text = data['transport']?.toString() ?? '0.00';
    });
    
    print("DEBUG: Populated form with:");
    print("  selectedStudentId=$selectedStudentId, selectedStudentName=$selectedStudentName");
    print("  selectedCompanyId=$selectedCompanyId, selectedCompanyName=$selectedCompanyName");
  }

  Future<void> _pickDate(BuildContext context) async {
    final initialDate = evaluateDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        evaluateDate = picked;
        evaluateDateController.text = picked.toIso8601String().substring(0, 10);
      });
    }
  }

  Future<void> _saveEvaluation() async {
    if (_formKey.currentState!.validate()) {
      if (selectedStudentId == null ||
          selectedCompanyId == null ||
          selectedTerm == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('กรุณากรอกข้อมูลที่จำเป็น'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => isLoading = true);

      try {
        final url = Uri.parse("$_baseUrl/savedatainterneevaluations.php");

        final body = {
          "evaluate_date": evaluateDateController.text,
          "company_id": int.parse(selectedCompanyId ?? '0').toString(),
          "std_id": int.parse(selectedStudentId ?? '0').toString(),
          "term": selectedTerm,
          "status": selectedStatus.toString(),
          "detail": detailController.text,
          "prog_language": progLanguageController.text,
          "price": priceController.text,
          "cost": costController.text,
          "transport": transportController.text,
          "xcase": widget.evaluation == null ? "1" : "2",
        };

        // Log values for debugging
        print("DEBUG: Form Data Being Sent:");
        print("  evaluate_date: ${body['evaluate_date']}");
        print("  company_id: ${body['company_id']}");
        print("  std_id: ${body['std_id']}");
        print("  term: ${body['term']}");
        print("  status: ${body['status']}");
        print("  xcase: ${body['xcase']}");

        final response = await http
            .post(url, body: body)
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          try {
            final result = json.decode(response.body);
            print(
              "DEBUG: API Response - Status: ${result['status']}, Message: ${result['message']}",
            );
            print("DEBUG: Full Response: ${response.body}");

            if (result['status'] == 'success' || result['status'] == 'ok') {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('บันทึกข้อมูลสำเร็จ'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context, true);
              }
            } else {
              // Show error in dialog to see full details
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('เกิดข้อผิดพลาด'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ข้อความ: ${result['message'] ?? 'ไม่ระบุ'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          if (result.containsKey('sent_values'))
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ค่าที่ส่งมา:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  jsonEncode(result['sent_values']),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          if (result.containsKey(
                            'existing_records_for_this_company_student',
                          ))
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Record ที่มีอยู่:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  jsonEncode(
                                    result['existing_records_for_this_company_student'],
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('ปิด'),
                      ),
                    ],
                  ),
                );
              }
            }
          } catch (e) {
            print("DEBUG: Error parsing response - $e");
            if (response.body.isEmpty ||
                response.body == "1" ||
                response.body.contains("success")) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('บันทึกข้อมูลสำเร็จ'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context, true);
              }
            } else {
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('เกิดข้อผิดพลาด'),
                    content: SingleChildScrollView(
                      child: SelectableText(
                        'Response Body:\n${response.body}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('ปิด'),
                      ),
                    ],
                  ),
                );
              }
            }
          }
        } else {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('เกิดข้อผิดพลาด'),
                content: Text(
                  'Status Code: ${response.statusCode}\n\n${response.body}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ปิด'),
                  ),
                ],
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
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.evaluation == null
              ? 'เพิ่มข้อมูลประเมินผล'
              : 'แก้ไขข้อมูลประเมินผล',
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
                // Evaluate date
                const Text(
                  "วันที่ประเมิน",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: evaluateDateController,
                  readOnly: true,
                  onTap: widget.evaluation != null ? null : () => _pickDate(context),
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
                    filled: widget.evaluation != null,
                    fillColor: widget.evaluation != null ? Colors.grey[300] : null,
                    suffixIcon: widget.evaluation != null 
                      ? null 
                      : const Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 16),

                // Student dropdown
                const Text(
                  "นักศึกษา",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (widget.evaluation != null)
                  // Editing mode - show as read-only field
                  TextFormField(
                    controller: studentNameController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[300],
                    ),
                  )
                else
                  // Add mode - show dropdown
                  DropdownButtonFormField<String>(
                    value:
                        selectedStudentId != null &&
                            studentsList.any(
                              (s) =>
                                  s['student_id'].toString() == selectedStudentId,
                            )
                        ? selectedStudentId
                        : null,
                    hint: const Text("เลือกนักศึกษา"),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text("-- เลือกนักศึกษา --"),
                      ),
                      ...studentsList.map((student) {
                        final studentId = student['student_id'].toString();
                        final studentName = student['student_name']?.toString() ?? 'student_name';
                        return DropdownMenuItem(
                          value: studentId,
                          child: Text("$studentName ($studentId)"),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStudentId = value;
                        if (value != null) {
                          final student = studentsList.firstWhere(
                            (s) => s['student_id'].toString() == value,
                            orElse: () => {},
                          );
                          selectedStudentName = student['student_name']?.toString();
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณาเลือกนักศึกษา';
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

                // Company dropdown
                const Text(
                  "สถานประกอบการณ์",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (widget.evaluation != null)
                  // Editing mode - show as read-only field
                  TextFormField(
                    controller: companyNameController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[300],
                    ),
                  )
                else
                  // Add mode - show dropdown
                  DropdownButtonFormField<String>(
                    value:
                        selectedCompanyId != null &&
                            companiesList.any(
                              (c) =>
                                  c['company_id'].toString() == selectedCompanyId,
                            )
                        ? selectedCompanyId
                        : null,
                    hint: const Text("เลือกสถานประกอบการณ์"),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text("-- เลือกสถานประกอบการณ์ --"),
                      ),
                      ...companiesList.map((company) {
                        final companyId = company['company_id'].toString();
                        final companyName = company['company_name']?.toString() ?? 'ไม่ระบุ';
                        return DropdownMenuItem(
                          value: companyId,
                          child: Text(companyName),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCompanyId = value;
                        if (value != null) {
                          final company = companiesList.firstWhere(
                            (c) => c['company_id'].toString() == value,
                            orElse: () => {},
                          );
                          selectedCompanyName = company['company_name']?.toString();
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณาเลือกสถานประกอบการณ์';
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

                // Term dropdown
                const Text(
                  "เทอม",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (widget.evaluation != null)
                  // Editing mode - show as read-only field
                  TextFormField(
                    controller: termDisplayController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[300],
                    ),
                  )
                else
                  // Add mode - show dropdown
                  DropdownButtonFormField<String>(
                    value:
                        selectedTerm != null &&
                            termsList.any(
                              (t) => t['term'].toString() == selectedTerm,
                            )
                        ? selectedTerm
                        : null,
                    hint: const Text("เลือกเทอม"),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text("-- เลือกเทอม --"),
                      ),
                      ...termsList.map((term) {
                        final termValue = term['term'].toString();
                        return DropdownMenuItem(
                          value: termValue,
                          child: Text(termValue),
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
                        return 'กรุณาเลือกเทอม';
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

                // Status
                const Text(
                  "สถานะการประเมิน",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("ผ่าน")),
                    DropdownMenuItem(value: 0, child: Text("ไม่ผ่าน")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value ?? 1;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Detail
                const Text(
                  "รายละเอียด",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: detailController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: "กรุณาอธิบายรายละเอียด",
                  ),
                ),
                const SizedBox(height: 16),

                // Programming language
                const Text(
                  "ภาษาโปรแกรมที่ใช้",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: progLanguageController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: "กรุณากรอกภาษาโปรแกรมที่ใช้",
                  ),
                ),
                const SizedBox(height: 16),

                // Price
                const Text(
                  "เบี้ยเรียน",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: "0.00",
                    prefixText: "฿ ",
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'กรุณากรอกจำนวนที่ถูกต้อง';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Cost
                const Text(
                  "ค่าทำการ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: costController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: "0.00",
                    prefixText: "฿ ",
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'กรุณากรอกจำนวนที่ถูกต้อง';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Transport
                const Text(
                  "ค่าเดินทาง",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: transportController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: "0.00",
                    prefixText: "฿ ",
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'กรุณากรอกจำนวนที่ถูกต้อง';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pop(context),
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
                        onPressed: isLoading ? null : _saveEvaluation,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    evaluateDateController.dispose();
    companyIdController.dispose();
    stdIdController.dispose();
    termController.dispose();
    detailController.dispose();
    progLanguageController.dispose();
    priceController.dispose();
    costController.dispose();
    transportController.dispose();
    studentNameController.dispose();
    companyNameController.dispose();
    termDisplayController.dispose();
    super.dispose();
  }
}
