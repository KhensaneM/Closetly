
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color _sage = Color(0xFF87977B);
const Color _darkGreen = Color(0xFF354735);
const Color _cream = Color(0xFFF8F7F1);
const Color _softGreen = Color(0xFFE8EDE3);

class CreateOutfitPage extends StatefulWidget {
  const CreateOutfitPage({super.key});

  @override
  State<CreateOutfitPage> createState() => _CreateOutfitPageState();
}

class _CreateOutfitPageState extends State<CreateOutfitPage> {
  static const String clothesKey = 'closetly_clothes';
  static const String outfitsKey = 'closetly_outfits';

  List<Map<String, dynamic>> clothes = [];
  List<Map<String, dynamic>> savedOutfits = [];

  Map<String, dynamic>? selectedTop;
  Map<String, dynamic>? selectedBottom;
  Map<String, dynamic>? selectedShoes;

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  List<Map<String, dynamic>> _decodeList(String? value) {
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

      final loadedClothes = _decodeList(prefs.getString(clothesKey));
      final loadedOutfits = _decodeList(prefs.getString(outfitsKey));

      if (!mounted) return;

      setState(() {
        clothes = loadedClothes;
        savedOutfits = loadedOutfits;
        isLoading = false;
      });
    } catch (error) {
      debugPrint('Error loading Closetly data: $error');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage('Could not load your wardrobe. Please try again.');
    }
  }

  Future<void> refreshClothes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final latestClothes = _decodeList(prefs.getString(clothesKey));

      if (!mounted) return;

      setState(() {
        clothes = latestClothes;
      });
    } catch (error) {
      debugPrint('Error refreshing wardrobe: $error');
    }
  }

  Future<void> saveOutfits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(outfitsKey, jsonEncode(savedOutfits));
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  List<Map<String, dynamic>> itemsInCategory(String category) {
    return clothes
        .where((item) => item['category'] == category)
        .toList();
  }

  Future<void> chooseClothing(String category) async {
    // Refresh the wardrobe each time a category is tapped.
    // This prevents stale data when using IndexedStack navigation.
    await refreshClothes();

    if (!mounted) return;

    final availableItems = itemsInCategory(category);

    if (availableItems.isEmpty) {
      _showMessage('No $category found. Add some in your Wardrobe first.');
      return;
    }

    final selectedItem = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: _cream,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.65,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 12, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Choose $category',
                          style: const TextStyle(
                            color: _darkGreen,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: availableItems.length,
                    separatorBuilder: (_, index) =>
                    const Divider(height: 1),
                    itemBuilder: (itemContext, index) {
                      final item = availableItems[index];
                      final imagePath = item['imagePath'] as String?;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        leading: _clothingImage(
                          imagePath,
                          category,
                          55,
                        ),
                        title: Text(
                          item['name']?.toString() ?? 'Clothing item',
                          style: const TextStyle(
                            color: _darkGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(category),
                        trailing: const Icon(
                          Icons.add_circle_outline,
                          color: _sage,
                        ),
                        onTap: () {
                          Navigator.pop(
                            sheetContext,
                            Map<String, dynamic>.from(item),
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

    if (!mounted || selectedItem == null) return;

    setState(() {
      switch (category) {
        case 'Tops':
          selectedTop = selectedItem;
          break;
        case 'Bottoms':
          selectedBottom = selectedItem;
          break;
        case 'Shoes':
          selectedShoes = selectedItem;
          break;
      }
    });
  }

  Widget _clothingImage(
      String? imagePath,
      String category,
      double size,
      ) {
    final fileExists =
        imagePath != null && File(imagePath).existsSync();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _softGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: fileExists
          ? Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _categoryIcon(category);
        },
      )
          : _categoryIcon(category),
    );
  }

  Widget _categoryIcon(String category) {
    IconData icon;

    switch (category) {
      case 'Tops':
        icon = Icons.checkroom_outlined;
        break;
      case 'Bottoms':
        icon = Icons.shopping_bag_outlined;
        break;
      default:
        icon = Icons.directions_walk_outlined;
    }

    return Icon(icon, color: _sage, size: 35);
  }

  Widget _selectionCard(
      String category,
      Map<String, dynamic>? selectedItem,
      ) {
    final hasSelection = selectedItem != null;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => chooseClothing(category),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hasSelection ? _sage : _softGreen,
              width: hasSelection ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              _clothingImage(
                selectedItem?['imagePath'] as String?,
                category,
                65,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        color: _sage,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      selectedItem?['name']?.toString() ??
                          'Choose $category',
                      style: const TextStyle(
                        color: _darkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasSelection
                          ? 'Tap to change'
                          : 'Select from wardrobe',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: _sage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveOutfit() async {
    if (selectedTop == null ||
        selectedBottom == null ||
        selectedShoes == null ||
        isSaving) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    final outfit = <String, dynamic>{
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'top': Map<String, dynamic>.from(selectedTop!),
      'bottom': Map<String, dynamic>.from(selectedBottom!),
      'shoes': Map<String, dynamic>.from(selectedShoes!),
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      final updatedOutfits = [outfit, ...savedOutfits];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        outfitsKey,
        jsonEncode(updatedOutfits),
      );

      if (!mounted) return;

      setState(() {
        savedOutfits = updatedOutfits;
        selectedTop = null;
        selectedBottom = null;
        selectedShoes = null;
        isSaving = false;
      });

      _showMessage('Your outfit has been saved!');
    } catch (error) {
      debugPrint('Error saving outfit: $error');

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      _showMessage('Could not save your outfit. Please try again.');
    }
  }

  Future<void> deleteOutfit(String id) async {
    final previousOutfits = List<Map<String, dynamic>>.from(savedOutfits);

    setState(() {
      savedOutfits.removeWhere((outfit) => outfit['id'] == id);
    });

    try {
      await saveOutfits();
      _showMessage('Outfit deleted.');
    } catch (error) {
      debugPrint('Error deleting outfit: $error');

      if (!mounted) return;

      setState(() {
        savedOutfits = previousOutfits;
      });

      _showMessage('Could not delete the outfit.');
    }
  }

  Widget _savedOutfitCard(Map<String, dynamic> outfit) {
    final top = Map<String, dynamic>.from(outfit['top']);
    final bottom = Map<String, dynamic>.from(outfit['bottom']);
    final shoes = Map<String, dynamic>.from(outfit['shoes']);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Saved look',
                  style: TextStyle(
                    color: _darkGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Delete outfit',
                onPressed: () => deleteOutfit(outfit['id'].toString()),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _savedItem(top, 'Tops')),
              const SizedBox(width: 8),
              Expanded(child: _savedItem(bottom, 'Bottoms')),
              const SizedBox(width: 8),
              Expanded(child: _savedItem(shoes, 'Shoes')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _savedItem(
      Map<String, dynamic> item,
      String category,
      ) {
    return Column(
      children: [
        _clothingImage(
          item['imagePath'] as String?,
          category,
          75,
        ),
        const SizedBox(height: 7),
        Text(
          item['name']?.toString() ?? 'Clothing item',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _darkGreen,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSave = selectedTop != null &&
        selectedBottom != null &&
        selectedShoes != null;

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        title: const Text(
          'Create Outfit',
          style: TextStyle(
            color: _darkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh wardrobe',
            onPressed: loadData,
            icon: const Icon(
              Icons.refresh,
              color: _darkGreen,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: _sage),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: _darkGreen,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STYLE YOURSELF',
                    style: TextStyle(
                      color: Color(0xFFD7E1D0),
                      letterSpacing: 2,
                      fontSize: 11,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Create a look\nthat feels like you.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      height: 1.3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Build your outfit',
              style: TextStyle(
                color: _darkGreen,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Choose pieces from your personal wardrobe.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 18),
            _selectionCard('Tops', selectedTop),
            const SizedBox(height: 12),
            _selectionCard('Bottoms', selectedBottom),
            const SizedBox(height: 12),
            _selectionCard('Shoes', selectedShoes),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canSave && !isSaving ? saveOutfit : null,
                icon: isSaving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.favorite_outline),
                label: Text(
                  isSaving ? 'Saving...' : 'Save outfit',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _sage,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 35),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'My saved outfits',
                    style: TextStyle(
                      color: _darkGreen,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${savedOutfits.length} looks',
                  style: const TextStyle(
                    color: _sage,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (savedOutfits.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: _softGreen,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.checkroom_outlined,
                      size: 45,
                      color: _sage,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No saved outfits yet',
                      style: TextStyle(
                        color: _darkGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Your favourite looks will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...savedOutfits.map(_savedOutfitCard),
          ],
        ),
      ),
    );
  }
}
