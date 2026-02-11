import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
// import 'user_model.dart';
// import 'package:provider/provider.dart';

class ProvinceItem {
  final String code;
  final String nameTh;
  ProvinceItem({required this.code, required this.nameTh});
  factory ProvinceItem.fromJson(Map<String, dynamic> json) {
    return ProvinceItem(
      code: json['province_code'].toString(),
      nameTh: json['name_th'].toString(),
    );
  }
}

class AmphurItem {
  final String code;
  final String nameTh;
  AmphurItem({required this.code, required this.nameTh});

  factory AmphurItem.fromJson(Map<String, dynamic> json) {
    return AmphurItem(
      code: json['amphur_code'].toString(),
      nameTh: json['name_th'].toString(),
    );
  }
}

class TumbolItem {
  final String code;
  final String nameTh;
  TumbolItem({required this.code, required this.nameTh});

  factory TumbolItem.fromJson(Map<String, dynamic> json) {
    return TumbolItem(
      code: json['tumbol_code'].toString(),
      nameTh: json['name_th'].toString(),
    );
  }
}

class StudentPage extends StatefulWidget {
  final String? student_id;
  final String? student_name;
  final String? address;
  final String? tumbon;
  final String? amphur;
  final String? province;
  final String? postcode;
  final String? telno;
  final int? xcase;

  const StudentPage({
    super.key,
    this.student_id,
    this.student_name,
    this.address,
    this.tumbon,
    this.amphur,
    this.province,
    this.postcode,
    this.telno,
    this.xcase,
  });

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final TextEditingController student_idController = TextEditingController();
  final TextEditingController student_nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();
  final TextEditingController telnoController = TextEditingController();

  List<ProvinceItem> provinces = [];
  String? selectedProvinceCode;
  bool provincesLoading = false;
  String? provincesError;

  List<AmphurItem> amphurs = [];
  String? selectedAmphurCode;
  bool amphursLoading = false;
  String? amphursError;

  List<TumbolItem> tumbols = [];
  String? selectedTumbolCode;
  bool tumbolsLoading = false;
  String? tumbolsError;

  @override
  void initState() {
    super.initState();
    // รับค่ามาแสดง (กรณีแก้ไข)
    if (widget.student_id != null) {
      student_idController.text = widget.student_id!;
    }
    if (widget.student_name != null) {
      student_nameController.text = widget.student_name!;
    }
    if (widget.address != null) {
      addressController.text = widget.address!;
    }
    if (widget.postcode != null) {
      postcodeController.text = widget.postcode!;
    }
    if (widget.telno != null) {
      telnoController.text = widget.telno!;
    }

    _fetchProvinces();
  }

  Future<void> _fetchProvinces() async {
    setState(() {
      provincesLoading = true;
      provincesError = null;
    });
    try {
      final url = Uri.parse("http://192.168.1.228/api_copy/getprovince.php");
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        provinces = data
            .map((e) => ProvinceItem.fromJson(e as Map<String, dynamic>))
            .toList();

        // เลือกจังหวัดเริ่มต้น ถ้ามีข้อมูลเก่า (Edit Case)
        if (widget.province != null && widget.province!.isNotEmpty) {
          final String input = widget.province!.toString().trim();
          final byMatch = provinces.firstWhere(
            (p) => p.code == input || p.nameTh == input,
            orElse: () => ProvinceItem(code: "", nameTh: ""),
          );

          if (byMatch.code.isNotEmpty) {
            setState(() {
              selectedProvinceCode = byMatch.code;
            });
            await _fetchAmphurs(byMatch.code);
          }
        }
        setState(() {
          provincesLoading = false;
        });
      } else {
        setState(() {
          provincesLoading = false;
          provincesError = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        provincesLoading = false;
        provincesError = "เกิดข้อผิดพลาดในการโหลดจังหวัด: $e";
      });
    }
  }

  Future<void> _fetchAmphurs(String provinceCode) async {
    setState(() {
      amphursLoading = true;
      amphursError = null;
      amphurs = [];
      selectedAmphurCode = null;
    });

    try {
      final url = Uri.parse(
        "http://192.168.1.228/api_copy/getamphur.php?province_code=$provinceCode",
      );

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        amphurs = data
            .map((e) => AmphurItem.fromJson(e as Map<String, dynamic>))
            .toList();

        setState(() {
          // เลือก amphur เดิม ถ้ามี
          if (widget.amphur != null && widget.amphur!.isNotEmpty) {
            final String input = widget.amphur!.toString().trim();
            final found = amphurs.firstWhere(
              (a) => a.code == input || a.nameTh == input,
              orElse: () => AmphurItem(code: "", nameTh: ""),
            );

            if (found.code.isNotEmpty) {
              selectedAmphurCode = found.code;
            }
          }
          amphursLoading = false;
        });

        // โหลด tumbol หลัง setState
        if (widget.amphur != null && widget.amphur!.isNotEmpty) {
          final String input = widget.amphur!.toString().trim();
          final found = amphurs.firstWhere(
            (a) => a.code == input || a.nameTh == input,
            orElse: () => AmphurItem(code: "", nameTh: ""),
          );

          if (found.code.isNotEmpty) {
            await _fetchTumbols(found.code);
          }
        }
      } else {
        setState(() {
          amphursLoading = false;
          amphursError = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        amphursLoading = false;
        amphursError = "เกิดข้อผิดพลาดในการโหลดอำเภอ: $e";
      });
    }
  }

  Future<void> _fetchTumbols(String amphurCode) async {
    setState(() {
      tumbolsLoading = true;
      tumbolsError = null;
      tumbols = [];
      selectedTumbolCode = null;
    });

    try {
      final url = Uri.parse(
        "http://192.168.1.228/api_copy/gettumbol.php?amphur_code=$amphurCode",
      );

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        tumbols = data
            .map((e) => TumbolItem.fromJson(e as Map<String, dynamic>))
            .toList();

        // เลือก tumbol เดิมถ้ามี
        if (widget.tumbon != null && widget.tumbon!.isNotEmpty) {
          final String input = widget.tumbon!.toString().trim();
          final found = tumbols.firstWhere(
            (t) => t.code == input || t.nameTh == input,
            orElse: () => TumbolItem(code: "", nameTh: ""),
          );

          if (found.code.isNotEmpty) {
            selectedTumbolCode = found.code;
          }
        }

        setState(() {
          tumbolsLoading = false;
        });
      } else {
        setState(() {
          tumbolsLoading = false;
          tumbolsError = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        tumbolsLoading = false;
        tumbolsError = "เกิดข้อผิดพลาดในการโหลดตำบล: $e";
      });
    }
  }

  Future<void> _submitData() async {
    // student_id ไม่ต้องดึงจาก text field ในกรณีเพิ่มใหม่ เพราะ PHP จะสร้างให้
    // แต่กรณีแก้ไข เราต้องส่ง student_id เดิมกลับไป
    final student_id = student_idController.text.trim();
    final student_name = student_nameController.text.trim();
    final address = addressController.text.trim();
    final tumbon = selectedTumbolCode ?? "";
    final amphur = selectedAmphurCode ?? "";
    final province = selectedProvinceCode ?? "";
    final postcode = postcodeController.text.trim();
    final telno = telnoController.text.trim();

    // ตรวจสอบข้อมูลว่าง (ตัด student_id ออกจากการตรวจสอบกรณี xcase=1)
    if (widget.xcase == 2) {
      if (student_id.isEmpty ||
          student_name.isEmpty ||
          address.isEmpty ||
          tumbon.isEmpty ||
          amphur.isEmpty ||
          province.isEmpty ||
          postcode.isEmpty ||
          telno.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("กรุณากรอกข้อมูลให้ครบถ้วน")),
        );
        return;
      }
    } else if (widget.xcase == 1) {
      // กรณีเพิ่มใหม่ เช็คแค่ชื่อ (เพราะ id สร้างเอง)
      if (student_name.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("กรุณากรอกชื่อ-นามสกุล")));
        return;
      }
    }

    try {
      final url = Uri.parse("http://192.168.1.228/api_copy/savedatastudent.php");
      final response = await http.post(
        url,
        body: {
          "student_id": student_id, // ส่งค่าว่างไปถ้าเป็น case 1
          "student_name": student_name,
          "address": address,
          "tumbon": tumbon,
          "amphur": amphur,
          "province": province,
          "postcode": postcode,
          "telno": telno,
          "xcase": widget.xcase.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["status"] == "success") {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("บันทึกข้อมูลสำเร็จ")));
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "บันทึกไม่สำเร็จ")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter> numericInputFormatter = [
      FilteringTextInputFormatter.digitsOnly,
    ];

    String titleText = "";
    if (widget.xcase == 1) {
      titleText = "เพิ่มข้อมูลนักศึกษา";
    } else if (widget.xcase == 2) {
      titleText = "แก้ไขข้อมูลนักศึกษา";
    } else if (widget.xcase == 3) {
      titleText = "ลบข้อมูลนักศึกษา";
    } else {
      titleText = "ข้อมูลนักศึกษา";
    }

    return Scaffold(
      appBar: AppBar(title: Text(titleText), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: student_idController,
              enabled: false, // ปิดการแก้ไขตลอดเวลา (เหมือน Company)
              decoration: const InputDecoration(
                labelText: "รหัสนักศึกษา (ระบบสร้างอัตโนมัติ)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: student_nameController,
              decoration: const InputDecoration(
                labelText: "ชื่อ-นามสกุล",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "ที่อยู่",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            provincesLoading
                ? const SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                : provincesError != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        provincesError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  )
                : DropdownButtonFormField<String>(
                    value: selectedProvinceCode,
                    decoration: const InputDecoration(
                      labelText: "จังหวัด",
                      border: OutlineInputBorder(),
                    ),
                    items: provinces
                        .map(
                          (p) => DropdownMenuItem<String>(
                            value: p.code,
                            child: Text(p.nameTh),
                          ),
                        )
                        .toList(),
                    onChanged: (val) async {
                      setState(() {
                        selectedProvinceCode = val;
                      });

                      if (val != null && val.isNotEmpty) {
                        await _fetchAmphurs(val);
                      }
                    },
                    selectedItemBuilder: (context) {
                      return provinces.map((p) => Text(p.nameTh)).toList();
                    },
                  ),
            const SizedBox(height: 10),
            amphursLoading
                ? const SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                : amphursError != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        amphursError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  )
                : DropdownButtonFormField<String>(
                    value: selectedAmphurCode,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "อำเภอ",
                      border: OutlineInputBorder(),
                    ),
                    disabledHint: const Text("กรุณาเลือกจังหวัดก่อน"),
                    items: amphurs.isEmpty
                        ? []
                        : amphurs
                            .map(
                              (a) => DropdownMenuItem<String>(
                                value: a.code,
                                child: Text(a.nameTh),
                              ),
                            )
                            .toList(),
                    onChanged: amphurs.isEmpty
                        ? null
                        : (val) async {
                            setState(() {
                              selectedAmphurCode = val;
                            });

                            if (val != null && val.isNotEmpty) {
                              await _fetchTumbols(val);
                            }
                          },
                    selectedItemBuilder: (context) {
                      return amphurs.map((a) => Text(a.nameTh)).toList();
                    },
                  ),
            const SizedBox(height: 10),
            tumbolsLoading
                ? const SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                : tumbolsError != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        tumbolsError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  )
                : DropdownButtonFormField<String>(
                    value: selectedTumbolCode,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "ตำบล",
                      border: OutlineInputBorder(),
                    ),
                    disabledHint: const Text("กรุณาเลือกอำเภอก่อน"),
                    items: tumbols.isEmpty
                        ? []
                        : tumbols
                            .map(
                              (t) => DropdownMenuItem<String>(
                                value: t.code,
                                child: Text(t.nameTh),
                              ),
                            )
                            .toList(),
                    onChanged: tumbols.isEmpty
                        ? null
                        : (val) {
                            setState(() {
                              selectedTumbolCode = val;
                            });
                          },
                    selectedItemBuilder: (context) {
                      return tumbols.map((t) => Text(t.nameTh)).toList();
                    },
                  ),
            const SizedBox(height: 10),
            TextField(
              controller: postcodeController,
              keyboardType: TextInputType.number,
              inputFormatters: numericInputFormatter,
              decoration: const InputDecoration(
                labelText: "รหัสไปรษณีย์",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: telnoController,
              keyboardType: TextInputType.phone,
              inputFormatters: numericInputFormatter,
              decoration: const InputDecoration(
                labelText: "เบอร์โทรศัพท์",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.xcase == 3 ? Colors.red : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text(widget.xcase == 3 ? "ยืนยันการลบ" : "บันทึกข้อมูล"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
