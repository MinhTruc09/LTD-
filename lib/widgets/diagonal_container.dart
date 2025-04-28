import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3F54D1).withOpacity(0.1),
            Colors.black.withOpacity(0.3),
          ],
        ),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF3F54D1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                title,
                style: GoogleFonts.aBeeZee(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          ...items.map((item) => Column(
            children: [
              item,
              if (items.indexOf(item) < items.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    color: Colors.white.withOpacity(0.1),
                    thickness: 2,
                  ),
                ),
            ],
          )),
        ],
      ),
    );
  }
}