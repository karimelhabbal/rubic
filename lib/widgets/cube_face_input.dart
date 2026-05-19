import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cube_state.dart';

class CubeFaceInput extends StatelessWidget {
  final int faceIndex;
  final Function(int) onCellTap;

  const CubeFaceInput({
    super.key,
    required this.faceIndex,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CubeState>(
      builder: (context, state, _) {
        final face = state.faces[faceIndex];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF12121A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _faceDot(faceIndex),
                  const SizedBox(width: 8),
                  Text(
                    CubeState.faceNamesAr[faceIndex],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 240,
                height: 240,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return _buildCell(context, face[index], index, index == 4);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _faceDot(int faceIndex) {
    final faceColors = [
      Colors.white,
      Colors.red,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.green,
    ];
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: faceColors[faceIndex],
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: faceColors[faceIndex].withOpacity(0.5),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildCell(BuildContext context, CubeColor color, int index, bool isCenter) {
    return GestureDetector(
      onTap: isCenter ? null : () => onCellTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _colorValue(color),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCenter
                ? Colors.white.withOpacity(0.3)
                : color == CubeColor.none
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.3),
            width: isCenter ? 2 : 1,
          ),
          boxShadow: color != CubeColor.none && !isCenter
              ? [
                  BoxShadow(
                    color: _colorValue(color).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: isCenter
            ? Center(
                child: Icon(
                  Icons.circle,
                  color: Colors.white.withOpacity(0.5),
                  size: 14,
                ),
              )
            : color == CubeColor.none
                ? Center(
                    child: Icon(
                      Icons.add,
                      color: Colors.white.withOpacity(0.15),
                      size: 18,
                    ),
                  )
                : null,
      ),
    );
  }

  Color _colorValue(CubeColor color) {
    switch (color) {
      case CubeColor.white: return const Color(0xFFEEEEEE);
      case CubeColor.yellow: return const Color(0xFFFFD700);
      case CubeColor.red: return const Color(0xFFE53935);
      case CubeColor.orange: return const Color(0xFFFF6F00);
      case CubeColor.blue: return const Color(0xFF1565C0);
      case CubeColor.green: return const Color(0xFF2E7D32);
      case CubeColor.none: return const Color(0xFF1E1E2E);
    }
  }
}
