// lib/views/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  UserRole _selectedRole = UserRole.candidate;
  String? _selectedGender;
  DateTime? _selectedBirthday;
  
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedBirthday = picked);
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    final user = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
      gender: _selectedGender,
      birthday: _selectedBirthday,
    );

    final success = await ref.read(authProvider.notifier).register(user);

    if (success && mounted) {
      _navigateAfterLogin();
    } else if (mounted) {
      final errorMsg = ref.read(authProvider).errorMessage ?? 'Đăng ký thất bại';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _navigateAfterLogin() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    switch (user.role) {
      case UserRole.candidate:
        context.go('/jobs');
      case UserRole.recruiter:
        context.go('/applications');
      case UserRole.admin:
        context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;

    return Scaffold(
      body: Row(
        children: [
          // ── Left panel (hero) - desktop only ─────────────────────────────
          if (isDesktop)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.registerTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.registerSubtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ── Right panel (form) ────────────────────────────────────────────
          Expanded(
            child: Container(
              color: AppColors.backgroundLight,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppStrings.register,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 32),

                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Role Selection
                                  const Text('Bạn là:', style: TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _RoleCard(
                                          label: 'Ứng viên',
                                          icon: Icons.person_outline,
                                          isSelected: _selectedRole == UserRole.candidate,
                                          onTap: () => setState(() => _selectedRole = UserRole.candidate),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _RoleCard(
                                          label: 'Nhà tuyển dụng',
                                          icon: Icons.business_outlined,
                                          isSelected: _selectedRole == UserRole.recruiter,
                                          onTap: () => setState(() => _selectedRole = UserRole.recruiter),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Name
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: AppStrings.name,
                                      prefixIcon: Icon(Icons.person_outline),
                                    ),
                                    validator: (v) => (v == null || v.isEmpty) ? AppStrings.required : null,
                                  ),
                                  const SizedBox(height: 16),

                                  // Email
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      labelText: AppStrings.email,
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return AppStrings.required;
                                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return AppStrings.invalidEmail;
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Phone & Gender
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          decoration: const InputDecoration(
                                            labelText: AppStrings.phone,
                                            prefixIcon: Icon(Icons.phone_outlined),
                                          ),
                                          validator: (v) => (v == null || v.isEmpty) ? AppStrings.required : null,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: _selectedGender,
                                          decoration: const InputDecoration(
                                            labelText: AppStrings.gender,
                                            prefixIcon: Icon(Icons.wc_outlined),
                                          ),
                                          items: const [
                                            DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                                            DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                                            DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                                          ],
                                          onChanged: (v) => setState(() => _selectedGender = v),
                                          validator: (v) => (v == null) ? AppStrings.required : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Birthday
                                  InkWell(
                                    onTap: _selectBirthday,
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: AppStrings.birthday,
                                        prefixIcon: Icon(Icons.calendar_today_outlined),
                                      ),
                                      child: Text(
                                        _selectedBirthday == null
                                            ? 'Chọn ngày sinh'
                                            : '${_selectedBirthday!.day}/${_selectedBirthday!.month}/${_selectedBirthday!.year}',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Password
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: AppStrings.password,
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                    ),
                                    validator: (v) => (v == null || v.length < 6) ? AppStrings.minLength6 : null,
                                  ),
                                  const SizedBox(height: 16),

                                  // Confirm Password
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: _obscurePassword,
                                    decoration: const InputDecoration(
                                      labelText: AppStrings.confirmPassword,
                                      prefixIcon: Icon(Icons.lock_reset_outlined),
                                    ),
                                    validator: (v) => (v != _passwordController.text) ? 'Mật khẩu không khớp' : null,
                                  ),
                                  const SizedBox(height: 24),

                                  // Register button
                                  SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : _handleRegister,
                                      child: isLoading
                                          ? const CircularProgressIndicator(color: Colors.white)
                                          : const Text(AppStrings.register),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: TextButton(
                              onPressed: () => context.go('/login'),
                              child: const Text(AppStrings.alreadyHaveAccount),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
