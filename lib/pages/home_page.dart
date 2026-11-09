import 'package:flutter/material.dart';

import '../app_state.dart';
import '../app_theme.dart';
import '../page_header.dart';
import 'recipes_page.dart';

String _greeting(int hour) => switch (hour) {
      >= 5 && < 12 => 'Good morning',
      >= 12 && < 17 => 'Good afternoon',
      >= 17 && < 22 => 'Good evening',
      _ => 'Late-night cravings?',
    };

class HomePage extends StatelessWidget {
  final AppState state;
  const HomePage({super.key, required this.state});

  void _open(BuildContext context, RecipeMatch m) {
    state.recordOpen(m.recipe);
    showDialog<void>(
      context: context,
      builder: (_) => RecipeDetailDialog(
        match: m,
        onFavorite: () => state.toggleFavorite(m.recipe),
        onHide: () => state.toggleHidden(m.recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shades = AppShades.of(context);
    final now = DateTime.now();
    final slot = mealForHour(now.hour);
    final picks = state.recommendations(now: now);
    final mostOpened = state
        .matches()
        .where((m) => m.recipe.clicks > 0 && !m.recipe.hidden)
        .toList()
      ..sort((a, b) => b.recipe.clicks.compareTo(a.recipe.clicks));

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        PageHeader(
          title: _greeting(now.hour),
          subtitle: "It's ${slot.label.toLowerCase()} time. Here's what fits right now.",
        ),
        const SizedBox(height: 24),
        const _Heading('Recommended for you'),
        const SizedBox(height: 12),
        if (picks.isEmpty)
          Text(
            'Add a few recipes and suggestions will show up here.',
            style: TextStyle(color: shades.muted),
          )
        else
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final m in picks)
                _PickCard(match: m, slot: slot, onTap: () => _open(context, m)),
            ],
          ),
        if (mostOpened.isNotEmpty) ...[
          const SizedBox(height: 28),
          const _Heading('Most opened'),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final m in mostOpened.take(5))
                  ListTile(
                    title: Text(m.recipe.name),
                    subtitle: Text(
                      '${m.have.length}/${m.recipe.ingredients.length} ingredients on hand',
                    ),
                    trailing: Text(
                      'Opened ${m.recipe.clicks}×',
                      style: TextStyle(color: shades.muted),
                    ),
                    onTap: () => _open(context, m),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppShades.of(context).ink,
      ),
    );
  }
}

class _PickCard extends StatelessWidget {
  final RecipeMatch match;
  final MealType slot;
  final VoidCallback onTap;

  const _PickCard({required this.match, required this.slot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final shades = AppShades.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final r = match.recipe;
    final total = r.ingredients.length;
    final fraction = total == 0 ? 0.0 : match.have.length / total;
    final fitsNow = r.meal == slot || r.type.toLowerCase() == slot.name;

    final reasons = [
      if (fitsNow) 'Good for ${slot.label.toLowerCase()}',
      if (r.clicks > 0) 'Opened ${r.clicks}×',
      '${match.have.length}/$total on hand',
    ];

    return SizedBox(
      width: 270,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        r.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: shades.ink,
                        ),
                      ),
                    ),
                    if (r.favorite) Icon(Icons.star_rounded, color: primary, size: 20),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final reason in reasons)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          reason,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: shades.ink,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: fraction,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                  backgroundColor: shades.ink.withValues(alpha: 0.12),
                  color: fraction == 1 ? shades.matchComplete : shades.matchPartial,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}