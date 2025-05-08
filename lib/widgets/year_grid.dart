import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class YearGrid extends StatelessWidget {
  final List<Map<String, dynamic>> years;
  final Function(String, String) onYearSelected;

  const YearGrid({
    super.key,
    required this.years,
    required this.onYearSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn Năm',
            style: GoogleFonts.aBeeZee(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: years.map((year) {
              return GestureDetector(
                onTap: () {
                  onYearSelected(year['slug'], year['name']);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F54D1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    year['name'],
                    style: GoogleFonts.aBeeZee(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
