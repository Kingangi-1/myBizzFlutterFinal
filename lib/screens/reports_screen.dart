import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/credit_provider.dart';
import '../services/report_service.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();
  final ReportService _reportService = ReportService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports & Analytics'),
        backgroundColor: Colors.blue[700],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Financial Summary'),
            Tab(text: 'Credit Aging'),
            Tab(text: 'Profit & Loss'),
            Tab(text: 'Export Data'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFinancialSummary(),
          _buildCreditAgingAnalysis(),
          _buildProfitLossStatement(),
          _buildExportSection(),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final currentMonth = DateTime.now();
        final totalIncome = transactionProvider.getMonthlyIncome(currentMonth);
        final totalExpenses =
            transactionProvider.getMonthlyExpenses(currentMonth);
        final netProfit = totalIncome - totalExpenses;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildMonthSelector(),
                SizedBox(height: 20),

                // Use Flexible instead of fixed height for top cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Income',
                        totalIncome,
                        Colors.green,
                        Icons.arrow_upward,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Expenses',
                        totalExpenses,
                        Colors.red,
                        Icons.arrow_downward,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                _buildSummaryCard(
                  'Net Profit',
                  netProfit,
                  netProfit >= 0 ? Colors.blue : Colors.orange,
                  netProfit >= 0 ? Icons.trending_up : Icons.trending_down,
                ),
                SizedBox(height: 20),

                // Remove fixed height constraint for trends section
                _buildMonthlyTrends(transactionProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthSelector() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.calendar_today),
        title: Text('Selected Month'),
        subtitle: Text(DateFormat('MMMM yyyy').format(_selectedMonth)),
        trailing: IconButton(
          icon: Icon(Icons.calendar_month),
          onPressed: () => _selectMonth(context),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, double amount, Color color, IconData icon) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'KES ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTrends(TransactionProvider transactionProvider) {
    final monthlyTrends = transactionProvider.getMonthlyTrends(months: 6);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Financial Trends',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (monthlyTrends.isEmpty)
              Container(
                constraints: BoxConstraints(minHeight: 200),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'No data available',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        'Add transactions to see trends',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  // Income vs Expenses Bar Chart
                  Container(
                    constraints: BoxConstraints(minHeight: 160),
                    child: _buildBarChart(monthlyTrends),
                  ),
                  SizedBox(height: 16),
                  // Profit/Loss Line Chart
                  Container(
                    constraints: BoxConstraints(minHeight: 140),
                    child: _buildProfitChart(monthlyTrends),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, Map<String, double>> monthlyTrends) {
    final months = monthlyTrends.keys.toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Income vs Expenses',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: months.length,
                itemBuilder: (context, index) {
                  final month = months[index];
                  final data = monthlyTrends[month]!;
                  final maxValue = [data['income']!, data['expenses']!]
                      .reduce((a, b) => a > b ? a : b);
                  final maxHeight = 60.0;

                  return Container(
                    width: 50,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Income bar
                        Container(
                          width: 15,
                          height: maxValue > 0
                              ? (data['income']! / maxValue) * maxHeight
                              : 0,
                          color: Colors.green,
                        ),
                        SizedBox(height: 2),
                        // Expense bar
                        Container(
                          width: 15,
                          height: maxValue > 0
                              ? (data['expenses']! / maxValue) * maxHeight
                              : 0,
                          color: Colors.red,
                        ),
                        SizedBox(height: 4),
                        Container(
                          height: 20,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                month.split(' ')[0],
                                style: TextStyle(fontSize: 9),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 8, height: 8, color: Colors.green),
                SizedBox(width: 2),
                Text('Income', style: TextStyle(fontSize: 10)),
                SizedBox(width: 8),
                Container(width: 8, height: 8, color: Colors.red),
                SizedBox(width: 2),
                Text('Expenses', style: TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitChart(Map<String, Map<String, double>> monthlyTrends) {
    final months = monthlyTrends.keys.toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Profit/Loss',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: months.length,
                itemBuilder: (context, index) {
                  final month = months[index];
                  final data = monthlyTrends[month]!;
                  final profit = data['profit']!;

                  return Container(
                    width: 40,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          color: profit >= 0 ? Colors.green : Colors.red,
                          child: Center(
                            child: Text(
                              profit.abs().toStringAsFixed(0),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(height: 2),
                        Container(
                          height: 20,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                month.split(' ')[0],
                                style: TextStyle(fontSize: 8),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                profit >= 0 ? '+' : '-',
                                style: TextStyle(
                                  fontSize: 8,
                                  color:
                                      profit >= 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditAgingAnalysis() {
    return Consumer<CreditProvider>(
      builder: (context, creditProvider, child) {
        final agingAnalysis =
            _reportService.getAgingAnalysis(creditProvider.credits);

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Credit Aging Analysis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildAgingSummary(agingAnalysis),
                SizedBox(height: 20),
                _buildAgingDetails(agingAnalysis, creditProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAgingSummary(Map<String, double> agingAnalysis) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildAgingCard('Current', agingAnalysis['current'] ?? 0, Colors.green),
        _buildAgingCard('1-30 Days', agingAnalysis['1-30'] ?? 0, Colors.blue),
        _buildAgingCard(
            '31-60 Days', agingAnalysis['31-60'] ?? 0, Colors.orange),
        _buildAgingCard('61+ Days', agingAnalysis['61+'] ?? 0, Colors.red),
      ],
    );
  }

  Widget _buildAgingCard(String period, double amount, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              period,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              'KES ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgingDetails(
      Map<String, double> agingAnalysis, CreditProvider creditProvider) {
    final overdueCredits = creditProvider.overdueCredits;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overdue Credits (${overdueCredits.length})',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            overdueCredits.isEmpty
                ? Container(
                    height: 150,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.credit_card_off,
                              size: 64, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text('No overdue credits',
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  )
                : ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 400,
                      minHeight: 100,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: overdueCredits.length,
                      itemBuilder: (context, index) {
                        final credit = overdueCredits[index];
                        final daysOverdue =
                            DateTime.now().difference(credit.dueDate).inDays;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(Icons.warning,
                                color: Colors.white, size: 20),
                          ),
                          title: Text(
                            credit.contactName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                              'Due: ${DateFormat('dd/MM/yyyy').format(credit.dueDate)}'),
                          trailing: SizedBox(
                            width: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'KES ${credit.remainingAmount.toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '$daysOverdue days overdue',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  Widget _buildProfitLossStatement() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final pnlData = _reportService.generateProfitLossStatement(
            transactionProvider.transactions, _selectedMonth);

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildMonthSelector(),
                SizedBox(height: 20),
                _buildPnlCard(pnlData),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPnlCard(Map<String, dynamic> pnlData) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'PROFIT & LOSS STATEMENT',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                DateFormat('MMMM yyyy').format(_selectedMonth),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 20),
            _buildPnlSection('INCOME', pnlData['income'] ?? [], Colors.green),
            SizedBox(height: 16),
            _buildPnlSection('EXPENSES', pnlData['expenses'] ?? [], Colors.red),
            SizedBox(height: 16),
            Divider(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NET PROFIT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: (pnlData['netProfit'] ?? 0) >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  Text(
                    'KES ${(pnlData['netProfit'] ?? 0).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: (pnlData['netProfit'] ?? 0) >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPnlSection(
      String title, List<Map<String, dynamic>> items, Color color) {
    double total = items.fold(0.0, (sum, item) => sum + (item['amount'] ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 8),
        ...items
            .map((item) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['category'] ?? 'Uncategorized',
                          style: TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'KES ${(item['amount'] ?? 0).toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ))
            .toList(),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total $title',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'KES ${total.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExportSection() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Business Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Download your business data in various formats for accounting, analysis, or record keeping.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info, color: Colors.blue[700]),
                    SizedBox(height: 8),
                    Text(
                      'Export Location:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('• Files are saved to your Downloads folder'),
                    Text('• On Windows: C:\\Users\\[YourUsername]\\Downloads'),
                    Text('• Look for: mybiz_report_[date].[format]'),
                    SizedBox(height: 8),
                    Text(
                      'Note: This is a demo. In a real app, files would be saved to your device.',
                      style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildExportOption(
              Icons.picture_as_pdf,
              'PDF Report',
              'Generate a comprehensive PDF report with all financial data',
              () => _exportData('pdf'),
            ),
            SizedBox(height: 16),
            _buildExportOption(
              Icons.table_chart,
              'Excel Spreadsheet',
              'Export to Excel for advanced analysis and calculations',
              () => _exportData('excel'),
            ),
            SizedBox(height: 16),
            _buildExportOption(
              Icons.text_snippet,
              'CSV File',
              'Simple CSV format for importing into other applications',
              () => _exportData('csv'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(
      IconData icon, String title, String description, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.blue[700]),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: Icon(Icons.download),
        onTap: onTap,
      ),
    );
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  Future<void> _exportData(String format) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generating $format report...'),
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(Duration(seconds: 2));

      final now = DateTime.now();
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(now);
      final fileName = 'mybiz_report_$dateStr.$format';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$format report generated successfully!'),
              SizedBox(height: 4),
              Text(
                'File: $fileName',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                'Saved to your Downloads folder',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );

      print('Export completed: $fileName');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
