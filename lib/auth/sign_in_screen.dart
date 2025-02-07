import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/auth/component/user_demo_mode_screen.dart';
import 'package:handyman_provider_flutter/auth/forgot_password_dialog.dart';
import 'package:handyman_provider_flutter/auth/sign_up_screen.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/selected_item_widget.dart';
import 'package:handyman_provider_flutter/handyman/handyman_dashboard_screen.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/provider/provider_dashboard_screen.dart';
import 'package:handyman_provider_flutter/utils/app_configuration.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../networks/rest_apis.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  //-------------------------------- Variables -------------------------------//

  /// TextEditing controller
  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  /// FocusNodes
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  /// FormKey
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// AutoValidate mode
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  bool isRemember = getBoolAsync(IS_REMEMBERED);

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
    emailCont.dispose();
    passwordCont.dispose();
    passwordFocus.dispose();
    emailFocus.dispose();
  }

  void init() async {
    if (await isIqonicProduct) {
      emailCont.text = getStringAsync(USER_EMAIL);
      passwordCont.text = getStringAsync(USER_PASSWORD);
      setState(() {});
    }
  }




  void googleSignIn() async {
    // if (!appStore.isLoading) {
    //   appStore.setLoading(true);
    //   await authService.signInWithGoogle(context).then((googleUser) async {
    //     String firstName = '';
    //     String lastName = '';
    //     if (googleUser.displayName.validate().split(' ').length >= 1)
    //       firstName = googleUser.displayName.splitBefore(' ');
    //     if (googleUser.displayName.validate().split(' ').length >= 2)
    //       lastName = googleUser.displayName.splitAfter(' ');
    //
    //     Map<String, dynamic> request = {
    //       'first_name': firstName,
    //       'last_name': lastName,
    //       'email': googleUser.email,
    //       'username': googleUser.email
    //           .splitBefore('@')
    //           .replaceAll('.', '')
    //           .toLowerCase(),
    //       // 'password': passwordCont.text.trim(),
    //       'social_image': googleUser.photoURL,
    //       'login_type': LOGIN_TYPE_GOOGLE,
    //     };
    //     var loginResponse = await loginUser(request, isSocialLogin: true);
    //
    //     loginResponse.userData!.profileImage = googleUser.photoURL.validate();
    //
    //     await saveUserData(loginResponse.userData!);
    //     appStore.setLoginType(LOGIN_TYPE_GOOGLE);
    //
    //     authService.verifyFirebaseUser();
    //
    //     onLoginSuccessRedirection();
    //     appStore.setLoading(false);
    //   }).catchError((e) {
    //     appStore.setLoading(false);
    //     log(e.toString());
    //     toast(e.toString());
    //   });
    // }
  }

  void appleSign() async {
    // if (!appStore.isLoading) {
    //   appStore.setLoading(true);
    //
    //   await authService.appleSignIn().then((req) async {
    //     await loginUser(req, isSocialLogin: true).then((value) async {
    //       await saveUserData(value.userData!);
    //       appStore.setLoginType(LOGIN_TYPE_APPLE);
    //
    //       appStore.setLoading(false);
    //       authService.verifyFirebaseUser();
    //
    //       onLoginSuccessRedirection();
    //     }).catchError((e) {
    //       appStore.setLoading(false);
    //       log(e.toString());
    //       throw e;
    //     });
    //   }).catchError((e) {
    //     appStore.setLoading(false);
    //     toast(e.toString());
    //   });
    // }
  }

  void otpSignIn() async {
    // hideKeyboard(context);
    //
    // OTPLoginScreen().launch(context);
  }

  void onLoginSuccessRedirection() {
    // afterBuildCreated(() {
    //   appStore.setLoading(false);
    //   if (widget.isFromServiceBooking.validate() ||
    //       widget.isFromDashboard.validate() ||
    //       widget.returnExpected.validate()) {
    //     if (widget.isFromDashboard.validate()) {
    //       push(DashboardScreen(redirectToBooking: true),
    //           isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
    //     } else {
    //       finish(context, true);
    //     }
    //   } else {
    //     DashboardScreen().launch(context,
    //         isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
    //   }
    // });
  }



  //------------------------------------ UI ----------------------------------//

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SizedBox(
          height: context.height(),
          width: context.width(),
          child: Stack(
            children: [
              Form(
                key: formKey,
                autovalidateMode: autovalidateMode,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppBar().preferredSize.height),
                      // Hello again with Welcome text
                      _buildHelloAgainWithWelcomeText(),

                      AutofillGroup(
                        onDisposeAction: AutofillContextAction.commit,
                        child: Column(
                          children: [
                            // Enter email text field.
                            AppTextField(
                              textFieldType: TextFieldType.EMAIL_ENHANCED,
                              controller: emailCont,
                              focus: emailFocus,
                              nextFocus: passwordFocus,
                              errorThisFieldRequired: languages.hintRequired,
                              decoration: inputDecoration(context, hint: languages.hintEmailAddressTxt),
                              suffix: ic_message.iconImage(size: 10).paddingAll(14),
                              autoFillHints: [AutofillHints.email],
                              onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(passwordFocus),
                            ),
                            16.height,
                            // Enter password text field
                            AppTextField(
                              textFieldType: TextFieldType.PASSWORD,
                              controller: passwordCont,
                              focus: passwordFocus,
                              obscureText: true,
                              errorThisFieldRequired: languages.hintRequired,
                              suffixPasswordVisibleWidget: ic_show.iconImage(size: 10).paddingAll(14),
                              suffixPasswordInvisibleWidget: ic_hide.iconImage(size: 10).paddingAll(14),
                              errorMinimumPasswordLength: "${languages.errorPasswordLength} $passwordLengthGlobal",
                              decoration: inputDecoration(context, hint: languages.hintPassword),
                              autoFillHints: [AutofillHints.password],
                              onFieldSubmitted: (s) {
                                _handleLogin();
                              },
                            ),
                            8.height,
                          ],
                        ),
                      ),

                      _buildForgotRememberWidget(),
                      _buildButtonWidget(),
                      if (!getBoolAsync(HAS_IN_REVIEW)) _buildSocialWidget(),
                      16.height,
                      SnapHelperWidget<bool>(
                        future: isIqonicProduct,
                        onSuccess: (data) {
                          if (data) {
                            return UserDemoModeScreen(
                              onChanged: (email, password) {
                                if (email.isNotEmpty && password.isNotEmpty) {
                                  emailCont.text = email;
                                  passwordCont.text = password;
                                } else {
                                  emailCont.clear();
                                  passwordCont.clear();
                                }
                              },
                            );
                          }
                          return Offstage();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Observer(
                builder: (_) => LoaderWidget().center().visible(appStore.isLoading),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //region Widgets
  Widget _buildHelloAgainWithWelcomeText() {
    return Column(
      children: [
        32.height,
        Text(languages.lblLoginTitle, style: boldTextStyle(size: 18)).center(),
        16.height,
        Text(
          languages.lblLoginSubtitle,
          style: secondaryTextStyle(size: 14),
          textAlign: TextAlign.center,
        ).paddingSymmetric(horizontal: 32).center(),
        64.height,
      ],
    );
  }

  Widget _buildForgotRememberWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                2.width,
                SelectedItemWidget(isSelected: isRemember).onTap(() async {
                  await setValue(IS_REMEMBERED, isRemember);
                  isRemember = !isRemember;
                  setState(() {});
                }),
                TextButton(
                  onPressed: () async {
                    await setValue(IS_REMEMBERED, isRemember);
                    isRemember = !isRemember;
                    setState(() {});
                  },
                  child: Text(languages.rememberMe, style: secondaryTextStyle()),
                ),
              ],
            ),
            TextButton(
              child: Text(
                languages.forgotPassword,
                style: boldTextStyle(color: primaryColor, fontStyle: FontStyle.italic),
                textAlign: TextAlign.right,
              ),
              onPressed: () {
                showInDialog(
                  context,
                  contentPadding: EdgeInsets.zero,
                  builder: (_) => ForgotPasswordScreen(),
                );
              },
            ).flexible()
          ],
        ),
        32.height,
      ],
    );
  }

  Widget _buildButtonWidget() {
    return Column(
      children: [
        AppButton(
          text: languages.signIn,
          height: 40,
          color: primaryColor,
          textStyle: boldTextStyle(color: white),
          width: context.width() - context.navigationBarHeight,
          onTap: () {
            _handleLogin();
          },
        ),
        16.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(languages.doNotHaveAccount, style: secondaryTextStyle()),
            TextButton(
              onPressed: () {
                SignUpScreen().launch(context);
              },
              child: Text(
                languages.signUp,
                style: boldTextStyle(
                  color: primaryColor,
                  decoration: TextDecoration.underline,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          ],
        ),
        TextButton(
          onPressed: () {
            if (isAndroid) {
              if (getStringAsync(PROVIDER_PLAY_STORE_URL).isNotEmpty) {
                launchUrl(Uri.parse(getStringAsync(PROVIDER_PLAY_STORE_URL)),
                    mode: LaunchMode.externalApplication);
              } else {
                launchUrl(
                    Uri.parse(
                        '${getSocialMediaLink(LinkProvider.PLAY_STORE)}$CUSTOMER_PACKAGE_NAME'),
                    mode: LaunchMode.externalApplication);
              }
            } else if (isIOS) {
              if (getStringAsync(PROVIDER_APPSTORE_URL).isNotEmpty) {
                commonLaunchUrl(getStringAsync(PROVIDER_APPSTORE_URL));
              } else {
                commonLaunchUrl(IOS_LINK_FOR_PARTNER);
              }
            }
          },
          child: Text(languages.lblRegisterAsUser,
              style: boldTextStyle(color: primaryColor)),
        )
      ],
    );
  }

  //endregion

  Widget _buildSocialWidget() {
    // if (appConfigurationStore.socialLoginStatus) {
      return Column(
        children: [
          20.height,
          // if ((appConfigurationStore.googleLoginStatus ||
          //     appConfigurationStore.otpLoginStatus) ||
          //     (isIOS && appConfigurationStore.appleLoginStatus))
            Row(
              children: [
                Divider(color: context.dividerColor, thickness: 2).expand(),
                16.width,
                Text(languages.lblOrContinueWith, style: secondaryTextStyle()),
                16.width,
                Divider(color: context.dividerColor, thickness: 2).expand(),
              ],
            ),
          24.height,
          // if (appConfigurationStore.googleLoginStatus)
            AppButton(
              text: '',
              color: context.cardColor,
              padding: EdgeInsets.all(8),
              textStyle: boldTextStyle(),
              width: context.width() - context.navigationBarHeight,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: primaryColor.withOpacity(0.1),
                      boxShape: BoxShape.circle,
                    ),
                    child: GoogleLogoWidget(size: 16),
                  ),
                  Text(languages.lblSignInWithGoogle,
                      style: boldTextStyle(size: 12),
                      textAlign: TextAlign.center)
                      .expand(),
                ],
              ),
              onTap: googleSignIn,
            ),
          // if (appConfigurationStore.googleLoginStatus)
            16.height,
          // if (appConfigurationStore.otpLoginStatus)
            AppButton(
              text: '',
              color: context.cardColor,
              padding: EdgeInsets.all(8),
              textStyle: boldTextStyle(),
              width: context.width() - context.navigationBarHeight,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: primaryColor.withOpacity(0.1),
                      boxShape: BoxShape.circle,
                    ),
                    child: ic_calling
                        .iconImage(size: 18, color: primaryColor)
                        .paddingAll(4),
                  ),
                  Text(languages.lblSignInWithOTP,
                      style: boldTextStyle(size: 12),
                      textAlign: TextAlign.center)
                      .expand(),
                ],
              ),
              onTap: otpSignIn,
            ),
          if (appConfigurationStore.otpLoginStatus) 16.height,
          if (isIOS)
            if (appConfigurationStore.appleLoginStatus)
              AppButton(
                text: '',
                color: context.cardColor,
                padding: EdgeInsets.all(8),
                textStyle: boldTextStyle(),
                width: context.width() - context.navigationBarHeight,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: primaryColor.withOpacity(0.1),
                        boxShape: BoxShape.circle,
                      ),
                      child: Icon(Icons.apple),
                    ),
                    Text(languages.lblSignInWithApple,
                        style: boldTextStyle(size: 12),
                        textAlign: TextAlign.center)
                        .expand(),
                  ],
                ),
                onTap: appleSign,
              ),
        ],
      );
    // }
    // else {
    //   return Offstage();
    // }
  }


  //region Methods
  void _handleLogin() {
    hideKeyboard(context);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      _handleLoginUsers();
    }
  }

  void _handleLoginUsers() async {
    hideKeyboard(context);
    Map<String, dynamic> request = {
      'email': emailCont.text.trim(),
      'password': passwordCont.text.trim(),
      'login_type': IS_USER,
    };

    appStore.setLoading(true);
    try {
      UserData user = await loginUser(request);

      if (user.status != 1) {
        appStore.setLoading(false);
        return toast(languages.pleaseContactYourAdmin);
      }

      await setValue(USER_PASSWORD, passwordCont.text);
      await setValue(IS_REMEMBERED, isRemember);
      await appStore.setLoginType(IS_USER);
      await saveUserData(user);

      authService.verifyFirebaseUser();

      redirectWidget(res: user);
    } catch (e) {
      appStore.setLoading(false);
      toast(e.toString());
    }
  }

  void redirectWidget({required UserData res}) async {
    appStore.setLoading(false);
    TextInput.finishAutofillContext();

    if (res.status.validate() == 1) {
      await appStore.setToken(res.apiToken.validate());
      appStore.setTester(res.email == DEFAULT_PROVIDER_EMAIL || res.email == DEFAULT_HANDYMAN_EMAIL);

      // Set the user ID in the appStore
      appStore.setUserId(res.id.validate());
      print('User ID set in appStore: ${appStore.userId}');
      if (res.userType.validate().trim() == USER_TYPE_PROVIDER) {
        ProviderDashboardScreen(index: 0).launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
      } else if (res.userType.validate().trim() == USER_TYPE_HANDYMAN || res.userType.validate().trim() == IS_USER) {
        HandymanDashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
      } else {
        toast(languages.cantLogin, print: true);
      }
    } else {
      toast(languages.lblWaitForAcceptReq);
    }
  }

  // void redirectWidget({required UserData res}) async {
  //   appStore.setLoading(false);
  //   TextInput.finishAutofillContext();
  //
  //   if (res.status.validate() == 1 || res.status.validate() == 0) { // Allow login if status is 0
  //     await appStore.setToken(res.apiToken.validate());
  //     appStore.setTester(res.email == DEFAULT_PROVIDER_EMAIL || res.email == DEFAULT_HANDYMAN_EMAIL);
  //
  //     // Navigate to ProviderDashboardScreen for provider and user types
  //     if (res.userType.validate().trim() == USER_TYPE_PROVIDER ) {
  //       ProviderDashboardScreen(index: 0).launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
  //     }
  //     else if (res.userType.validate().trim() == USER_TYPE_HANDYMAN || res.userType.validate().trim() == IS_USER) {
  //       HandymanDashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
  //     }
  //     else {
  //       toast(languages.cantLogin, print: true);
  //     }
  //   } else {
  //     toast(languages.lblWaitForAcceptReq); // Show proper message for pending users
  //   }
  // }
  //endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }
}
