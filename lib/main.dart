
import 'package:flutter/material.dart';
import 'pages/wardrobe_page.dart';
import 'pages/create_outfit_page.dart';
import 'pages/outfit_calendar_page.dart';

void main() {
  runApp(const ClosetlyApp());
}

const Color sage = Color(0xFF87977B);
const Color darkGreen = Color(0xFF354735);
const Color cream = Color(0xFFF8F7F1);
const Color softGreen = Color(0xFFE8EDE3);

class ClosetlyApp extends StatelessWidget {
  const ClosetlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Closetly',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: sage,
          surface: cream,
        ),
        fontFamily: 'Roboto',
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;

  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  late final List<Widget> pages = [
    HomePage(onNavigate: changePage),
    const WardrobePage(),
    const CreateOutfitPage(),
    const OutfitCalendarPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: changePage,
        backgroundColor: Colors.white,
        indicatorColor: softGreen,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: darkGreen),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.checkroom_outlined),
            selectedIcon: Icon(Icons.checkroom, color: darkGreen),
            label: 'Wardrobe',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle, color: darkGreen),
            label: 'Create',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(
              Icons.calendar_month,
              color: darkGreen,
            ),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: darkGreen),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// HOME PAGE

class HomePage extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const HomePage({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CLOSETLY',
                    style: TextStyle(
                      color: sage,
                      fontSize: 14,
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Hello, fashion lover!',
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const CircleAvatar(
                radius: 25,
                backgroundColor: softGreen,
                child: Icon(
                  Icons.person_outline,
                  color: darkGreen,
                  size: 28,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: darkGreen,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR STYLE, YOUR STORY',
                  style: TextStyle(
                    color: Color(0xFFD7E1D0),
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Get dressed.\nFeel confident.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    height: 1.3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Your wardrobe, organised your way.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => onNavigate(3),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDCE5D5),
                    foregroundColor: darkGreen,
                  ),
                  child: const Text('Discover your style →'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Today's inspiration",
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            height: 155,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E5DA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'THE LOOK OF THE DAY',
                          style: TextStyle(
                            color: sage,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Effortlessly\nchic.',
                          style: TextStyle(
                            fontSize: 23,
                            color: darkGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create your perfect outfit.',
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Icon(
                      Icons.checkroom,
                      size: 85,
                      color: sage,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            'Explore your wardrobe',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: CategoryCard(
                  title: 'Tops',
                  icon: Icons.checkroom,
                  color: softGreen,
                  onTap: () => onNavigate(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CategoryCard(
                  title: 'Bottoms',
                  icon: Icons.dry_cleaning,
                  color: const Color(0xFFF0E8DF),
                  onTap: () => onNavigate(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CategoryCard(
                  title: 'Shoes',
                  icon: Icons.shopping_bag_outlined,
                  color: const Color(0xFFEAE7F0),
                  onTap: () => onNavigate(1),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: softGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.favorite_outline,
                  color: darkGreen,
                  size: 30,
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Love your wardrobe.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Make every outfit count.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// CATEGORY CARD

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: darkGreen,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: darkGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CREATE PAGE

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePage(
      icon: Icons.add_circle_outline,
      title: 'Create an outfit',
      subtitle: 'Bring your favourite clothing pieces together.',
      description:
      'Mix and match items from your wardrobe to create outfits that express your personal style.',
    );
  }
}

// EXPLORE PAGE

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePage(
      icon: Icons.explore_outlined,
      title: 'Explore your style',
      subtitle: 'Find inspiration for your next look.',
      description:
      'Discover fashion ideas, explore different aesthetics and find new ways to express yourself.',
    );
  }
}

// PROFILE PAGE

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePage(
      icon: Icons.person_outline,
      title: 'Your profile',
      subtitle: 'Your personal fashion space.',
      description:
      'Your Closetly profile will bring your style preferences and personal settings together.',
    );
  }
}

// SHARED FEATURE PAGE

class FeaturePage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;

  const FeaturePage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          const Text(
            'CLOSETLY',
            style: TextStyle(
              color: sage,
              fontSize: 14,
              letterSpacing: 4,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 35),
          Container(
            height: 190,
            width: double.infinity,
            decoration: BoxDecoration(
              color: softGreen,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              size: 85,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            title,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: sage,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
