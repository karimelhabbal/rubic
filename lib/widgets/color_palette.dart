import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cube_state.dart';

class ColorPalette extends StatelessWidget {
  const ColorPalette({super.key});

  static const _colors = [
    (CubeColor.white, Color(0xFFEEEEEE), 'أبيض'),
    (CubeColor.yellow, Color(0xFFFFD700), 'أصفر'),
    (CubeColor.red, Color(0xFFE53935), 'أحمر'),
    (CubeColor.orange, Color(0xFFFF6F00), 'برتقالي'),
    (CubeColor.blue, Color(0xFF1565C0), 'أزرق'),
    (CubeColor.green, Color(0xFF2E7D32), 'أخضر'),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<CubeState>(
      builder: (context, state, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF12121A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 4, bottom: 12),
                child: Text(
                  'اختر اللون',
                  style: TextStyle(
                    color: Colors.white54,
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _colors.map((c) {
                  final isSelected = state.selectedColor == c.$1;
                  return GestureDetector(
                    onTap: () => state.selectColor(c.$1),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isSelected ? 48 : 40,
                          height: isSelected ? 48 : 40,
                          decoration: BoxDecoration(
                            color: c.$2,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 2.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: c.$2.withOpacity(0.6),
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: c.$2.withOpacity(0.2),
                                      blurRadius: 8,
                                    ),
                                  ],
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.black54, size: 20)
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c.$3,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white38,
                            fontFamily: 'Cairo',
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
