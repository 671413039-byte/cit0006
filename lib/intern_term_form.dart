import 'package:flutter/material.dart';

class InternTermFormPage extends StatefulWidget {
  final Map<String, dynamic>? term; // ถ้ามีคือแก้ไข ถ้า null คือเพิ่มใหม่
  const InternTermFormPage({Key? key, this.term}) : super(key: key);

  @override
  State<InternTermFormPage> createState() => _InternTermFormPageState();
}

class _InternTermFormPageState extends State<InternTermFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String term;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    term = widget.term?['term'] ?? '';
    startDate = widget.term?['start_date'] != null ? DateTime.tryParse(widget.term!['start_date']) : null;
    endDate = widget.term?['end_date'] != null ? DateTime.tryParse(widget.term!['end_date']) : null;
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now());
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      print({
        'term': term,
        'start_date': startDate?.toIso8601String().substring(0, 10),
        'end_date': endDate?.toIso8601String().substring(0, 10),
      }); // debug
      Navigator.of(context).pop({
        'term': term,
        'start_date': startDate?.toIso8601String().substring(0, 10),
        'end_date': endDate?.toIso8601String().substring(0, 10),
      });
    }
  }

  void _delete() {
    // TODO: ลบข้อมูล term จาก backend
    Navigator.of(context).pop({'delete': true, 'term': term});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.term == null ? 'เพิ่มภาคการศึกษา' : 'แก้ไขภาคการศึกษา'),
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextFormField(
                    initialValue: term,
                    enabled: widget.term == null,
                    decoration: const InputDecoration(
                      labelText: 'ภาคการศึกษา',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (val) => term = val,
                    validator: (val) => val == null || val.isEmpty ? 'กรุณากรอกภาคการศึกษา' : null,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: InkWell(
                          onTap: () => _pickDate(context, true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'วันที่เริ่มฝึก',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            child: Text(startDate != null ? '${startDate!.toLocal()}'.split(' ')[0] : 'เลือกวันที่'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: InkWell(
                          onTap: () => _pickDate(context, false),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'วันที่สิ้นสุด',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            child: Text(endDate != null ? '${endDate!.toLocal()}'.split(' ')[0] : 'เลือกวันที่'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          onPressed: _save,
                          child: const Text('บันทึก'),
                        ),
                      ),
                    ),
                    if (widget.term != null) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            onPressed: _delete,
                            child: const Text('ลบ'),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
