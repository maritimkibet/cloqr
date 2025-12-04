import 'package:flutter/material.dart';
import 'avatar_selection_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String email;
  final String mode;
  final String? qrCode;
  final String? adminPassword;
  final String? password;
  final bool emailVerified;

  const ProfileSetupScreen({
    super.key,
    required this.email,
    required this.mode,
    this.qrCode,
    this.adminPassword,
    this.password,
    this.emailVerified = false,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _campusController = TextEditingController();
  final _yearController = TextEditingController();
  final _courseController = TextEditingController();
  final _bioController = TextEditingController();

  List<String> selectedInterests = [];
  String? selectedStudyStyle;

  final List<String> interestOptions = [
    'Music', 'Sports', 'Gaming', 'Reading', 'Movies',
    'Coding', 'Art', 'Travel', 'Food', 'Fitness'
  ];

  final List<String> studyStyles = [
    'Group Study', 'Solo Study', 'Library', 'Cafe', 'Online'
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _campusController.dispose();
    _yearController.dispose();
    _courseController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AvatarSelectionScreen(
          email: widget.email,
          username: _usernameController.text.trim(),
          campus: _campusController.text.trim(),
          mode: widget.mode,
          qrCode: widget.qrCode,
          adminPassword: widget.adminPassword,
          password: widget.password,
          emailVerified: widget.emailVerified,
          profileData: {
            'year': int.tryParse(_yearController.text),
            'course': _courseController.text.trim(),
            'bio': _bioController.text.trim(),
            'interests': selectedInterests,
            'study_style': selectedStudyStyle,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Profile'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Tell us about yourself',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _campusController,
                decoration: InputDecoration(
                  labelText: 'Campus',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter campus';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Year of Study',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _courseController,
                decoration: InputDecoration(
                  labelText: 'Course',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Interests',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: interestOptions.map((interest) {
                  final isSelected = selectedInterests.contains(interest);
                  return FilterChip(
                    label: Text(interest),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedInterests.add(interest);
                        } else {
                          selectedInterests.remove(interest);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              if (widget.mode == 'study') ...[
                const SizedBox(height: 24),
                Text(
                  'Study Style',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: studyStyles.map((style) {
                    final isSelected = selectedStudyStyle == style;
                    return ChoiceChip(
                      label: Text(style),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedStudyStyle = selected ? style : null;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
