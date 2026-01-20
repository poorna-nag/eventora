import 'package:flutter/material.dart';

class PartyCategoryGrid extends StatefulWidget {
  final Function(List<String>) onCategoriesChanged;

  const PartyCategoryGrid({super.key, required this.onCategoriesChanged});

  @override
  State<PartyCategoryGrid> createState() => _PartyCategoryGridState();
}

class _PartyCategoryGridState extends State<PartyCategoryGrid> {
  final Set<int> selectedIndexes = {};

  final List<Map<String, dynamic>> categories = [
    {"title": "Food", "icon": Icons.fastfood},
    {"title": "Drinks", "icon": Icons.local_bar},
    {"title": "Pets", "icon": Icons.pets},
    {"title": "18+", "icon": Icons.warning},
    {"title": "Music", "icon": Icons.music_note},
    {"title": "DJ", "icon": Icons.headphones},
    {"title": "Dance", "icon": Icons.directions_run},
    {"title": "Games", "icon": Icons.videogame_asset},
    {"title": "Party", "icon": Icons.celebration},
    {"title": "Live", "icon": Icons.theater_comedy},
  ];

  void _updateSelection() {
    final selected = selectedIndexes
        .map((i) => categories[i]["title"] as String)
        .toList();
    widget.onCategoriesChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(categories.length, (index) {
            final item = categories[index];
            final bool isSelected = selectedIndexes.contains(index);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedIndexes.remove(index);
                  } else {
                    selectedIndexes.add(index);
                  }
                  _updateSelection();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 10),
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: isSelected ? null : Colors.grey.shade300,
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF3B5BD6),
                            Color(0xFF7A3EE6),
                            Color(0xFF9A4EDB),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected
                      ? [
                          const BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item["icon"],
                      size: 26,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item["title"],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
