import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/helpers.dart/date_formatter.dart';
import '../bloc/mood_stats_bloc.dart';
import '../widgets/mood_chips_widget.dart';
import '../widgets/pie_chart_widget.dart';

class MoodStatsLayout extends StatefulWidget {
  const MoodStatsLayout({super.key});

  @override
  State<MoodStatsLayout> createState() => _MoodStatsLayoutState();
}

class _MoodStatsLayoutState extends State<MoodStatsLayout> {
  int? _openedCardIndex;

  @override
  void initState() {
    super.initState();
    _openedCardIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    context.read<MoodStatsBloc>().add(FetchMoodStatsEvent());
    final colorTheme = Theme.of(context).colorScheme;
    return BlocBuilder<MoodStatsBloc, MoodStatsState>(
      builder: (context, state) {
        if (state is MoodStatsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MoodStatsLoaded) {
          final weeklyMoodPercentages = state.weeklyMoodPercentages;
          final weeklyMoodCounts = state.weeklyMoodCounts;
          final dateRanges = state.dateRanges;

          if (weeklyMoodPercentages.isEmpty) {
            return const Center(child: Text('No data available.'));
          }

          return ListView.builder(
            itemCount: weeklyMoodPercentages.length,
            itemBuilder: (context, index) {
              final moodPercentages = weeklyMoodPercentages[index];
              final moodCounts = weeklyMoodCounts[index];
              final dateRange = dateRanges[index];

              final isOpen = _openedCardIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _openedCardIndex = isOpen ? null : index;
                  });
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.surface,
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child:
                          isOpen
                              ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formatDateRange(dateRange),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colorTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 50),
                                  MoodPieChart(
                                    moodPercentages: moodPercentages,
                                  ),
                                  const SizedBox(height: 16),
                                  MoodChips(moodCounts: moodCounts),
                                ],
                              )
                              : Text(
                                formatDateRange(dateRange),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorTheme.primary,
                                ),
                              ),
                    ),
                  ),
                ),
              );
            },
          );
        } else if (state is MoodStatsError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text('No data available.'));
      },
    );
  }
}
