import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LevelUpApp());
}

class LevelUpApp extends StatelessWidget {
  const LevelUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Level Up',
      theme: ThemeData(
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Premium Slate Dark
        primaryColor: const Color(0xFF3B82F6),
      ),
      home: const HabitDashboard(),
    );
  }
}

class HabitDashboard extends StatefulWidget {
  const HabitDashboard({super.key});

  @override
  State<HabitDashboard> createState() => _HabitDashboardState();
}

class _HabitDashboardState extends State<HabitDashboard> {
  int totalPoints = 0;
  List<String> completedHabitsToday = [];
  bool isLoading = true;

  // 📌 Habit Data with Points & Icons (No Numbers)
  final List<Map<String, dynamic>> habitsList = [
    {'id': 'h1', 'title': 'Wake up at 6:00 AM', 'points': 50, 'icon': Icons.wb_sunny_rounded, 'color': Colors.amber},
    {'id': 'h2', 'title': 'Drink 2 Glasses of Water', 'points': 10, 'icon': Icons.water_drop_rounded, 'color': Colors.lightBlueAccent},
    {'id': 'h3', 'title': 'Exercise & Workout', 'points': 40, 'icon': Icons.fitness_center_rounded, 'color': Colors.redAccent},
    {'id': 'h4', 'title': 'Learn English (30 mins)', 'points': 30, 'icon': Icons.language_rounded, 'color': Colors.indigoAccent},
    {'id': 'h5', 'title': 'Read a Book (30 mins)', 'points': 30, 'icon': Icons.menu_book_rounded, 'color': Colors.tealAccent},
    {'id': 'h6', 'title': 'Practice Silence & Speak Less', 'points': 20, 'icon': Icons.self_improvement_rounded, 'color': Colors.purpleAccent},
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  // 💾 Load Data & Check for New Day
  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toString().substring(0, 10); // "YYYY-MM-DD"
    String lastDate = prefs.getString('last_date') ?? '';

    setState(() {
      totalPoints = prefs.getInt('total_points') ?? 0;
      
      // Agar naya din hai, toh tasks un-tick ho jayenge (lekin points bachenge)
      if (today != lastDate) {
        completedHabitsToday = [];
        prefs.setString('last_date', today);
        prefs.setStringList('completed_today', []);
      } else {
        completedHabitsToday = prefs.getStringList('completed_today') ?? [];
      }
      isLoading = false;
    });
  }

  // ✅ Mark Habit as Done and Give Reward
  Future<void> _completeHabit(String id, int pointsEarned) async {
    if (completedHabitsToday.contains(id)) return; // Pehle se done hai toh kuch mat karo

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      completedHabitsToday.add(id);
      totalPoints += pointsEarned;
    });

    await prefs.setStringList('completed_today', completedHabitsToday);
    await prefs.setInt('total_points', totalPoints);

    // 🎊 Show Reward Snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
              const SizedBox(width: 12),
              Text(
                'Awesome! +$pointsEarned XP Gained',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981), // Neon Green
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // 🎮 Calculate Level (Har 100 points pe ek level)
  int get currentLevel => (totalPoints ~/ 100) + 1;
  double get levelProgress => (totalPoints % 100) / 100;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌟 Top Player Profile & Level Board
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B), // Premium Slate card
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("My Journey", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text("Daily Quest", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.2), // Blue tint
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
                        ),
                        child: Text(
                          "Level $currentLevel",
                          style: const TextStyle(color: Color(0xFF60A5FA), fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 25),
                  
                  // Level Progress Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total XP: $totalPoints", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text("Next Level: ${(currentLevel * 100)} XP", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: levelProgress,
                      minHeight: 10,
                      backgroundColor: const Color(0xFF0F172A),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)), // Neon Green Bar
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),
            
            // 📜 Daily Tasks List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Today's Habits",
                style: TextStyle(color: Colors.blueGrey[200], fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: habitsList.length,
                itemBuilder: (context, index) {
                  final habit = habitsList[index];
                  bool isDone = completedHabitsToday.contains(habit['id']);

                  return GestureDetector(
                    onTap: () => _completeHabit(habit['id'], habit['points']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFF1E293B).withOpacity(0.5) : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDone ? const Color(0xFF10B981) : Colors.transparent, // Green border if done
                          width: 2,
                        ),
                        boxShadow: [
                          if (!isDone)
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                        ],
                      ),
                      child: Row(
                        children: [
                          // 🎨 Icon with colorful background
                          Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              color: isDone ? Colors.grey.withOpacity(0.1) : habit['color'].withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              isDone ? Icons.check_circle_rounded : habit['icon'], 
                              color: isDone ? const Color(0xFF10B981) : habit['color'], 
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // 📋 Habit Name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit['title'],
                                  style: TextStyle(
                                    color: isDone ? Colors.grey : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    decoration: isDone ? TextDecoration.lineThrough : null, // Katt gaya (strikethrough)
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "+${habit['points']} XP Reward",
                                  style: TextStyle(color: isDone ? Colors.grey[600] : const Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),

                          // ✅ Claim Button / Status
                          isDone 
                            ? const Text("DONE", style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, letterSpacing: 1))
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text("CLAIM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                              )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
