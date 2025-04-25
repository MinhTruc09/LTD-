import 'package:flutter/material.dart';
import 'package:diagonal_decoration/diagonal_decoration.dart';
import 'package:movieom_app/widgets/item_tile.dart';

class DiagonalContainer extends StatelessWidget {
  final String title;
  final List<ItemTile> items;

  const DiagonalContainer({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 36),
      padding: const EdgeInsets.all(25),
      decoration: const DiagonalDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
            const SizedBox(height: 20),
          ],
          ...items.map((item) => Column(
            children: [
              item,
              if (items.indexOf(item) < items.length - 1)
                const SizedBox(height: 20),
            ],
          )),
        ],
      ),
    );
  }
}