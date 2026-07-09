import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/tracker_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Initial helper to fetch initials
  String _getInitials(String name) {
    if (name.isEmpty) return 'AJ';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0].substring(0, (parts[0].length >= 2 ? 2 : 1)).toUpperCase();
  }

  // Add Item Bottom Sheet trigger
  void _showAddTrackerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const AddTrackerBottomSheet();
      },
    ).then((value) {
      // If added, transition to Home Tab
      if (value == true) {
        setState(() {
          _selectedIndex = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final userName = user?.fullName ?? 'Alex Johnson';
    final userEmail = user?.email ?? 'alex@example.com';
    final initials = _getInitials(userName);

    // Sub-screens list
    final List<Widget> children = [
      HomeTabView(userName: userName, initials: initials),
      const StatsTabView(),
      const SizedBox.shrink(), // Placeholder for Central FAB
      const ScheduleTabView(),
      ProfileTabView(userName: userName, userEmail: userEmail, initials: initials),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A1128), // Figma Deep Blue Background
      body: Stack(
        children: [
          // Sub-screen viewport
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 90.0), // Padding to prevent bottom navbar clipping
              child: IndexedStack(
                index: _selectedIndex,
                children: children,
              ),
            ),
          ),

          // Custom Floating Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_rounded, 'Home'),
                  _buildNavItem(1, Icons.bar_chart_rounded, 'Stats'),
                  
                  // Central Floating Action Button
                  GestureDetector(
                    onTap: () => _showAddTrackerSheet(context),
                    child: Transform.translate(
                      offset: const Offset(0, -18),
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4D7DF2), Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4D7DF2).withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  _buildNavItem(3, Icons.calendar_month_rounded, 'Schedule'),
                  _buildNavItem(4, Icons.person_rounded, 'Profile'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final themeColor = isSelected ? const Color(0xFF4D7DF2) : const Color(0xFF94A3B8);

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: themeColor, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 3),
            // Bottom selection dot
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4D7DF2) : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================================
// 1. HOME TAB VIEW (Figma Screen 3 layout)
// ==========================================================================
class HomeTabView extends StatelessWidget {
  final String userName;
  final String initials;

  const HomeTabView({super.key, required this.userName, required this.initials});

  @override
  Widget build(BuildContext context) {
    final trackerProvider = Provider.of<TrackerProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Greeting & Profile Avatar Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning ☀️',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    userName,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Overview Stats white card container
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                  icon: Icons.menu_book_rounded,
                  iconBg: const Color(0xFFE0E9FE),
                  iconColor: const Color(0xFF3B82F6),
                  value: '${trackerProvider.totalStudyHours.toStringAsFixed(1)}h',
                  label: 'Studied',
                ),
                _buildStatDivider(),
                _buildStatColumn(
                  icon: Icons.track_changes_rounded,
                  iconBg: const Color(0xFFFEE2E2),
                  iconColor: const Color(0xFFEF4444),
                  value: trackerProvider.habitsRatioString,
                  label: 'Habits',
                ),
                _buildStatDivider(),
                _buildStatColumn(
                  icon: Icons.local_fire_department_rounded,
                  iconBg: const Color(0xFFFEF3C7),
                  iconColor: const Color(0xFFF59E0B),
                  value: '${trackerProvider.streakPercentage}%',
                  label: 'Streak',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Today's Sessions Section
          Row(
            children: [
              Text(
                "Today's Sessions",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: trackerProvider.sessions.length,
            itemBuilder: (context, index) {
              final session = trackerProvider.sessions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () => trackerProvider.toggleSession(session.id),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: session.done ? Colors.white : const Color(0xFF132A60),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: session.done ? Colors.transparent : const Color(0xFF4D7DF2).withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.subject,
                                  style: GoogleFonts.outfit(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: session.done ? const Color(0xFF1E293B) : Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  session.topic,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: session.done ? const Color(0xFF64748B) : Colors.white.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                            session.done
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE6FDF4),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_rounded, color: Color(0xFF059669), size: 12),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Done',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF059669),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4D7DF2).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${session.duration} min',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF93C5FD),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: SizedBox(
                            height: 6,
                            child: LinearProgressIndicator(
                              value: (session.done ? 100 : session.progress) / 100.0,
                              backgroundColor: session.done ? const Color(0xFFF1F5F9) : Colors.white.withValues(alpha: 0.1),
                              color: session.done ? const Color(0xFF10B981) : const Color(0xFF4D7DF2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Daily Habits Section
          Row(
            children: [
              Text(
                "Daily Habits",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Flex layout of habits (4 side-by-side or scrollable row)
          SizedBox(
            height: 135,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: trackerProvider.habits.length,
              itemBuilder: (context, index) {
                final habit = trackerProvider.habits[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: InkWell(
                    onTap: () => trackerProvider.toggleHabit(habit.id),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 90,
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: habit.done ? const Color(0xFF132A60) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: habit.done ? const Color(0xFF4D7DF2).withValues(alpha: 0.3) : Colors.transparent,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            habit.icon,
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            habit.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              color: habit.done ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF97316), size: 12),
                              Text(
                                '${habit.streak}d',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFF97316),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Streak Info Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5046E6), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You're on a ${trackerProvider.highestStreakCount}-day streak!",
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trackerProvider.remainingHabitsCount > 0
                            ? "Complete ${trackerProvider.remainingHabitsCount} more habit${trackerProvider.remainingHabitsCount > 1 ? 's' : ''} to keep it going"
                            : "All daily habits completed! Awesome job! 🚀",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFFE2E8F0),
    );
  }
}

// ==========================================================================
// 2. STATS TAB VIEW (Weekly performance details)
// ==========================================================================
class StatsTabView extends StatelessWidget {
  const StatsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    // Hardcoded analytics to representation
    final studyStats = [
      {'day': 'Mon', 'val': 1.5, 'height': 0.4},
      {'day': 'Tue', 'val': 3.0, 'height': 0.7},
      {'day': 'Wed', 'val': 4.2, 'height': 0.9},
      {'day': 'Thu', 'val': 2.2, 'height': 0.55},
      {'day': 'Fri', 'val': 3.6, 'height': 0.8},
      {'day': 'Sat', 'val': 1.0, 'height': 0.25},
      {'day': 'Sun', 'val': 0.4, 'height': 0.1},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Weekly Insights',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Weekly Performance',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hours dedicated to study sessions over the last 7 days',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 28),

                // Manual bar chart representation
                SizedBox(
                  height: 160,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: studyStats.map((item) {
                      final double heightMultiplier = item['height'] as double;
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${item['val']}h',
                              style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.bold, color: const Color(0xFF4D7DF2)),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              height: 110 * heightMultiplier,
                              width: 12,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF60A5FA), Color(0xFF4D7DF2)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['day'] as String,
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Metrics row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInsightCol('15.9h', 'Total Studied'),
                    _buildInsightCol('2.3h', 'Daily Avg'),
                    _buildInsightCol('88%', 'Adherence'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCol(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

// ==========================================================================
// 3. SCHEDULE TAB VIEW (Weekly timeline planner)
// ==========================================================================
class ScheduleTabView extends StatelessWidget {
  const ScheduleTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final days = [
      {'name': 'M', 'num': '6', 'active': false},
      {'name': 'T', 'num': '7', 'active': false},
      {'name': 'W', 'num': '8', 'active': true},
      {'name': 'T', 'num': '9', 'active': false},
      {'name': 'F', 'num': '10', 'active': false},
      {'name': 'S', 'num': '11', 'active': false},
      {'name': 'S', 'num': '12', 'active': false},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Schedule Planner',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: days.map((day) {
                    final bool active = day['active'] as bool;
                    return InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        decoration: BoxDecoration(
                          color: active ? const Color(0xFF4D7DF2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              day['name'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: active ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              day['num'] as String,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: active ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                
                // Timeline events
                _buildTimelineSlot('09:00 AM', 'Mathematics Lecture', 'Calculus Derivatives basics', const Color(0xFF3B82F6), const Color(0xFFEFF6FF), const Color(0xFF1E3A8A)),
                const SizedBox(height: 16),
                _buildTimelineSlot('11:30 AM', 'Physics Lab Work', 'Wave mechanics properties', const Color(0xFFF97316), const Color(0xFFFFF7ED), const Color(0xFF7C2D12)),
                const SizedBox(height: 16),
                _buildTimelineSlot('03:00 PM', 'Personal Reading Habit', 'Read 30 minutes of Atomic Habits', const Color(0xFF10B981), const Color(0xFFECFDF5), const Color(0xFF064E3B)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSlot(
    String time,
    String title,
    String desc,
    Color accentColor,
    Color bg,
    Color textThemeColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 65,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              time,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(color: accentColor, width: 4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textThemeColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================================================
// 4. PROFILE TAB VIEW (User configurations / logouts)
// ==========================================================================
class ProfileTabView extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String initials;

  const ProfileTabView({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'My Profile',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar Large
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userEmail,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 28),

                // Settings items list
                _buildSettingsRow('Account Tier', 'PRO', isBadge: true),
                const SizedBox(height: 10),
                _buildSettingsRow('Current Streak', '7 days'),
                const SizedBox(height: 10),
                _buildSettingsRow('Total Study Time', '42 hours'),
                const SizedBox(height: 28),

                // Sign out Button
                ElevatedButton(
                  onPressed: () {
                    authProvider.logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE2E2),
                    foregroundColor: const Color(0xFFEF4444),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Sign Out',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
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

  Widget _buildSettingsRow(String title, String val, {bool isBadge = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          isBadge
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    val,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                )
              : Text(
                  val,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF64748B),
                  ),
                ),
        ],
      ),
    );
  }
}

// ==========================================================================
// 5. FAB ADD TRACKER BOTTOM SHEET
// ==========================================================================
class AddTrackerBottomSheet extends StatefulWidget {
  const AddTrackerBottomSheet({super.key});

  @override
  State<AddTrackerBottomSheet> createState() => _AddTrackerBottomSheetState();
}

class _AddTrackerBottomSheetState extends State<AddTrackerBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _sessionFormKey = GlobalKey<FormState>();
  final _habitFormKey = GlobalKey<FormState>();

  // Session controllers
  final _subjectController = TextEditingController();
  final _topicController = TextEditingController();
  final _durationController = TextEditingController();

  // Habit controllers
  final _habitNameController = TextEditingController();
  String _selectedEmoji = '📖';
  final _habitStreakController = TextEditingController(text: '0');

  final List<String> _emojiOptions = ['📖', '🏃', '🧘', '💧', '🍎', '💻', '💤'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectController.dispose();
    _topicController.dispose();
    _durationController.dispose();
    _habitNameController.dispose();
    _habitStreakController.dispose();
    super.dispose();
  }

  void _submitSession() {
    if (!_sessionFormKey.currentState!.validate()) return;
    
    final trackerProvider = Provider.of<TrackerProvider>(context, listen: false);
    trackerProvider.addSession(
      _subjectController.text.trim(),
      _topicController.text.trim(),
      int.parse(_durationController.text),
    );
    Navigator.of(context).pop(true); // Close with true (trigger redirect)
  }

  void _submitHabit() {
    if (!_habitFormKey.currentState!.validate()) return;
    
    final trackerProvider = Provider.of<TrackerProvider>(context, listen: false);
    trackerProvider.addHabit(
      _habitNameController.text.trim(),
      _selectedEmoji,
      int.tryParse(_habitStreakController.text) ?? 0,
    );
    Navigator.of(context).pop(true); // Close with true
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Tracker',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Modal Tabs selector
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                    ),
                  ],
                ),
                labelColor: const Color(0xFF1E293B),
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Study Session'),
                  Tab(text: 'Daily Habit'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tabs Content View
            Flexible(
              child: SizedBox(
                height: 280,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Form 1: Study Session
                    Form(
                      key: _sessionFormKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildInputLabel('Subject'),
                            TextFormField(
                              controller: _subjectController,
                              style: const TextStyle(color: Color(0xFF1E293B)),
                              decoration: _buildInputDecoration('e.g. Mathematics, History'),
                              validator: (val) => val == null || val.isEmpty ? 'Subject is required' : null,
                            ),
                            const SizedBox(height: 12),
                            _buildInputLabel('Topic'),
                            TextFormField(
                              controller: _topicController,
                              style: const TextStyle(color: Color(0xFF1E293B)),
                              decoration: _buildInputDecoration('e.g. Integration, WW2'),
                              validator: (val) => val == null || val.isEmpty ? 'Topic is required' : null,
                            ),
                            const SizedBox(height: 12),
                            _buildInputLabel('Duration (Minutes)'),
                            TextFormField(
                              controller: _durationController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Color(0xFF1E293B)),
                              decoration: _buildInputDecoration('e.g. 45, 60'),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Duration is required';
                                final num = int.tryParse(val);
                                if (num == null || num <= 0) return 'Enter a valid duration';
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _submitSession,
                              style: _buildSubmitBtnStyle(),
                              child: Text('Add Session', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Form 2: Daily Habit
                    Form(
                      key: _habitFormKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildInputLabel('Habit Name'),
                            TextFormField(
                              controller: _habitNameController,
                              style: const TextStyle(color: Color(0xFF1E293B)),
                              decoration: _buildInputDecoration('e.g. Read 30 min, Exercise'),
                              validator: (val) => val == null || val.isEmpty ? 'Habit name is required' : null,
                            ),
                            const SizedBox(height: 12),
                            _buildInputLabel('Habit Icon/Emoji'),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedEmoji,
                              dropdownColor: Colors.white,
                              style: GoogleFonts.inter(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold),
                              decoration: _buildInputDecoration(''),
                              items: _emojiOptions.map((emoji) {
                                return DropdownMenuItem(
                                  value: emoji,
                                  child: Row(
                                    children: [
                                      Text(emoji, style: const TextStyle(fontSize: 18)),
                                      const SizedBox(width: 8),
                                      Text(_getEmojiName(emoji)),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedEmoji = val;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildInputLabel('Initial Streak Days'),
                            TextFormField(
                              controller: _habitStreakController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Color(0xFF1E293B)),
                              decoration: _buildInputDecoration('e.g. 0, 7'),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Streak is required';
                                if (int.tryParse(val) == null) return 'Enter a valid number';
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _submitHabit,
                              style: _buildSubmitBtnStyle(),
                              child: Text('Add Habit', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4D7DF2), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  ButtonStyle _buildSubmitBtnStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4D7DF2),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  String _getEmojiName(String emoji) {
    switch (emoji) {
      case '📖': return 'Book Reading';
      case '🏃': return 'Exercise / Workout';
      case '🧘': return 'Meditation';
      case '💧': return 'Water Hydration';
      case '🍎': return 'Healthy Eating';
      case '💻': return 'Coding Practice';
      case '💤': return 'Sleep Schedule';
      default: return 'Habit';
    }
  }
}
