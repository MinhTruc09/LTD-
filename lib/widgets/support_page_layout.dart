import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportPageLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showBackButton;
  final List<Widget>? actions;

  const SupportPageLayout({
    Key? key,
    required this.title,
    required this.child,
    this.showBackButton = true,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          title,
          style: GoogleFonts.aBeeZee(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: showBackButton 
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: actions,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}

// Common styled section title
class SectionTitle extends StatelessWidget {
  final String text;
  
  const SectionTitle(this.text, {Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
      child: Text(
        text,
        style: GoogleFonts.aBeeZee(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF3F54D1),
        ),
      ),
    );
  }
}

// Common styled paragraph
class Paragraph extends StatelessWidget {
  final String text;
  
  const Paragraph(this.text, {Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: GoogleFonts.aBeeZee(
          fontSize: 16,
          color: Colors.white,
          height: 1.5,
        ),
      ),
    );
  }
}

// Developer card for About page
class DeveloperCard extends StatelessWidget {
  final String name;
  final String studentId;
  final String role;
  final String? githubUrl;
  final String? imageUrl;
  
  const DeveloperCard({
    Key? key,
    required this.name,
    required this.studentId,
    required this.role,
    this.githubUrl,
    this.imageUrl,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3F54D1).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF3F54D1).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF3F54D1),
                width: 2,
              ),
            ),
            child: imageUrl != null
                ? ClipOval(
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        color: Color(0xFF3F54D1),
                        size: 40,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.person,
                    color: Color(0xFF3F54D1),
                    size: 40,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.aBeeZee(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  studentId,
                  style: GoogleFonts.aBeeZee(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: GoogleFonts.aBeeZee(
                    fontSize: 14,
                    color: const Color(0xFF3F54D1),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (githubUrl != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.link, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          githubUrl!,
                          style: GoogleFonts.aBeeZee(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Contact method card
class ContactMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  
  const ContactMethodCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    this.color = const Color(0xFF3F54D1),
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.aBeeZee(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.aBeeZee(
                    fontSize: 14,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 