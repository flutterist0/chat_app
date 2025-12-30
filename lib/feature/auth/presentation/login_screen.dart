import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/feature/auth/presentation/register_screen.dart';
import 'package:test_app/feature/chat/presentation/screens/chat_list_screen.dart';
import 'package:test_app/shared/routers/app_router.dart';
import '../data/auth_service.dart';
// Bloc fayllarını import etməyi unutmayın (yuxarıda yaratdığımız fayllar)
import '../logic/login/bloc/login_bloc.dart';

@RoutePage()
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 1. Bloc-u yaradırıq və ağaca (tree) əlavə edirik
    return BlocProvider(
      create: (context) => LoginBloc(AuthService()),
      child: _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 2. BlocConsumer həm dinləyir (Listener), həm də çəkir (Builder)
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            // Uğurlu giriş -> Yönləndirmə
            context.router.push(ChatsListRoute());
          } else if (state is LoginFailure) {
            // Xəta -> SnackBar göstər
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // Loading vəziyyətini yoxlayırıq
          final bool isLoading = state is LoginLoading;

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 60),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chat_bubble_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 32),
                      Text(
                        'Xoş gəlmisiniz!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Hesabınıza daxil olun',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 40),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isLoading, // Loading gedərkən inputu dondururuq
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'email@example.com',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email daxil edin';
                          if (!value.contains('@')) return 'Düzgün email daxil edin';
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: 'Şifrə',
                          hintText: '••••••••',
                          prefixIcon: Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Şifrə daxil edin';
                          if (value.length < 6) return 'Şifrə ən azı 6 simvol olmalıdır';
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      // Daxil ol düyməsi
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                          if (_formKey.currentState!.validate()) {
                            // 3. Bloc-a EVENT göndəririk
                            context.read<LoginBloc>().add(
                              LoginSubmitted(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : Text(
                          'Daxil ol',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      // Qeydiyyat linki
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hesabınız yoxdur? ',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RegisterScreen()),
                              );
                            },
                            child: Text(
                              'Qeydiyyatdan keçin',
                              style: TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w600,
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
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}