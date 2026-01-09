import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/feature/auth/logic/bloc/register/register_bloc.dart';
import 'package:test_app/shared/injection_container.dart';
import 'package:test_app/shared/routers/app_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/auth/presentation/widgets/auth_header.dart';
import 'package:test_app/feature/auth/presentation/widgets/auth_text_field.dart';
import 'package:test_app/shared/themes/app_styles.dart';
import 'package:test_app/shared/utils/app_strings.dart';

@RoutePage()
class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RegisterBloc>(),
      child: _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();


  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            context.router.push(LoginRoute());
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.registerSuccess),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is RegisterGoogleSuccess) {
             context.router.replaceAll([ChatsListRoute()]);
          } else if (state is RegisterFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final bool isLoading = state is RegisterLoading;

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(AppStyles.paddingDefault),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 40.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      AuthHeader(
                        icon: Icons.person_add_rounded,
                        title: AppStrings.createAccount,
                        subTitle: AppStrings.registerAndChat,
                      ),
                      SizedBox(height: 32.h),
                      
                      AuthTextField(
                        controller: _nameController,
                        label: AppStrings.fullName,
                        hint: AppStrings.enterName,
                        prefixIcon: Icons.person_outlined,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) return AppStrings.enterNameError;
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      
                      AuthTextField(
                        controller: _emailController,
                        label: AppStrings.email,
                        hint: AppStrings.emailPlaceholder,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) return AppStrings.enterEmail;
                          if (!value.contains('@')) return AppStrings.correctValidEmail;
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      
                      AuthTextField(
                        controller: _passwordController,
                        label: AppStrings.password,
                        hint: AppStrings.passwordHintText,
                        prefixIcon: Icons.lock_outlined,
                        isPassword: true,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) return AppStrings.enterPassword;
                          if (value.length < 6) return AppStrings.passwordLeastCharacter;
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      
                      AuthTextField(
                        controller: _confirmPasswordController,
                        label: AppStrings.confirmPassword,
                        hint: AppStrings.passwordHintText,
                        prefixIcon: Icons.lock_outlined,
                        isPassword: true,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) return AppStrings.confirmPasswordError;
                          if (value != _passwordController.text) return AppStrings.passwordMismatchError;
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),
                      
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<RegisterBloc>().add(
                                        RegisterSubmitted(
                                          fullName: _nameController.text.trim(),
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text.trim(),
                                        ),
                                      );
                                }
                              },
                        style: AppStyles.primaryButton,
                        child: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppStyles.white),
                                ),
                              )
                            : Text(
                                AppStrings.registerAction,
                                  style: AppStyles.buttonText,
                              ),
                      ),
                      SizedBox(height: 16.h),
                      OutlinedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () {
                                context.read<RegisterBloc>().add(RegisterWithGoogle());
                              },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: BorderSide(color: AppStyles.primaryBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(Icons.g_mobiledata, size: 32.sp, color: AppStyles.primaryBlue),
                        label: Text(
                          "Google ilə davam et",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppStyles.primaryBlue,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.alreadyHaveAccount,
                            style: AppStyles.bodyText(context),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              AppStrings.loginAction,
                              style: AppStyles.linkText,
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}