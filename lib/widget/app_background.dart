import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [

          Container(
            height: MediaQuery.of(context).size.height * 0.85,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2D3A8C),
                  Color(0xFF4F8CFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // lower color section
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            ),
          ),

          Align(
            alignment: Alignment.center,
            child: ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // 🔐 CONTENT
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, size.height - 40);

    path.quadraticBezierTo(
      size.width / 2,
      size.height + 40,
      size.width,
      size.height - 40,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}