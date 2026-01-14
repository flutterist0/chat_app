import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/feature/auth/presentation/register_screen.dart';
import 'package:test_app/feature/chat/presentation/screens/chat_list_screen.dart';
import 'package:test_app/l10n/app_localizations.dart';
import 'package:test_app/shared/injection_container.dart';
import 'package:test_app/shared/routers/app_router.dart';
import 'package:test_app/shared/routers/app_router.dart';
import '../service/auth_service.dart';
import '../logic/bloc/login/login_bloc.dart';
import 'package:test_app/feature/auth/presentation/widgets/auth_header.dart';
import 'package:test_app/feature/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/shared/themes/app_styles.dart';

@RoutePage()
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginBloc>(),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            context.router.push(ChatsListRoute());
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppStyles.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final bool isLoading = state is LoginLoading;

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(AppStyles.paddingDefault),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 60.h),
                      AuthHeader(
                        icon: Icons.chat_bubble_rounded,
                        title: AppLocalizations.of(context)!.welcome,
                        subTitle: AppLocalizations.of(context)!.loginAccount,
                      ),
                      SizedBox(height: 40.h),
                      AuthTextField(
                        controller: _emailController,
                        label: AppLocalizations.of(context)!.email,
                        hint: AppLocalizations.of(context)!.emailPlaceholder,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) return AppLocalizations.of(context)!.enterEmail;
                          if (!value.contains('@')) return AppLocalizations.of(context)!.validEmail;
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      AuthTextField(
                        controller: _passwordController,
                        label: AppLocalizations.of(context)!.password,
                        hint: AppLocalizations.of(context)!.passwordHintText,
                        prefixIcon: Icons.lock_outlined,
                        isPassword: true,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) return AppLocalizations.of(context)!.enterPassword;
                          if (value.length < 6) return AppLocalizations.of(context)!.passwordLeastCharacter;
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                          if (_formKey.currentState!.validate()) {
                            context.read<LoginBloc>().add(
                              LoginSubmitted(
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
                          AppLocalizations.of(context)!.login,
                          style: AppStyles.buttonText,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      OutlinedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () {
                                context.read<LoginBloc>().add(LoginWithGoogle());
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
                          AppLocalizations.of(context)!.continueWithGoogle,
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
                            AppLocalizations.of(context)!.dontHaveAccount,
                            style: AppStyles.bodyText(context),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.router.push(RegisterRoute());
                            },
                            child: Text(
                              AppLocalizations.of(context)!.register,
                              style: AppStyles.linkText,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      TextButton.icon(
                        onPressed: () {
                          context.router.push(AccountCenterRoute());
                        },
                        icon: Icon(Icons.manage_accounts, color: AppStyles.primaryBlue),
                        label: Text(
                          AppLocalizations.of(context)!.savedAccounts,
                          style: TextStyle(color: AppStyles.primaryBlue),
                        ),
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