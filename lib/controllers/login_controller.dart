import 'package:get/get.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/login_sign_up/set_user_name.dart';
import '../screens/login_sign_up/verify_phone_login_OTP.dart';
import '../screens/settings_menu/change_language.dart';
import '../util/shared_prefs.dart';
import 'dart:async';
import 'package:foap/manager/socket_manager.dart';
import 'package:foap/util/form_validator.dart';
import 'package:foap/apiHandler/api_controller.dart';
import 'package:foap/screens/dashboard/dashboard_screen.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
import 'package:foap/screens/login_sign_up/login_screen.dart';
import 'package:foap/screens/login_sign_up/verify_otp.dart';
import 'package:foap/screens/login_sign_up/reset_password.dart';

bool isLoginFirstTime = false;

class LoginController extends GetxController {
  final SettingsController _settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  bool passwordReset = false;
  int userNameCheckStatus = -1;
  RxBool canResendOTP = true.obs;

  RxString passwordStrengthText = ''.obs;
  RxDouble passwordStrength = 0.toDouble().obs;
  RxString phoneCountryCode = '+1'.obs;

  int pinLength = 4;
  RxBool hasError = false.obs;
  RxBool otpFilled = false.obs;

  RegExp numReg = RegExp(r".*[0-9].*");
  RegExp letterReg = RegExp(r".*[A-Za-z].*");

  void login(String email, String password) {
    if (FormValidator().isTextEmpty(email)) {
      showErrorMessage(
        LocalizationString.pleaseEnterValidEmail,
      );
    } else if (FormValidator().isTextEmpty(password)) {
      showErrorMessage(
        LocalizationString.pleaseEnterPassword,
      );
    } else {
      AppUtil.checkInternet().then((value) {
        if (value) {
          EasyLoading.show(status: LocalizationString.loading);
          ApiController().login(email, password).then((response) async {
            if (response.success) {
              EasyLoading.dismiss();
              await SharedPrefs().setAuthorizationKey(response.authKey!);
              await _userProfileManager.refreshProfile();
              await _settingsController.getSettings();
              getIt<SocketManager>().connect();
              // ask for location
              // getIt<LocationManager>().postLocation();

              //For Testing Dating Flow
              // isLoginFirstTime = true;
              // Get.to(() => const SetLocation())!.then((value) {});

              if (_userProfileManager.user.value!.userName.isEmpty) {
                // isLoginFirstTime = true;
                Get.to(() => const SetUserName())!.then((value) {});
              } else {
                Get.offAll(() => const ChangeLanguage());

                ///LOGIN NAVIGATION
                // Get.offAll(() => const DashboardScreen());
                ///
                // isLoginFirstTime = false;
                // Get.offAll(() => const DashboardScreen());
                getIt<SocketManager>().connect();
                // getIt<LocationManager>().postLocation();
                // if (response.isLoginFirstTime) {
                //   Get.offAll(() => const SetProfileCategoryType(
                //         isFromSignup: false,
                //       ));
                // } else {
                //   SharedPrefs().setUserLoggedIn(true);
                //   Get.offAll(() => const DashboardScreen());
              }
            } else {
              EasyLoading.dismiss();
              if (response.token != null) {
                Get.to(() => VerifyOTPScreen(
                      isVerifyingEmail: true,
                      isVerifyingPhone: false,
                      token: response.token!,
                    ));
              } else {
                EasyLoading.dismiss();
                showErrorMessage(
                  response.message,
                );
              }
            }
          });
        } else {
          showErrorMessage(
            LocalizationString.noInternet,
          );
        }
      });
    }
  }

  void phoneLogin({required String countryCode, required String phone}) {
    if (FormValidator().isTextEmpty(phone)) {
      showErrorMessage(LocalizationString.pleaseEnterValidPhone);
    } else {
      AppUtil.checkInternet().then((value) {
        if (value) {
          EasyLoading.show(status: LocalizationString.loading);
          ApiController()
              .loginWithPhone(code: countryCode, phone: phone)
              .then((response) async {
            if (response.success) {
              EasyLoading.dismiss();
              print('VerifyPhoneLoginOTP 1');
              Get.to(() => VerifyPhoneLoginOTP(
                    token: response.token!,
                  ));
            } else {
              EasyLoading.dismiss();
              showErrorMessage(
                response.message,
              );
            }
          });
        } else {
          showErrorMessage(
            LocalizationString.noInternet,
          );
        }
      });
    }
  }

  checkPassword(String password) {
    password = password.trim();

    if (password.isEmpty) {
      passwordStrength.value = 0;
      passwordStrengthText.value = 'Please enter you password';
    } else if (password.length < 6) {
      passwordStrength.value = 1 / 4;
      passwordStrengthText.value = 'Your password is too short';
    } else if (password.length < 8) {
      passwordStrength.value = 2 / 4;
      passwordStrengthText.value = 'Your password is acceptable but not strong';
    } else {
      if (!letterReg.hasMatch(password) || !numReg.hasMatch(password)) {
        // Password length >= 8
        // But doesn't contain both letter and digit characters
        passwordStrength.value = 3 / 4;
        passwordStrengthText.value =
            'Your password must contain letter and number';
      } else {
        // Password length >= 8
        // Password contains both letter and digit characters
        passwordStrength.value = 1;
        passwordStrengthText.value = 'Your password is great';
      }
    }
  }

  void register(
      {required String email,
      required String name,
      required String password,
      required String confirmPassword,
      required BuildContext context}) {
    // if (FormValidator().isTextEmpty(name) || userNameCheckStatus != 1) {
    //   showErrorMessage(
    //     LocalizationString.pleaseEnterValidUserName,
    //   );
    // }
    if (name.contains(' ')) {
      showErrorMessage(
        LocalizationString.userNameCanNotHaveSpace,
      );
    } else if (FormValidator().isTextEmpty(email)) {
      showErrorMessage(
        LocalizationString.pleaseEnterValidEmail,
      );
    } else if (FormValidator().isNotValidEmail(email)) {
      showErrorMessage(
        LocalizationString.pleaseEnterValidEmail,
      );
    } else if (FormValidator().isTextEmpty(password)) {
      showErrorMessage(
        LocalizationString.pleaseEnterPassword,
      );
    } else if (FormValidator().isTextEmpty(confirmPassword)) {
      showErrorMessage(
        LocalizationString.pleaseEnterConfirmPassword,
      );
    } else if (password != confirmPassword) {
      showErrorMessage(
        LocalizationString.passwordsDoesNotMatched,
      );
    } else {
      AppUtil.checkInternet().then((value) {
        if (value) {
          EasyLoading.show(status: LocalizationString.loading);

          ApiController()
              .registerUser(name, email, password)
              .then((response) async {
            if (response.success) {
              EasyLoading.dismiss();
              Get.to(() => VerifyOTPScreen(
                    isVerifyingEmail: true,
                    isVerifyingPhone: false,
                    token: response.token!,
                  ));
            } else {
              EasyLoading.dismiss();
              showErrorMessage(
                response.message,
              );
            }
          });
        } else {
          showErrorMessage(
            LocalizationString.noInternet,
          );
        }
      });
    }
  }

  void resetPassword(
      {required String newPassword,
      required String confirmPassword,
      required String token,
      required BuildContext context}) {
    if (FormValidator().isTextEmpty(newPassword)) {
      showErrorMessage(
        LocalizationString.pleaseEnterPassword,
      );
    } else if (FormValidator().isTextEmpty(confirmPassword)) {
      showErrorMessage(
        LocalizationString.pleaseEnterConfirmPassword,
      );
    } else if (newPassword != confirmPassword) {
      showErrorMessage(
        LocalizationString.passwordsDoesNotMatched,
      );
    } else {
      AppUtil.checkInternet().then((value) {
        if (value) {
          ApiController()
              .resetPassword(newPassword, token)
              .then((response) async {
            if (response.success) {
              passwordReset = true;
              update();
            } else {
              showErrorMessage(
                response.message,
              );
            }
          });
        } else {
          showErrorMessage(
            LocalizationString.noInternet,
          );
        }
      });
    }
  }

  void verifyUsername(String userName) {
    if (userName.contains(' ')) {
      userNameCheckStatus = 0;
      return;
    }
    AppUtil.checkInternet().then((value) {
      if (value) {
        // AppUtil.showLoader(context);
        ApiController().checkUsername(userName).then((response) async {
          // Navigator.of(context).pop();
          if (response.success) {
            userNameCheckStatus = 1;
          } else {
            userNameCheckStatus = 0;
          }
          update();
        });
      } else {
        userNameCheckStatus = 0;
      }
    });
  }

  phoneCodeSelected(String code) {
    phoneCountryCode.value = code;
  }

  otpTextFilled(String otp) {
    otpFilled.value = otp.length == pinLength;
    hasError.value = false;

    update();
  }

  otpCompleted() {
    otpFilled.value = true;
    hasError.value = false;

    update();
  }

  void resendOTP({required String token, required BuildContext context}) {
    AppUtil.checkInternet().then((value) {
      if (value) {
        EasyLoading.show(status: LocalizationString.loading);
        ApiController().resendOTP(token).then((response) async {
          EasyLoading.dismiss();
          showSuccessMessage(
            response.message,
          );
          canResendOTP.value = false;

          update();
        });
      } else {
        showErrorMessage(
          LocalizationString.noInternet,
        );
      }
    });
  }

  void callVerifyOTP({
    required bool isVerifyingEmail,
    required bool isVerifyingPhone,
    required String otp,
    required String token,
  }) {
    AppUtil.checkInternet().then((value) {
      if (value) {
        EasyLoading.show(status: LocalizationString.loading);
        ApiController()
            .verifyOTP(isVerifyingEmail, otp, token)
            .then((response) async {
          EasyLoading.dismiss();

          if (response.success) {
            Future.delayed(const Duration(milliseconds: 500), () async {
              if (isVerifyingEmail == true || isVerifyingPhone == true) {
                SharedPrefs().setUserLoggedIn(true);
                await SharedPrefs().setAuthorizationKey(response.authKey!);
                await _userProfileManager.refreshProfile();
                await _settingsController.getSettings();

                if (_userProfileManager.user.value != null) {
                  if (_userProfileManager.user.value!.userName.isEmpty) {
                    isLoginFirstTime = true;
                    Get.offAll(() => const SetUserName());
                  } else {
                    // ask for location
                    AppUtil.showToast(
                        message: LocalizationString.registeredSuccessFully,
                        isSuccess: true);
                    Get.to(() => const LoginScreen());
                  }
                }
              } else {
                Get.to(() => ResetPasswordScreen(token: response.token!));
              }
            });
          } else {
            AppUtil.showToast(message: response.message, isSuccess: false);
          }
        });
      } else {
        AppUtil.showToast(
            message: LocalizationString.noInternet, isSuccess: false);
      }
    });
  }

  void callVerifyOTPForPhoneLogin({
    required String otp,
    required String token,
  }) {
    AppUtil.checkInternet().then((value) {
      if (value) {
        EasyLoading.show(status: LocalizationString.loading);
        ApiController().verifyPhoneLoginOTP(otp, token).then((response) async {
          EasyLoading.dismiss();

          if (response.success) {
            Future.delayed(const Duration(milliseconds: 500), () async {
              SharedPrefs().setUserLoggedIn(true);
              await SharedPrefs().setAuthorizationKey(response.authKey!);
              await _userProfileManager.refreshProfile();
              await _settingsController.getSettings();

              print(
                  '_userProfileManager.user.value ${_userProfileManager.user.value}');
              if (_userProfileManager.user.value != null) {
                print(
                    '_userProfileManager.user.value!.userName ${_userProfileManager.user.value!.userName}');
                if (_userProfileManager.user.value!.userName.isEmpty) {
                  isLoginFirstTime = true;
                  Get.offAll(() => const SetUserName());
                } else {
                  // ask for location
                  AppUtil.showToast(
                      message: LocalizationString.registeredSuccessFully,
                      isSuccess: true);
                  Get.to(() => const LoginScreen());
                }
              }
            });
          } else {
            AppUtil.showToast(message: response.message, isSuccess: false);
          }
        });
      } else {
        AppUtil.showToast(
            message: LocalizationString.noInternet, isSuccess: false);
      }
    });
  }

  void callVerifyOTPForChangePhone(
      {required String otp,
      required String token,
      required BuildContext context}) {
    AppUtil.checkInternet().then((value) {
      if (value) {
        EasyLoading.show(status: LocalizationString.loading);
        ApiController().verifyChangePhoneOTP(otp, token).then((response) async {
          EasyLoading.dismiss();
          AppUtil.showToast(message: response.message, isSuccess: true);
          if (response.success) {
            Future.delayed(const Duration(milliseconds: 500), () {
              Get.back();
            });
          }
        });
      } else {
        AppUtil.showToast(
            message: LocalizationString.noInternet, isSuccess: false);
      }
    });
  }

  void forgotPassword({required String email, required BuildContext context}) {
    if (FormValidator().isTextEmpty(email)) {
      AppUtil.showToast(
          message: LocalizationString.pleaseEnterEmail, isSuccess: false);
    } else if (FormValidator().isNotValidEmail(email)) {
      AppUtil.showToast(
          message: LocalizationString.pleaseEnterValidEmail, isSuccess: false);
    } else {
      AppUtil.checkInternet().then((value) {
        if (value) {
          EasyLoading.show(status: LocalizationString.loading);
          ApiController().forgotPassword(email).then((response) async {
            EasyLoading.dismiss();
            AppUtil.showToast(message: response.message, isSuccess: true);
            if (response.success) {
              Get.to(() => VerifyOTPScreen(
                    isVerifyingEmail: false,
                    isVerifyingPhone: false,
                    token: response.token!,
                  ));
            }
          });
        } else {
          AppUtil.showToast(
              message: LocalizationString.noInternet, isSuccess: false);
        }
      });
    }
  }

  Future<void> launchUrlInBrowser(String url) async {
    await launchUrl(Uri.parse(url));
  }

  showSuccessMessage(String message) {
    AppUtil.showToast(message: message, isSuccess: true);
  }

  showErrorMessage(String message) {
    AppUtil.showToast(message: message, isSuccess: false);
  }
}
