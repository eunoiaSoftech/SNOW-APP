import 'package:flutter/material.dart';

class CurvedBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CurvedBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<IconData> icons = [
      Icons.home,
      Icons.access_time,
      Icons.grid_view,
      Icons.person,
    ];

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Curved Background
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 80),
          painter: _NavPainter(),
        ),

        // Floating Center Icon
        Positioned(
          bottom: 30,
          left: (MediaQuery.of(context).size.width / icons.length) *
                  selectedIndex +
              8,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: CircleAvatar(
              backgroundColor: Colors.lightGreenAccent,
              radius: 26,
              child: Icon(
                icons[selectedIndex],
                color: Colors.black,
              ),
            ),
          ),
        ),

        // Icons Row
        Positioned(
          bottom: 0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(icons.length, (index) {
                return IconButton(
                  icon: Icon(
                    icons[index],
                    color: index == selectedIndex
                        ? Colors.transparent
                        : Colors.white,
                  ),
                  onPressed: () => onItemTapped(index),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final path = Path()
      ..moveTo(0, 20)
      ..quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0)
      ..arcToPoint(
        Offset(size.width * 0.65, 0),
        radius: const Radius.circular(20),
        clockwise: false,
      )
      ..quadraticBezierTo(size.width * 0.80, 0, size.width, 20)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawShadow(path, Colors.black, 4, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
