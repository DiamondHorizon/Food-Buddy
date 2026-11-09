import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app_state.dart';
import 'app_theme.dart';
import 'burger_sidebar.dart';
import 'pages/preferences.dart';
import 'pages/home_page.dart';
import 'pages/inventory_page.dart';
import 'pages/recipes_page.dart';
import 'platform.dart';

class AppTab {
  final String label;
  final IconData icon;
  final Color accent;
  final List<Color> lightBg;
  final List<Color> darkBg;
  final String? imageAsset;

  const AppTab({
    required this.label,
    required this.icon,
    required this.accent,
    required this.lightBg,
    required this.darkBg,
    this.imageAsset,
  });
}

const appTabs = [
  AppTab(
    label: 'Home',
    icon: Icons.home_outlined,
    accent: AppColors.homeAccent,
    lightBg: AppColors.homeBg,
    darkBg: AppColors.homeBgDark,
  ),
  AppTab(
    label: 'Inventory',
    icon: Icons.kitchen_outlined,
    accent: AppColors.inventoryAccent,
    lightBg: AppColors.inventoryBg,
    darkBg: AppColors.inventoryBgDark,
  ),
  AppTab(
    label: 'Recipes',
    icon: Icons.menu_book_outlined,
    accent: AppColors.recipesAccent,
    lightBg: AppColors.recipesBg,
    darkBg: AppColors.recipesBgDark,
  ),
  AppTab(
    label: 'Account',
    icon: Icons.person_outline,
    accent: AppColors.accountAccent,
    lightBg: AppColors.accountBg,
    darkBg: AppColors.accountBgDark,
  ),
];

const _accountIndex = 3;

class AppShell extends StatefulWidget {
  final AppState state;
  const AppShell({super.key, required this.state});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selected = 0;

  Widget _pageFor(int index) => switch (index) {
        0 => HomePage(state: widget.state),
        1 => InventoryPage(state: widget.state),
        2 => RecipesPage(state: widget.state),
        _ => const AccountPage(),
      };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final tab = appTabs[_selected];
        final dark = widget.state.darkMode;

        return AnimatedTheme(
          data: buildAppTheme(tab.accent, dark),
          child: Scaffold(
            body: Column(
              children: [
                AppBanner(
                  color: tab.accent,
                  darkMode: dark,
                  accountSelected: _selected == _accountIndex,
                  onToggleDarkMode: widget.state.toggleDarkMode,
                  onAccount: () => setState(() => _selected = _accountIndex),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BurgerSidebar(
                        accent: tab.accent,
                        darkMode: dark,
                        pages: [
                          for (final t in appTabs.take(_accountIndex))
                            BurgerPage(t.label, t.icon),
                        ],
                        selected: _selected,
                        onSelect: (i) => setState(() => _selected = i),
                      ),
                      Expanded(
                        child: TabBackground(
                          tab: tab,
                          dark: dark,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: KeyedSubtree(
                              key: ValueKey(_selected),
                              child: _pageFor(_selected),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AppBanner extends StatelessWidget {
  final Color color;
  final bool darkMode;
  final bool accountSelected;
  final VoidCallback onToggleDarkMode;
  final VoidCallback onAccount;

  const AppBanner({
    super.key,
    required this.color,
    required this.darkMode,
    required this.accountSelected,
    required this.onToggleDarkMode,
    required this.onAccount,
  });

  @override
  Widget build(BuildContext context) {
    const title = Text(
      'Food Buddy',
      style: TextStyle(
        color: AppColors.bannerText,
        fontFamily: 'CaveatBrush',
        fontSize: 26,
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 56,
      color: color,
      padding: EdgeInsets.only(left: isMac ? 76 : 20),
      child: Row(
        children: [
          Expanded(
            child: isDesktop
                ? DragToMoveArea(
                    child: const SizedBox.expand(
                      child: Align(alignment: Alignment.centerLeft, child: title),
                    ),
                  )
                : const Align(alignment: Alignment.centerLeft, child: title),
          ),
          IconButton(
            tooltip: darkMode ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: onToggleDarkMode,
            color: AppColors.bannerText,
            icon: Icon(darkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Account and preferences',
            onPressed: onAccount,
            color: AppColors.bannerText,
            style: IconButton.styleFrom(
              backgroundColor:
                  accountSelected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
            ),
            icon: Icon(accountSelected ? Icons.person : Icons.person_outline),
          ),
          SizedBox(width: showCustomWindowButtons ? 12 : 16),
          if (showCustomWindowButtons) const WindowButtons(),
        ],
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _WindowButton(
          icon: Icons.remove,
          tooltip: 'Minimize',
          onTap: () => windowManager.minimize(),
        ),
        _WindowButton(
          icon: Icons.crop_square,
          tooltip: 'Maximize',
          onTap: () async {
            if (await windowManager.isMaximized()) {
              await windowManager.unmaximize();
            } else {
              await windowManager.maximize();
            }
          },
        ),
        _WindowButton(
          icon: Icons.close,
          tooltip: 'Close',
          hoverColor: AppColors.closeHover,
          onTap: () => windowManager.close(),
        ),
      ],
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? hoverColor;

  const _WindowButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.hoverColor,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final hoverBg = widget.hoverColor ?? Colors.white.withValues(alpha: 0.12);
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 600),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 48,
            height: 56,
            color: _hover ? hoverBg : Colors.transparent,
            child: Icon(widget.icon, size: 18, color: AppColors.bannerText),
          ),
        ),
      ),
    );
  }
}

class TabBackground extends StatelessWidget {
  final AppTab tab;
  final bool dark;
  final Widget child;
  const TabBackground({super.key, required this.tab, required this.dark, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark ? tab.darkBg : tab.lightBg,
        ),
        image: tab.imageAsset == null
            ? null
            : DecorationImage(
                image: AssetImage(tab.imageAsset!),
                fit: BoxFit.cover,
                opacity: 0.18,
              ),
      ),
      child: child,
    );
  }
}
