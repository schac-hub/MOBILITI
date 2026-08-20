import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../home/main_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const route = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Driver specific controllers
  final _carModelController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _carColorController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _carYearController = TextEditingController();
  final _carCapacityController = TextEditingController();
  
  String _userType = 'passenger'; // 'passenger' or 'driver'
  File? _carImage;
  File? _licenseImage;
  File? _idCardImage;
  final _picker = ImagePicker();
  
  bool _acceptTerms = false;

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _carModelController.dispose();
    _licensePlateController.dispose();
    _carColorController.dispose();
    _licenseNumberController.dispose();
    _carYearController.dispose();
    _carCapacityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        if (type == 'car') _carImage = File(pickedFile.path);
        if (type == 'license') _licenseImage = File(pickedFile.path);
        if (type == 'id') _idCardImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions générales'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_userType == 'driver') {
      if (_carImage == null || _licenseImage == null || _idCardImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez fournir toutes les photos requises'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
    }

    final authProvider = context.read<AuthProvider>();
    
    // Nettoyage du numéro de téléphone
    String phone = _phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');
    if (phone.startsWith('+225')) {
      phone = phone.substring(4);
    } else if (phone.startsWith('225')) {
      phone = phone.substring(3);
    }

    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: phone,
      userType: _userType,
      carModel: _userType == 'driver' ? _carModelController.text.trim() : null,
      licensePlate: _userType == 'driver' ? _licensePlateController.text.trim() : null,
      carColor: _userType == 'driver' ? _carColorController.text.trim() : null,
      licenseNumber: _userType == 'driver' ? _licenseNumberController.text.trim() : null,
      carYear: _userType == 'driver' ? int.tryParse(_carYearController.text) : null,
      carCapacity: _userType == 'driver' ? int.tryParse(_carCapacityController.text) : null,
      carImage: _userType == 'driver' ? _carImage : null,
      licenseImage: _userType == 'driver' ? _licenseImage : null,
      idCardImage: _userType == 'driver' ? _idCardImage : null,
    );

    if (mounted) {
      if (success) {
        Navigator.pushReplacementNamed(context, MainScreen.route);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Erreur lors de l\'inscription'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Téléphone requis';
    }
    final phoneRegex = RegExp(r'^[0-9+\-\s()]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Numéro invalide (10-15 chiffres)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }
    if (value.length < 6) {
      return 'Minimum 6 caractères';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmez le mot de passe';
    }
    if (value != _passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  Widget _typeCard(String type, String label, IconData icon) {
    final active = _userType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _userType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? AppColors.primary : AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: active ? Colors.white : AppColors.text, size: 28),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: active ? Colors.white : AppColors.text, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePickerTile(String label, File? image, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(image == null ? Icons.camera_alt_outlined : Icons.check_circle, 
                   color: image == null ? AppColors.muted : Colors.green),
              const SizedBox(width: 16),
              Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
              if (image != null) ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(image, height: 40, width: 40, fit: BoxFit.cover),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Créer un compte',
          style: TextStyle(color: AppColors.text),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rejoignez Mobiliti',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Nom',
                        hintText: 'Traoré',
                        controller: _lastNameController,
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Prénom',
                        hintText: 'Aïssata',
                        controller: _firstNameController,
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Email',
                  hintText: 'votre@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Numéro de téléphone',
                  hintText: '+221 77 XXX XX XX',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  maxLength: 15,
                  showCounter: true,
                  validator: _validatePhone,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                
                // --- Type d'utilisateur ---
                const Text('Vous êtes ?', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _typeCard('passenger', 'Passager', Icons.person_outline),
                    const SizedBox(width: 12),
                    _typeCard('driver', 'Conducteur', Icons.drive_eta_outlined),
                  ],
                ),
                const SizedBox(height: 24),

                if (_userType == 'driver') ...[
                  const Text('Informations du véhicule', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: CustomTextField(label: 'Modèle', hintText: 'Ex: Toyota Corolla', controller: _carModelController)),
                      const SizedBox(width: 12),
                      Expanded(child: CustomTextField(label: 'Couleur', hintText: 'Ex: Blanc', controller: _carColorController)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: CustomTextField(label: 'Plaque', hintText: 'XX-1234-YY', controller: _licensePlateController)),
                      const SizedBox(width: 12),
                      Expanded(child: CustomTextField(label: 'Année', hintText: '2018', controller: _carYearController, keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: CustomTextField(label: 'Permis', hintText: 'Numéro', controller: _licenseNumberController)),
                      const SizedBox(width: 12),
                      Expanded(child: CustomTextField(label: 'Places', hintText: '4', controller: _carCapacityController, keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  const Text('Documents (Photos)', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _imagePickerTile('Photo du véhicule', _carImage, () => _pickImage('car')),
                  _imagePickerTile('Photo du permis', _licenseImage, () => _pickImage('license')),
                  _imagePickerTile('Photo de la CNI', _idCardImage, () => _pickImage('id')),
                  const SizedBox(height: 24),
                ],

                CustomTextField(
                  label: 'Mot de passe',
                  hintText: '••••••••',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outlined,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Confirmer le mot de passe',
                  hintText: '••••••••',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outlined,
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() => _acceptTerms = value ?? false);
                      },
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 12, color: AppColors.text),
                          children: [
                            TextSpan(text: 'J\'accepte les '),
                            TextSpan(
                              text: 'conditions générales',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) => CustomButton(
                    text: 'S\'inscrire',
                    onPressed: _submit,
                    isLoading: authProvider.isLoading,
                    enabled: !authProvider.isLoading,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Déjà inscrit? ',
                      style: TextStyle(fontSize: 14, color: AppColors.muted),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, LoginScreen.route),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
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
}