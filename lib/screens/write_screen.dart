import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 글쓰기 화면 (상품 등록)
/// - 사진 업로드(자리만 마련)
/// - 상품명
/// - 대여 장소
/// - 1일 가격
/// - 상세 설명(멀티라인)
/// - 대여 가능 기간(시작/종료 날짜)
/// - 보증금
///
/// 팔레트/폰트는 기존 앱 규칙을 따릅니다.
class WriteScreen extends StatefulWidget {
  const WriteScreen({super.key});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  // Design palette
  static const Color strong = Color(0xFF213555);
  static const Color weak = Color(0xFF3E5879);
  static const Color bg = Color(0xFFF5EFE7);

  // Controllers
  final _titleCtrl = TextEditingController();
  final _placeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(); // 1일 가격
  final _depositCtrl = TextEditingController(); // 보증금
  final _descCtrl = TextEditingController(); // 상세 설명

  final _formKey = GlobalKey<FormState>();

  DateTime? _startDate;
  DateTime? _endDate;

  // ---- helpers ----
  InputDecoration _boxInput(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontFamily: 'NotoSans', color: Colors.black54),
    filled: true,
    fillColor: const Color(0xFFF5EFE7),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8, top: 20),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: 'NotoSans',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
  );

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate ?? now)
        : (_endDate ?? (_startDate ?? now));
    final first = DateTime(now.year - 1);
    final last = DateTime(now.year + 3);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: const ColorScheme.light(primary: strong)),
          child: child!,
        );
      },
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        // 시작일이 종료일보다 뒤면 종료일을 비움
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  String _dateText(DateTime? d, String placeholder) =>
      d == null ? placeholder : "${d.year}.${_two(d.month)}.${_two(d.day)}";

  String _two(int n) => n.toString().padLeft(2, '0');

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('대여 가능 기간을 선택해 주세요.')));
      return;
    }

    // TODO: 업로드 로직(이미지/데이터 전송) 연결
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('등록 완료! (업로드 로직 연결 필요)')));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _placeCtrl.dispose();
    _priceCtrl.dispose();
    _depositCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
    // ignore: dead_code
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: strong,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, // 화살표 색상을 흰색으로 설정
        ),
        title: const Text(
          '글쓰기',
          style: TextStyle(
            fontFamily: 'NotoSans',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 사진 업로드 자리
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // TODO: image_picker 연동 (카메라/갤러리)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('사진 업로드는 추후 연결됩니다.')),
                        );
                      },
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5EFE7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.photo_camera_outlined,
                          size: 36,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '최소 1장 이상의 사진을 등록해 주세요.',
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),

                // 상품명
                _label('상품명'),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: _boxInput('예: 생활자전거 26인치'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '상품명을 입력해 주세요.' : null,
                ),

                // 대여 장소
                _label('대여 장소'),
                TextFormField(
                  controller: _placeCtrl,
                  decoration: _boxInput('예: 서울시 마포구 합정동'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? '대여 장소를 입력해 주세요.'
                      : null,
                ),

                // 1일 가격
                _label('1일 가격'),
                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _boxInput('예: 15000 (숫자만)'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '가격을 입력해 주세요.' : null,
                ),

                // 보증금
                _label('보증금'),
                TextFormField(
                  controller: _depositCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _boxInput('예: 50000 (선택 사항)'),
                ),

                // 상세 설명
                _label('상세 설명'),
                TextFormField(
                  controller: _descCtrl,
                  decoration: _boxInput('물품 상태, 주의사항, 특징 등을 자세히 적어 주세요.'),
                  maxLines: 6,
                  minLines: 4,
                ),

                // 대여 가능 기간
                _label('대여 가능 기간'),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(isStart: true),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5EFE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _dateText(_startDate, '시작일 선택'),
                                style: const TextStyle(
                                  fontFamily: 'NotoSans',
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '~',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(isStart: false),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5EFE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _dateText(_endDate, '종료일 선택'),
                                style: const TextStyle(
                                  fontFamily: 'NotoSans',
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: strong,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _submit,
                    child: const Text(
                      '등록하기',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
