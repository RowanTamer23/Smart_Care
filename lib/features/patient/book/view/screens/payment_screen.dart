import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/features/doctor/schedule/cubit/appointment_cubit.dart';
import 'package:smart_care/features/doctor/schedule/data/model/appointment_model.dart';
import 'package:smart_care/features/patient/theme3.dart';

class PaymentScreen extends StatefulWidget {
  final Appointment appointment;
  final String doctorName;
  final String specialty;
  final double fee;

  const PaymentScreen({
    super.key,
    required this.appointment,
    required this.doctorName,
    required this.specialty,
    required this.fee,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with SingleTickerProviderStateMixin {
  int _selectedMethodIndex = 0; // 0 = Card, 1 = Apple Pay, 2 = PayPal
  
  // Card Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  // Focus nodes to detect CVV focus for card flipping
  final _cvvFocusNode = FocusNode();

  // Card Flip Animation Controllers
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // Processing states
  bool _isProcessing = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    
    // Setup animation controller for 3D card flip
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _cvvFocusNode.addListener(() {
      if (_cvvFocusNode.hasFocus) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cvvFocusNode.dispose();
    _flipController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _getCardType(String number) {
    final cleaned = number.replaceAll(' ', '');
    if (cleaned.startsWith('4')) return 'Visa';
    if (cleaned.startsWith('5')) return 'Mastercard';
    if (cleaned.startsWith('3')) return 'Amex';
    return 'Generic';
  }

  void _handlePay() async {
    if (_selectedMethodIndex == 0) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate secure banking checkout delays
    await Future.delayed(const Duration(milliseconds: 2200));

    if (!mounted) return;

    // Call Supabase booking via bloc
    context.read<AppointmentCubit>().bookAppointment(widget.appointment).then((_) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isSuccess = true;
        });
      }
    }).catchError((err) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.red,
            content: Text('Failed to book appointment: $err'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingFee = 5.00;
    final tax = widget.fee * 0.05; // 5% VAT
    final totalAmount = widget.fee + bookingFee + tax;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Navigator.maybePop(context),
            ),
            title: Text('Secure Payment', style: AppText.display(18, color: AppColors.primary)),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(Icons.lock_outline_rounded, color: AppColors.green, size: 20),
              )
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDoctorSummaryCard(),
                const SizedBox(height: 16),
                _buildPaymentMethodSelector(),
                const SizedBox(height: 20),
                if (_selectedMethodIndex == 0) ...[
                  _buildInteractiveCreditCard(),
                  const SizedBox(height: 24),
                  _buildCreditCardForm(),
                ] else if (_selectedMethodIndex == 1) ...[
                  _buildApplePayMethod(totalAmount),
                ] else ...[
                  _buildPayPalMethod(totalAmount),
                ],
                const SizedBox(height: 24),
                _buildReceiptSummary(widget.fee, bookingFee, tax, totalAmount),
                const SizedBox(height: 120), // spacing for bottom bar
              ],
            ),
          ),
          bottomNavigationBar: _buildPaymentBottomBar(totalAmount),
        ),

        // Fullscreen Transaction Loader
        if (_isProcessing) _buildProcessingOverlay(),

        // Fullscreen Success Screen
        if (_isSuccess) _buildSuccessScreen(totalAmount),
      ],
    );
  }

  Widget _buildDoctorSummaryCard() {
    final careTypeStr = widget.appointment.careType?.name == 'video'
        ? 'Video Consultation'
        : widget.appointment.careType?.name == 'inPerson'
            ? 'In-Person Visit'
            : 'Home Visit';

    final careIcon = widget.appointment.careType?.name == 'video'
        ? Icons.videocam_rounded
        : widget.appointment.careType?.name == 'inPerson'
            ? 'In-Person Visit'
            : Icons.home_rounded;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              careIcon is IconData ? careIcon : Icons.calendar_today_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.doctorName, style: AppText.display(16, color: AppColors.primary)),
                const SizedBox(height: 3),
                Text(widget.specialty, style: AppText.body(13, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, size: 14, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(widget.appointment.appointmentDate),
                      style: AppText.body(12, color: AppColors.textSecondary, weight: FontWeight.w600),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.access_time, size: 14, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(widget.appointment.appointmentTime),
                      style: AppText.body(12, color: AppColors.textSecondary, weight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.green),
                    const SizedBox(width: 4),
                    Text(careTypeStr, style: AppText.label(color: AppColors.green, size: 11)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    final methods = [
      (Icons.credit_card_rounded, 'Card'),
      (Icons.apple_rounded, 'Apple Pay'),
      (Icons.paypal_rounded, 'PayPal'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Payment Method', style: AppText.display(14, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Row(
            children: List.generate(methods.length, (index) {
              final selected = _selectedMethodIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMethodIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.only(
                      right: index == methods.length - 1 ? 0 : 8,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                        width: 1.5,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          methods[index].$1,
                          color: selected ? Colors.white : AppColors.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          methods[index].$2,
                          style: AppText.body(
                            13,
                            color: selected ? Colors.white : AppColors.textSecondary,
                            weight: selected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _buildInteractiveCreditCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective
                ..rotateY(_flipAnimation.value),
              alignment: Alignment.center,
              child: _flipAnimation.value < pi / 2
                  ? _buildCardFront()
                  : Transform(
                      transform: Matrix4.identity()..rotateY(pi),
                      alignment: Alignment.center,
                      child: _buildCardBack(),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    final numberText = _numberController.text.isEmpty ? '•••• •••• •••• ••••' : _numberController.text;
    final holderName = _nameController.text.isEmpty ? 'CARDHOLDER NAME' : _nameController.text.toUpperCase();
    final expiryText = _expiryController.text.isEmpty ? 'MM/YY' : _expiryController.text;
    final cardType = _getCardType(_numberController.text);

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E4D40), // Premium Teal
            Color(0xFF0F2D25), // Dark Teal Forest
            Color(0xFF143329),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2D25).withOpacity(0.4),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Chip Icon
              Container(
                width: 40,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.accent.withOpacity(0.8),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF7C978), Color(0xFFE5A124)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 6,
                      bottom: 6,
                      left: 10,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black.withOpacity(0.15), width: 0.5),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      bottom: 10,
                      left: 6,
                      right: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black.withOpacity(0.15), width: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Card Type Brand
              if (cardType == 'Visa')
                const Text('VISA', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic))
              else if (cardType == 'Mastercard')
                Row(
                  children: [
                    Container(width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.withOpacity(0.9))),
                    Transform.translate(offset: const Offset(-8, 0), child: Container(width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.orange.withOpacity(0.9)))),
                  ],
                )
              else if (cardType == 'Amex')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.shade800, borderRadius: BorderRadius.circular(4)),
                  child: const Text('AMEX', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                )
              else
                const Icon(Icons.payment_rounded, color: Colors.white70, size: 28),
            ],
          ),
          
          // Card Number
          Text(
            numberText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CARD HOLDER', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(
                      holderName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('EXPIRES', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(
                    expiryText,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    final cvvText = _cvvController.text.isEmpty ? '•••' : _cvvController.text;

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E4D40),
            Color(0xFF0F2D25),
            Color(0xFF143329),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Magnetic Strip
          Container(
            height: 40,
            width: double.infinity,
            color: Colors.black87,
          ),
          const SizedBox(height: 20),
          // White panel and CVV
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36,
                    color: Colors.white.withOpacity(0.8),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      'Signature Panel',
                      style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 36,
                  color: AppColors.accent,
                  alignment: Alignment.center,
                  child: Text(
                    cvvText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                )
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 16),
            child: Text(
              'Smart Care Systems International Inc.',
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 8),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Cardholder Name
            TextFormField(
              controller: _nameController,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              style: AppText.body(14, color: AppColors.textPrimary),
              onChanged: (_) => setState(() {}),
              decoration: _buildInputDecoration('Cardholder Name', Icons.person_outline_rounded),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Enter cardholder name';
                if (val.trim().split(' ').length < 2) return 'Enter full name (First & Last)';
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Card Number
            TextFormField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CardNumberFormatter(),
              ],
              style: AppText.body(14, color: AppColors.textPrimary),
              onChanged: (_) => setState(() {}),
              decoration: _buildInputDecoration('Card Number', Icons.credit_card_rounded),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Enter card number';
                final cleaned = val.replaceAll(' ', '');
                if (cleaned.length < 15) return 'Invalid card number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Expiry Date
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ExpiryDateFormatter(),
                    ],
                    style: AppText.body(14, color: AppColors.textPrimary),
                    onChanged: (_) => setState(() {}),
                    decoration: _buildInputDecoration('MM / YY', Icons.calendar_today_rounded),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Enter expiry date';
                      final parts = val.split('/');
                      if (parts.length != 2) return 'Use MM/YY';
                      final month = int.tryParse(parts[0]) ?? 0;
                      final year = int.tryParse(parts[1]) ?? 0;
                      if (month < 1 || month > 12) return 'Invalid Month';
                      if (year < 26) return 'Expired Card'; // Assuming current year is 2026
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // CVV
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    focusNode: _cvvFocusNode,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    style: AppText.body(14, color: AppColors.textPrimary),
                    onChanged: (_) => setState(() {}),
                    decoration: _buildInputDecoration('CVV', Icons.lock_outline_rounded),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Enter CVV';
                      if (val.length < 3) return 'Invalid CVV';
                      return null;
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppText.body(13, color: AppColors.textMuted),
      prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.red, width: 1.5),
      ),
    );
  }

  Widget _buildApplePayMethod(double total) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.apple_rounded, size: 54, color: Colors.black),
          const SizedBox(height: 12),
          Text(
            'Apple Pay Express',
            style: AppText.display(16, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Confirm payment instantly using FaceID/TouchID.',
            textAlign: TextAlign.center,
            style: AppText.body(13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handlePay,
              icon: const Icon(Icons.touch_app_rounded, size: 20, color: Colors.white),
              label: Text('Pay with Pay (\$${total.toStringAsFixed(2)})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: AppText.body(14, weight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPayPalMethod(double total) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.paypal_rounded, size: 54, color: Colors.blue.shade900),
          const SizedBox(height: 12),
          Text(
            'PayPal Account',
            style: AppText.display(16, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'You will be redirected to PayPal to complete your purchase securely.',
            textAlign: TextAlign.center,
            style: AppText.body(13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handlePay,
              icon: Icon(Icons.login_rounded, size: 20, color: Colors.blue.shade900),
              label: Text(
                'Log in to PayPal (\$${total.toStringAsFixed(2)})',
                style: TextStyle(color: Colors.blue.shade900),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC439), // PayPal gold
                foregroundColor: Colors.blue.shade900,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: AppText.body(14, weight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReceiptSummary(double subtotal, double bookingFee, double tax, double total) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Receipt Summary', style: AppText.display(14, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _buildReceiptRow('Consultation Fee', '\$${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildReceiptRow('Booking & Platform Fee', '\$${bookingFee.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildReceiptRow('Tax (VAT 5%)', '\$${tax.toStringAsFixed(2)}'),
          const Divider(height: 20, color: AppColors.border, thickness: 1),
          _buildReceiptRow('Total Charge', '\$${total.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppText.body(
            isTotal ? 14 : 13,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            weight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: AppText.display(
            isTotal ? 16 : 13,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
            weight: isTotal ? FontWeight.w800 : FontWeight.w600,
          ),
        )
      ],
    );
  }

  Widget _buildPaymentBottomBar(double total) {
    if (_selectedMethodIndex != 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total to Pay', style: AppText.body(12, color: AppColors.textSecondary)),
                Text('\$${total.toStringAsFixed(2)}', style: AppText.display(22, color: AppColors.primary)),
              ],
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: _handlePay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                'Pay & Book',
                style: AppText.body(15, color: Colors.white, weight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.85),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Safe spinner
            const SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 4.5,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Securing Transaction...',
              style: AppText.display(18, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Please do not refresh or close the page',
              style: AppText.body(13, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessScreen(double total) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Animated scaling success checkmark container
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, val, child) {
                  return Transform.scale(
                    scale: val,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 54,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
              Text(
                'Payment Confirmed!',
                style: AppText.display(22, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Your appointment has been booked successfully.',
                textAlign: TextAlign.center,
                style: AppText.body(14, color: Colors.white70),
              ),
              const SizedBox(height: 36),
              
              // Success Detail Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    _buildSuccessDetailRow('Doctor', widget.doctorName),
                    const SizedBox(height: 10),
                    _buildSuccessDetailRow('Specialty', widget.specialty),
                    const SizedBox(height: 10),
                    _buildSuccessDetailRow('Date', _formatDate(widget.appointment.appointmentDate)),
                    const SizedBox(height: 10),
                    _buildSuccessDetailRow('Time', _formatTime(widget.appointment.appointmentTime)),
                    const Divider(height: 24, color: Colors.white24),
                    _buildSuccessDetailRow('Amount Paid', '\$${total.toStringAsFixed(2)}', highlight: true),
                  ],
                ),
              ),
              
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to the doctor screen
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Done',
                    style: AppText.body(15, color: AppColors.primary, weight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessDetailRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppText.body(13, color: Colors.white60),
        ),
        Text(
          value,
          style: AppText.body(
            highlight ? 15 : 13,
            color: highlight ? AppColors.accent : Colors.white,
            weight: highlight ? FontWeight.bold : FontWeight.w600,
          ),
        )
      ],
    );
  }
}

// Custom Input Formatters
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) text = text.substring(0, 16);
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('/', '');
    if (text.length > 4) text = text.substring(0, 4);
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex == 2 && nonZeroIndex != text.length) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
