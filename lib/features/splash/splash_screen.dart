import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../home/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const route = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack)
        .drive(Tween(begin: 0.7, end: 1.0));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));
    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      Navigator.pushReplacementNamed(
        context,
        auth.isLoggedIn ? MainScreen.route : LoginScreen.route,
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),

            // ── Logo animé ────────────────────────────────────────────────
            ScaleTransition(
              scale: _scale,
              child: FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    _AppLogo(size: 130),
                    const SizedBox(height: 28),
                    const Text(
                      'Mobiliti',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Partagez la route, allégez la ville',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 3),

            // ── Boutons ───────────────────────────────────────────────────
            FadeTransition(
              opacity: _fade,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                            context, LoginScreen.route),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Commencer',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, LoginScreen.route),
                      child: const Text(
                        "J'ai déjà un compte",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Logo feuille + route ──────────────────────────────────────────────────────
class _AppLogo extends StatelessWidget {
  const _AppLogo({this.size = 100});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LeafLogoPainter()),
    );
  }
}

class _LeafLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Feuille sombre
    final leafDark = Paint()
      ..color = const Color(0xFF1B5E38)
      ..style = PaintingStyle.fill;

    final pathDark = Path()
      ..moveTo(w * 0.25, h * 0.85)
      ..quadraticBezierTo(w * 0.0, h * 0.4, w * 0.35, h * 0.08)
      ..quadraticBezierTo(w * 0.5, h * 0.0, w * 0.65, h * 0.12)
      ..quadraticBezierTo(w * 0.55, h * 0.5, w * 0.25, h * 0.85)
      ..close();
    canvas.drawPath(pathDark, leafDark);

    // Feuille claire
    final leafLight = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final pathLight = Path()
      ..moveTo(w * 0.5, h * 0.85)
      ..quadraticBezierTo(w * 0.85, h * 0.55, w * 0.75, h * 0.12)
      ..quadraticBezierTo(w * 0.65, h * 0.0, w * 0.55, h * 0.08)
      ..quadraticBezierTo(w * 0.7, h * 0.5, w * 0.5, h * 0.85)
      ..close();
    canvas.drawPath(pathLight, leafLight);

    // Route en pointillés
    final roadPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;

    const dashLen = 10.0;
    const gapLen = 8.0;
    final routePath = Path()
      ..moveTo(w * 0.42, h * 0.82)
      ..quadraticBezierTo(w * 0.45, h * 0.4, w * 0.55, h * 0.15);

    _drawDashedPath(canvas, routePath, roadPaint, dashLen, gapLen);
  }

  void _drawDashedPath(
      Canvas canvas, Path path, Paint paint, double dashLen, double gapLen) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double dist = 0;
      while (dist < metric.length) {
        final end = (dist + dashLen).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, end), paint);
        dist += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
