
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color sage = Color(0xFF87977B);
const Color darkGreen = Color(0xFF354735);
const Color cream = Color(0xFFF8F7F1);
const Color softGreen = Color(0xFFE8EDE3);

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  final ImagePicker picker = ImagePicker();

  static const String storageKey = 'closetly_clothes';

  String selectedCategory = 'All';
  bool isLoading = true;

  List<Map<String, dynamic>> clothes = [];

  final List<Map<String, dynamic>> defaultClothes = [
    {
      'id': 'sample-1',
      'name': 'White T-shirt',
      'category': 'Tops',
      'imagePath': null,
    },
    {
      'id': 'sample-2',
      'name': 'Blue Jeans',
      'category': 'Bottoms',
      'imagePath': null,
    },
    {
      'id': 'sample-3',
      'name': 'White Sneakers',
      'category': 'Shoes',
      'imagePath': null,
    },
    {
      'id': 'sample-4',
      'name': 'Green Sweater',
      'category': 'Tops',
      'imagePath': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    loadClothes();
  }

  Future<void> loadClothes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedClothes = prefs.getString(storageKey);

      if (savedClothes == null) {
        clothes = List<Map<String, dynamic>>.from(
          defaultClothes.map((item) => Map<String, dynamic>.from(item)),
        );
        await saveClothes();
      } else {
        final List<dynamic> decoded = jsonDecode(savedClothes);

        clothes = decoded.map((item) {
          return Map<String, dynamic>.from(item);
        }).toList();
      }
    } catch (error) {
      debugPrint('Could not load wardrobe: $error');
      clothes = List<Map<String, dynamic>>.from(
        defaultClothes.map((item) => Map<String, dynamic>.from(item)),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveClothes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(storageKey, jsonEncode(clothes));
    } catch (error) {
      debugPrint('Could not save wardrobe: $error');
    }
  }

  IconData categoryIcon(String category) {
    switch (category) {
      case 'Tops':
        return Icons.checkroom_outlined;
      case 'Bottoms':
        return Icons.shopping_bag_outlined;
      case 'Shoes':
        return Icons.directions_walk_outlined;
      default:
        return Icons.style_outlined;
    }
  }

  List<Map<String, dynamic>> get filteredClothes {
    if (selectedCategory == 'All') {
      return clothes;
    }

    return clothes
        .where((item) => item['category'] == selectedCategory)
        .toList();
  }

  Future<String?> saveImagePermanently(String temporaryPath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDirectory = Directory('${directory.path}/closetly_images');

      if (!await imagesDirectory.exists()) {
        await imagesDirectory.create(recursive: true);
      }

      final extension = temporaryPath.contains('.')
          ? temporaryPath.split('.').last
          : 'jpg';

      final fileName =
          'clothing_${DateTime.now().microsecondsSinceEpoch}.$extension';

      final savedFile = await File(temporaryPath).copy(
        '${imagesDirectory.path}/$fileName',
      );

      return savedFile.path;
    } catch (error) {
      debugPrint('Could not save image: $error');
      return null;
    }
  }

  Future<void> addClothing() async {
    final nameController = TextEditingController();

    String category = 'Tops';
    XFile? selectedImage;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cream,
              title: const Text(
                'Add clothing',
                style: TextStyle(
                  color: darkGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: softGreen,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(selectedImage!.path),
                          fit: BoxFit.cover,
                        ),
                      )
                          : const Icon(
                        Icons.add_a_photo_outlined,
                        size: 45,
                        color: sage,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final image = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 80,
                              );

                              if (image != null) {
                                setDialogState(() {
                                  selectedImage = image;
                                });
                              }
                            },
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Gallery'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final image = await picker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 80,
                              );

                              if (image != null) {
                                setDialogState(() {
                                  selectedImage = image;
                                });
                              }
                            },
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Camera'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Clothing name',
                        hintText: 'e.g. Black jacket',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: ['Tops', 'Bottoms', 'Shoes']
                          .map(
                            (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            category = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sage,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final name = nameController.text.trim();

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a clothing name.'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext, {
                      'name': name,
                      'category': category,
                      'temporaryImagePath': selectedImage?.path,
                    });
                  },
                  child: const Text('Add item'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();

    if (result == null) return;

    String? permanentImagePath;

    final temporaryPath = result['temporaryImagePath'] as String?;

    if (temporaryPath != null) {
      permanentImagePath = await saveImagePermanently(temporaryPath);
    }

    if (!mounted) return;

    final newClothing = <String, dynamic>{
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'name': result['name'],
      'category': result['category'],
      'imagePath': permanentImagePath,
    };

    setState(() {
      clothes.add(newClothing);
    });

    await saveClothes();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Clothing added to your wardrobe!'),
      ),
    );
  }

  Future<void> removeClothing(Map<String, dynamic> item) async {
    final imagePath = item['imagePath'] as String?;

    setState(() {
      clothes.removeWhere((clothing) => clothing['id'] == item['id']);
    });

    await saveClothes();

    if (imagePath != null) {
      try {
        final imageFile = File(imagePath);

        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      } catch (error) {
        debugPrint('Could not delete clothing image: $error');
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} removed from your wardrobe.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        elevation: 0,
        title: const Text(
          'My Wardrobe',
          style: TextStyle(
            color: darkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: sage),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your personal collection',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 18),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Tops', 'Bottoms', 'Shoes']
                        .map((category) {
                      final isSelected =
                          selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          selectedColor: sage,
                          backgroundColor: softGreen,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : darkGreen,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredClothes.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.checkroom_outlined,
                    size: 65,
                    color: sage,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nothing here yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Add something to this category.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: addClothing,
                    icon: const Icon(Icons.add),
                    label: const Text('Add clothing'),
                  ),
                ],
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                100,
              ),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemCount: filteredClothes.length,
              itemBuilder: (context, index) {
                final item = filteredClothes[index];
                final imagePath =
                item['imagePath'] as String?;

                return Dismissible(
                  key: ValueKey(item['id']),
                  direction: DismissDirection.up,
                  onDismissed: (_) => removeClothing(item),
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 35,
                      ),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.04,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                            const BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                            child: Container(
                              width: double.infinity,
                              color: softGreen,
                              child: imagePath != null &&
                                  File(imagePath).existsSync()
                                  ? Image.file(
                                File(imagePath),
                                fit: BoxFit.cover,
                                errorBuilder: (
                                    context,
                                    error,
                                    stackTrace,
                                    ) {
                                  return Icon(
                                    categoryIcon(
                                      item['category'],
                                    ),
                                    size: 55,
                                    color: sage,
                                  );
                                },
                              )
                                  : Icon(
                                categoryIcon(
                                  item['category'],
                                ),
                                size: 55,
                                color: sage,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] ?? 'Clothing item',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: darkGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['category'] ?? '',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
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
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addClothing,
        backgroundColor: sage,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add clothing'),
      ),
    );
  }
}
