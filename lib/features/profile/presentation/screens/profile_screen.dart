import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../home/bloc/profile_bloc.dart';
import '../../../home/bloc/profile_event.dart';
import '../../../home/bloc/profile_state.dart';
import '../../../auth/data/models/user_model.dart';

/// Profile editing screen — updates all user details in Firestore.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dobController;
  String _selectedGender = '';
  String _selectedNationality = '';
  String _selectedLanguage = '';
  bool _isInitialized = false;

  static const List<String> _genderOptions = ['Male', 'Female', 'Other'];
  static const List<String> _nationalityOptions = [
    'Indian',
    'American',
    'British',
    'Canadian',
    'Australian',
    'German',
    'French',
    'Japanese',
    'Chinese',
    'Brazilian',
    'South African',
    'Other',
  ];
  static const List<String> _languageOptions = [
    'English',
    'Hindi',
    'Spanish',
    'French',
    'German',
    'Japanese',
    'Chinese (Mandarin)',
    'Arabic',
    'Portuguese',
    'Bengali',
    'Tamil',
    'Telugu',
    'Other',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _initControllers(UserModel user) {
    if (!_isInitialized) {
      _firstNameController = TextEditingController(text: user.firstName);
      _lastNameController = TextEditingController(text: user.lastName);
      _dobController = TextEditingController(text: user.dateOfBirth);
      _selectedGender = user.gender;
      _selectedNationality = user.nationality;
      _selectedLanguage = user.languageSpoken;
      _isInitialized = true;
    }
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _onSave(UserModel currentUser) {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a gender'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_selectedNationality.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a nationality'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_selectedLanguage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a language'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final updatedUser = currentUser.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      dateOfBirth: _dobController.text,
      gender: _selectedGender,
      nationality: _selectedNationality,
      languageSpoken: _selectedLanguage,
    );
    context.read<ProfileBloc>().add(UpdateProfile(user: updatedUser));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: AppColors.secondary,
              ),
            );
            Navigator.pop(context);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoaded) {
            _initControllers(state.user);
            return _buildForm(context, state.user);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Avatar
            Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  user.firstName.isNotEmpty
                      ? user.firstName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // First Name
            TextFormField(
              controller: _firstNameController,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'First Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            // Last Name
            TextFormField(
              controller: _lastNameController,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Last Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            // Date of Birth
            TextFormField(
              controller: _dobController,
              readOnly: true,
              onTap: _selectDateOfBirth,
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                prefixIcon: Icon(Icons.calendar_today),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
            ),
            const SizedBox(height: 20),

            // Gender
            const Text(
              'Gender',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            RadioGroup<String>(
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() => _selectedGender = value ?? '');
              },
              child: Column(
                children: _genderOptions.map((gender) {
                  return RadioListTile<String>(
                    title: Text(gender),
                    value: gender,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

            // Nationality
            DropdownButtonFormField<String>(
              initialValue:
                  _selectedNationality.isEmpty ? null : _selectedNationality,
              decoration: const InputDecoration(
                labelText: 'Nationality',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: _nationalityOptions.map((n) {
                return DropdownMenuItem(value: n, child: Text(n));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedNationality = value ?? '');
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your nationality';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Language Spoken
            DropdownButtonFormField<String>(
              initialValue:
                  _selectedLanguage.isEmpty ? null : _selectedLanguage,
              decoration: const InputDecoration(
                labelText: 'Language Spoken',
                prefixIcon: Icon(Icons.language),
              ),
              items: _languageOptions.map((l) {
                return DropdownMenuItem(value: l, child: Text(l));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedLanguage = value ?? '');
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a language';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Save Button
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        state is ProfileLoading ? null : () => _onSave(user),
                    child: state is ProfileLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Changes'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
