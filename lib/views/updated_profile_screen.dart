import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';

class UpdatedProfileScreen extends StatelessWidget {
  const UpdatedProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final UserModel? user = authController.appUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Updated'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text("No user data found."))
          : Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A148C), Color(0xFF673AB7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: user.imageUrl.isNotEmpty
                      ? NetworkImage(user.imageUrl)
                      : const AssetImage('assets/profile_placeholder.jpg') as ImageProvider,
                ),
                const SizedBox(height: 20),
                Text(
                  user.name,
                  style: GoogleFonts.montserrat(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailTile(Icons.phone, "Phone", user.phone),
                _buildDetailTile(Icons.flag, "Country", user.country),
                _buildDetailTile(Icons.location_on, "Location", user.location),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text('Back to Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/profile');
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 10),
          Text(
            "$title: ",
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not set',
              style: GoogleFonts.openSans(
                color: Colors.white70,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
