import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final bool showLogo;
  final String? title;

  const CustomAppBar({
    super.key,
    this.actions,
    this.showLogo = true,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: showLogo ? false : true,
      title: showLogo
          ? Image.asset(
              'assets/images/logo_srb.png',
              height: 35,
              errorBuilder: (context, error, stackTrace) => Text(
                'SRB MOTOR',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2563EB),
                  letterSpacing: 1.2,
                ),
              ),
            )
          : (title != null
              ? Text(
                  title!,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                )
              : null),
      actions: actions ?? [
        Stack(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_outlined, color: Colors.black87),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
              ),
            )
          ],
        ),
        const SizedBox(width: 8),
      ],
      iconTheme: const IconThemeData(color: Colors.black87),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
