import 'package:flutter/material.dart';

import 'app_theme.dart';

class BurgerPage {
  final String label;
  final IconData icon;
  const BurgerPage(this.label, this.icon);
}

class _Layer {
  final Color color;
  final double closedHeight;
  final double openHeight;
  final BorderRadius radius;
  final double inset;
  final int? page;
  final Color labelColor;
  final bool sesame;

  const _Layer({
    required this.color,
    required this.closedHeight,
    required this.openHeight,
    required this.radius,
    this.inset = 0,
    this.page,
    this.labelColor = Colors.white,
    this.sesame = false,
  });
}

const _layers = [
  _Layer(
    color: AppColors.bun,
    closedHeight: 14,
    openHeight: 34,
    radius: BorderRadius.vertical(top: Radius.circular(40), bottom: Radius.circular(4)),
    inset: 2,
    sesame: true,
  ),
  _Layer(
    color: AppColors.lettuce,
    closedHeight: 4,
    openHeight: 10,
    radius: BorderRadius.all(Radius.circular(6)),
  ),
  _Layer(
    color: AppColors.cheese,
    closedHeight: 4,
    openHeight: 42,
    radius: BorderRadius.all(Radius.circular(4)),
    inset: 1,
    page: 0,
    labelColor: Color(0xFF1F1A14),
  ),
  _Layer(
    color: AppColors.patty,
    closedHeight: 7,
    openHeight: 42,
    radius: BorderRadius.all(Radius.circular(10)),
    inset: 3,
    page: 1,
  ),
  _Layer(
    color: Color.fromARGB(255, 212, 133, 255),
    closedHeight: 3,
    openHeight: 8,
    radius: BorderRadius.all(Radius.circular(6)),
    inset: 4,
  ),
  _Layer(
    color: AppColors.tomato,
    closedHeight: 4,
    openHeight: 42,
    radius: BorderRadius.all(Radius.circular(8)),
    inset: 2,
    page: 2,
  ),
  _Layer(
    color: AppColors.bun,
    closedHeight: 9,
    openHeight: 22,
    radius: BorderRadius.vertical(top: Radius.circular(4), bottom: Radius.circular(16)),
    inset: 2,
  ),
];

class BurgerSidebar extends StatefulWidget {
  final Color accent;
  final bool darkMode;
  final List<BurgerPage> pages;
  final int selected;
  final ValueChanged<int> onSelect;

  const BurgerSidebar({
    super.key,
    required this.accent,
    required this.darkMode,
    required this.pages,
    required this.selected,
    required this.onSelect,
  });

  @override
  State<BurgerSidebar> createState() => _BurgerSidebarState();
}

class _BurgerSidebarState extends State<BurgerSidebar> {
  bool _hover = false;
  bool _pinned = false;

  bool get _open => _hover || _pinned;

  @override
  Widget build(BuildContext context) {
    final shades = AppShades.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        width: _open ? 220 : 76,
        color: AppColors.sidebarFor(widget.accent, widget.darkMode),
        padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < _layers.length; i++) _buildLayer(i, shades),
          ],
        ),
      ),
    );
  }

  Widget _buildLayer(int i, AppShades shades) {
    final layer = _layers[i];
    final page = layer.page;
    final selected = page != null && page == widget.selected;

    final box = AnimatedContainer(
      duration: Duration(milliseconds: 220 + i * 35),
      curve: Curves.easeOutCubic,
      height: _open ? layer.openHeight : layer.closedHeight,
      margin: EdgeInsets.only(
        top: _open && i > 0 ? 8 : 0,
        left: layer.inset,
        right: layer.inset,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: layer.color,
        borderRadius: layer.radius,
        border: selected && _open ? Border.all(color: shades.ink, width: 2.5) : null,
      ),
      child: layer.sesame
          ? const _Sesame()
          : page == null || page >= widget.pages.length
              ? null
              : _Label(
                  page: widget.pages[page],
                  color: layer.labelColor,
                  visible: _open,
                  selected: selected,
                ),
    );

    if (page != null && _open) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: () => widget.onSelect(page), child: box),
      );
    }

    return Tooltip(
      message: _pinned ? 'Unpin menu' : 'Pin menu open',
      waitDuration: const Duration(milliseconds: 800),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() => _pinned = !_pinned),
          child: box,
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final BurgerPage page;
  final Color color;
  final bool visible;
  final bool selected;

  const _Label({
    required this.page,
    required this.color,
    required this.visible,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: visible ? 1 : 0,
      child: OverflowBox(
        alignment: Alignment.centerLeft,
        minWidth: 0,
        maxWidth: 200,
        minHeight: 0,
        maxHeight: 42,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(page.icon, size: 20, color: color),
              const SizedBox(width: 10),
              Text(
                page.label,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sesame extends StatelessWidget {
  const _Sesame();

  static const _spots = [
    Alignment(-0.55, 0.1),
    Alignment(-0.15, -0.35),
    Alignment(0.25, 0.15),
    Alignment(0.6, -0.25),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final a in _spots)
          Align(
            alignment: a,
            child: FractionallySizedBox(
              widthFactor: 0.07,
              heightFactor: 0.18,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
      ],
    );
  }
}