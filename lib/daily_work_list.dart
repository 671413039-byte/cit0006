import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'daily_work_form.dart';

class DailyWorkListPage extends StatefulWidget {
  const DailyWorkListPage({super.key});

  @override
  State<DailyWorkListPage> createState() => _DailyWorkListPageState();
}

class _DailyWorkListPageState extends State<DailyWorkListPage> {
  List<Map<String, dynamic>> dataList = [];
  List<Map<String, dynamic>> filteredDataList = [];
  Timer? timer;
  bool isLoading = true;
  String? error;

  // Filter variables
  String? selectedStudentId;
  String? selectedTerm;
  String? selectedInternType;

  // Dropdown data
  List<Map<String, dynamic>> studentsList = [];
  List<Map<String, dynamic>> termsList = [];
  List<Map<String, dynamic>> internTypesList = [];

  final String _baseUrl = "http://192.168.1.228/api_copy";

  @override
  void initState() {
    super.initState();
    fetchAllData();
    timer = Timer.periodic(const Duration(seconds: 10), (_) => fetchAllData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchAllData() async {
    await Future.wait([
      fetchDailyWorkData(),
      fetchStudents(),
      fetchTerms(),
      fetchInternTypes(),
    ]);
  }

  Future<void> fetchDailyWorkData() async {
    if (!mounted) return;
    try {
      final url = Uri.parse("$_baseUrl/getdatadailywork.php");
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          if (mounted) {
            setState(() {
              // Filter only records with void = 0
              dataList = List<Map<String, dynamic>>.from(
                data.where((item) => item['void'] == '0' || item['void'] == 0),
              );
              isLoading = false;
              error = null;
              applyFilters();
            });
          }
        } else {
          if (mounted) {
            setState(() {
              if (data == null) {
                dataList = [];
              } else {
                error = "รูปแบบข้อมูลไม่ถูกต้อง";
              }
              isLoading = false;
              applyFilters();
            });
          }
        }
      } else {
        if (mounted) {
          String errorMsg = "Server error: ${response.statusCode}";
          if (response.statusCode == 400) {
            errorMsg = "ข้อมูลไม่ถูกต้องบนเซิร์ฟเวอร์";
          } else if (response.statusCode == 404) {
            errorMsg = "ไม่พบ API ที่ร้องขอ";
          } else if (response.statusCode == 500) {
            errorMsg = "เกิดข้อผิดพลาดบนเซิร์ฟเวอร์";
          }
          setState(() {
            error = errorMsg;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = "เกิดข้อผิดพลาด: $e";
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchStudents() async {
    try {
      final url = Uri.parse("$_baseUrl/getdatastudent.php");
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && mounted) {
          setState(() {
            studentsList = List<Map<String, dynamic>>.from(data);
          });
        }
      }
    } catch (e) {
      print("Error fetching students: $e");
    }
  }

  Future<void> fetchTerms() async {
    try {
      final url = Uri.parse("$_baseUrl/getdataterm.php");
      final response = await http.post(url).timeout(const Duration(seconds: 5));

      print("DEBUG: fetchTerms response status = ${response.statusCode}");
      print("DEBUG: fetchTerms response body = ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("DEBUG: fetchTerms parsed data = $data");
        
        if (data is List && data.isNotEmpty && mounted) {
          setState(() {
            termsList = List<Map<String, dynamic>>.from(data);
            print("DEBUG: termsList loaded from API: $termsList");
          });
          return;
        }
      }
      
      // Fallback if API fails or returns empty
      print("DEBUG: Using fallback terms data");
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
      print("Error fetching terms: $e");
      // Use fallback on error
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

  Future<void> fetchInternTypes() async {
    try {
      final url = Uri.parse("$_baseUrl/getinterntype.php");
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty && mounted) {
          setState(() {
            internTypesList = List<Map<String, dynamic>>.from(data);
            print("DEBUG: internTypesList loaded from API: $internTypesList");
          });
          return;
        }
      }
      
      // Fallback if API fails
      print("DEBUG: Using fallback intern types data");
      if (mounted) {
        setState(() {
          internTypesList = [
            {'type_intern': 1, 'type_name': 'เตรียมฝึก'},
            {'type_intern': 2, 'type_name': 'ฝึกประสบการณ์'},
          ];
        });
      }
    } catch (e) {
      print("Error fetching intern types: $e");
      // Use fallback on error
      if (mounted) {
        setState(() {
          internTypesList = [
            {'type_intern': 1, 'type_name': 'เตรียมฝึก'},
            {'type_intern': 2, 'type_name': 'ฝึกประสบการณ์'},
          ];
        });
      }
    }
  }

  void applyFilters() {
    setState(() {
      filteredDataList = dataList.where((item) {
        // Filter by student
        if (selectedStudentId != null &&
            selectedStudentId!.isNotEmpty &&
            item['std_id'] != selectedStudentId) {
          return false;
        }

        // Filter by term
        if (selectedTerm != null &&
            selectedTerm!.isNotEmpty &&
            item['term'] != selectedTerm) {
          return false;
        }

        // Filter by internship type
        if (selectedInternType != null &&
            selectedInternType!.isNotEmpty &&
            item['type_intern'].toString() != selectedInternType) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  Future<void> _deleteDailyWork(String workDate, String stdId) async {
    try {
      final url = Uri.parse("$_baseUrl/savedatadailywork.php");
      final response = await http.post(
        url,
        body: {
          "work_date": workDate,
          "std_id": stdId,
          "xcase": "3", // Delete operation
        },
      );

      if (response.statusCode == 200) {
        try {
          final result = json.decode(response.body);
          if (result['status'] == 'success') {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("ลบข้อมูลสำเร็จ")),
              );
            }
            fetchDailyWorkData();
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

  void _showConfirmDelete(String workDate, String stdId, String studentName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ยกเลิกข้อมูล"),
        content: Text("คุณต้องการยกเลิกข้อมูลสำหรับ $studentName ในวันที่ $workDate หรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteDailyWork(workDate, stdId);
            },
            child: const Text("ยกเลิกข้อมูล", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("บันทึกปฏิบัติงาน"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => const DailyWorkFormPage(),
                      ),
                    )
                    .then((_) => fetchDailyWorkData());
              },
              child: const Text('เพิ่ม', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8FFF4),
      body: Column(
        children: [
          // Filter section
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Student filter
                  SizedBox(
                    width: 150,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text("เลือก นักศึกษา"),
                      value: selectedStudentId,
                      items: [
                        const DropdownMenuItem(
                          value: "",
                          child: Text("ทั้งหมด"),
                        ),
                        ...studentsList.map((student) {
                          return DropdownMenuItem(
                            value: student['student_id'].toString(),
                            child: Text(
                              student['student_name']?.toString() ?? "ไม่ระบุ",
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedStudentId = value;
                        });
                        applyFilters();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Term filter
                  SizedBox(
                    width: 150,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text("เลือก เทอม"),
                      value: selectedTerm,
                      items: [
                        const DropdownMenuItem(
                          value: "",
                          child: Text("ทั้งหมด"),
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
                        applyFilters();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Internship type filter
                  SizedBox(
                    width: 150,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text("เลือก ประเภทฝึก"),
                      value: selectedInternType,
                      items: [
                        const DropdownMenuItem(
                          value: "",
                          child: Text("ทั้งหมด"),
                        ),
                        ...internTypesList.map((type) {
                          return DropdownMenuItem(
                            value: type['type_intern'].toString(),
                            child: Text(type['type_name']?.toString() ?? "ไม่ระบุ"),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedInternType = value;
                        });
                        applyFilters();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          // Data list section
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : error != null
                    ? Center(
                        child: Text(
                          error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : filteredDataList.isEmpty
                        ? const Center(
                            child: Text("ไม่พบข้อมูล"),
                          )
                        : ListView.builder(
                            itemCount: filteredDataList.length,
                            itemBuilder: (context, index) {
                              final item = filteredDataList[index];
                              // Find student name from studentsList
                              final studentName = studentsList.firstWhere(
                                (s) => s['student_id']?.toString() == item['std_id'],
                                orElse: () => {'student_name': item['std_id']},
                              )['student_name'] ?? item['std_id'];
                              
                              // Find type name from internTypesList
                              final typeName = internTypesList.firstWhere(
                                (t) => t['type_intern']?.toString() == item['type_intern']?.toString(),
                                orElse: () => {'type_name': item['type_intern']},
                              )['type_name'] ?? item['type_intern'];
                              
                              return Card(
                                margin: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: Text(
                                    "นักศึกษา: $studentName",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "วันที่: ${item['work_date'] ?? '-'}",
                                      ),
                                      Text(
                                        "เทอม: ${item['term'] ?? '-'} | ประเภท: $typeName",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  trailing: SizedBox(
                                    width: 160,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
                                            foregroundColor: const Color.fromARGB(255, 0, 255, 0),
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        DailyWorkFormPage(
                                                          dailyWork: item,
                                                        ),
                                                  ),
                                                )
                                                .then((_) => fetchDailyWorkData());
                                          },
                                          child: const Text('แก้ไข', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            elevation: 2,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          onPressed: () {
                                            _showConfirmDelete(
                                              item['work_date'],
                                              item['std_id'],
                                              studentName,
                                            );
                                          },
                                          child: const Text('ลบ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
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
}
