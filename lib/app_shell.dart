import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_state.dart';
import 'app_theme.dart';
import 'pages/account_page.dart';
import 'pages/inventory_page.dart';
import 'pages/recipes_page.dart';
import 'platform.dart';

class AppTab {
  final String label;
  final IconData icon;
  final Color accent;
  final List<Color> lightBg;
  final List<Color> darkBg;
  final bool bottom;
  final String? imageAsset;

  const AppTab({
    required this.label,
    required this.icon,
    required this.accent,
    required this.lightBg,
    required this.darkBg,
    this.bottom = false,
    this.imageAsset,
  });
}

const appTabs = [
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
    bottom: true,
  ),
];

class AppShell extends StatefulWidget {
  final AppState state;
  const AppShell({super.key, required this.state});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selected = 0;
  bool _collapsed = false;

  Widget _pageFor(int index) => switch (index) {
        0 => InventoryPage(state: widget.state),
        1 => RecipesPage(state: widget.state),
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
                  onToggleSidebar: () => setState(() => _collapsed = !_collapsed),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Sidebar(
                        accent: tab.accent,
                        tabs: appTabs,
                        selected: _selected,
                        collapsed: _collapsed,
                        darkMode: dark,
                        onToggleDarkMode: widget.state.toggleDarkMode,
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
  final VoidCallback onToggleSidebar;
  const AppBanner({super.key, required this.color, required this.onToggleSidebar});

  @override
  Widget build(BuildContext context) {
    final title = Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text(
          'Food Buddy',
          style: TextStyle(
            color: AppColors.bannerText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 64,
      color: color,
      padding: EdgeInsets.only(left: isMac ? 76 : 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Toggle sidebar',
            icon: SvgPicture.asset(
              'assets/icons/menu.svg',
              width: 45,
              height: 45,
            ),
            onPressed: onToggleSidebar,
            padding: const EdgeInsets.all(4)
          ),
          const SizedBox(width: 4),
          Expanded(
            child: isDesktop
                ? DragToMoveArea(
                    child: SizedBox.expand(
                      child: Align(alignment: Alignment.centerLeft, child: title),
                    ),
                  )
                : Align(alignment: Alignment.centerLeft, child: title),
          ),
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

class Sidebar extends StatelessWidget {
  final Color accent;
  final List<AppTab> tabs;
  final int selected;
  final bool collapsed;
  final bool darkMode;
  final VoidCallback onToggleDarkMode;
  final ValueChanged<int> onSelect;

  const Sidebar({
    super.key,
    required this.accent,
    required this.tabs,
    required this.selected,
    required this.collapsed,
    required this.darkMode,
    required this.onToggleDarkMode,
    required this.onSelect,
  });

  Widget _item(int i) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: _maybeTooltip(
          tabs[i].label,
          _SidebarItem(
            tab: tabs[i],
            selected: i == selected,
            onTap: () => onSelect(i),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: collapsed ? 68 : 216,
      color: AppColors.sidebarFor(accent, darkMode),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tabs.length; i++)
            if (!tabs[i].bottom) _item(i),
          const Spacer(),
          for (var i = 0; i < tabs.length; i++)
            if (tabs[i].bottom) _item(i),
          _maybeTooltip(
            darkMode ? 'Switch to light mode' : 'Switch to dark mode',
            _ThemeToggle(darkMode: darkMode, onToggle: onToggleDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _maybeTooltip(String label, Widget child) =>
      collapsed ? Tooltip(message: label, child: child) : child;
}

class _SidebarItem extends StatelessWidget {
  final AppTab tab;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({required this.tab, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppShades.of(context).ink;

    return Material(
      color: selected ? tab.accent : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: LayoutBuilder(
            builder: (context, c) => Row(
              children: [
                SizedBox(width: 38, child: Icon(tab.icon, color: fg, size: 22)),
                if (c.maxWidth > 120)
                  Expanded(
                    child: Text(
                      tab.label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        color: fg,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final bool darkMode;
  final VoidCallback onToggle;

  const _ThemeToggle({required this.darkMode, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final fg = AppShades.of(context).ink;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onToggle,
        child: SizedBox(
          height: 44,
          child: LayoutBuilder(
            builder: (context, c) => Row(
              children: [
                SizedBox(
                  width: 38,
                  child: Icon(
                    darkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                    color: fg,
                    size: 22,
                  ),
                ),
                if (c.maxWidth > 150) ...[
                  Expanded(
                    child: Text(
                      'Dark mode',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: TextStyle(color: fg, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Switch(value: darkMode, onChanged: (_) => onToggle()),
                ],
              ],
            ),
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