import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class QuranHeader extends StatelessWidget implements PreferredSizeWidget {
  const QuranHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF8FAF9),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xFF111827),
          size: 20,
        ),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
      ),
      title: Text(
        'Quran',
        style: GoogleFonts.inter(
          color: const Color(0xFF111827),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF111827),
            size: 24,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
