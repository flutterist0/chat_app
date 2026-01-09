import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/auth/domain/repositories/auth_repository.dart';
import 'package:test_app/shared/injection_container.dart';
import 'package:test_app/shared/themes/app_styles.dart';

@RoutePage()
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = getIt<AuthRepository>().currentUser;
    _nameController = TextEditingController(text: user?.displayName);
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await getIt<AuthRepository>().updateProfile(
        name: _nameController.text.trim(),
        password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      );
      
      await FirebaseAuth.instance.currentUser?.reload();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profil uğurla yeniləndi!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profilə Düzəliş"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Ad Soyad",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => 
                    value == null || value.isEmpty ? "Ad boş ola bilməz" : null,
              ),
              SizedBox(height: 16.h),

              SizedBox(height: 16.h),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Yeni Şifrə (Dəyişmək istəmirsinizsə boş buraxın)",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return "Şifrə ən azı 6 simvol olmalıdır";
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryBlue,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Yadda Saxla", style: TextStyle(fontSize: 16.sp, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
