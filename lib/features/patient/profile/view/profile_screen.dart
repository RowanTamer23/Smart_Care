import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/features/auth/cubit/auth_cubit.dart';
import 'package:smart_care/features/auth/cubit/auth_state.dart';

class C {
  static const bg = Color(0xFFF4F6FB);
  static const surface = Color(0xFFFFFFFF);
  static const primary = Color(0xFF16302B);
  static const primaryMid = Color(0xFF1F4035);
  static const teal = Color(0xFF0F9B8E);
  static const tealLight = Color(0xFFCCF5F2);
  static const amber = Color(0xFFF5A623);
  static const amberLight = Color(0xFFFFF3DC);
  static const red = Color(0xFFDC3545);
  static const redLight = Color(0xFFFFEBED);
  static const green = Color(0xFF1A9E6A);
  static const greenLight = Color(0xFFD6F5E8);
  static const blue = Color(0xFF2563EB);
  static const blueLight = Color(0xFFDCEBFE);
  static const purple = Color(0xFF7C3AED);
  static const purpleLight = Color(0xFFEDE9FE);
  static const orange = Color(0xFFEA580C);
  static const orangeLight = Color(0xFFFFEDD5);
  static const border = Color(0xFFE4E8F0);
  static const txt1 = Color(0xFF0D1B2A);
  static const txt2 = Color(0xFF536070);
  static const txt3 = Color(0xFF9BAAB8);
}

TextStyle _h(double s, {Color? c, FontWeight? w, double? ls}) => TextStyle(
      fontSize: s,
      fontWeight: w ?? FontWeight.w700,
      color: c ?? C.txt1,
      letterSpacing: ls ?? -0.3,
      height: 1.2,
    );
TextStyle _b(double s, {Color? c, FontWeight? w}) => TextStyle(
      fontSize: s,
      fontWeight: w ?? FontWeight.w400,
      color: c ?? C.txt1,
      height: 1.5,
    );
TextStyle _lbl({Color? c, double s = 11, FontWeight? w}) => TextStyle(
      fontSize: s,
      fontWeight: w ?? FontWeight.w600,
      color: c ?? C.txt3,
      letterSpacing: 0.5,
    );

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});
  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen>
    with TickerProviderStateMixin {
  late final TabController _historyTab;
  int _reminderToggle = 0;
  final Map<String, bool> _medicineActive = {
    'Metformin 500mg': true,
    'Lisinopril 10mg': true,
    'Atorvastatin 20mg': false,
  };

  @override
  void initState() {
    super.initState();
    _historyTab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _historyTab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogoutCubit, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
        backgroundColor: C.bg,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildPatientCard(),
                    const SizedBox(height: 20),
                    // _buildHealthStats(),
                    // const SizedBox(height: 20),
                    _buildMedicineReminders(),
                    const SizedBox(height: 20),
                    _buildAllergiesAlerts(),
                    const SizedBox(height: 20),
                    _buildMedicalHistory(),
                    const SizedBox(height: 20),
                    // _buildVaccinations(),
                    // const SizedBox(height: 24),
                    _buildLabResults(),
                    const SizedBox(height: 20),
                    // _buildEmergencyContacts(),
                    // const SizedBox(height: 24),
                    _buildInsuranceCard(),
                    const SizedBox(height: 20),
                    // _buildUpcomingAppointments(),
                    // const SizedBox(height: 24),
                    // _buildDietAndLifestyle(),
                    // const SizedBox(height: 24),
                    _buildDocuments(),
                    const SizedBox(height: 20),
                    _buildDangerZone(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SLIVER APP BAR ───────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 150,
      pinned: true,
      backgroundColor: C.primary,
      leading: const SizedBox(),
      title: Row(
        children: [
          SizedBox(
            width: 50,
          ),
          Text('Rowan Tamer', style: _h(20, c: Colors.white)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.ios_share_outlined,
              color: Colors.white70, size: 20),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.edit_rounded, color: Colors.white70, size: 20),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // gradient bg
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF16302B), Color(0xFF0A4040)],
                ),
              ),
            ),
            // decorative circles
            Positioned(
                right: -40,
                top: -40,
                child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04)))),
            Positioned(
                left: -20,
                bottom: -20,
                child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: C.teal.withOpacity(0.12)))),
            // content
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 80, 18, 16),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [C.teal, Color(0xFF0A6B62)],
                          ),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 3),
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: Colors.white, size: 44),
                      ),
                      Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                  color: C.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2)),
                              child: const Icon(Icons.check,
                                  color: Colors.white, size: 11))),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(children: [
                          _Pill('Female', C.teal, C.tealLight.withOpacity(0.2)),
                          const SizedBox(width: 6),
                          _Pill(
                              '25 yrs', C.amber, C.amberLight.withOpacity(0.2)),
                          const SizedBox(width: 6),
                          _Pill('A+', C.red, C.redLight.withOpacity(0.2)),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.badge_outlined,
                              size: 13, color: Colors.white54),
                          const SizedBox(width: 5),
                          Text('ID: #CP-2024-8821',
                              style: _lbl(c: Colors.white54, s: 12)),
                        ]),
                      ],
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

  // ── PATIENT QUICK CARD ───────────────────────
  Widget _buildPatientCard() {
    return _Card(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuickInfo(Icons.cake_rounded, 'Date of Birth', 'Mar 14, 1990'),
              _Divider(),
              _QuickInfo(Icons.straighten_rounded, 'Height', '5\'11"  178cm'),
              _Divider(),
              _QuickInfo(Icons.monitor_weight_rounded, 'Weight', '78 kg'),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: C.border, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuickInfo(Icons.water_drop_rounded, 'Blood Type', 'A Positive'),
              _Divider(),
              _QuickInfo(Icons.fitness_center_rounded, 'BMI', '24.6 Normal'),
              _Divider(),
              _QuickInfo(Icons.smoke_free_rounded, 'Smoker', 'Non-smoker'),
            ],
          ),
        ],
      ),
    );
  }

  // ── HEALTH STATS ─────────────────────────────
  Widget _buildHealthStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Health Vitals',
            icon: Icons.monitor_heart_rounded, color: C.red),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: const [
            _VitalCard(
                icon: Icons.favorite_rounded,
                label: 'Blood Pressure',
                value: '120/80',
                unit: 'mmHg',
                trend: '+2%',
                trendUp: true,
                color: C.blue,
                bg: C.blueLight),
            _VitalCard(
                icon: Icons.monitor_heart_outlined,
                label: 'Heart Rate',
                value: '72',
                unit: 'bpm',
                trend: 'Normal',
                trendUp: true,
                color: C.green,
                bg: C.greenLight),
            _VitalCard(
                icon: Icons.thermostat_rounded,
                label: 'Temperature',
                value: '98.6',
                unit: '°F',
                trend: 'Normal',
                trendUp: true,
                color: C.orange,
                bg: C.orangeLight),
            _VitalCard(
                icon: Icons.air_rounded,
                label: 'Oxygen Sat.',
                value: '98',
                unit: '%',
                trend: '-1%',
                trendUp: false,
                color: C.teal,
                bg: C.tealLight),
          ],
        ),
      ],
    );
  }

  // ── MEDICINE REMINDERS ────────────────────────
  Widget _buildMedicineReminders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Medicine Reminders',
            icon: Icons.medication_rounded,
            color: C.amber,
            action: 'Add New',
            onAction: () {}),
        const SizedBox(height: 12),
        // Today's schedule strip
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF16302B), Color(0xFF1A4A40)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Today's Doses", style: _h(14, c: Colors.white)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: C.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 12, color: C.green),
                      const SizedBox(width: 4),
                      Text('2/4 taken', style: _lbl(c: C.green, s: 11)),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _DoseTimePill('08:00 AM', 'Taken', true),
                    _DoseTimePill('12:00 PM', 'Taken', true),
                    _DoseTimePill('06:00 PM', 'Pending', false),
                    _DoseTimePill('10:00 PM', 'Pending', false),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Medicine cards
        ...['Metformin 500mg', 'Lisinopril 10mg', 'Atorvastatin 20mg']
            .map((med) => _MedicineCard(
                  name: med,
                  data: _medData[med]!,
                  active: _medicineActive[med] ?? false,
                  onToggle: (v) => setState(() => _medicineActive[med] = v),
                )),
      ],
    );
  }

  static const _medData = {
    'Metformin 500mg': (
      dose: '1 tablet',
      freq: 'Twice daily',
      icon: Icons.circle_rounded,
      color: C.blue,
      bg: C.blueLight,
      desc: 'Type 2 Diabetes management',
      refill: '12 days left',
      times: '08:00 AM & 06:00 PM',
    ),
    'Lisinopril 10mg': (
      dose: '1 tablet',
      freq: 'Once daily',
      icon: Icons.favorite_rounded,
      color: C.red,
      bg: C.redLight,
      desc: 'Blood pressure control',
      refill: '24 days left',
      times: '08:00 AM',
    ),
    'Atorvastatin 20mg': (
      dose: '1 tablet',
      freq: 'Once nightly',
      icon: Icons.water_drop_rounded,
      color: C.purple,
      bg: C.purpleLight,
      desc: 'Cholesterol management',
      refill: '7 days left',
      times: '10:00 PM',
    ),
  };

  // ── ALLERGIES & ALERTS ───────────────────────
  Widget _buildAllergiesAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Allergies & Alerts',
            icon: Icons.warning_amber_rounded, color: C.red),
        const SizedBox(height: 12),
        _Card(
          padding: 0,
          child: Column(
            children: [
              _AllergyRow('Penicillin', 'Severe anaphylaxis', C.red, C.redLight,
                  Icons.emergency_rounded),
              const Divider(
                  height: 1, color: C.border, indent: 16, endIndent: 16),
              _AllergyRow('Aspirin', 'Moderate — hives', C.orange,
                  C.orangeLight, Icons.warning_rounded),
              const Divider(
                  height: 1, color: C.border, indent: 16, endIndent: 16),
              _AllergyRow('Shellfish', 'Mild — nausea', C.amber, C.amberLight,
                  Icons.info_rounded),
            ],
          ),
        ),
      ],
    );
  }

  // ── MEDICAL HISTORY ───────────────────────────
  Widget _buildMedicalHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Medical History',
            icon: Icons.history_edu_rounded, color: C.teal),
        const SizedBox(height: 12),
        _Card(
          child: Column(
            children: [
              TabBar(
                controller: _historyTab,
                labelColor: C.primary,
                unselectedLabelColor: C.txt3,
                indicatorColor: C.teal,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: C.border,
                labelStyle: _b(13, w: FontWeight.w700),
                unselectedLabelStyle: _b(13),
                tabs: const [
                  Tab(text: 'Conditions'),
                  Tab(text: 'Surgeries'),
                  Tab(text: 'Family'),
                ],
              ),
              SizedBox(
                height: 200,
                child: TabBarView(
                  controller: _historyTab,
                  children: [
                    _buildConditions(),
                    _buildSurgeries(),
                    _buildFamilyHistory(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConditions() {
    final items = [
      ('Type 2 Diabetes', '2019', C.blue, 'Managed with medication'),
      ('Hypertension', '2021', C.red, 'Under control'),
      ('Mild Asthma', '2015', C.teal, 'Infrequent episodes'),
    ];
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: items.map((e) => _HistoryItem(e.$1, e.$2, e.$3, e.$4)).toList(),
    );
  }

  Widget _buildSurgeries() {
    final items = [
      ('Appendectomy', '2012', C.orange, 'Fully recovered'),
      ('Knee Arthroscopy', '2018', C.purple, 'Right knee — healed'),
    ];
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: items.map((e) => _HistoryItem(e.$1, e.$2, e.$3, e.$4)).toList(),
    );
  }

  Widget _buildFamilyHistory() {
    final items = [
      ('Father — Heart Disease', 'Paternal', C.red, 'Diagnosed at 58'),
      ('Mother — Type 2 Diabetes', 'Maternal', C.blue, 'Managed with insulin'),
      ('Grandfather — Hypertension', 'Paternal', C.orange, 'Stroke history'),
    ];
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: items.map((e) => _HistoryItem(e.$1, e.$2, e.$3, e.$4)).toList(),
    );
  }

  // ── VACCINATIONS ─────────────────────────────
  // Widget _buildVaccinations() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _SectionHeader('Vaccinations',
  //           icon: Icons.vaccines_rounded, color: C.green),
  //       const SizedBox(height: 12),
  //       _Card(
  //         padding: 0,
  //         child: Column(
  //           children: [
  //             _VaccineRow(
  //                 'COVID-19 (Booster)', 'Sep 2023', true, 'Pfizer-BioNTech'),
  //             const Divider(
  //                 height: 1, color: C.border, indent: 16, endIndent: 16),
  //             _VaccineRow('Influenza', 'Oct 2023', true, 'Seasonal flu shot'),
  //             const Divider(
  //                 height: 1, color: C.border, indent: 16, endIndent: 16),
  //             _VaccineRow('Hepatitis B', 'Mar 2021', true, '3-dose series'),
  //             const Divider(
  //                 height: 1, color: C.border, indent: 16, endIndent: 16),
  //             _VaccineRow(
  //                 'Tetanus (Td)', 'Jun 2019', false, 'Due for booster 2029'),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // ── LAB RESULTS ──────────────────────────────
  Widget _buildLabResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Recent Lab Results',
            icon: Icons.science_rounded,
            color: C.purple,
            action: 'View All',
            onAction: () {}),
        const SizedBox(height: 12),
        _Card(
          padding: 0,
          child: Column(
            children: [
              _LabRow('HbA1c', '6.8%', '< 7.0%', _LabStatus.normal),
              const Divider(
                  height: 1, color: C.border, indent: 16, endIndent: 16),
              _LabRow('LDL Cholesterol', '128 mg/dL', '< 100 mg/dL',
                  _LabStatus.borderline),
              const Divider(
                  height: 1, color: C.border, indent: 16, endIndent: 16),
              _LabRow('Creatinine', '1.1 mg/dL', '0.7–1.3 mg/dL',
                  _LabStatus.normal),
              const Divider(
                  height: 1, color: C.border, indent: 16, endIndent: 16),
              _LabRow(
                  'Hemoglobin', '13.2 g/dL', '13.5–17.5 g/dL', _LabStatus.low),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Text('Last updated: Nov 10, 2023', style: _lbl(c: C.txt3)),
        ),
      ],
    );
  }

  // ── EMERGENCY CONTACTS ────────────────────────
  Widget _buildEmergencyContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Emergency Contacts',
            icon: Icons.emergency_rounded, color: C.red),
        const SizedBox(height: 12),
        _Card(
          padding: 0,
          child: Column(
            children: [
              _ContactRow('Sarah Parker', 'Spouse', '+1 (555) 234-5678',
                  Icons.favorite_rounded, C.red),
              const Divider(
                  height: 1, color: C.border, indent: 16, endIndent: 16),
              _ContactRow('Michael Parker', 'Brother', '+1 (555) 876-4321',
                  Icons.person_rounded, C.blue),
              const Divider(
                  height: 1, color: C.border, indent: 16, endIndent: 16),
              _ContactRow('Dr. Elena Ross', 'Primary Physician',
                  '+1 (555) 100-2000', Icons.medical_services_rounded, C.teal),
            ],
          ),
        ),
      ],
    );
  }

  // ── INSURANCE ─────────────────────────────────
  Widget _buildInsuranceCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Insurance Information',
            icon: Icons.shield_rounded, color: C.blue),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D4ED8), Color(0xFF1E40AF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: C.blue.withOpacity(0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HEALTH INSURANCE',
                            style: _lbl(c: Colors.white54, s: 10)),
                        const SizedBox(height: 4),
                        Text('BlueCross BlueShield',
                            style: _h(18, c: Colors.white)),
                      ]),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield_rounded,
                        color: Colors.white, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('MEMBER ID', style: _lbl(c: Colors.white54, s: 9)),
                        const SizedBox(height: 3),
                        Text('BCB-2024-44892',
                            style: _b(14, c: Colors.white, w: FontWeight.w600)),
                      ])),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('GROUP NO.', style: _lbl(c: Colors.white54, s: 9)),
                        const SizedBox(height: 3),
                        Text('GRP-77341',
                            style: _b(14, c: Colors.white, w: FontWeight.w600)),
                      ])),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('VALID THROUGH',
                            style: _lbl(c: Colors.white54, s: 9)),
                        const SizedBox(height: 3),
                        Text('Dec 31, 2024',
                            style: _b(14, c: Colors.white, w: FontWeight.w600)),
                      ])),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('PLAN TYPE', style: _lbl(c: Colors.white54, s: 9)),
                        const SizedBox(height: 3),
                        Text('PPO Premium',
                            style: _b(14, c: Colors.white, w: FontWeight.w600)),
                      ])),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Deductible met: \$1,200 / \$3,000',
                        style: _b(12, c: Colors.white70)),
                    Container(
                      height: 6,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: C.green,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── UPCOMING APPOINTMENTS ─────────────────────
  Widget _buildUpcomingAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Upcoming Appointments',
            icon: Icons.calendar_today_rounded,
            color: C.primary,
            action: 'Book New',
            onAction: () {}),
        const SizedBox(height: 12),
        _AppointmentCard(
          doctor: 'Dr. Elena Ross',
          specialty: 'Neurology',
          date: 'Fri, Nov 24, 2023',
          time: '2:30 PM',
          type: 'Video Consult',
          typeColor: C.teal,
          typeBg: C.tealLight,
          avatar: 'ER',
          avatarColor: C.teal,
        ),
        const SizedBox(height: 10),
        _AppointmentCard(
          doctor: 'Dr. Michael Park',
          specialty: 'Endocrinology',
          date: 'Mon, Dec 4, 2023',
          time: '10:00 AM',
          type: 'In-Person',
          typeColor: C.blue,
          typeBg: C.blueLight,
          avatar: 'MP',
          avatarColor: C.blue,
        ),
      ],
    );
  }

  // ── DIET & LIFESTYLE ──────────────────────────
  Widget _buildDietAndLifestyle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Diet & Lifestyle',
            icon: Icons.spa_rounded, color: C.green),
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: _LifestyleItem(Icons.restaurant_menu_rounded,
                          'Diet', 'Diabetic-friendly', C.green, C.greenLight)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _LifestyleItem(Icons.directions_run_rounded,
                          'Activity', 'Moderate', C.blue, C.blueLight)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _LifestyleItem(Icons.local_bar_rounded, 'Alcohol',
                          'Occasional', C.orange, C.orangeLight)),
                ],
              ),
              const SizedBox(height: 16),
              Text('Dietary Restrictions', style: _b(13, w: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Low Sodium',
                  'Low Sugar',
                  'Gluten-Free',
                  'No Shellfish',
                  'Lactose-Free'
                ]
                    .map((r) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: C.greenLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: C.green.withOpacity(0.3)),
                          ),
                          child: Text(r, style: _lbl(c: C.green, s: 11)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 14),
              const Divider(color: C.border, height: 1),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _GoalCircle('Steps', '8,400', '10K', 0.84, C.amber),
                  _GoalCircle('Water', '6', '8 gl', 0.75, C.teal),
                  _GoalCircle('Sleep', '6.5h', '8h', 0.81, C.purple),
                  _GoalCircle('Cals', '1,820', '2,200', 0.83, C.green),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── DOCUMENTS ─────────────────────────────────
  Widget _buildDocuments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Documents & Reports',
            icon: Icons.folder_rounded,
            color: C.amber,
            action: 'Upload',
            onAction: () {}),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _DocCard(Icons.picture_as_pdf_rounded, 'Blood Report',
                    'Nov 10, 2023', C.red, C.redLight)),
            const SizedBox(width: 10),
            Expanded(
                child: _DocCard(Icons.image_rounded, 'MRI Scan', 'Aug 30, 2023',
                    C.purple, C.purpleLight)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: _DocCard(Icons.description_rounded, 'Prescription',
                    'Nov 24, 2023', C.blue, C.blueLight)),
            const SizedBox(width: 10),
            Expanded(
                child: _DocCard(Icons.receipt_long_rounded, 'Insurance Claim',
                    'Oct 15, 2023', C.green, C.greenLight)),
          ],
        ),
      ],
    );
  }

  // ── DANGER ZONE ───────────────────────────────
  Widget _buildDangerZone() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.settings_rounded, size: 16, color: C.txt2),
            const SizedBox(width: 8),
            Text('Account Actions', style: _b(14, w: FontWeight.w600)),
          ]),
          const SizedBox(height: 14),
          _ActionRow(
              Icons.download_rounded, 'Download Health Data', C.blue, () {}),
          _ActionRow(
              Icons.share_rounded, 'Share Records with Doctor', C.teal, () {}),
          _ActionRow(
              Icons.lock_reset_rounded, 'Change Password', C.orange, () {}),
          _ActionRow(Icons.logout_rounded, 'Sign Out', C.red, () {
            context.read<LogoutCubit>().logout();
            Navigator.of(context).pushReplacementNamed('/login');
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENTS
// ─────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final double padding;
  const _Card({required this.child, this.padding = 16});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding > 0 ? EdgeInsets.all(padding) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: C.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 3))
          ],
        ),
        child: child,
      );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String? action;
  final VoidCallback? onAction;
  const _SectionHeader(this.title,
      {required this.icon, required this.color, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 10),
        Text(title, style: _h(16)),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: C.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(action!, style: _lbl(c: C.primary, s: 12)),
            ),
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color textColor, bg;
  const _Pill(this.text, this.textColor, this.bg);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: _lbl(c: textColor, s: 11)),
      );
}

class _QuickInfo extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _QuickInfo(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, size: 18, color: C.teal),
          const SizedBox(height: 5),
          Text(label, style: _lbl(c: C.txt3, s: 10)),
          const SizedBox(height: 3),
          Text(value,
              style: _b(12, w: FontWeight.w700), textAlign: TextAlign.center),
        ],
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 44, color: C.border);
}

class _VitalCard extends StatelessWidget {
  final IconData icon;
  final String label, value, unit, trend;
  final bool trendUp;
  final Color color, bg;
  const _VitalCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.unit,
      required this.trend,
      required this.trendUp,
      required this.color,
      required this.bg});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 18),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                        trendUp
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 10,
                        color: trendUp ? C.green : C.red),
                    const SizedBox(width: 2),
                    Text(trend,
                        style: _lbl(c: trendUp ? C.green : C.red, s: 9)),
                  ]),
                ),
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value, style: _h(22, c: color)),
                const SizedBox(width: 3),
                Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(unit,
                        style: _lbl(c: color.withOpacity(0.7), s: 10))),
              ],
            ),
            const SizedBox(height: 2),
            Text(label, style: _lbl(c: color.withOpacity(0.8), s: 10)),
          ],
        ),
      );
}

class _DoseTimePill extends StatelessWidget {
  final String time, status;
  final bool taken;
  const _DoseTimePill(this.time, this.status, this.taken);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color:
              taken ? C.green.withOpacity(0.2) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: taken
                  ? C.green.withOpacity(0.4)
                  : Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(
                taken
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: taken ? C.green : Colors.white54),
            const SizedBox(height: 5),
            Text(time, style: _b(11, c: Colors.white, w: FontWeight.w600)),
            Text(status,
                style: _lbl(c: taken ? C.green : Colors.white54, s: 9)),
          ],
        ),
      );
}

class _MedicineCard extends StatelessWidget {
  final String name;
  final ({
    String dose,
    String freq,
    IconData icon,
    Color color,
    Color bg,
    String desc,
    String refill,
    String times
  }) data;
  final bool active;
  final ValueChanged<bool> onToggle;
  const _MedicineCard(
      {required this.name,
      required this.data,
      required this.active,
      required this.onToggle});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: active ? data.color.withOpacity(0.25) : C.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                      color: data.bg, borderRadius: BorderRadius.circular(13)),
                  child: Icon(data.icon, color: data.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: _b(14, w: FontWeight.w700)),
                    Text(data.desc, style: _b(12, c: C.txt2)),
                  ],
                )),
                Switch(
                  value: active,
                  onChanged: onToggle,
                  activeColor: data.color,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: C.border, height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MedDetail(Icons.medication_rounded, data.dose, C.txt2),
                _MedDetail(Icons.repeat_rounded, data.freq, C.txt2),
                _MedDetail(Icons.access_time_rounded, data.times, data.color),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: data.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.inventory_2_rounded,
                        size: 13, color: data.color),
                    const SizedBox(width: 5),
                    Text('Refill: ${data.refill}',
                        style: _lbl(c: data.color, s: 11)),
                  ]),
                  GestureDetector(
                    child: Text('Request Refill →',
                        style: _lbl(c: data.color, s: 11)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _MedDetail extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _MedDetail(this.icon, this.text, this.color);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(text, style: _b(11, c: color, w: FontWeight.w500)),
        ],
      );
}

class _AllergyRow extends StatelessWidget {
  final String name, severity;
  final Color color, bg;
  final IconData icon;
  const _AllergyRow(this.name, this.severity, this.color, this.bg, this.icon);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(name, style: _b(13, w: FontWeight.w700)),
                  Text(severity, style: _b(12, c: C.txt2)),
                ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(20)),
              child: Text(
                severity.startsWith('Severe')
                    ? 'SEVERE'
                    : severity.startsWith('Mod')
                        ? 'MODERATE'
                        : 'MILD',
                style: _lbl(c: color, s: 10),
              ),
            ),
          ],
        ),
      );
}

class _HistoryItem extends StatelessWidget {
  final String name, year;
  final Color color;
  final String note;
  const _HistoryItem(this.name, this.year, this.color, this.note);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 10, top: 5),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name, style: _b(13, w: FontWeight.w600)),
                        Text(year, style: _lbl(c: C.txt3)),
                      ]),
                  Text(note, style: _b(12, c: C.txt2)),
                ])),
          ],
        ),
      );
}

class _VaccineRow extends StatelessWidget {
  final String name, date, brand;
  final bool done;
  const _VaccineRow(this.name, this.date, this.done, this.brand);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: done ? C.greenLight : C.amberLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                done ? Icons.verified_rounded : Icons.schedule_rounded,
                color: done ? C.green : C.amber,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(name, style: _b(13, w: FontWeight.w700)),
                  Text(brand, style: _b(12, c: C.txt2)),
                ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(date, style: _lbl(c: C.txt3)),
              const SizedBox(height: 3),
              Text(done ? '✓ Complete' : 'Pending',
                  style: _lbl(c: done ? C.green : C.amber, s: 10)),
            ]),
          ],
        ),
      );
}

enum _LabStatus { normal, borderline, low, high }

class _LabRow extends StatelessWidget {
  final String test, value, range;
  final _LabStatus status;
  const _LabRow(this.test, this.value, this.range, this.status);

  Color get _color => switch (status) {
        _LabStatus.normal => C.green,
        _LabStatus.borderline => C.amber,
        _LabStatus.low => C.blue,
        _LabStatus.high => C.red,
      };
  String get _label => switch (status) {
        _LabStatus.normal => 'Normal',
        _LabStatus.borderline => 'Borderline',
        _LabStatus.low => 'Low',
        _LabStatus.high => 'High',
      };

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(test, style: _b(13, w: FontWeight.w700)),
                  Text('Ref: $range', style: _lbl(c: C.txt3, s: 10)),
                ])),
            Text(value, style: _b(14, c: _color, w: FontWeight.w700)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_label, style: _lbl(c: _color, s: 10)),
            ),
          ],
        ),
      );
}

class _ContactRow extends StatelessWidget {
  final String name, relation, phone;
  final IconData icon;
  final Color color;
  const _ContactRow(
      this.name, this.relation, this.phone, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(name, style: _b(13, w: FontWeight.w700)),
                  Text(relation, style: _b(12, c: C.txt2)),
                ])),
            Row(children: [
              GestureDetector(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: C.greenLight,
                      borderRadius: BorderRadius.circular(10)),
                  child:
                      const Icon(Icons.phone_rounded, size: 17, color: C.green),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.message_rounded, size: 17, color: color),
                ),
              ),
            ]),
          ],
        ),
      );
}

class _AppointmentCard extends StatelessWidget {
  final String doctor, specialty, date, time, type, avatar;
  final Color typeColor, typeBg, avatarColor;
  const _AppointmentCard({
    required this.doctor,
    required this.specialty,
    required this.date,
    required this.time,
    required this.type,
    required this.typeColor,
    required this.typeBg,
    required this.avatar,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: typeColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: avatarColor.withOpacity(0.15),
              child: Text(avatar,
                  style: _b(13, c: avatarColor, w: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(doctor, style: _b(14, w: FontWeight.w700)),
                  Text(specialty, style: _b(12, c: C.txt2)),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 12, color: C.txt3),
                    const SizedBox(width: 4),
                    Text('$date  •  $time', style: _lbl(c: C.txt3)),
                  ]),
                ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: typeBg, borderRadius: BorderRadius.circular(20)),
                child: Text(type, style: _lbl(c: typeColor, s: 11)),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                child: Text('Reschedule', style: _lbl(c: C.primary, s: 11)),
              ),
            ]),
          ],
        ),
      );
}

class _LifestyleItem extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color, bg;
  const _LifestyleItem(this.icon, this.label, this.value, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 5),
            Text(label, style: _lbl(c: color.withOpacity(0.7), s: 9)),
            const SizedBox(height: 2),
            Text(value,
                style: _b(11, c: color, w: FontWeight.w700),
                textAlign: TextAlign.center),
          ],
        ),
      );
}

class _GoalCircle extends StatelessWidget {
  final String label, value, target;
  final double progress;
  final Color color;
  const _GoalCircle(
      this.label, this.value, this.target, this.progress, this.color);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 6,
                  color: color.withOpacity(0.12),
                ),
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  color: color,
                  strokeCap: StrokeCap.round,
                ),
                Text(value.length > 5 ? value.substring(0, 4) : value,
                    style: _b(10, c: color, w: FontWeight.w800),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: _lbl(c: C.txt2, s: 10)),
          Text('/ $target', style: _lbl(c: C.txt3, s: 9)),
        ],
      );
}

class _DocCard extends StatelessWidget {
  final IconData icon;
  final String name, date;
  final Color color, bg;
  const _DocCard(this.icon, this.name, this.date, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(name, style: _b(13, w: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(date, style: _lbl(c: C.txt3)),
            const SizedBox(height: 10),
            Row(children: [
              GestureDetector(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: bg, borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.download_rounded, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text('PDF', style: _lbl(c: color, s: 11)),
                  ]),
                ),
              ),
              const Spacer(),
              Icon(Icons.more_horiz_rounded, size: 18, color: C.txt3),
            ]),
          ],
        ),
      );
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionRow(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 14),
              Text(label, style: _b(14, w: FontWeight.w500)),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: C.txt3, size: 20),
            ],
          ),
        ),
      );
}
