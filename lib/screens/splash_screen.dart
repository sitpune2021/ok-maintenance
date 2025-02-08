import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/auth/sign_in_screen.dart';
import 'package:handyman_provider_flutter/handyman/handyman_dashboard_screen.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/provider/provider_dashboard_screen.dart';
import 'package:handyman_provider_flutter/screens/maintenance_mode_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/app_widgets.dart';
import '../networks/rest_apis.dart';
import '../utils/constant.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool appNotSynced = false;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      setStatusBarColor(Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness:
              appStore.isDarkMode ? Brightness.light : Brightness.dark);

      init();
    });
  }

  // Future<void> init() async {
  //   ///Set app configurations
  //   await getAppConfigurations().then((value) {}).catchError((e) async {
  //     if (!await isNetworkAvailable()) {
  //       toast(errorInternetNotAvailable);
  //     }
  //     log(e);
  //   });
  //
  //   appStore.setLoading(false);
  //   if (!getBoolAsync(IS_APP_CONFIGURATION_SYNCED_AT_LEAST_ONCE)) {
  //     appNotSynced = true;
  //     setState(() {});
  //   } else {
  //     appStore.setLanguage(
  //         getStringAsync(SELECTED_LANGUAGE_CODE,
  //             defaultValue: DEFAULT_LANGUAGE),
  //         context: context);
  //     int themeModeIndex =
  //         getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_SYSTEM);
  //     if (themeModeIndex == THEME_MODE_SYSTEM) {
  //       appStore.setDarkMode(
  //           MediaQuery.of(context).platformBrightness == Brightness.dark);
  //     }
  //
  //     if (appConfigurationStore.maintenanceModeStatus) {
  //       MaintenanceModeScreen()
  //           .launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
  //     } else {
  //     // Check if the user is unauthorized and logged in, then clear preferences and cached data.
  //     // This condition occurs when the user is marked as inactive from the admin panel,
  //     if (!appConfigurationStore.isUserAuthorized && appStore.isLoggedIn) {
  //       await clearPreferences();
  //     }
  //
  //     if (!appStore.isLoggedIn || appStore.userId.toString().isEmpty) {
  //       await updateProfilePhoto();
  //       log('User ID: ${appStore.userId}');
  //       print('User ID: ${appStore.userId}');
  //       SignInScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
  //     }
  //     else {
  //       await updateProfilePhoto();
  //       log('User ID2: ${appStore.userId}');
  //       print('User ID2: ${appStore.userId}');
  //       if (isUserTypeProvider) {
  //         ProviderDashboardScreen(index: 0).launch(context, isNewTask: true);
  //       } else if (isUserTypeHandyman) {
  //         HandymanDashboardScreen(index: 0).launch(context, isNewTask: true);
  //       }
  //       else {
  //         SignInScreen().launch(context, isNewTask: true);
  //       }
  //     }
  //
  //     }
  //   }
  // }
  Future<void> init() async {
    /// Set app configurations
    await getAppConfigurations().then((value) {}).catchError((e) async {
      if (!await isNetworkAvailable()) {
        toast(errorInternetNotAvailable);
      }
      log(e);
    });

    appStore.setLoading(false);
    if (!getBoolAsync(IS_APP_CONFIGURATION_SYNCED_AT_LEAST_ONCE)) {
      appNotSynced = true;
      setState(() {});
    } else {
      appStore.setLanguage(
          getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: DEFAULT_LANGUAGE),
          context: context);
      int themeModeIndex =
      getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_SYSTEM);
      if (themeModeIndex == THEME_MODE_SYSTEM) {
        appStore.setDarkMode(
            MediaQuery.of(context).platformBrightness == Brightness.dark);
      }

      if (appConfigurationStore.maintenanceModeStatus) {
        MaintenanceModeScreen()
            .launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
      } else {
        // Check if the user is unauthorized and logged in, then clear preferences and cached data.
        if (!appConfigurationStore.isUserAuthorized && appStore.isLoggedIn) {
          await clearPreferences();
        }

        // Log User ID before making decisions
        if (appStore.userId.toString().isNotEmpty) {
          log('User ID Available: ${appStore.userId}');
          print('User ID Available: ${appStore.userId}');
        } else {
          log('User ID Not Found');
          print('User ID Not Found');
        }

        // Add the requested if condition
        if (!appStore.isLoggedIn || appStore.userId.toString().isEmpty) {
          await updateProfilePhoto();
          log('Navigating to SignInScreen');
          SignInScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
        } else
        {
          await updateProfilePhoto();
          log('User ID2 Available: ${appStore.userId}');
          print('User ID2 Available: ${appStore.userId}');

          if (isUserTypeProvider) {
            ProviderDashboardScreen(index: 0).launch(context, isNewTask: true);
          } else if (isUserTypeHandyman) {
            HandymanDashboardScreen(index: 0).launch(context, isNewTask: true);
          }else if(isUserTypeUser){
            HandymanDashboardScreen(index: 0).launch(context, isNewTask: true);
          }
          else {
            SignInScreen().launch(context, isNewTask: true);
          }
        }
      }
    }
  }

  updateProfilePhoto() async {
     getUserDetail(appStore.userId).then((value) async {
      await appStore.setUserProfile(value.data!.profileImage.validate());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            appStore.isDarkMode ? splash_background : splash_light_background,
            height: context.height(),
            width: context.width(),
            fit: BoxFit.cover,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(appLogo, height: 120, width: 120),
              32.height,
              Text(APP_NAME,
                  style: boldTextStyle(
                      size: 26,
                      color: appStore.isDarkMode ? Colors.white : Colors.black),
                  textAlign: TextAlign.center),
              16.height,
              if (appNotSynced)
                Observer(
                  builder: (_) => appStore.isLoading
                      ? LoaderWidget().center()
                      : TextButton(
                          child: Text(languages.reload, style: boldTextStyle()),
                          onPressed: () {
                            appStore.setLoading(true);
                            init();
                          },
                        ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
