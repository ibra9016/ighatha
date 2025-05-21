import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/components/superAdminNav.dart';

class StatisticsPage extends StatefulWidget {

  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Statistics"),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard("Requests Overview", _buildRequestsBarChart()),
            const SizedBox(height: 20),
            _buildCard("Monthly Missions", _buildMissionsPieChart(), _buildPieLegend()),
          ],
        ),
      ),
      bottomNavigationBar: SuperAdminBottomNavBar(
      currentIndex: _selectedIndex, 
      onTap: (index) {
            setState(() {
              _selectedIndex = index;
                });
          if (index == 0) {
            Navigator.pushNamed(context, '/superAdminfeed');

             } 
          else if (index == 1) {
            Navigator.pushNamed(context, '/usersDisplay');
          }
          else if (index == 3) {
            Navigator.pushNamed(context, '/superAdminProfile');
          }
  }),
    );
  }

  Widget _buildCard(String title, Widget content, [Widget? footer]) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(height: 220, child: content),
          if (footer != null) ...[
            const SizedBox(height: 12),
            footer,
          ],
        ],
      ),
    );
  }

  Widget _buildRequestsBarChart() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final incoming = [10, 12, 8, 14, 18, 16];
    final accepted = [6, 9, 7, 10, 12, 13];

    final chart = BarChart(
      BarChartData(
        barGroups: List.generate(months.length, (i) {
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: incoming[i].toDouble(),
              width: 8,
              color: Colors.blue[300],
              borderRadius: BorderRadius.circular(4),
            ),
            BarChartRodData(
              toY: accepted[i].toDouble(),
              width: 8,
              color: Colors.green[400],
              borderRadius: BorderRadius.circular(4),
            ),
          ]);
        }),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(months[value.toInt()],
                      style: const TextStyle(fontSize: 12)),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        barTouchData: BarTouchData(enabled: true),
      ),
    );

    final legend = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildLegendIndicator(Colors.blue[300]!, 'Incoming Requests'),
        const SizedBox(width: 16),
        _buildLegendIndicator(Colors.green[400]!, 'Accepted Requests'),
      ],
    );

    return Column(
      children: [
        Expanded(child: chart),
        const SizedBox(height: 10),
        legend,
      ],
    );
  }

  Widget _buildMissionsPieChart() {
    final missionData = {
      "Jan": 5,
      "Feb": 8,
      "Mar": 7,
      "Apr": 6,
      "May": 10,
      "Jun": 9,
    };

    final colors = [
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.redAccent,
      Colors.blue,
      Colors.green,
    ];

    final total = missionData.values.reduce((a, b) => a + b);

    return PieChart(
      PieChartData(
        sections: missionData.entries.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final percent = (data.value / total) * 100;

          return PieChartSectionData(
            color: colors[index],
            value: data.value.toDouble(),
            title: '${percent.toStringAsFixed(1)}%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 30,
      ),
    );
  }

  Widget _buildLegendIndicator(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildPieLegend() {
    final labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"];
    final colors = [
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.redAccent,
      Colors.blue,
      Colors.green,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 10,
      children: List.generate(labels.length, (i) {
        return _buildLegendIndicator(colors[i], labels[i]);
      }),
    );
  }
}
