import 'package:flutter/material.dart';

class DockingBar extends StatefulWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;

  const DockingBar({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  State<DockingBar> createState() => _DockingBarState();
}

class _DockingBarState extends State<DockingBar> {
  List<IconData> icons = [
    Icons.home,
    Icons.search,
    Icons.favorite,
    Icons.person,
  ];

  Tween<double> tween = Tween<double>(begin: 2.0, end: 2.4);
  bool animationCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TweenAnimationBuilder(
        key: ValueKey(widget.activeIndex),
        tween: tween,
        duration: Duration(milliseconds: animationCompleted ? 2000 : 200),
        curve: animationCompleted ? Curves.elasticOut : Curves.easeOut,
        onEnd: () {
          setState(() {
            animationCompleted = true;
            tween = Tween(begin: 1.5, end: 1.0);
          });
        },
        builder: (context, value, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(icons.length, (i) {
              return Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.identity()
                  ..scale(i == widget.activeIndex ? value : 1.0)
                  ..translate(
                      0.0, i == widget.activeIndex ? 80.0 * (1 - value) : 0.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      animationCompleted = false;
                      tween = Tween(begin: 1.0, end: 1.2);
                    });
                    widget.onTap(i); // Gọi callback để thay đổi trang
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(i == widget.activeIndex ? 0.3 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icons[i],
                      size: 30,
                      color: i == widget.activeIndex ? Color(0xFF3F54D1) : Colors.white,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}