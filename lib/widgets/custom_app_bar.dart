import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../screens/menu/notification_screen.dart';

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
          ? Row(
              children: [
                Image.asset(
                  'assets/images/logo_srb.png',
                  height: 30,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
                Text(
                  'SRB MOTOR',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
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
        Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            return Stack(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationScreen()),
                    );
                  },
                  icon: const Icon(Icons.notifications_none_outlined, color: Colors.black87),
                ),
                if (provider.unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${provider.unreadCount > 9 ? '9+' : provider.unreadCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      iconTheme: const IconThemeData(color: Colors.black87),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
