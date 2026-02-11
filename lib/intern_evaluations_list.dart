import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'intern_evaluations_form.dart';

class InternEvaluationsListPage extends StatefulWidget {
  const InternEvaluationsListPage({super.key});

  @override
  State<InternEvaluationsListPage> createState() =>
      _InternEvaluationsListPageState();
}

class _InternEvaluationsListPageState extends State<InternEvaluationsListPage> {
  List<Map<String, dynamic>> dataList = [];
  List<Map<String, dynamic>> filteredDataList = [];
  Timer? timer;
  bool isLoading = true;
  String? error;

  // Filter variables
  String? selectedStudentId;
  String? selectedCompanyId;
  String? selectedTerm;

  // Dropdown data
  List<Map<String, dynamic>> studentsList = [];
  List<Map<String, dynamic>> companiesList = [];
  List<Map<String, dynamic>> termsList = [];

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
      fetchEvaluationsData(),
      fetchStudents(),
      fetchCompanies(),
      fetchTerms(),
    ]);
  }

  Future<void> fetchEvaluationsData() async {
    if (!mounted) return;
    try {
      final url = Uri.parse("$_baseUrl/getdatainternevaluations.php");
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("DEBUG: API Response Type: ${data.runtimeType}, Response: $data");

        List<Map<String, dynamic>> resultList = [];

        if (data is List) {
          // If response is already a list
          resultList = List<Map<String, dynamic>>.from(data);
        } else if (data is Map<String, dynamic>) {
          // If response is an object, try to extract data from common keys
          if (data.containsKey('data') && data['data'] is List) {
            resultList = List<Map<String, dynamic>>.from(data['data']);
          } else if (data.containsKey('result') && data['result'] is List) {
            resultList = List<Map<String, dynamic>>.from(data['result']);
          } else if (data.containsKey('records') && data['records'] is List) {
            resultList = List<Map<String, dynamic>>.from(data['records']);
          } else {
            // If it's a map but doesn't have expected keys, treat as empty
            resultList = [];
          }
        } else {
          // Unknown format
          resultList = [];
        }

        if (mounted) {
          setState(() {
            dataList = resultList;
            isLoading = false;
            error = null;
            applyFilters();
          });
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
      print("DEBUG: Exception in fetchEvaluationsData: $e");
    }
  }

  Future<void> fetchStudents() async {
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
          });
        }
      }
    } catch (e) {
      print("Error fetching students: $e");
    }
  }

  Future<void> fetchCompanies() async {
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
          });
        }
      }
    } catch (e) {
      print("Error fetching companies: $e");
    }
  }

  Future<void> fetchTerms() async {
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

  void applyFilters() {
    filteredDataList = dataList.where((item) {
      if (selectedStudentId != null &&
          selectedStudentId!.isNotEmpty &&
          item['std_id']?.toString() != selectedStudentId) {
        return false;
      }
      if (selectedCompanyId != null &&
          selectedCompanyId!.isNotEmpty &&
          item['company_id']?.toString() != selectedCompanyId) {
        return false;
      }
      if (selectedTerm != null &&
          selectedTerm!.isNotEmpty &&
          item['term']?.toString() != selectedTerm) {
        return false;
      }
      return true;
    }).toList();
  }

  void _applyFilter() {
    setState(() {
      applyFilters();
    });
  }

  void _resetFilters() {
    setState(() {
      selectedStudentId = null;
      selectedCompanyId = null;
      selectedTerm = null;
      applyFilters();
    });
  }

  String _getStatusText(dynamic status) {
    int? statusVal = int.tryParse(status?.toString() ?? '');
    switch (statusVal) {
      case 1:
        return "ผ่าน";
      case 0:
        return "ไม่ผ่าน";
      default:
        return "ไม่ระบุ";
    }
  }

  Color _getStatusColor(dynamic status) {
    int? statusVal = int.tryParse(status?.toString() ?? '');
    switch (statusVal) {
      case 1:
        return Colors.green;
      case 0:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _deleteEvaluation(Map<String, dynamic> item) async {
    try {
      final url = Uri.parse("$_baseUrl/savedatainterneevaluations.php");
      final response = await http.post(
        url,
        body: {
          "evaluate_date": item['evaluate_date'],
          "company_id": item['company_id'],
          "std_id": item['std_id'],
          "xcase": "3",
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
            }
            fetchAllData();
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message'] ?? "ลบข้อมูลไม่สำเร็จ"),
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

  void _confirmDeleteEvaluation(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ยืนยันการลบ"),
        content: Text(
          "คุณต้องการลบข้อมูลประเมินผลสำหรับ ${item['student_name'] ?? 'ไม่ระบุ'} ที่ ${item['company_name'] ?? 'ไม่ระบุ'} ในวันที่ ${item['evaluate_date']} หรือไม่?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvaluation(item);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("ลบ", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ประเมินผลสถานประกอบการณ์"),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InternEvaluationsFormPage(),
                  ),
                ).then((value) {
                  if (value == true) {
                    fetchAllData();
                  }
                });
              },
              child: const Text(
                'เพิ่ม',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8FFF4),
      body: Column(
        children: [
          // Filter dropdowns
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Student filter
                DropdownButtonFormField<String>(
                  value: selectedStudentId,
                  decoration: InputDecoration(
                    labelText: "เลือกนักศึกษา",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text("-- ทั้งหมด --"),
                    ),
                    ...studentsList.map((student) {
                      return DropdownMenuItem(
                        value: student['student_id'].toString(),
                        child: Text(
                          "${student['student_name']} (${student['student_id']})",
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStudentId = value;
                      applyFilters();
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Company filter
                DropdownButtonFormField<String>(
                  value: selectedCompanyId,
                  decoration: InputDecoration(
                    labelText: "เลือกสถานประกอบการณ์",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text("-- ทั้งหมด --"),
                    ),
                    ...companiesList.map((company) {
                      return DropdownMenuItem(
                        value: company['company_id'].toString(),
                        child: Text(company['company_name'].toString()),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCompanyId = value;
                      applyFilters();
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Term filter
                DropdownButtonFormField<String>(
                  value: selectedTerm,
                  decoration: InputDecoration(
                    labelText: "เลือกเทอม",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text("-- ทั้งหมด --"),
                    ),
                    ...termsList.map((term) {
                      return DropdownMenuItem(
                        value: term['term'].toString(),
                        child: Text(term['term'].toString()),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedTerm = value;
                      applyFilters();
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Clear filter button
                if (selectedStudentId != null ||
                    selectedCompanyId != null ||
                    selectedTerm != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                      ),
                      onPressed: _resetFilters,
                      child: const Text("ล้างตัวกรอง"),
                    ),
                  ),
              ],
            ),
          ),

          // Filter info
          if (selectedStudentId != null ||
              selectedCompanyId != null ||
              selectedTerm != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: const Color.fromARGB(255, 23, 163, 58),
              child: Text(
                "แสดงผลกรองข้อมูล (${filteredDataList.length} รายการ)",
                style: const TextStyle(color: Color.fromARGB(255, 44, 243, 33)),
              ),
            ),

          // Main content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => fetchAllData(),
                          child: const Text("ลองใหม่"),
                        ),
                      ],
                    ),
                  )
                : filteredDataList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          "ไม่มีข้อมูลประเมินผลสถานประกอบการณ์",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => fetchAllData(),
                          child: const Text("รีเฟรช"),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredDataList.length,
                    itemBuilder: (context, index) {
                      final item = filteredDataList[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "วันที่ประเมิน: ${item['evaluate_date'] ?? 'ไม่ระบุ'}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "เทอม: ${item['term'] ?? 'ไม่ระบุ'}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(item['status']),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _getStatusText(item['status']),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Details row
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "สถานประกอบการ",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          item['company_name'] ??
                                              item['company_id'] ??
                                              'ไม่ระบุ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "นักศึกษา",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          item['student_name'] ??
                                              item['std_id'] ??
                                              'ไม่ระบุ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Cost info
                              Row(
                                children: [
                                  Expanded(
                                    child: _infoChip(
                                      "ค่าเรียน",
                                      "฿ ${item['price'] ?? '0'}",
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _infoChip(
                                      "ค่าทำการ",
                                      "฿ ${item['cost'] ?? '0'}",
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _infoChip(
                                      "ค่าเดินทาง",
                                      "฿ ${item['transport'] ?? '0'}",
                                    ),
                                  ),
                                ],
                              ),

                              if (item['detail'] != null &&
                                  item['detail']!.toString().isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 12),
                                    const Text(
                                      "รายละเอียด",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['detail'].toString(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 12),
                              // Buttons row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[700],
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              InternEvaluationsFormPage(
                                                evaluation: item,
                                              ),
                                        ),
                                      ).then((value) {
                                        if (value == true) {
                                          fetchAllData();
                                        }
                                      });
                                    },
                                    child: const Text(
                                      'แก้ไข',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () {
                                      _confirmDeleteEvaluation(item);
                                    },
                                    child: const Text(
                                      'ลบ',
                                      style: TextStyle(fontSize: 12),
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

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
