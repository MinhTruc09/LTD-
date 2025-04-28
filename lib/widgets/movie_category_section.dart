import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movieom_app/Entity/movie_model.dart';
import 'package:movieom_app/widgets/movie_item.dart';

class MovieCategorySection extends StatelessWidget {
  final String title;
  final List<MovieModel> movies;
  final VoidCallback onViewAll;

  const MovieCategorySection({
    super.key,
    required this.title,
    required this.movies,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.aBeeZee(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'Xem tất cả >',
                  style: GoogleFonts.aBeeZee(
                    color: const Color(0xFF3F54D1),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 190,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return MovieItem(
                movie: movies[index],
                width: 120,
              );
            },
          ),
        ),
      ],
    );
  }
}
