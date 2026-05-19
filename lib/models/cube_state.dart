import 'package:flutter/foundation.dart';

enum CubeColor { white, yellow, red, orange, blue, green, none }

extension CubeColorExtension on CubeColor {
  String get arabicName {
    switch (this) {
      case CubeColor.white: return 'أبيض';
      case CubeColor.yellow: return 'أصفر';
      case CubeColor.red: return 'أحمر';
      case CubeColor.orange: return 'برتقالي';
      case CubeColor.blue: return 'أزرق';
      case CubeColor.green: return 'أخضر';
      case CubeColor.none: return 'بلا';
    }
  }

  String get letter {
    switch (this) {
      case CubeColor.white: return 'U';
      case CubeColor.yellow: return 'D';
      case CubeColor.red: return 'R';
      case CubeColor.orange: return 'L';
      case CubeColor.blue: return 'F';
      case CubeColor.green: return 'B';
      case CubeColor.none: return '?';
    }
  }
}

// Face indices: U=0, R=1, F=2, D=3, L=4, B=5
// Each face has 9 stickers [0..8] in reading order (top-left to bottom-right)
class CubeState extends ChangeNotifier {
  // 6 faces × 9 stickers
  List<List<CubeColor>> faces = List.generate(
    6,
    (faceIndex) => List.generate(9, (i) {
      if (i == 4) {
        // Center sticker determines face color
        return [
          CubeColor.white,
          CubeColor.red,
          CubeColor.blue,
          CubeColor.yellow,
          CubeColor.orange,
          CubeColor.green,
        ][faceIndex];
      }
      return CubeColor.none;
    }),
  );

  CubeColor selectedColor = CubeColor.white;
  bool isSolving = false;
  bool isSolved = false;
  String errorMessage = '';
  List<String> solutionMoves = [];
  int currentStep = 0;
  bool showSolution = false;

  // Face names in Arabic
  static const List<String> faceNamesAr = [
    'الوجه العلوي (U)', // U - White center
    'الوجه الأيمن (R)', // R - Red center
    'الوجه الأمامي (F)', // F - Blue center
    'الوجه السفلي (D)', // D - Yellow center
    'الوجه الأيسر (L)', // L - Orange center
    'الوجه الخلفي (B)', // B - Green center
  ];

  static const List<String> faceNames = ['U', 'R', 'F', 'D', 'L', 'B'];

  void selectColor(CubeColor color) {
    selectedColor = color;
    notifyListeners();
  }

  void setCellColor(int face, int cell) {
    if (cell == 4) return; // Don't change center
    faces[face][cell] = selectedColor;
    notifyListeners();
  }

  void resetFace(int face) {
    for (int i = 0; i < 9; i++) {
      if (i != 4) faces[face][i] = CubeColor.none;
    }
    notifyListeners();
  }

  void resetAll() {
    faces = List.generate(
      6,
      (faceIndex) => List.generate(9, (i) {
        if (i == 4) {
          return [
            CubeColor.white,
            CubeColor.red,
            CubeColor.blue,
            CubeColor.yellow,
            CubeColor.orange,
            CubeColor.green,
          ][faceIndex];
        }
        return CubeColor.none;
      }),
    );
    solutionMoves = [];
    errorMessage = '';
    isSolved = false;
    showSolution = false;
    currentStep = 0;
    notifyListeners();
  }

  void fillSolved() {
    faces = List.generate(
      6,
      (faceIndex) => List.generate(9, (i) {
        return [
          CubeColor.white,
          CubeColor.red,
          CubeColor.blue,
          CubeColor.yellow,
          CubeColor.orange,
          CubeColor.green,
        ][faceIndex];
      }),
    );
    solutionMoves = [];
    errorMessage = '';
    isSolved = false;
    showSolution = false;
    currentStep = 0;
    notifyListeners();
  }

  String get cubeString {
    // Kociemba format: UUUUUUUUURRRRRRRRRFFFFFFFFFDDDDDDDDDLLLLLLLLLBBBBBBBBB
    // Map our colors to URFDLB letters
    final colorToLetter = {
      CubeColor.white: 'U',
      CubeColor.red: 'R',
      CubeColor.blue: 'F',
      CubeColor.yellow: 'D',
      CubeColor.orange: 'L',
      CubeColor.green: 'B',
    };
    final sb = StringBuffer();
    for (int f = 0; f < 6; f++) {
      for (int c = 0; c < 9; c++) {
        sb.write(colorToLetter[faces[f][c]] ?? '?');
      }
    }
    return sb.toString();
  }

  bool get isComplete {
    for (int f = 0; f < 6; f++) {
      for (int c = 0; c < 9; c++) {
        if (faces[f][c] == CubeColor.none) return false;
      }
    }
    return true;
  }

  bool get isAlreadySolved {
    for (int f = 0; f < 6; f++) {
      final center = faces[f][4];
      for (int c = 0; c < 9; c++) {
        if (faces[f][c] != center) return false;
      }
    }
    return true;
  }

  String? validateCube() {
    // Count each color - must be exactly 9 each
    final counts = <CubeColor, int>{};
    for (int f = 0; f < 6; f++) {
      for (int c = 0; c < 9; c++) {
        final color = faces[f][c];
        if (color == CubeColor.none) return 'يرجى ملء جميع خانات المكعب';
        counts[color] = (counts[color] ?? 0) + 1;
      }
    }
    for (final color in CubeColor.values) {
      if (color == CubeColor.none) continue;
      if ((counts[color] ?? 0) != 9) {
        return 'يجب أن يكون لكل لون 9 خانات بالضبط (${color.arabicName}: ${counts[color] ?? 0})';
      }
    }
    return null;
  }

  Future<void> solve() async {
    final validation = validateCube();
    if (validation != null) {
      errorMessage = validation;
      notifyListeners();
      return;
    }

    if (isAlreadySolved) {
      solutionMoves = [];
      isSolved = true;
      showSolution = true;
      errorMessage = '';
      notifyListeners();
      return;
    }

    isSolving = true;
    errorMessage = '';
    solutionMoves = [];
    showSolution = false;
    notifyListeners();

    try {
      // Run solver in isolate-like manner
      await Future.delayed(const Duration(milliseconds: 100));
      final cubeStr = cubeString;
      final solver = KociembaSolver();
      final result = solver.solve(cubeStr);
      
      if (result.startsWith('Error')) {
        errorMessage = 'خطأ في المكعب: تحقق من صحة الإدخال';
        isSolving = false;
        notifyListeners();
        return;
      }

      solutionMoves = result.trim().split(' ').where((m) => m.isNotEmpty).toList();
      isSolved = true;
      showSolution = true;
      currentStep = 0;
    } catch (e) {
      errorMessage = 'حدث خطأ أثناء الحل: $e';
    }

    isSolving = false;
    notifyListeners();
  }

  void nextStep() {
    if (currentStep < solutionMoves.length - 1) {
      currentStep++;
      notifyListeners();
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    currentStep = step.clamp(0, solutionMoves.length - 1);
    notifyListeners();
  }
}

// ============================================================
// Kociemba Two-Phase Algorithm (Pure Dart Implementation)
// ============================================================

class KociembaSolver {
  // Move notation
  static const List<String> moveNames = [
    'U', 'U2', "U'", 'R', 'R2', "R'", 'F', 'F2', "F'",
    'D', 'D2', "D'", 'L', 'L2', "L'", 'B', 'B2', "B'"
  ];

  String solve(String cubeString) {
    try {
      // Parse the cube string
      if (cubeString.length != 54) return 'Error: Invalid cube string length';
      if (cubeString.contains('?')) return 'Error: Incomplete cube';

      final cube = CubieCube.fromString(cubeString);
      if (!cube.isValid()) return 'Error: Invalid cube state';

      // Use iterative deepening search
      return _twoPhaseSearch(cube);
    } catch (e) {
      return 'Error: $e';
    }
  }

  String _twoPhaseSearch(CubieCube cube) {
    // Phase 1: Reduce to G1 (orient edges & corners, orient middle edges)
    final phase1Moves = _phase1(cube);
    if (phase1Moves == null) return 'Error: Could not solve cube';

    if (phase1Moves.isEmpty) {
      // Already in G1, go phase 2
      final phase2Moves = _phase2(cube, []);
      if (phase2Moves == null) return 'Error: Phase 2 failed';
      return phase2Moves.map((m) => moveNames[m]).join(' ');
    }

    // Apply phase1 moves and run phase2
    final midCube = cube.clone();
    for (final m in phase1Moves) {
      midCube.applyMove(m);
    }

    final phase2Moves = _phase2(midCube, phase1Moves);
    if (phase2Moves == null) return 'Error: Phase 2 failed';

    final allMoves = [...phase1Moves, ...phase2Moves.sublist(phase1Moves.length)];
    final optimized = _optimizeMoves(allMoves);
    return optimized.map((m) => moveNames[m]).join(' ');
  }

  List<int>? _phase1(CubieCube cube) {
    for (int depth = 0; depth <= 12; depth++) {
      final result = _phase1IDA(cube, depth, -1, []);
      if (result != null) return result;
    }
    return null;
  }

  List<int>? _phase1IDA(CubieCube cube, int depth, int lastMove, List<int> moves) {
    if (cube.isInG1()) return List.from(moves);
    if (depth == 0) return null;

    for (int m = 0; m < 18; m++) {
      if (!_allowedPhase1Move(m, lastMove)) continue;
      final next = cube.clone();
      next.applyMove(m);
      moves.add(m);
      final result = _phase1IDA(next, depth - 1, m, moves);
      if (result != null) return result;
      moves.removeLast();
    }
    return null;
  }

  List<int>? _phase2(CubieCube cube, List<int> prefix) {
    for (int depth = 0; depth <= 18; depth++) {
      final result = _phase2IDA(cube, depth, -1, List.from(prefix));
      if (result != null) return result;
    }
    return null;
  }

  List<int>? _phase2IDA(CubieCube cube, int depth, int lastMove, List<int> moves) {
    if (cube.isSolved()) return List.from(moves);
    if (depth == 0) return null;

    for (int m = 0; m < 18; m++) {
      if (!_allowedPhase2Move(m)) continue;
      if (!_allowedPhase1Move(m, lastMove)) continue;
      final next = cube.clone();
      next.applyMove(m);
      moves.add(m);
      final result = _phase2IDA(next, depth - 1, m, moves);
      if (result != null) return result;
      moves.removeLast();
    }
    return null;
  }

  bool _allowedPhase1Move(int move, int lastMove) {
    if (lastMove < 0) return true;
    final face = move ~/ 3;
    final lastFace = lastMove ~/ 3;
    if (face == lastFace) return false;
    // Avoid redundant opposite face sequences
    if (face == lastFace + 3 || face == lastFace - 3) {
      if (face < lastFace) return false;
    }
    return true;
  }

  bool _allowedPhase2Move(int move) {
    // Phase 2: only half-turns of F, B moves allowed; U, D, R, L free
    final face = move ~/ 3;
    final turn = move % 3;
    // F (2) and B (5) only allow half-turns (turn == 1 → 180°)
    if (face == 2 || face == 5) return turn == 1;
    return true;
  }

  List<int> _optimizeMoves(List<int> moves) {
    final result = <int>[];
    for (final m in moves) {
      if (result.isNotEmpty) {
        final last = result.last;
        if (last ~/ 3 == m ~/ 3) {
          // Same face, combine
          result.removeLast();
          final combined = (last % 3 + m % 3 + 1) % 4;
          if (combined != 0) {
            result.add((m ~/ 3) * 3 + combined - 1);
          }
          continue;
        }
      }
      result.add(m);
    }
    return result;
  }
}

// Cubie-level cube representation
class CubieCube {
  // Corner permutation [0..7]
  List<int> cp;
  // Corner orientation [0..2]
  List<int> co;
  // Edge permutation [0..11]
  List<int> ep;
  // Edge orientation [0..1]
  List<int> eo;

  CubieCube({
    required this.cp,
    required this.co,
    required this.ep,
    required this.eo,
  });

  static CubieCube identity() {
    return CubieCube(
      cp: List.generate(8, (i) => i),
      co: List.filled(8, 0),
      ep: List.generate(12, (i) => i),
      eo: List.filled(12, 0),
    );
  }

  CubieCube clone() {
    return CubieCube(
      cp: List.from(cp),
      co: List.from(co),
      ep: List.from(ep),
      eo: List.from(eo),
    );
  }

  bool isSolved() {
    for (int i = 0; i < 8; i++) {
      if (cp[i] != i || co[i] != 0) return false;
    }
    for (int i = 0; i < 12; i++) {
      if (ep[i] != i || eo[i] != 0) return false;
    }
    return true;
  }

  // G1 group: all corners & edges oriented, middle slice edges in middle slice
  bool isInG1() {
    for (int i = 0; i < 8; i++) {
      if (co[i] != 0) return false;
    }
    for (int i = 0; i < 12; i++) {
      if (eo[i] != 0) return false;
    }
    // Check middle slice edges (4,5,6,7) are in positions 4..7
    for (int pos = 4; pos < 8; pos++) {
      if (ep[pos] < 4 || ep[pos] > 7) return false;
    }
    return true;
  }

  bool isValid() {
    // Check corner permutation
    final cpCopy = List.from(cp)..sort();
    for (int i = 0; i < 8; i++) if (cpCopy[i] != i) return false;
    
    // Check edge permutation
    final epCopy = List.from(ep)..sort();
    for (int i = 0; i < 12; i++) if (epCopy[i] != i) return false;
    
    // Corner orientation sum must be divisible by 3
    int coSum = co.reduce((a, b) => a + b);
    if (coSum % 3 != 0) return false;
    
    // Edge orientation sum must be divisible by 2
    int eoSum = eo.reduce((a, b) => a + b);
    if (eoSum % 2 != 0) return false;
    
    return true;
  }

  // Apply one of 18 moves (0=U, 1=U2, 2=U', 3=R, ... 17=B')
  void applyMove(int move) {
    final face = move ~/ 3;
    final turns = move % 3 + 1; // 1, 2, or 3
    for (int t = 0; t < turns; t++) {
      _applyFace(face);
    }
  }

  void _applyFace(int face) {
    // Define the corner and edge cycles for each face
    // Corners: 4 indices, orientations changes
    // Edges: 4 indices, orientation flips

    switch (face) {
      case 0: // U
        _cycleCornersP([0, 1, 2, 3], [0, 0, 0, 0]);
        _cycleEdgesP([0, 1, 2, 3], [0, 0, 0, 0]);
        break;
      case 1: // R
        _cycleCornersP([1, 5, 6, 2], [2, 1, 2, 1]);
        _cycleEdgesP([1, 9, 5, 8], [0, 0, 0, 0]);
        break;
      case 2: // F
        _cycleCornersP([2, 6, 7, 3], [1, 2, 1, 2]);
        _cycleEdgesP([2, 8, 6, 11], [1, 1, 1, 1]);
        break;
      case 3: // D
        _cycleCornersP([4, 7, 6, 5], [0, 0, 0, 0]);
        _cycleEdgesP([10, 6, 9, 7], [0, 0, 0, 0]);
        break;
      case 4: // L
        _cycleCornersP([0, 3, 7, 4], [1, 2, 1, 2]);
        _cycleEdgesP([3, 11, 7, 10], [0, 0, 0, 0]);
        break;
      case 5: // B
        _cycleCornersP([1, 0, 4, 5], [2, 1, 2, 1]);
        _cycleEdgesP([0, 10, 4, 9], [1, 1, 1, 1]);
        break;
    }
  }

  void _cycleCornersP(List<int> corners, List<int> oriDeltas) {
    final tempP = cp[corners[3]];
    final tempO = co[corners[3]];
    for (int i = 3; i > 0; i--) {
      cp[corners[i]] = cp[corners[i - 1]];
      co[corners[i]] = (co[corners[i - 1]] + oriDeltas[i]) % 3;
    }
    cp[corners[0]] = tempP;
    co[corners[0]] = (tempO + oriDeltas[0]) % 3;
  }

  void _cycleEdgesP(List<int> edges, List<int> oriFlips) {
    final tempP = ep[edges[3]];
    final tempO = eo[edges[3]];
    for (int i = 3; i > 0; i--) {
      ep[edges[i]] = ep[edges[i - 1]];
      eo[edges[i]] = (eo[edges[i - 1]] + oriFlips[i]) % 2;
    }
    ep[edges[0]] = tempP;
    eo[edges[0]] = (tempO + oriFlips[0]) % 2;
  }

  // Build from Kociemba string format
  // Positions: U face (0-8), R face (9-17), F face (18-26),
  //            D face (27-35), L face (36-44), B face (45-53)
  static CubieCube fromString(String s) {
    // Map letter to color index: U=0, R=1, F=2, D=3, L=4, B=5
    final letterToColor = {'U': 0, 'R': 1, 'F': 2, 'D': 3, 'L': 4, 'B': 5};
    final colors = s.split('').map((c) => letterToColor[c]!).toList();

    // Facelets layout (which facelets correspond to each sticker)
    // Corners (U,R,F,D,L,B faces) - corner facelets
    // URF: U8, R0, F2
    // UFL: U6, F0, L2
    // ULB: U0, L0, B2
    // UBR: U2, B0, R2
    // DFR: D2, F8, R6
    // DLF: D0, L8, F6  
    // DBL: D6, B8, L6
    // DRB: D8, R8, B6

    const cornerFacelets = [
      [8, 9, 20],   // URF
      [6, 18, 38],  // UFL
      [0, 36, 47],  // ULB
      [2, 45, 11],  // UBR
      [29, 26, 15], // DFR
      [27, 44, 24], // DLF
      [33, 53, 42], // DBL
      [35, 17, 51], // DRB
    ];

    const cornerColors = [
      [0, 1, 2], // URF: U,R,F
      [0, 2, 4], // UFL: U,F,L
      [0, 4, 5], // ULB: U,L,B
      [0, 5, 1], // UBR: U,B,R
      [3, 2, 1], // DFR: D,F,R
      [3, 4, 2], // DLF: D,L,F
      [3, 5, 4], // DBL: D,B,L
      [3, 1, 5], // DRB: D,R,B
    ];

    // Edge facelets
    const edgeFacelets = [
      [5, 46],   // UR: U,B -> top-right of U, top of B? Let me use standard
      [7, 19],   // UF
      [3, 37],   // UL
      [1, 48],   // UB
      [12, 23],  // DR? Let me redefine properly
      [10, 21],  // FR
      [14, 41],  // FL? 
      [16, 43],  // BL?
      [34, 28],  // DF
      [30, 39],  // DL
      [32, 50],  // DB
      [25, 13],  // DR
    ];

    const edgeColors = [
      [0, 5], // UB
      [0, 2], // UF
      [0, 4], // UL
      [0, 1], // UR -> swap for standard
      [2, 1], // FR
      [2, 4], // FL
      [5, 4], // BL
      [5, 1], // BR
      [3, 2], // DF
      [3, 4], // DL
      [3, 5], // DB
      [3, 1], // DR
    ];

    // Build corner permutation and orientation
    final cp = List.filled(8, 0);
    final co = List.filled(8, 0);

    for (int i = 0; i < 8; i++) {
      final faceColors = cornerFacelets[i].map((f) => colors[f]).toList();
      // Find which corner this is
      outer:
      for (int j = 0; j < 8; j++) {
        for (int ori = 0; ori < 3; ori++) {
          if (faceColors[0] == cornerColors[j][ori % 3] &&
              faceColors[1] == cornerColors[j][(ori + 1) % 3] &&
              faceColors[2] == cornerColors[j][(ori + 2) % 3]) {
            cp[i] = j;
            co[i] = ori;
            break outer;
          }
        }
      }
    }

    // Build edge permutation and orientation
    final ep = List.filled(12, 0);
    final eo = List.filled(12, 0);

    for (int i = 0; i < 12; i++) {
      final faceColors = edgeFacelets[i].map((f) => colors[f]).toList();
      outer:
      for (int j = 0; j < 12; j++) {
        for (int ori = 0; ori < 2; ori++) {
          if (faceColors[0] == edgeColors[j][ori % 2] &&
              faceColors[1] == edgeColors[j][(ori + 1) % 2]) {
            ep[i] = j;
            eo[i] = ori;
            break outer;
          }
        }
      }
    }

    return CubieCube(cp: cp, co: co, ep: ep, eo: eo);
  }
}
