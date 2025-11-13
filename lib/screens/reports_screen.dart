import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'weekly'; // 'daily', 'weekly', 'monthly'
  String _selectedChart = 'profit'; // 'profit', 'income', 'expenses'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports & Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          final transactions = transactionProvider.transactions;
          final totalIncome = _calculateTotalIncome(transactions);
          final totalExpenses = _calculateTotalExpenses(transactions);
          final netProfit = totalIncome - totalExpenses;

          // Generate data based on selected period
          final chartData = _generateChartData(transactions, _selectedPeriod);
          final expenseData = _generateExpenseData(transactions);
          final incomeSources = _generateIncomeSources(transactions);

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Toggle - Daily, Weekly, Monthly
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PeriodToggle(
                        label: 'Daily',
                        isSelected: _selectedPeriod == 'daily',
                        onTap: () => setState(() => _selectedPeriod = 'daily'),
                      ),
                      _PeriodToggle(
                        label: 'Weekly',
                        isSelected: _selectedPeriod == 'weekly',
                        onTap: () => setState(() => _selectedPeriod = 'weekly'),
                      ),
                      _PeriodToggle(
                        label: 'Monthly',
                        isSelected: _selectedPeriod == 'monthly',
                        onTap: () =>
                            setState(() => _selectedPeriod = 'monthly'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Chart Type Selector
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _ChartTypeToggle(
                          label: 'Profit',
                          isSelected: _selectedChart == 'profit',
                          onTap: () =>
                              setState(() => _selectedChart = 'profit'),
                        ),
                        _ChartTypeToggle(
                          label: 'Income',
                          isSelected: _selectedChart == 'income',
                          onTap: () =>
                              setState(() => _selectedChart = 'income'),
                        ),
                        _ChartTypeToggle(
                          label: 'Expenses',
                          isSelected: _selectedChart == 'expenses',
                          onTap: () =>
                              setState(() => _selectedChart = 'expenses'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Summary Cards
                _buildSummaryCards(
                    totalIncome, totalExpenses, netProfit, transactions.length),
                SizedBox(height: 24),

                // Selected Chart
                Text(
                  _getChartTitle(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                // Main Chart
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildMainChart(chartData),
                  ),
                ),
                SizedBox(height: 24),

                // Income vs Expenses Comparison
                Text(
                  'Income vs Expenses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildIncomeExpenseComparison(
                        totalIncome, totalExpenses),
                  ),
                ),
                SizedBox(height: 24),

                // Expense Breakdown
                Text(
                  'Expense Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                // Expense List
                _buildExpenseBreakdown(expenseData),
                SizedBox(height: 24),

                // Income Sources
                Text(
                  'Income Sources',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                // Income Sources List
                _buildIncomeSources(incomeSources),
              ],
            ),
          );
        },
      ),
    );
  }

  // Summary Cards
  Widget _buildSummaryCards(double totalIncome, double totalExpenses,
      double netProfit, int transactionCount) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Net Profit',
                amount: netProfit,
                color: netProfit >= 0 ? Colors.green : Colors.red,
                icon: netProfit >= 0 ? Icons.trending_up : Icons.trending_down,
                subtitle: netProfit >= 0 ? 'Profit' : 'Loss',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Total Income',
                amount: totalIncome,
                color: Colors.green,
                icon: Icons.arrow_upward,
                subtitle: 'Revenue',
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Total Expenses',
                amount: totalExpenses,
                color: Colors.red,
                icon: Icons.arrow_downward,
                subtitle: 'Costs',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Transactions',
                amount: transactionCount.toDouble(),
                color: Colors.blue,
                icon: Icons.receipt,
                subtitle: 'Total',
                isCount: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Main Chart Builder - FIXED LABEL OVERLAPPING
  Widget _buildMainChart(List<ChartData> chartData) {
    if (chartData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
            SizedBox(height: 8),
            Text(
              'No data available',
              style: TextStyle(color: Colors.grey[500]),
            ),
            Text(
              'Add transactions to see charts',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      );
    }

    // Calculate max Y value with a minimum of 100 to prevent chart rendering issues
    final maxYValue = chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final maxY = maxYValue > 0 ? maxYValue * 1.2 : 100.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${chartData[groupIndex].x}\n',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: 'KES ${rod.toY.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < chartData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      chartData[index].x,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }
                return Text('');
              },
              reservedSize: 30, // Increased reserved space for labels
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text(
                    'KES ${value.toInt()}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey[200],
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: chartData
            .asMap()
            .map((index, data) => MapEntry(
                  index,
                  BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data.y,
                        color: _getChartColor(),
                        width: 20, // Slightly wider for better touch
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ))
            .values
            .toList(),
      ),
    );
  }

  // Income vs Expenses Comparison
  Widget _buildIncomeExpenseComparison(double income, double expenses) {
    final total = income + expenses;
    final incomePercent = total > 0 ? (income / total) * 100 : 50;
    final expensePercent = total > 0 ? (expenses / total) * 100 : 50;

    return Column(
      children: [
        // Percentage Bars
        Row(
          children: [
            Expanded(
              flex: incomePercent.round(),
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${incomePercent.round()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: expensePercent.round(),
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${expensePercent.round()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Income',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'KES ${income.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Expenses',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'KES ${expenses.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Expense Breakdown
  Widget _buildExpenseBreakdown(List<ChartData> expenseData) {
    if (expenseData.isEmpty) {
      return _buildEmptyState('No expense data available');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: expenseData
            .map((expense) => ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.money_off, color: Colors.red, size: 20),
                  ),
                  title: Text(
                    expense.x,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: Text(
                    'KES ${expense.y.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  // Income Sources
  Widget _buildIncomeSources(List<ChartData> incomeSources) {
    if (incomeSources.isEmpty) {
      return _buildEmptyState('No income data available');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: incomeSources
            .map((income) => ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Icon(Icons.attach_money, color: Colors.green, size: 20),
                  ),
                  title: Text(
                    income.x,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: Text(
                    'KES ${income.y.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }

  Color _getChartColor() {
    switch (_selectedChart) {
      case 'profit':
        return AppConstants.primaryColor;
      case 'income':
        return Colors.green;
      case 'expenses':
        return Colors.red;
      default:
        return AppConstants.primaryColor;
    }
  }

  String _getChartTitle() {
    switch (_selectedChart) {
      case 'profit':
        return '${_selectedPeriod.capitalize()} Profit Trend';
      case 'income':
        return '${_selectedPeriod.capitalize()} Income Trend';
      case 'expenses':
        return '${_selectedPeriod.capitalize()} Expense Trend';
      default:
        return 'Business Analytics';
    }
  }

  // FIXED: Data Generation Methods - Now uses real transaction data
  List<ChartData> _generateChartData(
      List<BusinessTransaction> transactions, String period) {
    final now = DateTime.now();

    switch (period) {
      case 'daily':
        return _generateDailyData(transactions, now);
      case 'weekly':
        return _generateWeeklyData(transactions, now);
      case 'monthly':
        return _generateMonthlyData(transactions, now);
      default:
        return [];
    }
  }

  List<ChartData> _generateDailyData(
      List<BusinessTransaction> transactions, DateTime now) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dailyData = List<double>.filled(7, 0.0);

    // Get the start of the current week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    for (var i = 0; i < 7; i++) {
      final currentDay = startOfWeek.add(Duration(days: i));
      final dayTransactions = transactions.where((t) {
        final transactionDate = DateTime(t.date.year, t.date.month, t.date.day);
        final compareDate =
            DateTime(currentDay.year, currentDay.month, currentDay.day);
        return transactionDate == compareDate;
      }).toList();

      switch (_selectedChart) {
        case 'profit':
          final income = dayTransactions
              .where((t) => Helpers.isIncomeType(t.type))
              .fold(0.0, (sum, t) => sum + t.amount);
          final expenses = dayTransactions
              .where((t) => Helpers.isExpenseType(t.type))
              .fold(0.0, (sum, t) => sum + t.amount);
          dailyData[i] = income - expenses;
          break;
        case 'income':
          dailyData[i] = dayTransactions
              .where((t) => Helpers.isIncomeType(t.type))
              .fold(0.0, (sum, t) => sum + t.amount);
          break;
        case 'expenses':
          dailyData[i] = dayTransactions
              .where((t) => Helpers.isExpenseType(t.type))
              .fold(0.0, (sum, t) => sum + t.amount);
          break;
      }
    }

    return List.generate(
        7, (index) => ChartData(days[index], dailyData[index]));
  }

  List<ChartData> _generateWeeklyData(
      List<BusinessTransaction> transactions, DateTime now) {
    final weeklyData = List<double>.filled(4, 0.0);
    final weekLabels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];

    for (var week = 0; week < 4; week++) {
      final weekStart = DateTime(now.year, now.month, 1 + (week * 7));
      final weekEnd = week == 3
          ? DateTime(now.year, now.month + 1, 0) // Last day of month
          : DateTime(now.year, now.month, 1 + ((week + 1) * 7) - 1);

      final weekTransactions = transactions.where((t) {
        return t.date.isAfter(weekStart.subtract(Duration(days: 1))) &&
            t.date.isBefore(weekEnd.add(Duration(days: 1)));
      }).toList();

      switch (_selectedChart) {
        case 'profit':
          final income = weekTransactions
              .where((t) => Helpers.isIncomeType(t.type))
              .fold(0.0, (sum, t) => sum + t.amount);
          final expenses = weekTransactions
              .where((t) => Helpers.isExpenseType(t.type))
              .fold(0.0, (sum, t) => sum + t.amount);
          weeklyData[week] = income - expenses;
          break;
        case 'income':
          weeklyData[week] = weekTransactions
              .where((t) => Helpers.isIncomeType(t.type))
              .fold(0.0, (sum, t) => sum + t.amount);
          break;
        case 'expenses':
          weeklyData[week] = weekTransactions
              .where((t) => Helpers.isExpenseType(t.type))
              .fold(0.0, (sum, t) => sum + t.amount);
          break;
      }
    }

    return List.generate(
        4, (index) => ChartData(weekLabels[index], weeklyData[index]));
  }

  List<ChartData> _generateMonthlyData(
      List<BusinessTransaction> transactions, DateTime now) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final monthlyData = List<double>.filled(6, 0.0);
    final monthLabels = <String>[];

    // Get last 6 months including current month
    for (var i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      monthLabels.add(months[monthDate.month - 1]);

      final monthStart = DateTime(monthDate.year, monthDate.month, 1);
      final monthEnd = DateTime(monthDate.year, monthDate.month + 1, 0);

      final monthTransactions = transactions.where((t) {
        return t.date.isAfter(monthStart.subtract(Duration(days: 1))) &&
            t.date.isBefore(monthEnd.add(Duration(days: 1)));
      }).toList();

      switch (_selectedChart) {
        case 'profit':
          final income = monthTransactions
              .where((t) => Helpers.isIncomeType(t.type))
              .fold(0.0, (sum, t) => sum + t.amount);
          final expenses = monthTransactions
              .where((t) => Helpers.isExpenseType(t.type))
              .fold(0.0, (sum, t) => sum + t.amount);
          monthlyData[5 - i] = income - expenses;
          break;
        case 'income':
          monthlyData[5 - i] = monthTransactions
              .where((t) => Helpers.isIncomeType(t.type))
              .fold(0.0, (sum, t) => sum + t.amount);
          break;
        case 'expenses':
          monthlyData[5 - i] = monthTransactions
              .where((t) => Helpers.isExpenseType(t.type))
              .fold(0.0, (sum, t) => sum + t.amount);
          break;
      }
    }

    return List.generate(
        6, (index) => ChartData(monthLabels[index], monthlyData[index]));
  }

  List<ChartData> _generateExpenseData(List<BusinessTransaction> transactions) {
    final expenseTransactions =
        transactions.where((t) => Helpers.isExpenseType(t.type)).toList();

    if (expenseTransactions.isEmpty) {
      return [];
    }

    // Group by category - FIXED: Handle nullable category
    final categoryTotals = <String, double>{};

    for (final transaction in expenseTransactions) {
      final category = transaction.category ?? 'Uncategorized';
      categoryTotals.update(category, (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount);
    }

    // Convert to ChartData and sort by amount (descending)
    return categoryTotals.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList()
      ..sort((a, b) => b.y.compareTo(a.y));
  }

  List<ChartData> _generateIncomeSources(
      List<BusinessTransaction> transactions) {
    final incomeTransactions =
        transactions.where((t) => Helpers.isIncomeType(t.type)).toList();

    if (incomeTransactions.isEmpty) {
      return [];
    }

    // Group by category - FIXED: Handle nullable category
    final categoryTotals = <String, double>{};

    for (final transaction in incomeTransactions) {
      final category = transaction.category ?? 'Uncategorized';
      categoryTotals.update(category, (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount);
    }

    // Convert to ChartData and sort by amount (descending)
    return categoryTotals.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList()
      ..sort((a, b) => b.y.compareTo(a.y));
  }

  double _calculateTotalIncome(List<BusinessTransaction> transactions) {
    return transactions
        .where((t) => Helpers.isIncomeType(t.type))
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double _calculateTotalExpenses(List<BusinessTransaction> transactions) {
    return transactions
        .where((t) => Helpers.isExpenseType(t.type))
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }
}

// Chart Data Model
class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}

class _PeriodToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodToggle({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ChartTypeToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChartTypeToggle({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  final String subtitle;
  final bool isCount;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    required this.subtitle,
    this.isCount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            isCount
                ? amount.toInt().toString()
                : 'KES ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
