import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'Home.dart';
import 'profile_page.dart';
import 'tools_page.dart';
import '../features/playground/code_playground_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const CodePlaygroundPage(),
    const ToolsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      // نستخدم Stack باش نخليو الـ BottomNav ديما الفوق ويكون عائم (Floating)
      body: Stack(
        children: [
          // IndexedStack يحافظ على الـ state متاع الصفحات باش ميتعاودش تحميلهم كل مرة
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          
          // الـ Floating Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 24, // يبعد شوية على القاع باش يعطي شكل الـ Floating
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // تأثير الزجاج
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark.withOpacity(0.8), // لون شبه شفاف
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1), // بوردر خفيف
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(0, Icons.home_rounded, 'Home'),
                      _buildNavItem(1, Icons.terminal_rounded, 'Code'),
                      _buildNavItem(2, Icons.grid_view_rounded, 'Tools'),
                      _buildNavItem(3, Icons.person_rounded, 'Profile'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint, // حركة smooth
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primary : AppTheme.textMutedDark,
              size: 24,
            ),
            // نطلعو الـ Text كان كي يبدا العنصر selected
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
