import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;

  const OtpVerificationPage({super.key, required this.email});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;

  // Countdown timer
  static const int _resendCooldown = 60;
  int _secondsLeft = _resendCooldown;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendCooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        if (mounted) setState(() => _secondsLeft = 0);
      } else {
        if (mounted) setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  bool get _isOtpComplete => _otp.length == 5;

  /// Mask email: "abc@example.com" → "a**@example.com"
  String get _maskedEmail {
    final parts = widget.email.split('@');
    if (parts.length != 2) return widget.email;
    final local = parts[0];
    final domain = parts[1];
    if (local.length <= 1) return widget.email;
    return '${local[0]}${'*' * (local.length - 1)}@$domain';
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 4) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _verifyOtp() async {
    if (!_isOtpComplete) return;

    setState(() => _isLoading = true);

    try {
      final dioClient = sl<DioClient>();
      final response = await dioClient.post(
        '/auth/verify-otp',
        data: {'email': widget.email, 'otp': _otp},
      );

      if (response.statusCode == 200 && mounted) {
        context.pushReplacement(
          '/reset-password?email=${Uri.encodeComponent(widget.email)}'
          '&otp=${Uri.encodeComponent(_otp)}',
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        String message = 'Mã OTP không hợp lệ hoặc đã hết hạn';
        if (e.response?.data is Map) {
          message = e.response?.data['message'] ?? message;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_secondsLeft > 0 || _isResending) return;

    setState(() => _isResending = true);

    try {
      final dioClient = sl<DioClient>();
      await dioClient.post(
        '/auth/forgot-password',
        data: {'email': widget.email},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã gửi lại mã OTP đến $_maskedEmail'),
            backgroundColor: AppColors.success,
          ),
        );
        _startTimer();
        // Clear fields
        for (var c in _controllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
        setState(() {});
      }
    } on DioException catch (e) {
      if (mounted) {
        String message = 'Không thể gửi lại mã OTP';
        if (e.response?.data is Map) {
          message = e.response?.data['message'] ?? message;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Step indicator + Back
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Spacer(),
                  _buildStepIndicator(2),
                ],
              ),

              const SizedBox(height: 36),

              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_unread_outlined,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),

              const SizedBox(height: 24),

              // Header
              Text(
                'Nhập mã xác thực',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 10),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'Chúng tôi đã gửi mã đến\n'),
                    TextSpan(
                      text: _maskedEmail,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Flexible(
                    child: Container(
                      width: 52,
                      height: 60,
                      margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        enabled: !_isLoading,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: _controllers[index].text.isNotEmpty
                              ? AppColors.primary.withOpacity(0.08)
                              : AppColors.inputBackground,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: _controllers[index].text.isNotEmpty
                                ? BorderSide(color: AppColors.primary, width: 1.5)
                                : BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _onOtpChanged(index, value),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading || !_isOtpComplete ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                      : Text(
                          'Xác thực',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Resend with countdown
              _buildResendRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResendRow() {
    final canResend = _secondsLeft == 0 && !_isResending;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Không nhận được mã? ',
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        if (_secondsLeft > 0)
          Text(
            'Gửi lại sau ${_secondsLeft}s',
            style: GoogleFonts.poppins(
              color: AppColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          )
        else
          GestureDetector(
            onTap: canResend ? _resendOtp : null,
            child: _isResending
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Gửi lại',
                    style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
      ],
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final step = i + 1;
        final isActive = step == currentStep;
        final isDone = step < currentStep;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive || isDone
                    ? AppColors.primary
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            if (i < 2) const SizedBox(width: 4),
          ],
        );
      }),
    );
  }
}
