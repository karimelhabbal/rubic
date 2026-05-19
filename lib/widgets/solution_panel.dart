import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cube_state.dart';

class SolutionPanel extends StatelessWidget {
  const SolutionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CubeState>(
      builder: (context, state, _) {
        if (!state.showSolution) return const SizedBox();

        if (state.solutionMoves.isEmpty) {
          return _buildAlreadySolvedCard();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(state),
            const SizedBox(height: 12),
            _buildCurrentMove(state),
            const SizedBox(height: 12),
            _buildStepControls(context, state),
            const SizedBox(height: 12),
            _buildAllMoves(context, state),
            const SizedBox(height: 12),
            _buildLegend(),
          ],
        );
      },
    );
  }

  Widget _buildAlreadySolvedCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.15),
            Colors.teal.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 48),
          SizedBox(height: 12),
          Text(
            'المكعب محلول بالفعل! ✓',
            style: TextStyle(
              color: Colors.greenAccent,
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'ممتاز! لا توجد حركات مطلوبة',
            style: TextStyle(
              color: Colors.white54,
              fontFamily: 'Cairo',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(CubeState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A28), Color(0xFF16162A)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.route_rounded, color: Color(0xFF9B8FFF), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الحل وجد!',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${state.solutionMoves.length} حركة مطلوبة',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontFamily: 'Cairo',
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${state.currentStep + 1} / ${state.solutionMoves.length}',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMove(CubeState state) {
    final move = state.solutionMoves[state.currentStep];
    final moveInfo = _getMoveInfo(move);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            moveInfo.color.withOpacity(0.12),
            moveInfo.color.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: moveInfo.color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'الحركة الحالية',
            style: TextStyle(
              color: moveInfo.color.withOpacity(0.7),
              fontFamily: 'Cairo',
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: moveInfo.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: moveInfo.color.withOpacity(0.4), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: moveInfo.color.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    move,
                    style: TextStyle(
                      color: moveInfo.color,
                      fontFamily: 'Cairo',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      moveInfo.arabicName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      moveInfo.description,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontFamily: 'Cairo',
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(moveInfo.icon, color: moveInfo.color, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          moveInfo.direction,
                          style: TextStyle(
                            color: moveInfo.color,
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepControls(BuildContext context, CubeState state) {
    final isFirst = state.currentStep == 0;
    final isLast = state.currentStep == state.solutionMoves.length - 1;

    return Row(
      children: [
        Expanded(
          child: _controlBtn(
            onTap: isFirst ? null : () => state.prevStep(),
            icon: Icons.arrow_forward_ios_rounded,
            label: 'السابق',
            enabled: !isFirst,
          ),
        ),
        const SizedBox(width: 12),
        _centerControl(context, state),
        const SizedBox(width: 12),
        Expanded(
          child: _controlBtn(
            onTap: isLast ? null : () => state.nextStep(),
            icon: Icons.arrow_back_ios_rounded,
            label: 'التالي',
            enabled: !isLast,
            isNext: true,
          ),
        ),
      ],
    );
  }

  Widget _controlBtn({
    required VoidCallback? onTap,
    required IconData icon,
    required String label,
    required bool enabled,
    bool isNext = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF1A1A28)
              : const Color(0xFF14141E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.04),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: isNext
              ? [
                  Text(
                    label,
                    style: TextStyle(
                      color: enabled ? Colors.white : Colors.white24,
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(icon, color: enabled ? Colors.white70 : Colors.white24, size: 16),
                ]
              : [
                  Icon(icon, color: enabled ? Colors.white70 : Colors.white24, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: enabled ? Colors.white : Colors.white24,
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
        ),
      ),
    );
  }

  Widget _centerControl(BuildContext context, CubeState state) {
    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: IconButton(
        onPressed: () => state.goToStep(0),
        icon: const Icon(Icons.first_page_rounded, color: Colors.white54, size: 22),
        tooltip: 'البداية',
      ),
    );
  }

  Widget _buildAllMoves(BuildContext context, CubeState state) {
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
          const Text(
            'جميع الحركات',
            style: TextStyle(
              color: Colors.white54,
              fontFamily: 'Cairo',
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.solutionMoves.asMap().entries.map((e) {
              final idx = e.key;
              final move = e.value;
              final isCurrent = idx == state.currentStep;
              final isPast = idx < state.currentStep;
              final info = _getMoveInfo(move);

              return GestureDetector(
                onTap: () => state.goToStep(idx),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? info.color.withOpacity(0.2)
                        : isPast
                            ? const Color(0xFF1A1A28)
                            : const Color(0xFF14141E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCurrent
                          ? info.color.withOpacity(0.6)
                          : isPast
                              ? Colors.white.withOpacity(0.08)
                              : Colors.white.withOpacity(0.04),
                      width: isCurrent ? 1.5 : 1,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: info.color.withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${idx + 1}.',
                        style: TextStyle(
                          color: isCurrent ? info.color.withOpacity(0.7) : Colors.white24,
                          fontFamily: 'Cairo',
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        move,
                        style: TextStyle(
                          color: isCurrent
                              ? info.color
                              : isPast
                                  ? Colors.white38
                                  : Colors.white70,
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          decoration: isPast ? TextDecoration.lineThrough : null,
                          decorationColor: Colors.white24,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
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
          const Text(
            'دليل الرموز',
            style: TextStyle(
              color: Colors.white54,
              fontFamily: 'Cairo',
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _legendItem('U', 'الوجه العلوي'),
              _legendItem('D', 'الوجه السفلي'),
              _legendItem('R', 'الوجه الأيمن'),
              _legendItem('L', 'الوجه الأيسر'),
              _legendItem('F', 'الوجه الأمامي'),
              _legendItem('B', 'الوجه الخلفي'),
              _legendItem("'", 'عكس عقارب الساعة'),
              _legendItem('2', 'نصف دورة (180°)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String symbol, String desc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              symbol,
              style: const TextStyle(
                color: Color(0xFF9B8FFF),
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            desc,
            style: const TextStyle(
              color: Colors.white54,
              fontFamily: 'Cairo',
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  _MoveInfo _getMoveInfo(String move) {
    final face = move[0];
    final modifier = move.length > 1 ? move[1] : '';

    String arabicName;
    Color color;
    String description;

    switch (face) {
      case 'U':
        arabicName = 'الوجه العلوي';
        color = const Color(0xFFEEEEEE);
        description = 'أدر الطبقة العلوية';
        break;
      case 'D':
        arabicName = 'الوجه السفلي';
        color = const Color(0xFFFFD700);
        description = 'أدر الطبقة السفلية';
        break;
      case 'R':
        arabicName = 'الوجه الأيمن';
        color = const Color(0xFFE53935);
        description = 'أدر العمود الأيمن';
        break;
      case 'L':
        arabicName = 'الوجه الأيسر';
        color = const Color(0xFFFF6F00);
        description = 'أدر العمود الأيسر';
        break;
      case 'F':
        arabicName = 'الوجه الأمامي';
        color = const Color(0xFF1565C0);
        description = 'أدر الوجه الأمامي';
        break;
      case 'B':
        arabicName = 'الوجه الخلفي';
        color = const Color(0xFF2E7D32);
        description = 'أدر الوجه الخلفي';
        break;
      default:
        arabicName = 'حركة';
        color = const Color(0xFF6C63FF);
        description = 'أدر الوجه';
    }

    String direction;
    IconData icon;
    if (modifier == "'") {
      direction = 'عكس عقارب الساعة';
      icon = Icons.rotate_left_rounded;
    } else if (modifier == '2') {
      direction = 'نصف دورة (180°)';
      icon = Icons.sync_rounded;
    } else {
      direction = 'مع عقارب الساعة';
      icon = Icons.rotate_right_rounded;
    }

    return _MoveInfo(
      arabicName: arabicName,
      color: color,
      description: description,
      direction: direction,
      icon: icon,
    );
  }
}

class _MoveInfo {
  final String arabicName;
  final Color color;
  final String description;
  final String direction;
  final IconData icon;

  _MoveInfo({
    required this.arabicName,
    required this.color,
    required this.description,
    required this.direction,
    required this.icon,
  });
}
