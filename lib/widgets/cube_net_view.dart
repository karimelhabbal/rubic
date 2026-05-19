import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cube_state.dart';

class CubeNetView extends StatelessWidget {
  final double scale;

  const CubeNetView({super.key, this.scale = 1.0});

  static const cellSize = 18.0;
  static const gap = 2.0;

  @override
  Widget build(BuildContext context) {
    return Consumer<CubeState>(
      builder: (context, state, _) {
        final faceSize = (cellSize * 3 + gap * 2);
        final totalWidth = faceSize * 4 + gap * 3;
        final totalHeight = faceSize * 3 + gap * 2;

        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: totalWidth,
            height: totalHeight,
            child: Stack(
              children: [
                // U face - top center
                Positioned(
                  left: faceSize + gap,
                  top: 0,
                  child: _buildFace(state.faces[0]),
                ),
                // L face - middle left
                Positioned(
                  left: 0,
                  top: faceSize + gap,
                  child: _buildFace(state.faces[4]),
                ),
                // F face - middle center
                Positioned(
                  left: faceSize + gap,
                  top: faceSize + gap,
                  child: _buildFace(state.faces[2]),
                ),
                // R face - middle right
                Positioned(
                  left: (faceSize + gap) * 2,
                  top: faceSize + gap,
                  child: _buildFace(state.faces[1]),
                ),
                // B face - middle far right
                Positioned(
                  left: (faceSize + gap) * 3,
                  top: faceSize + gap,
                  child: _buildFace(state.faces[5]),
                ),
                // D face - bottom center
                Positioned(
                  left: faceSize + gap,
                  top: (faceSize + gap) * 2,
                  child: _buildFace(state.faces[3]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFace(List<CubeColor> faceColors) {
    return SizedBox(
      width: cellSize * 3 + gap * 2,
      height: cellSize * 3 + gap * 2,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: gap,
          mainAxisSpacing: gap,
        ),
        itemCount: 9,
        itemBuilder: (_, i) => Container(
          decoration: BoxDecoration(
            color: _colorValue(faceColors[i]),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: Colors.black.withOpacity(0.4),
              width: 0.5,
            ),
          ),
        ),
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
      case CubeColor.none: return const Color(0xFF2A2A3E);
    }
  }
}
