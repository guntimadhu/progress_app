import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<AppProvider>(
      builder: (ctx, p, _) {
        final chartData = p.getChartData();
        final dist = p.taskDistribution;
        final streak = p.calcStreak();
        final insights = p.generateInsights();
        final todayPct = (p.todayPct * 100).round();
        final weekPct = p.weekAvgPct.round();

        final barLabels = p.statsPeriod == 'weekly'
            ? ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
            : p.statsPeriod == 'monthly'
                ? ['W1', 'W2', 'W3', 'W4', 'W5']
                : ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('📊 ANALYTICS',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)),
            const SizedBox(height: 14),

            // Period tabs
            Row(
              children: [
                _PTab('Weekly', 'weekly', p),
                const SizedBox(width: 7),
                _PTab('Monthly', 'monthly', p),
                const SizedBox(width: 7),
                _PTab('Yearly', 'yearly', p),
              ],
            ),
            const SizedBox(height: 16),

            // Stat cards
            Row(
              children: [
                Expanded(
                    child: _StatCard(
                        label: 'Today', value: '$todayPct%')),
                const SizedBox(width: 9),
                Expanded(
                    child: _StatCard(
                        label: 'Week', value: '$weekPct%')),
                const SizedBox(width: 9),
                Expanded(
                    child: _StatCard(
                        label: 'Streak', value: '$streak')),
              ],
            ),
            const SizedBox(height: 16),

            // Insights
            const Text('💡 INSIGHTS',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3)),
            const SizedBox(height: 10),
            ...insights.map((ins) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ins.icon,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(ins.text,
                            style: const TextStyle(
                                fontSize: 13, height: 1.5)),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),

            // Distribution Pie
            const Text('DISTRIBUTION',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3)),
            const SizedBox(height: 10),
            Container(
              height: 240,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: dist.isEmpty
                  ? const Center(
                      child: Text('Add tasks to see distribution',
                          style: TextStyle(color: AppColors.muted)))
                  : PieChart(
                      PieChartData(
                        sections: dist.entries.toList().asMap().entries.map((e) {
                          final colors = [
                            AppColors.primary,
                            AppColors.secondary,
                            AppColors.success,
                            AppColors.warning,
                          ];
                          final color = colors[e.key % colors.length];
                          return PieChartSectionData(
                            color: color,
                            value: e.value.value.toDouble(),
                            title:
                                '${e.value.key[0].toUpperCase()}${e.value.key.substring(1)}\n${e.value.value}',
                            radius: 80,
                            titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Trend Bar Chart
            const Text('TREND',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3)),
            const SizedBox(height: 10),
            Container(
              height: 240,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: chartData.isEmpty
                  ? const Center(
                      child: Text('No data yet',
                          style: TextStyle(color: AppColors.muted)))
                  : BarChart(
                      BarChartData(
                        barGroups: chartData
                            .asMap()
                            .entries
                            .where((e) => e.key < barLabels.length)
                            .map((e) => BarChartGroupData(
                                  x: e.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: e.value,
                                      color: AppColors.primary,
                                      width: 16,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        topRight: Radius.circular(6),
                                      ),
                                    ),
                                  ],
                                ))
                            .toList(),
                        maxY: 100,
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles:
                              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles:
                              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles:
                              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                final i = val.toInt();
                                if (i < 0 || i >= barLabels.length) {
                                  return const SizedBox();
                                }
                                return Text(barLabels[i],
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.muted));
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

class _PTab extends StatelessWidget {
  final String label;
  final String value;
  final AppProvider provider;
  const _PTab(this.label, this.value, this.provider);

  @override
  Widget build(BuildContext context) {
    final active = provider.statsPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setStatsPeriod(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            gradient: active ? AppColors.gradient : null,
            border: Border.all(
                color: active ? AppColors.primary : AppColors.border,
                width: 2),
            borderRadius: BorderRadius.circular(8),
            color: active ? null : Theme.of(context).cardColor,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: active ? Colors.white : AppColors.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
            left: BorderSide(color: AppColors.primary, width: 4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary)),
        ],
      ),
    );
  }
}
