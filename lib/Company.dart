// 1. สร้างฟอร์มชื่อ Company.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'user_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

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
      code: json['tumbol_code'].toString(), // เปลี่ยน key ตรงนี้
      nameTh: json['name_th'].toString(),
    );
  }
}

class CompanyPage extends StatefulWidget {
  final String? company_id;
  final String? company_name;
  final String? address;
  final String? tumbol_code;
  final String? amphur_code;
  final String? province_code;
  final String? postcode;
  final String? contact_name;
  final String? telno;
  final String? latitude;
  final String? longitude;
  final int? xcase;

  const CompanyPage({
    super.key,
    this.company_id,
    this.company_name,
    this.address,
    this.tumbol_code,
    this.amphur_code,
    this.province_code,
    this.postcode,
    this.contact_name,
    this.telno,
    this.latitude,
    this.longitude,
    this.xcase,
  });

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  final TextEditingController company_idController = TextEditingController();
  final TextEditingController company_nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController tumbol_codeController = TextEditingController();
  final TextEditingController amphur_codeController = TextEditingController();
  final TextEditingController province_codeController = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();
  final TextEditingController contact_nameController = TextEditingController();
  final TextEditingController telnoController = TextEditingController();

  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final MapController mapController = MapController();
  LatLng _markerPos = LatLng(15.87, 100.99); // ค่าเริ่มต้น

  List<AmphurItem> amphurs = [];
  String? selectedAmphurCode;
  bool amphursLoading = false;
  String? amphursError;

  List<ProvinceItem> provinces = [];
  String? selectedProvinceCode;
  bool provincesLoading = false;
  String? provincesError;

  List<TumbolItem> tumbols = [];
  String? selectedTumbolCode;
  bool tumbolsLoading = false;
  String? tumbolsError;

  @override
  void initState() {
    super.initState();
    company_idController.text = widget.company_id ?? "";
    company_nameController.text = widget.company_name ?? "";
    addressController.text = widget.address ?? "";
    tumbol_codeController.text = widget.tumbol_code ?? "";
    amphur_codeController.text = widget.amphur_code ?? "";
    province_codeController.text = widget.province_code ?? "";
    postcodeController.text = widget.postcode ?? "";
    contact_nameController.text = widget.contact_name ?? "";
    telnoController.text = widget.telno ?? "";
    latitudeController.text = widget.latitude ?? "";
    longitudeController.text = widget.longitude ?? "";

    if (widget.latitude != null && widget.longitude != null) {
      double? lat = double.tryParse(widget.latitude ?? "");
      double? lng = double.tryParse(widget.longitude ?? "");
      if (lat != null && lng != null) {
        _markerPos = LatLng(lat, lng);
      }
    }

    _fetchProvinces();
  }

  @override
  void dispose() {
    company_idController.dispose();
    company_nameController.dispose();
    addressController.dispose();
    tumbol_codeController.dispose();
    amphur_codeController.dispose();
    province_codeController.dispose();
    postcodeController.dispose();
    contact_nameController.dispose();
    telnoController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  Future<void> _setInitialLocationFromUser() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      if (result == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("กรุณาอนุญาต Location ในการตั้งค่าเครื่อง"),
          ),
        );
        return;
      }
    }
    // ดึงตำแหน่ง
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    LatLng userLatLng = LatLng(position.latitude, position.longitude);
    setState(() {
      _markerPos = userLatLng;
      latitudeController.text = position.latitude.toStringAsFixed(6);
      longitudeController.text = position.longitude.toStringAsFixed(6);
    });
    // เลื่อนแผนที่ไปตำแหน่งผู้ใช้
    mapController.move(userLatLng, 16);
  }

  // 5. สร้างฟังก์ชัน _fetchAmphurs
  Future<void> _fetchAmphurs(String provinceCode) async {
    setState(() {
      amphursLoading = true;
      amphursError = null;
      amphurs = [];
      selectedAmphurCode = null;
    });

    try {
      // ส่ง province_code ไปที่ API (GET query param)
      final url = Uri.parse(
        "http://192.168.171.1/api_copy/getamphur.php?province_code=$provinceCode",
      );

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // แปลงข้อมูล JSON ที่ได้มาให้เป็น List ของ Object AmphurItem
        amphurs = data
            .map((e) => AmphurItem.fromJson(e as Map<String, dynamic>))
            .toList();

        // ถ้ามีค่า amphur_code เดิมจาก widget ให้ preselect ถ้าตรงกับรายการ
        if (widget.amphur_code != null && widget.amphur_code!.isNotEmpty) {
          final String input = widget.amphur_code!.toString().trim();
          final found = amphurs.firstWhere(
            (a) => a.code == input || a.nameTh == input,
            orElse: () => AmphurItem(code: "", nameTh: ""),
          );

          if (found.code.isNotEmpty) {
            selectedAmphurCode = found.code;
            amphur_codeController.text = found.code;
          }
        }

        setState(() {
          amphursLoading = false;
        });
        
        // โหลด tumbols หลังจาก amphurs เสร็จ เป็น background
        if (widget.amphur_code != null && widget.amphur_code!.isNotEmpty) {
          final String input = widget.amphur_code!.toString().trim();
          final found = amphurs.firstWhere(
            (a) => a.code == input || a.nameTh == input,
            orElse: () => AmphurItem(code: "", nameTh: ""),
          );
          if (found.code.isNotEmpty) {
            _fetchTumbols(found.code);
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
      // ส่ง amphur_code ไปที่ API (เปลี่ยนชื่อไฟล์ php และพารามิเตอร์)
      final url = Uri.parse(
        "http://192.168.171.1/api_copy/gettumbol.php?amphur_code=$amphurCode",
      );

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        tumbols = data
            .map((e) => TumbolItem.fromJson(e as Map<String, dynamic>))
            .toList();

        // ถ้ามีค่า tumbol_code เดิมจาก widget ให้ preselect (ถ้าตรงกับรายการ)
        if (widget.tumbol_code != null && widget.tumbol_code!.isNotEmpty) {
          final String input = widget.tumbol_code!.toString().trim();
          final found = tumbols.firstWhere(
            (t) => t.code == input || t.nameTh == input,
            orElse: () => TumbolItem(code: "", nameTh: ""),
          );

          if (found.code.isNotEmpty) {
            selectedTumbolCode = found.code;
            tumbol_codeController.text = found.code;
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

  Future<void> _fetchProvinces() async {
    setState(() {
      provincesLoading = true;
      provincesError = null;
    });
    try {
      // ตรวจสอบ URL API ให้ถูกต้อง (ถ้าใช้ Emulator ต้องใช้ IP เครื่อง หรือ 10.0.2.2 แทน 192.168.171.1)
      final url = Uri.parse("http://192.168.171.1/api_copy/getprovince.php");
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        provinces = data
            .map((e) => ProvinceItem.fromJson(e as Map<String, dynamic>))
            .toList();

        // Logic เลือกจังหวัดเริ่มต้น ถ้ามีข้อมูลเก่าส่งมา (Edit Case)
        if (widget.province_code != null && widget.province_code!.isNotEmpty) {
          final String input = widget.province_code!.toString().trim();

          // หาตามรหัสหรือชื่อ
          final byMatch = provinces.firstWhere(
            (p) => p.code == input || p.nameTh == input,
            orElse: () => ProvinceItem(code: "", nameTh: ""),
          );

          if (byMatch.code.isNotEmpty) {
            setState(() {
              selectedProvinceCode = byMatch.code;
            });
            province_codeController.text = byMatch.code;
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

  void _updateLatLng(LatLng point) {
    setState(() {
      _markerPos = point;
      latitudeController.text = point.latitude.toStringAsFixed(6);
      longitudeController.text = point.longitude.toStringAsFixed(6);
    });
  }

  Future<void> _submitDevice() async {
    // เตรียมค่าที่จะส่งไป API ตามรูปแบบใหม่
    final nameController = company_nameController;
    final contactController = contact_nameController;
    final lat = latitudeController.text.trim();
    final lng = longitudeController.text.trim();
    final selectedProvince = selectedProvinceCode ?? province_codeController.text.trim();
    final selectedAmphur = selectedAmphurCode ?? amphur_codeController.text.trim();
    final selectedTumbol = selectedTumbolCode ?? tumbol_codeController.text.trim();

    // ตรวจสอบข้อมูลครบถ้วนทั้งเพิ่มและแก้ไข
    if ((widget.xcase == 1 || widget.xcase == 2)) {
      if ((nameController.text.trim().isEmpty) ||
          (addressController.text.trim().isEmpty) ||
          (selectedTumbol.isEmpty) ||
          (selectedAmphur.isEmpty) ||
          (selectedProvince.isEmpty) ||
          (postcodeController.text.trim().isEmpty) ||
          (contactController.text.trim().isEmpty) ||
          (telnoController.text.trim().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("กรุณากรอกข้อมูลให้ครบถ้วน")),
        );
        return;
      }
    }

    try {
      final response = await http.post(
        Uri.parse("http://192.168.171.1/api_copy/savedatacompany.php"),
        body: {
          "xcase": widget.xcase?.toString() ?? "",
          "company_id": widget.company_id ?? "", // สำคัญมากสำหรับการแก้ไข
          "company_name": nameController.text,
          "address": addressController.text,
          "tumbol_code": selectedTumbol,
          "amphur_code": selectedAmphur,
          "province_code": selectedProvince,
          "postcode": postcodeController.text,
          "telno": telnoController.text,
          "contact_name": contactController.text,
          "latitude": lat,
          "longitude": lng,
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "บันทึกสำเร็จ")),
          );
          Navigator.pop(context);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ฟังก์ชันช่วยให้ใส่ inputFormatters ให้ TextField รับได้เฉพาะตัวเลขและทศนิยม
    List<TextInputFormatter> numericInputFormatter = [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
    ];

    String titleText = "";

    if (widget.xcase == 1) {
      titleText = "เพิ่มสถานประกอบการ";
    } else if (widget.xcase == 2) {
      titleText = "แก้ไขสถานประกอบการ";
    } else if (widget.xcase == 3) {
      titleText = "ยกเลิกสถานประกอบการ";
    } else {
      titleText = "สถานประกอบการ";
    }

    return Scaffold(
      appBar: AppBar(title: Text(titleText), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: company_idController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: "รหัส",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: company_nameController,
              decoration: const InputDecoration(
                labelText: "ชื่อสถานประกอบการ",
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
                      const SizedBox(height: 8),
                      TextField(
                        controller: province_codeController,
                        decoration: const InputDecoration(
                          labelText: "จังหวัด (ป้อนด้วยมือ)",
                          border: OutlineInputBorder(),
                        ),
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
                    onChanged: (val) {
                      // อัปเดต selectedProvinceCode ทันที
                      setState(() {
                        selectedProvinceCode = val;
                      });

                      // อัปเดต province_codeController ด้วย code
                      final sel = provinces.firstWhere(
                        (p) => p.code == val,
                        orElse: () => ProvinceItem(code: "", nameTh: ""),
                      );

                      if (sel.code.isNotEmpty) {
                        province_codeController.text = sel.code;
                      } else {
                        province_codeController.clear();
                      }

                      // เคลียร์ amphur และ tumbols เตรียมโหลด
                      setState(() {
                        amphurs = [];
                        selectedAmphurCode = null;
                        amphur_codeController.clear();
                        tumbols = [];
                        selectedTumbolCode = null;
                        tumbol_codeController.clear();
                      });

                      // โหลด amphur ของจังหวัดที่เลือกเป็น background
                      if (val != null && val.isNotEmpty) {
                        _fetchAmphurs(val);
                      }
                    },
                    // แสดงชื่อจากฟิลด์ name_th
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
                      const SizedBox(height: 8),
                      TextField(
                        controller: amphur_codeController,
                        decoration: const InputDecoration(
                          labelText: "อำเภอ (ป้อนด้วยมือ)",
                          border: OutlineInputBorder(),
                        ),
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
                    // ข้อความเมื่อยังไม่เลือกจังหวัด หรือไม่มีข้อมูลอำเภอ
                    disabledHint: const Text("กรุณาเลือกจังหวัดก่อน"),

                    // ถ้าไม่มีข้อมูล ให้ items เป็น null หรือ list ว่าง
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
                    // ถ้าไม่มีข้อมูล ให้ onChanged เป็น null เพื่อปิดการกด (Disable)
                    onChanged: amphurs.isEmpty
                        ? null
                        : (val) {
                            setState(() {
                              selectedAmphurCode = val;
                            });
                            
                            final sel = amphurs.firstWhere(
                              (a) => a.code == val,
                              orElse: () => AmphurItem(code: "", nameTh: ""),
                            );
                            if (sel.code.isNotEmpty) {
                              amphur_codeController.text = sel.code;
                            } else {
                              amphur_codeController.clear();
                            }
                            
                            setState(() {
                              selectedTumbolCode = null;
                              tumbols = [];
                              tumbol_codeController.clear();
                            });
                            
                            if (val != null && val.isNotEmpty) {
                              _fetchTumbols(val);
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
                      const SizedBox(height: 8),
                      // fallback: ถ้าโหลดตำบลไม่สำเร็จ ให้แสดง TextField ให้แก้ไขได้
                      TextField(
                        controller:
                            tumbol_codeController, // อย่าลืมเปลี่ยนชื่อ Controller
                        decoration: const InputDecoration(
                          labelText: "ตำบล (ป้อนด้วยมือ)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  )
                : DropdownButtonFormField<String>(
                    value: selectedTumbolCode,
                    decoration: const InputDecoration(
                      labelText: "ตำบล",
                      border: OutlineInputBorder(),
                    ),
                    items: tumbols
                        .map(
                          (t) => DropdownMenuItem<String>(
                            value: t.code,
                            child: Text(t.nameTh),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedTumbolCode = val;

                        // หา Object ตําบลที่เลือกเพื่อเอาข้อมูลอื่น ๆ (ถ้าจำเป็น)
                        final sel = tumbols.firstWhere(
                          (t) => t.code == val,
                          orElse: () => TumbolItem(code: "", nameTh: ""),
                        );

                        if (sel.code.isNotEmpty) {
                          // อัปเดตค่าลง Controller (ถ้ามีใช้สำหรับส่งฟอร์ม)
                          tumbol_codeController.text = sel.code;
                        } else {
                          tumbol_codeController.clear();
                        }
                      });
                    },
                    selectedItemBuilder: (context) {
                      return tumbols.map((t) => Text(t.nameTh)).toList();
                    },
                  ),
            const SizedBox(height: 10),
            TextField(
              controller: postcodeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: numericInputFormatter,
              decoration: const InputDecoration(
                labelText: "รหัสไปรษณีย์",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contact_nameController,
              decoration: const InputDecoration(
                labelText: "ชื่อผู้ติดต่อ",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: telnoController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: numericInputFormatter,
              decoration: const InputDecoration(
                labelText: "เบอร์โทร",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Latitude / Longitude
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: latitudeController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Latitude",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: longitudeController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Longitude",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _setInitialLocationFromUser,
                icon: const Icon(Icons.my_location),
                label: const Text("ใช้ตำแหน่งปัจจุบัน"),
              ),
            ),
            const SizedBox(height: 10),
            // Map
            SizedBox(
              height: 350,
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: _markerPos,
                  initialZoom: 6.5,
                  onTap: (tapPos, point) => _updateLatLng(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'cit0006',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _markerPos,
                        width: 60,
                        height: 60,
                        child: const Icon(
                          Icons.location_on,
                          size: 50,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitDevice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text("บันทึกข้อมูล"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
