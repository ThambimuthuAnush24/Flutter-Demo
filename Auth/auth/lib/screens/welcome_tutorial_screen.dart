import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class WelcomeTutorialScreen extends StatefulWidget {
  const WelcomeTutorialScreen({super.key});

  @override
  WelcomeTutorialScreenState createState() => WelcomeTutorialScreenState();
}

class WelcomeTutorialScreenState extends State<WelcomeTutorialScreen> {
  final PageController _pageController = PageController();
  final ApiService _apiService = ApiService();
  int _currentPage = 0;
  bool _isLastPage = false;

  final List<Map<String, String>> _tutorialData = [
    {
      "title": "Track your habits effortlessly!",
      "description": "Add habits you want to build or break,\nset daily goals and reminders,and \nwatch your progress grow!",
      "image": "assets/tutorial1.png"
    },
    {
      "title": "Stay consistent and unlock streaks!",
      "description": "Complete habits daily \nto keep your streak alive and \ntrack your progress.",
      "image": "assets/tutorial2.png"
    },
    {
      "title": "Make habit-building fun!",
      "description": "Earn rewards,unlock \nachievements,and level up as you \nreach your goals.",
      "image": "assets/tutorial3.png"
    },
    {
      "title": "See your success at a glance!",
      "description": "Check your daily,weekly, \nand monthly progress with insightful \ncharts and stats.",
      "image": "assets/tutorial4.png"
    },
    {
      "title": "Share Your Progress with Friends!",
      "description": "Stay motivated and accountable by \nsharing your achievements.Let your friends \ncheer you on as you build better habits!",
      "image": "assets/tutorial5.png"
    },
  ];

  @override
  void initState() {
    super.initState();
    _markTutorialAsSeen();
  }

  Future<void> _markTutorialAsSeen() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool('has_seen_tutorial', true);

    // Optional: Notify Django backend that tutorial was seen
    try {
      await _apiService.markTutorialSeen();
    } catch (e) {
      debugPrint('Failed to notify backend: $e');
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
      _isLastPage = index == _tutorialData.length - 1;
    });
  }

  void _navigateToSignUp() {
    Navigator.pushReplacementNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 25),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Image.asset(
                    'assets/habitro_logo.png',
                    height: 45,
                    fit: BoxFit.contain,
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _tutorialData.length,
                    itemBuilder: (context, index) {
                      final data = _tutorialData[index];
                      return _buildTutorialPage(data, screenHeight);
                    },
                  ),
                ),
              ],
            ),
            _buildNavigationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialPage(Map<String, String> data, double screenHeight) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Image.asset(
              data["image"]!,
              height: screenHeight * 0.5,
            ),
            SizedBox(height: 12),
            Text(
              data["title"]!,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2853AF),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              data["description"]!,
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey[700],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Positioned(
      bottom: 48,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _tutorialData.length,
              (index) => AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Color(0xFF2853AF)
                      : Colors.grey[400],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: _isLastPage
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: [
                if (!_isLastPage)
                  TextButton(
                    onPressed: _navigateToSignUp,
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (_isLastPage)
                  ElevatedButton(
                    onPressed: _navigateToSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2853AF),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Get Started",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
