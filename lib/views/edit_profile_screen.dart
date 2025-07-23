import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthController>(context, listen: false).appUser;
      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        _countryController.text = user.country;
        _locationController.text = user.location;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      final authController = Provider.of<AuthController>(context, listen: false);
      final user = authController.appUser;
      if (user == null) return;

      authController.setLoading(true);

      final updatedUser = UserModel(
        uid: user.uid,
        name: _nameController.text.trim(),
        email: user.email,
        imageUrl: user.imageUrl,
        phone: _phoneController.text.trim(),
        country: _countryController.text.trim(),
        location: _locationController.text.trim(),
      );

      await authController.updateUserData(updatedUser);

      if (!mounted) return;

      if (authController.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authController.errorMessage!), backgroundColor: Colors.red),
        );
      } else {
        Navigator.pushReplacementNamed(context, '/updatedProfile');
      }

      authController.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final user = authController.appUser;
        if (user == null && authController.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Edit Profile"),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A148C), Color(0xFF673AB7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/profile_placeholder.jpg'),
                      ),
                      const SizedBox(height: 30),
                      _buildTextField(_nameController, 'Name', Icons.person),
                      const SizedBox(height: 16),
                      _buildTextField(_emailController, 'Email', Icons.email, readOnly: true),
                      const SizedBox(height: 16),
                      _buildTextField(_phoneController, 'Phone', Icons.phone),
                      const SizedBox(height: 16),
                      _buildTextField(_countryController, 'Country', Icons.flag),
                      const SizedBox(height: 16),
                      _buildTextField(_locationController, 'Location', Icons.location_on),
                      const SizedBox(height: 30),
                      authController.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : ElevatedButton(
                        onPressed: _submitUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          "Update Profile",
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool readOnly = false,
      }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      style: const TextStyle(color: Colors.white),
      validator: (value) => (value == null || value.isEmpty) ? 'This field is required' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: const Color.fromRGBO(255, 255, 255, 0.15),
        labelStyle: const TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromRGBO(255, 255, 255, 0.24)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
