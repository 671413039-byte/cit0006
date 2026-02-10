import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class InternshipFormPage extends StatefulWidget {
  final Map<String, dynamic>? internship;

  const InternshipFormPage({Key? key, this.internship}) : super(key: key);

  @override
  State<InternshipFormPage> createState() => _InternshipFormPageState();
}

class _InternshipFormPageState extends State<InternshipFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _stdIdController;
  late TextEditingController _termController;
  late TextEditingController _companyIdController;
  late TextEditingController _contactNameController;
  late TextEditingController _contactTelnoController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  int? _selectedTypeIntern;
  int _void = 0;
  bool _isLoading = false;
  List<Map<String, dynamic>> studentsList = [];
  List<Map<String, dynamic>> companiesList = [];
  List<Map<String, dynamic>> termsList = [];

  final String _baseUrl = "http://192.168.171.1/api_copy/internship_api.php";

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadDropdownData();
  }

  void _initializeControllers() {
    if (widget.internship != null) {
      _stdIdController = TextEditingController(text: widget.internship!['std_id'] ?? '');
      _termController = TextEditingController(text: widget.internship!['term']?.toString() ?? '');
      _companyIdController = TextEditingController(text: widget.internship!['company_id'] ?? '');
      _contactNameController = TextEditingController(text: widget.internship!['contact_name'] ?? '');
      _contactTelnoController = TextEditingController(text: widget.internship!['contact_telno'] ?? '');
      _startDateController = TextEditingController(text: widget.internship!['start_date'] ?? '');
      _endDateController = TextEditingController(text: widget.internship!['end_date'] ?? '');
      _selectedTypeIntern = widget.internship!['type_intern'] ?? 1;
      _void = widget.internship!['void'] ?? 0;
    } else {
      _stdIdController = TextEditingController();
      _termController = TextEditingController();
      _companyIdController = TextEditingController();
      _contactNameController = TextEditingController();
      _contactTelnoController = TextEditingController();
      _startDateController = TextEditingController();
      _endDateController = TextEditingController();
      _selectedTypeIntern = 1;
      _void = 0;
    }
  }

  Future<void> _loadDropdownData() async {
    try {
      final [studentsResp, companiesResp, termsResp] = await Future.wait([
        http.get(Uri.parse("$_baseUrl?action=students")),
        http.get(Uri.parse("$_baseUrl?action=companies")),
        http.get(Uri.parse("$_baseUrl?action=terms")),
      ]);

      if (studentsResp.statusCode == 200) {
        try {
          final data = jsonDecode(studentsResp.body);
          // ลบ duplicate students โดยใช้ student_id เป็น key
          final Map<String, Map<String, dynamic>> studentsMap = {};
          for (var item in (data is List ? data : data['data'] ?? [])) {
            final stdId = item['student_id']?.toString() ?? '';
            if (stdId.isNotEmpty && !studentsMap.containsKey(stdId)) {
              studentsMap[stdId] = item as Map<String, dynamic>;
            }
          }
          setState(() {
            studentsList = studentsMap.values.toList();
          });
          debugPrint("Students loaded: ${studentsList.length}");
        } catch (e) {
          debugPrint("Error parsing students: $e");
        }
      } else {
        debugPrint("Students API error: ${studentsResp.statusCode} - ${studentsResp.body}");
      }

      if (companiesResp.statusCode == 200) {
        try {
          final data = jsonDecode(companiesResp.body);
          // ลบ duplicate companies โดยใช้ company_id เป็น key
          final Map<String, Map<String, dynamic>> companiesMap = {};
          for (var item in (data is List ? data : data['data'] ?? [])) {
            final compId = item['company_id']?.toString() ?? '';
            if (compId.isNotEmpty && !companiesMap.containsKey(compId)) {
              companiesMap[compId] = item as Map<String, dynamic>;
            }
          }
          setState(() {
            companiesList = companiesMap.values.toList();
          });
          debugPrint("Companies loaded: ${companiesList.length}");
        } catch (e) {
          debugPrint("Error parsing companies: $e");
        }
      } else {
        debugPrint("Companies API error: ${companiesResp.statusCode} - ${companiesResp.body}");
      }

      if (termsResp.statusCode == 200) {
        try {
          final data = jsonDecode(termsResp.body);
          // ลบ duplicate terms โดยใช้ term เป็น key
          final Map<String, Map<String, dynamic>> termsMap = {};
          for (var item in (data is List ? data : data['data'] ?? [])) {
            final termValue = item['term']?.toString() ?? '';
            if (termValue.isNotEmpty && !termsMap.containsKey(termValue)) {
              termsMap[termValue] = item as Map<String, dynamic>;
            }
          }
          setState(() {
            termsList = termsMap.values.toList();
          });
          debugPrint("Terms loaded: ${termsList.length}");
        } catch (e) {
          debugPrint("Error parsing terms: $e");
        }
      } else {
        debugPrint("Terms API error: ${termsResp.statusCode} - ${termsResp.body}");
      }
    } catch (e) {
      debugPrint("Error loading dropdown data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ข้อผิดพลาดในการโหลดข้อมูล: $e")),
        );
      }
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final body = {
        'std_id': _stdIdController.text,
        'term': _termController.text,
        'type_intern': _selectedTypeIntern,
        'company_id': _companyIdController.text,
        'contact_name': _contactNameController.text,
        'contact_telno': _contactTelnoController.text,
        'start_date': _startDateController.text,
        'end_date': _endDateController.text,
        'void': _void,
      };

      final response = widget.internship != null
          ? await http.post(
              Uri.parse("$_baseUrl?action=update"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(body),
            )
          : await http.post(
              Uri.parse("$_baseUrl?action=add"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(body),
            );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.internship != null
                ? "แก้ไขข้อมูลเรียบร้อย"
                : "เพิ่มข้อมูลเรียบร้อย"),
          ),
        );
        Navigator.pop(context);
      } else {
        debugPrint("API error: ${response.statusCode} - ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("เกิดข้อผิดพลาดในการบันทึก: ${response.body}")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  void dispose() {
    _stdIdController.dispose();
    _termController.dispose();
    _companyIdController.dispose();
    _contactNameController.dispose();
    _contactTelnoController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.internship != null
            ? "แก้ไขข้อมูลฝึกประสบการณ์"
            : "เพิ่มข้อมูลฝึกประสบการณ์"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // รหัสนักศึกษา
                    DropdownButtonFormField<String>(
                      value: _stdIdController.text.isEmpty
                          ? null
                          : (studentsList.any((s) => s['student_id']?.toString() == _stdIdController.text)
                              ? _stdIdController.text
                              : null),
                      hint: const Text("เลือกรหัสนักศึกษา"),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text("เลือก"),
                        ),
                        ...studentsList.map((student) {
                          final stdId = student['student_id']?.toString() ?? '';
                          final stdName = student['student_name']?.toString() ?? '';
                          final displayText = stdName.isNotEmpty ? "$stdId - $stdName" : stdId;
                          return DropdownMenuItem(
                            value: stdId,
                            child: Text(displayText),
                          );
                        }),
                      ],
                      onChanged: widget.internship != null
                          ? null
                          : (value) {
                              setState(() {
                                _stdIdController.text = value ?? '';
                              });
                            },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "กรุณาเลือกรหัสนักศึกษา";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "รหัสนักศึกษา",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ภาคการศึกษา
                    DropdownButtonFormField<String>(
                      value: _termController.text.isEmpty
                          ? null
                          : (termsList.any((t) => t['term']?.toString() == _termController.text)
                              ? _termController.text
                              : null),
                      hint: const Text("เลือกภาคการศึกษา"),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text("เลือก"),
                        ),
                        ...termsList.map((term) {
                          final termValue = term['term']?.toString() ?? '';
                          final startDate = term['start_date']?.toString() ?? '';
                          final endDate = term['end_date']?.toString() ?? '';
                          final displayText = (startDate.isNotEmpty && endDate.isNotEmpty)
                            ? "$termValue ($startDate - $endDate)"
                            : "$termValue";
                          return DropdownMenuItem(
                            value: termValue,
                            child: Text(displayText),
                          );
                        }),
                      ],
                      onChanged: widget.internship != null
                          ? null
                          : (value) {
                              setState(() {
                                _termController.text = value ?? '';
                              });
                            },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "กรุณาเลือกภาคการศึกษา";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "ภาคการศึกษา",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ประเภทการฝึก
                    DropdownButtonFormField<int>(
                      value: _selectedTypeIntern,
                      items: const [
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
                          _selectedTypeIntern = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return "กรุณาเลือกประเภทการฝึก";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "ประเภทการฝึก",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // รหัสสถานประกอบการ
                    DropdownButtonFormField<String>(
                      value: _companyIdController.text.isEmpty
                          ? null
                          : (companiesList.any((c) => c['company_id']?.toString() == _companyIdController.text)
                              ? _companyIdController.text
                              : null),
                      hint: const Text("เลือกสถานประกอบการ"),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text("เลือก"),
                        ),
                        ...companiesList.map((company) {
                          final compId = company['company_id']?.toString() ?? '';
                          final compName = company['company_name']?.toString() ?? '';
                          final compAddress = company['address']?.toString() ?? company['company_address']?.toString() ?? '';
                          final displayText = compName.isNotEmpty 
                            ? "$compId - $compName"
                            : compId;
                          return DropdownMenuItem(
                            value: compId,
                            child: Tooltip(
                              message: compAddress,
                              child: Text(displayText, overflow: TextOverflow.ellipsis),
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _companyIdController.text = value ?? '';
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "กรุณาเลือกสถานประกอบการ";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "สถานประกอบการ",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ชื่อผู้ติดต่อ
                    TextFormField(
                      controller: _contactNameController,
                      decoration: InputDecoration(
                        labelText: "ชื่อผู้ติดต่อ",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "กรุณากรอกชื่อผู้ติดต่อ";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // เบอร์โทรศัพท์
                    TextFormField(
                      controller: _contactTelnoController,
                      decoration: InputDecoration(
                        labelText: "เบอร์โทรศัพท์",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "กรุณากรอกเบอร์โทรศัพท์";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // วันที่เริ่มฝึก
                    TextFormField(
                      controller: _startDateController,
                      readOnly: true,
                      onTap: () => _selectDate(_startDateController),
                      decoration: InputDecoration(
                        labelText: "วันที่เริ่มฝึก",
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "กรุณาเลือกวันที่เริ่มฝึก";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // วันที่สิ้นสุด
                    TextFormField(
                      controller: _endDateController,
                      readOnly: true,
                      onTap: () => _selectDate(_endDateController),
                      decoration: InputDecoration(
                        labelText: "วันที่สิ้นสุด",
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "กรุณาเลือกวันที่สิ้นสุด";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // สถานะ (เฉพาะการแก้ไข)
                    if (widget.internship != null)
                      CheckboxListTile(
                        title: const Text("ยกเลิก"),
                        value: _void == 1,
                        onChanged: (value) {
                          setState(() {
                            _void = value! ? 1 : 0;
                          });
                        },
                      ),
                    const SizedBox(height: 24),

                    // ปุ่ม
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _isLoading ? null : _submitForm,
                            child: const Text(
                              "บันทึก",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "ยกเลิก",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
