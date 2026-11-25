
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color _sage = Color(0xFF87977B);
const Color _darkGreen = Color(0xFF354735);
const Color _cream = Color(0xFFF8F7F1);
const Color _softGreen = Color(0xFFE8EDE3);

class OutfitCalendarPage extends StatefulWidget {
  const OutfitCalendarPage({super.key});

  @override
  State<OutfitCalendarPage> createState() => _OutfitCalendarPageState();
}

class _OutfitCalendarPageState extends State<OutfitCalendarPage> {
  static const String outfitsKey = 'closetly_outfits';
  static const String plansKey = 'closetly_outfit_plans';

  DateTime selectedDate = DateTime.now();
  DateTime displayedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  List<Map<String, dynamic>> outfits = [];
  Map<String, String> plans = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  String dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  List<Map<String, dynamic>> decodeOutfits(String? value) {
    if (value == null || value.isEmpty) return [];

    final decoded = jsonDecode(value);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final loadedOutfits =
          decodeOutfits(prefs.getString(outfitsKey));

      final decodedPlans = jsonDecode(
        prefs.getString(plansKey) ?? '{}',
      );

      final loadedPlans = <String, String>{};

      if (decodedPlans is Map) {
        decodedPlans.forEach((key, value) {
          if (key is String && value is String) {
            loadedPlans[key] = value;
          }
        });
      }

      if (!mounted) return;

      setState(() {
        outfits = loadedOutfits;
        plans = loadedPlans;
        isLoading = false;
      });
    } catch (error) {
      debugPrint('Calendar loading error: $error');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage('Could not load your calendar.');
    }
  }

  Future<void> refreshOutfits() async {
    final prefs = await SharedPreferences.getInstance();

    final latestOutfits =
        decodeOutfits(prefs.getString(outfitsKey));

    if (!mounted) return;

    setState(() {
      outfits = latestOutfits;
    });
  }

  Future<void> savePlans() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(plansKey, jsonEncode(plans));
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  String monthName(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  String readableDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Map<String, dynamic>? get selectedOutfit {
    final id = plans[dateKey(selectedDate)];

    if (id == null) return null;

    for (final outfit in outfits) {
      if (outfit['id'].toString() == id) {
        return outfit;
      }
    }

    return null;
  }

  void changeMonth(int amount) {
    setState(() {
      displayedMonth = DateTime(
        displayedMonth.year,
        displayedMonth.month + amount,
      );
    });
  }

  Future<void> chooseOutfit() async {
    await refreshOutfits();

    if (!mounted) return;

    if (outfits.isEmpty) {
      showMessage('Create an outfit first in the Create tab.');
      return;
    }

    final chosen = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: _cream,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.65,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Choose a saved outfit',
                    style: TextStyle(
                      color: _darkGreen,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: outfits.length,
                    separatorBuilder: (_, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final outfit = outfits[index];
                      final top = outfit['top'] is Map
                          ? outfit['top']['name'] ?? 'Top'
                          : 'Top';
                      final bottom = outfit['bottom'] is Map
                          ? outfit['bottom']['name'] ?? 'Bottom'
                          : 'Bottom';
                      final shoes = outfit['shoes'] is Map
                          ? outfit['shoes']['name'] ?? 'Shoes'
                          : 'Shoes';

                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: _softGreen,
                          child: Icon(
                            Icons.checkroom,
                            color: _darkGreen,
                          ),
                        ),
                        title: Text(
                          '$top + $bottom',
                          style: const TextStyle(
                            color: _darkGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(shoes.toString()),
                        trailing: const Icon(
                          Icons.add_circle_outline,
                          color: _sage,
                        ),
                        onTap: () {
                          Navigator.pop(
                            sheetContext,
                            Map<String, dynamic>.from(outfit),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || chosen == null) return;

    final previousPlans = Map<String, String>.from(plans);

    setState(() {
      plans[dateKey(selectedDate)] = chosen['id'].toString();
    });

    try {
      await savePlans();
      showMessage('Outfit planned for ${readableDate(selectedDate)}!');
    } catch (error) {
      debugPrint('Calendar save error: $error');

      if (!mounted) return;

      setState(() {
        plans = previousPlans;
      });

      showMessage('Could not save your outfit plan.');
    }
  }

  Future<void> removePlan() async {
    final key = dateKey(selectedDate);
    final previousPlans = Map<String, String>.from(plans);

    setState(() {
      plans.remove(key);
    });

    try {
      await savePlans();
      showMessage('Outfit plan removed.');
    } catch (error) {
      debugPrint('Calendar removal error: $error');

      if (!mounted) return;

      setState(() {
        plans = previousPlans;
      });

      showMessage('Could not remove the plan.');
    }
  }

  Widget buildCalendar() {
    final firstDay = DateTime(
      displayedMonth.year,
      displayedMonth.month,
      1,
    );

    final daysInMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month + 1,
      0,
    ).day;

    // Monday is the first day of the week.
    final startingOffset = firstDay.weekday - 1;
    final totalCells = ((startingOffset + daysInMonth + 6) ~/ 7) * 7;

    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
                color: _darkGreen,
              ),
              Text(
                monthName(displayedMonth),
                style: const TextStyle(
                  color: _darkGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => changeMonth(1),
                icon: const Icon(Icons.chevron_right),
                color: _darkGreen,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: weekdays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      color: _sage,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - startingOffset + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final date = DateTime(
                displayedMonth.year,
                displayedMonth.month,
                dayNumber,
              );

              final isSelected = dateKey(date) == dateKey(selectedDate);
              final isToday = dateKey(date) == dateKey(DateTime.now());
              final hasPlan = plans.containsKey(dateKey(date));

              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  setState(() {
                    selectedDate = date;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _darkGreen
                        : isToday
                            ? _softGreen
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: isToday && !isSelected
                        ? Border.all(color: _sage)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : _darkGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasPlan
                              ? (isSelected ? Colors.white : _sage)
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, size: 7, color: _sage),
              SizedBox(width: 6),
              Text(
                'Day with a planned outfit',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSelectedOutfit() {
    final outfit = selectedOutfit;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            readableDate(selectedDate),
            style: const TextStyle(
              color: _darkGreen,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          if (outfit == null) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 38,
                      color: _sage,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Nothing planned for this day yet.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _darkGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: chooseOutfit,
                icon: const Icon(Icons.add),
                label: const Text('Plan an outfit'),
              ),
            ),
          ] else ...[
            const Text(
              'YOUR PLANNED LOOK',
              style: TextStyle(
                color: _sage,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            _outfitDetails(outfit),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: chooseOutfit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Change'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: removePlan,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _outfitDetails(Map<String, dynamic> outfit) {
    String itemName(String key) {
      final item = outfit[key];
      if (item is Map) {
        return item['name']?.toString() ?? key;
      }
      return key;
    }

    return Column(
      children: [
        _detailRow(Icons.checkroom_outlined, 'Top', itemName('top')),
        const Divider(height: 18),
        _detailRow(Icons.shopping_bag_outlined, 'Bottom', itemName('bottom')),
        const Divider(height: 18),
        _detailRow(Icons.directions_walk_outlined, 'Shoes', itemName('shoes')),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String name) {
    return Row(
      children: [
        Icon(icon, color: _sage, size: 22),
        const SizedBox(width: 12),
        SizedBox(
          width: 65,
          child: Text(
            label,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              color: _darkGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        title: const Text(
          'Outfit Calendar',
          style: TextStyle(
            color: _darkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh outfits',
            onPressed: loadData,
            icon: const Icon(Icons.refresh, color: _darkGreen),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _sage),
            )
          : RefreshIndicator(
              onRefresh: loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                children: [
                  const Text(
                    'Plan your looks ahead.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 18),
                  buildCalendar(),
                  const SizedBox(height: 22),
                  buildSelectedOutfit(),
                ],
              ),
            ),
    );
  }
}
