import 'package:bafna_track/models/flat_model.dart';
import 'package:bafna_track/screens/about_us_screen.dart';
import 'package:bafna_track/screens/admin_panel_screen.dart';
import 'package:bafna_track/screens/archives_screen.dart';
import 'package:bafna_track/screens/plan_screen.dart';
import 'package:bafna_track/screens/quotation_screen.dart';
import 'package:bafna_track/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  String _selectedStatusFilter = 'All';
  late Future<List<dynamic>> _dataFuture;
  static const Color primaryColor = Color(0xff121212);
  static const Color accentColor = Colors.amberAccent;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
  }

  Future<List<dynamic>> _fetchData() async {
    final results = await Future.wait([
      supabase.from('projects').select('name').eq('is_archived', false),
      supabase.from('flats').select()
    ]);
    final names = (results[0] as List).map((item) => item['name'] as String).toList();
    final flats = (results[1] as List).map((json) => Flat.fromJson(json)).toList();
    if (mounted) {
      _tabController?.dispose();
      setState(() {
        _tabController = TabController(length: names.length, vsync: this);
      });
    }
    return [names, flats];
  }

  void _refreshData() {
    setState(() {
      _dataFuture = _fetchData();
    });
  }

  String _formatPrice(double? price) {
    if (price == null) return 'Price on Request';
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('BafnaTrack', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 10,
        shadowColor: Colors.black.withAlpha(128),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: FutureBuilder<List<dynamic>>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final projectNames = snapshot.data![0] as List<String>;
                return TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  tabs: projectNames.map((name) => Tab(text: name)).toList(),
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.poppins(),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[400],
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(width: 3.0, color: accentColor),
                  ),
                  onTap: (_) => setState(() => _selectedStatusFilter = 'All'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      drawer: _buildAppDrawer(),
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null || (snapshot.data![0] as List).isEmpty) {
            return const Center(child: Text('No projects found. Please add a project first.'));
          }
          final projectNames = snapshot.data![0] as List<String>;
          final allFlats = snapshot.data![1] as List<Flat>;
          final availableFlats = allFlats.where((f) => f.status == 'Available').length;
          final bookedFlats = allFlats.where((f) => f.status == 'Booked').length;
          final soldFlats = allFlats.where((f) => f.status == 'Sold').length;
          if (_tabController == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    _buildSummaryCard('Available', availableFlats, Colors.green),
                    const SizedBox(width: 12),
                    _buildSummaryCard('Booked', bookedFlats, Colors.orange),
                    const SizedBox(width: 12),
                    _buildSummaryCard('Sold', soldFlats, Colors.red),
                  ],
                ),
              ),
              _buildStatusFilters(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: projectNames.map((projectName) {
                    final projectFlats = allFlats.where((flat) => flat.projectId == projectName).toList();
                    if (projectFlats.isEmpty) return _buildEmptyProjectView();
                    final filteredFlats = _selectedStatusFilter == 'All'
                        ? projectFlats
                        : projectFlats.where((flat) => flat.status == _selectedStatusFilter).toList();
                    if (filteredFlats.isEmpty) return _buildEmptyFilterView();
                    return AnimationLimiter(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: filteredFlats.length,
                        itemBuilder: (context, index) {
                          return AnimationConfiguration.staggeredGrid(
                            position: index,
                            duration: const Duration(milliseconds: 500),
                            columnCount: 2,
                            child: ScaleAnimation(
                              child: FadeInAnimation(
                                child: _buildFlatCard(context, filteredFlats[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, int count, MaterialColor color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.shade400, color.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(102),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 8),
            Text(count.toString(), style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('BafnaTrack Menu', style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Navigate Your Options', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          _buildDrawerItem(context, 'Home', Icons.home, () {}),
          _buildDrawerItem(context, 'Admin Panel', Icons.admin_panel_settings, () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPanelScreen()));
            _refreshData();
          }),
          _buildDrawerItem(context, 'Quotation', Icons.request_quote_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QuotationScreen()))),
          _buildDrawerItem(context, 'Plans', Icons.map_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PlanScreen()))),
          _buildDrawerItem(context, 'Archives', Icons.archive, () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => const ArchivesScreen()));
            _refreshData();
          }),
          const Divider(),
          _buildDrawerItem(context, 'Settings', Icons.settings, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()))),
          _buildDrawerItem(context, 'About Us', Icons.info_outline, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsScreen()))),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title, style: GoogleFonts.poppins(color: Colors.black87)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Widget _buildFlatCard(BuildContext context, Flat flat) {
    Color statusColor;
    Color statusLightColor;
    switch (flat.status?.toLowerCase()) {
      case 'available':
        statusColor = Colors.green.shade800;
        statusLightColor = Colors.green.shade200;
        break;
      case 'booked':
        statusColor = Colors.orange.shade800;
        statusLightColor = Colors.orange.shade200;
        break;
      case 'sold':
        statusColor = Colors.red.shade800;
        statusLightColor = Colors.red.shade200;
        break;
      default:
        statusColor = Colors.grey.shade800;
        statusLightColor = Colors.grey.shade300;
    }
    return Hero(
      tag: 'flat_card_${flat.id}',
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.pushNamed(context, '/flatDetail', arguments: flat);
          if (result == true) {
            _refreshData();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [statusLightColor, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.8],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.grey.withAlpha(51), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(50)),
                  child: Text(
                      (flat.status ?? 'N/A').toUpperCase(),
                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)
                  ),
                ),
                const Spacer(),
                Center(
                  child: Column(
                    children: [
                      Text(
                          flat.flatNo,
                          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)
                      ),
                      const SizedBox(height: 4),
                      Text(
                          _formatPrice(flat.price),
                          style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600, color: statusColor)
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(Icons.area_chart_outlined, '${flat.area?.toInt() ?? 0} sq.ft'),
                    ),
                    Expanded(
                      child: _buildDetailItem(Icons.explore_outlined, flat.facing ?? 'N/A', alignment: MainAxisAlignment.end),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text, {MainAxisAlignment alignment = MainAxisAlignment.start}) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 16),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilters() {
    const Map<String, Color> statusColors = {'All': Color(0xff121212), 'Available': Color(0xff2E7D32), 'Booked': Color(0xffEF6C00), 'Sold': Color(0xffC62828)};
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: statusColors.keys.map((status) {
          bool isSelected = _selectedStatusFilter == status;
          Color color = statusColors[status]!;
          return ChoiceChip(
            label: Text(status),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedStatusFilter = status);
              }
            },
            labelStyle: GoogleFonts.poppins(color: isSelected ? Colors.white : color, fontWeight: FontWeight.w600),
            selectedColor: color,
            backgroundColor: Colors.white,
            shape: StadiumBorder(side: BorderSide(color: color, width: 1.5)),
            elevation: isSelected ? 2 : 0,
            pressElevation: 8,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyProjectView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.domain_disabled_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No flats listed in this project.', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No flats match the filter "$_selectedStatusFilter"',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}