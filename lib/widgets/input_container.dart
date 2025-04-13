import 'package:flutter/material.dart';

class InputContainer extends StatelessWidget {
  final Widget child;

  const InputContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.white,
              blurRadius: 15,
              offset: Offset(5, 5),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}