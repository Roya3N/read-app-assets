import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

class TracingScreen extends StatefulWidget {
  final String letter;
  final String imagePath; // آدرس عکس کاربرگ الفبا

  const TracingScreen({
    super.key,
    required this.letter,
    required this.imagePath,
  });

  @override
  State<TracingScreen> createState() => _TracingScreenState();
}

class _TracingScreenState extends State<TracingScreen> {
  // لیستی از نقاط برای ذخیره مسیر حرکت انگشت
  List<Offset?> _points = [];
  Color _selectedColor = const Color(0xFF8B5CF6); // رنگ پیش‌فرض قلم (بنفش)
  final double _strokeWidth = 8.0;

  final List<Color> _colors = [
    const Color(0xFF8B5CF6), // بنفش
    const Color(0xFFEF4444), // قرمز
    const Color(0xFF3B82F6), // آبی
    const Color(0xFF10B981), // سبز
    const Color(0xFFF59E0B), // زرد
  ];

  void _clearBoard() {
    HapticFeedback.mediumImpact();
    setState(() {
      _points.clear();
    });
  }

  void _finishTracing() {
    HapticFeedback.heavyImpact();
    // در اینجا می‌توانید منطق اضافه کردن XP به دیتابیس را قرار دهید
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✨ Awesome! +20 XP earned!"),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            // هدر صفحه
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  Text(
                    "Trace the Letter ${widget.letter}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  GestureDetector(
                    onTap: _clearBoard,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // بوم نقاشی و عکس پس‌زمینه
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(27),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 🖼️ عکس کاربرگ الفبا در پس‌زمینه
                      Image.asset(
                        widget.imagePath,
                        fit: BoxFit
                            .contain, // عکس رو کامل نشون میده بدون دفرمه شدن
                        alignment: Alignment.center,
                      ),

                      // 🖌️ لایه شیشه‌ای برای نقاشی کشیدن
                      GestureDetector(
                        onPanStart: (details) {
                          setState(() {
                            RenderBox renderBox =
                                context.findRenderObject() as RenderBox;
                            _points.add(
                              renderBox.globalToLocal(details.globalPosition) -
                                  const Offset(20, 90),
                            ); // تنظیم افست
                          });
                        },
                        onPanUpdate: (details) {
                          setState(() {
                            RenderBox renderBox =
                                context.findRenderObject() as RenderBox;
                            _points.add(
                              renderBox.globalToLocal(details.globalPosition) -
                                  const Offset(20, 90),
                            );
                          });
                        },
                        onPanEnd: (details) {
                          setState(() {
                            _points.add(null); // انگشت برداشته شد
                          });
                        },
                        child: CustomPaint(
                          painter: DrawingPainter(
                            points: _points,
                            color: _selectedColor,
                            strokeWidth: _strokeWidth,
                          ),
                          size: Size.infinite,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),
            ),

            // پالت رنگ‌ها و دکمه تایید
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // پالت رنگ
                  Row(
                    children: _colors.map((color) {
                      bool isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedColor = color);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          height: isSelected ? 45 : 35,
                          width: isSelected ? 45 : 35,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: isSelected ? 3 : 1,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // دکمه Done
                  ElevatedButton(
                    onPressed: _finishTracing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      "Done! 🌟",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🎨 کلاس منطق نقاشی
class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;
  final double strokeWidth;

  DrawingPainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
