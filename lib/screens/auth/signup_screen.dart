import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/theme.dart';
import '../../utils/translation_helper.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import 'verify_email_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  late AnimationController _iconController;
  late AnimationController _contentController;
  late Animation<double> _iconAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );

    _iconController.forward();
    _contentController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _iconController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please_accept_terms'.t(context)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      role: 'client', // Tous les nouveaux utilisateurs ont le rôle client
    );

    if (success && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              VerifyEmailScreen(email: _emailController.text.trim()),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'registration_failed'.t(context)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Text(
          'create_account'.t(context),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _iconAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _iconAnimation.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.yellow.withValues(alpha: 0.2),
                                AppColors.yellow.withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.yellow.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.asset(
                              'assets/images/bee-logo.png',
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            'create_account'.t(context),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Rejoignez ZIBENE SÉCURITÉ pour des services de protection professionnelle',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),

                          // Full Name Field
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF2A2A2A),
                                width: 1,
                              ),
                            ),
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: 'full_name'.t(context),
                                hintStyle: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.yellow.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.person_outline,
                                    color: AppColors.yellow,
                                    size: 20,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 16,
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'name_required'.t(context);
                                }
                                if (value.trim().length < 2) {
                                  return 'name_too_short'.t(context);
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Email Field
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF2A2A2A),
                                width: 1,
                              ),
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: 'email_address'.t(context),
                                hintStyle: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.yellow.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.email_outlined,
                                    color: AppColors.yellow,
                                    size: 20,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 16,
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'email_required'.t(context);
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'enter_valid_email'.t(context);
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Phone Field
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF2A2A2A),
                                width: 1,
                              ),
                            ),
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                hintText: 'phone_number'.t(context),
                                hintStyle: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.yellow.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.phone_outlined,
                                    color: AppColors.yellow,
                                    size: 20,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 16,
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'phone_required'.t(context);
                                }
                                if (!RegExp(r'^[\+]?[1-9][\d]{0,15}$').hasMatch(
                                  value.replaceAll(RegExp(r'[^\d+]'), ''),
                                )) {
                                  return 'enter_valid_phone'.t(context);
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF2A2A2A),
                                width: 1,
                              ),
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                hintText: 'password'.t(context),
                                hintStyle: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.yellow.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.lock_outline,
                                    color: AppColors.yellow,
                                    size: 20,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 16,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              obscureText: _obscurePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'password_required'.t(context);
                                }
                                if (value.length < 6) {
                                  return 'password_too_short'.t(context);
                                }
                                if (!RegExp(
                                  r'(?=.*[A-Z])(?=.*[a-z])(?=.*\d)',
                                ).hasMatch(value)) {
                                  return 'password_requirements'.t(context);
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password Field
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF2A2A2A),
                                width: 1,
                              ),
                            ),
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                hintText: 'confirm_password'.t(context),
                                hintStyle: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.yellow.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.lock_person_outlined,
                                    color: AppColors.yellow,
                                    size: 20,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 16,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              obscureText: _obscureConfirmPassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'confirm_password_required'.t(context);
                                }
                                if (value != _passwordController.text) {
                                  return 'passwords_not_match'.t(context);
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Terms and Conditions
                          Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _acceptTerms
                                        ? AppColors.yellow
                                        : const Color(0xFF2A2A2A),
                                  ),
                                  color: _acceptTerms
                                      ? AppColors.yellow.withValues(alpha: 0.2)
                                      : Colors.transparent,
                                ),
                                child: Checkbox(
                                  value: _acceptTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _acceptTerms = value ?? false;
                                    });
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  activeColor: AppColors.yellow,
                                  checkColor: const Color(0xFF121212),
                                  side: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'J\'accepte les ',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'terms_of_service'.t(context),
                                        style: const TextStyle(
                                          color: AppColors.yellow,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      const TextSpan(text: ' et la '),
                                      TextSpan(
                                        text: 'privacy_policy'.t(context),
                                        style: const TextStyle(
                                          color: AppColors.yellow,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Sign Up Button
                          if (authProvider.isLoading)
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.yellow.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.yellow,
                                  strokeWidth: 3,
                                ),
                              ),
                            )
                          else if (!FirebaseService.isInitialized)
                            Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Service indisponible',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'L\'inscription n\'est pas disponible sur cette plateforme. Veuillez utiliser un appareil mobile.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          else
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.yellow,
                                    AppColors.yellowAccent,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.yellow.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _handleSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  'create_account'.t(context),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF121212),
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 32),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "already_have_account".t(context),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                                child: Text(
                                  'sign_in'.t(context),
                                  style: const TextStyle(
                                    color: AppColors.yellow,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
