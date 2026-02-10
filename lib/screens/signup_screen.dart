import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/theme_extensions.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: context.themeColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Logo (Top)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: context.themeColors.colorPrimary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        'TR',
                        style: TextStyle(
                          color: context.themeColors.textInverse,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title "Bienvenue !"
                  Text(
                    'Bienvenue !',
                    style: TextStyle(
                      color: context.themeColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'Nous sommes ravis de vous voir',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Card Container for Inputs
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.themeColors.bgSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('NOM D\'UTILISATEUR'),
                        const SizedBox(height: 8),
                        _buildInput(_usernameController, 'Votre pseudo', false),

                        const SizedBox(height: 20),

                        _buildLabel('EMAIL'),
                        const SizedBox(height: 8),
                        _buildInput(_emailController, 'nom@exemple.com', false),

                        const SizedBox(height: 20),

                        _buildLabel('MOT DE PASSE'),
                        const SizedBox(height: 8),
                        _buildInput(
                            _passwordController, 'Votre mot de passe', true),

                        const SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Mock navigation to OTP or Home
                                Navigator.pushNamed(context, '/otp');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.themeColors.colorPrimary,
                              foregroundColor: context.themeColors.textInverse,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text(
                              'S\'inscrire',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: context.themeColors.borderMedium)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text('ou',
                                  style: TextStyle(
                                      color: context.themeColors.textMuted)),
                            ),
                            Expanded(
                                child: Divider(
                                    color: context.themeColors.borderMedium)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Continue with Google
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.g_mobiledata,
                                color: Colors.black, size: 28),
                            label: const Text(
                              'Continuer avec Google',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Déjà un compte ? ",
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context); // Go back to login
                              },
                              child: const Text(
                                'Se connecter',
                                style: TextStyle(
                                  color: AppTheme.telegramBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInput(
      TextEditingController controller, String hint, bool isPassword) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: context.themeColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.themeColors.textMuted),
        filled: true,
        fillColor: context.themeColors.bgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est requis';
        }
        return null;
      },
    );
  }
}
