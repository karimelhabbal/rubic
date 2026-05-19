import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cube_state.dart';
import '../widgets/cube_face_input.dart';
import '../widgets/color_palette.dart';
import '../widgets/solution_panel.dart';
import '../widgets/cube_net_view.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentFace = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _currentFace = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A0A0F), Color(0xFF12121A), Color(0xFF0D0D18)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildCubeNetSection(),
                        const SizedBox(height: 16),
                        _buildFaceSelector(),
                        const SizedBox(height: 12),
                        _buildFaceInput(),
                        const SizedBox(height: 16),
                        _buildColorPalette(),
                        const SizedBox(height: 16),
                        _buildActionButtons(),
                        const SizedBox(height: 16),
                        _buildSolutionSection(),
                        const SizedBox(height: 24),
                      ],
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

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
              onPressed: () {
                context.read<CubeState>().resetAll();
                _tabController.animateTo(0);
              },
              tooltip: 'إعادة تعيين',
            ),
          ),
          Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
                ).createShader(bounds),
                child: const Text(
                  'حل مكعب روبيك',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              const Text(
                'Rubik\'s Cube Solver',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white38,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: IconButton(
              icon: const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber),
              onPressed: () {
                context.read<CubeState>().fillSolved();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('تم ملء المكعب المحلول كمثال', textDirection: TextDirection.rtl),
                    backgroundColor: const Color(0xFF1A1A28),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              tooltip: 'مثال محلول',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCubeNetSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.08),
            blurRadius: 30,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'معاينة المكعب',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontFamily: 'Cairo',
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          const CubeNetView(scale: 0.85),
        ],
      ),
    );
  }

  Widget _buildFaceSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 44,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
          ),
        ),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        labelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        tabs: List.generate(6, (i) {
          final faceColors = [
            Colors.white,
            Colors.red,
            Colors.blue,
            Colors.yellow,
            Colors.orange,
            Colors.green,
          ];
          return Tab(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: faceColors[i],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 0.5),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(_shortFaceName(i)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  String _shortFaceName(int i) {
    return ['علوي', 'أيمن', 'أمامي', 'سفلي', 'أيسر', 'خلفي'][i];
  }

  Widget _buildFaceInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: CubeFaceInput(
        faceIndex: _currentFace,
        onCellTap: (cell) {
          context.read<CubeState>().setCellColor(_currentFace, cell);
        },
      ),
    );
  }

  Widget _buildColorPalette() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ColorPalette(),
    );
  }

  Widget _buildActionButtons() {
    return Consumer<CubeState>(
      builder: (context, state, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              if (state.errorMessage.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.errorMessage,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontFamily: 'Cairo',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: _buildSolveButton(state),
                  ),
                  const SizedBox(width: 12),
                  _buildResetFaceButton(state),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSolveButton(CubeState state) {
    return GestureDetector(
      onTap: state.isSolving ? null : () => state.solve(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: state.isSolving
              ? const LinearGradient(colors: [Color(0xFF3A3A5C), Color(0xFF3A3A5C)])
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
                ),
          boxShadow: state.isSolving
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: state.isSolving
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white54,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'جاري الحل...',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_fix_high_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'حل المكعب',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildResetFaceButton(CubeState state) {
    return GestureDetector(
      onTap: () {
        context.read<CubeState>().resetFace(_currentFace);
      },
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.07),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: const Icon(Icons.cleaning_services_rounded, color: Colors.white60, size: 22),
      ),
    );
  }

  Widget _buildSolutionSection() {
    return Consumer<CubeState>(
      builder: (context, state, _) {
        if (!state.showSolution) return const SizedBox();
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SolutionPanel(),
        );
      },
    );
  }
}
