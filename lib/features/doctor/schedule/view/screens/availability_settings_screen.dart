import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/core/shared/theme/theme2.dart';
import 'package:smart_care/features/doctor/schedule/cubit/availability_cubit.dart';
import 'package:smart_care/features/doctor/schedule/cubit/availability_state.dart';
import 'package:smart_care/features/doctor/schedule/data/model/Availability_model.dart';

class AvailabilitySettingsScreen extends StatefulWidget {
  final String staffProfileId;

  const AvailabilitySettingsScreen({super.key, required this.staffProfileId});

  @override
  State<AvailabilitySettingsScreen> createState() => _AvailabilitySettingsScreenState();
}

class _AvailabilitySettingsScreenState extends State<AvailabilitySettingsScreen> {
  static const List<String> _daysOfWeek = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  @override
  void initState() {
    super.initState();
    // Load the availability list when screen is opened
    context.read<AvailabilityCubit>().getAvailability(widget.staffProfileId);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  bool _isTimeRangeValid(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes > startMinutes;
  }

  bool _isWeekValid(List<StaffAvailability> list) {
    for (final day in list) {
      if (day.isActive) {
        if (!_isTimeRangeValid(day.startTime, day.endTime)) {
          return false;
        }
      }
    }
    return true;
  }

  Future<void> _selectTime(BuildContext context, StaffAvailability day, bool isStart) async {
    final cubit = context.read<AvailabilityCubit>();
    final initialTime = isStart ? day.startTime : day.endTime;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final updated = isStart
          ? day.copyWith(startTime: picked)
          : day.copyWith(endTime: picked);
      cubit.updateAvailability(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Weekly Availability',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<AvailabilityCubit, AvailabilityState>(
        listener: (context, state) {
          if (state is AvailabilitySuccess && !context.read<AvailabilityCubit>().state.runtimeType.toString().contains('Loading')) {
            // Note: If saved successfully, show success toast and pop
          } else if (state is AvailabilityFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.critical,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<AvailabilityCubit>();
          final list = cubit.availabilities;

          if (state is AvailabilityLoading && list.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (list.isEmpty) {
            return Center(
              child: Text(
                'No availability data found.',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
            );
          }

          final isValid = _isWeekValid(list);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final day = list[index];
                    final dayName = _daysOfWeek[day.weekday];
                    final timeValid = _isTimeRangeValid(day.startTime, day.endTime);

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: day.isActive
                              ? (timeValid ? AppColors.primary.withOpacity(0.3) : AppColors.critical.withOpacity(0.3))
                              : AppColors.border,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
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
                                  Text(
                                    dayName,
                                    style: AppTextStyles.heading3.copyWith(
                                      color: day.isActive ? AppColors.textPrimary : AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    day.isActive ? 'Available' : 'Unavailable',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: day.isActive ? AppColors.stable : AppColors.textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Switch.adaptive(
                                value: day.isActive,
                                activeThumbColor: AppColors.primary,
                                activeTrackColor: AppColors.tealLight.withOpacity(0.3),
                                onChanged: (val) {
                                  final updated = day.copyWith(isActive: val);
                                  cubit.updateAvailability(updated);
                                },
                              ),
                            ],
                          ),
                          if (day.isActive) ...[
                            const SizedBox(height: 16),
                            const Divider(height: 1, color: AppColors.border),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectTime(context, day, true),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('START TIME', style: AppTextStyles.caption),
                                              const SizedBox(height: 2),
                                              Text(
                                                _formatTime(day.startTime),
                                                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Icon(Icons.arrow_forward_rounded, color: AppColors.textMuted, size: 18),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectTime(context, day, false),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('END TIME', style: AppTextStyles.caption),
                                              const SizedBox(height: 2),
                                              Text(
                                                _formatTime(day.endTime),
                                                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (!timeValid) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: AppColors.critical, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'End time must be after start time',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.critical,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (state is AvailabilityLoading || !isValid)
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);
                            await cubit.saveWeeklyAvailability();
                            if (cubit.state is AvailabilitySuccess) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Weekly availability saved successfully!'),
                                  backgroundColor: AppColors.stable,
                                ),
                              );
                              navigator.pop();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.border,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: state is AvailabilityLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            'Save Changes',
                            style: AppTextStyles.heading3.copyWith(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
