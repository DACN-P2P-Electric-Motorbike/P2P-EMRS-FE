import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../data/models/register_params.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// User role enum for registration
enum UserRole {
  renter,
  owner;

  String get apiValue => this == UserRole.owner ? 'OWNER' : 'RENTER';

  String get displayName => this == UserRole.owner ? 'Vehicle Owner' : 'Renter';

  String get description => this == UserRole.owner
      ? 'I want to rent out my electric motorbike'
      : 'I want to rent electric motorbikes';

  IconData get icon =>
      this == UserRole.owner ? Icons.electric_moped : Icons.person_search;
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _RegisterPageContent(),
    );
  }
}

class _RegisterPageContent extends StatefulWidget {
  const _RegisterPageContent();

  @override
  State<_RegisterPageContent> createState() => _RegisterPageContentState();
}

class _RegisterPageContentState extends State<_RegisterPageContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Owner-specific fields
  final _idCardController = TextEditingController();
  final _addressController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserRole _selectedRole = UserRole.renter;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _idCardController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      // Get owner-specific fields safely
      String? idCardNum;
      String? address;
      
      if (_selectedRole == UserRole.owner) {
        final idCardText = _idCardController.text.trim();
        final addressText = _addressController.text.trim();
        
        if (idCardText.isNotEmpty) {
          idCardNum = idCardText;
        }
        if (addressText.isNotEmpty) {
          address = addressText;
        }
      }

      final params = RegisterParams(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _selectedRole.apiValue,
        idCardNum: idCardNum,
        address: address,
      );

      context.read<AuthBloc>().add(
            AuthRegisterStarted(registerParams: params),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess || state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Back Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Header
                      Text(
                        'Create New Account',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Join our community of electric motorbike\nrenters and owners',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Role Selection
                      _buildRoleSelector(isLoading),

                      const SizedBox(height: 24),

                      // Full Name Field
                      _buildTextField(
                        controller: _fullNameController,
                        hintText: 'Full Name',
                        prefixIcon: Icons.person_outline,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          if (value.length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Email Field
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Phone Field
                      _buildTextField(
                        controller: _phoneController,
                        hintText: 'Phone Number (+84...)',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          // Vietnamese phone number validation
                          if (!RegExp(r'^(\+84|84|0)[3|5|7|8|9][0-9]{8}$')
                              .hasMatch(value.replaceAll(' ', ''))) {
                            return 'Please enter a valid Vietnamese phone number';
                          }
                          return null;
                        },
                      ),

                      // Owner-specific fields
                      if (_selectedRole == UserRole.owner) ...[
                        const SizedBox(height: 24),
                        
                        // Owner section header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.verified_user_outlined,
                                color: AppColors.warning,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Owner Verification',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Required for vehicle registration',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),

                        // ID Card Number (CCCD/CMND)
                        _buildTextField(
                          controller: _idCardController,
                          hintText: 'ID Card Number (CCCD/CMND)',
                          prefixIcon: Icons.credit_card_outlined,
                          keyboardType: TextInputType.number,
                          enabled: !isLoading,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(12),
                          ],
                          validator: (value) {
                            if (_selectedRole == UserRole.owner) {
                              if (value == null || value.isEmpty) {
                                return 'ID Card number is required for owners';
                              }
                              if (value.length != 9 && value.length != 12) {
                                return 'ID Card must be 9 or 12 digits';
                              }
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Address
                        _buildTextField(
                          controller: _addressController,
                          hintText: 'Business Address (Optional)',
                          prefixIcon: Icons.location_on_outlined,
                          enabled: !isLoading,
                          maxLines: 2,
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Password Field
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        enabled: !isLoading,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Confirm Password Field
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirm Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscureConfirmPassword,
                        enabled: !isLoading,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _onRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SpinKitThreeBounce(
                                  color: Colors.white,
                                  size: 20,
                                )
                              : Text(
                                  _selectedRole == UserRole.owner
                                      ? 'Register as Owner'
                                      : 'Sign Up',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: Text(
                              'Log in',
                              style: GoogleFonts.poppins(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.border,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Or sign up with',
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.border,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Social Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildSocialButton(
                              label: 'Google',
                              isGoogle: true,
                              onPressed: () {
                                // TODO: Implement Google Sign In
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSocialButton(
                              label: 'Facebook',
                              isFacebook: true,
                              onPressed: () {
                                // TODO: Implement Facebook Sign In
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build role selector toggle
  Widget _buildRoleSelector(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I want to:',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: UserRole.values.map((role) {
            final isSelected = _selectedRole == role;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: role == UserRole.renter ? 8 : 0,
                  left: role == UserRole.owner ? 8 : 0,
                ),
                child: InkWell(
                  onTap: isLoading
                      ? null
                      : () {
                          setState(() {
                            _selectedRole = role;
                          });
                        },
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.15)
                                : AppColors.border.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            role.icon,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textMuted,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          role.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          role.description,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 8),
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        
        // Owner benefits info
        if (_selectedRole == UserRole.owner) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'As an owner, you can list your electric motorbikes and earn money from rentals!',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    bool enabled = true,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          color: AppColors.textMuted,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: AppColors.primary.withOpacity(0.7),
          size: 20,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    bool isGoogle = false,
    bool isFacebook = false,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isGoogle)
            SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [
                          Color(0xFF4285F4),
                          Color(0xFF34A853),
                          Color(0xFFFBBC05),
                          Color(0xFFEA4335),
                        ],
                      ).createShader(const Rect.fromLTWH(0, 0, 24, 24)),
                  ),
                ),
              ),
            )
          else if (isFacebook)
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF1877F2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'f',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
