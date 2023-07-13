import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

Widget backNavigationBar(
    {required BuildContext context, required String title}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      ThemeIconWidget(
        ThemeIcon.backArrow,
        size: 18,
        color: AppColorConstants.iconColor,
      ).ripple(() {
        Get.back();
      }),
      BodyLargeText(title.tr, weight: TextWeight.medium),
      const SizedBox(
        width: 20,
      )
    ],
  ).setPadding(left: 16, right: 16, top: 8, bottom: 16);
}

Widget backNavigationBarWithIcon(
    {required BuildContext context,
    required ThemeIcon icon,
    required String title,
    required VoidCallback iconBtnClicked}) {
  return Stack(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ThemeIconWidget(
            ThemeIcon.backArrow,
            size: 18,
            color: AppColorConstants.iconColor,
          ).ripple(() {
            Get.back();
          }),
          ThemeIconWidget(
            icon,
            size: 20,
            color: AppColorConstants.iconColor,
          ).ripple(() {
            iconBtnClicked();
          }),
        ],
      ),
      Positioned(
        left: 0,
        right: 0,
        child: Center(
          child: BodyLargeText(title.tr, weight: TextWeight.medium),
        ),
      ),
    ],
  ).setPadding(left: 16, right: 16, top: 8, bottom: 16);
}

Widget profileScreensNavigationBar(
    {required BuildContext context,
    required String title,
    String? rightBtnTitle,
    required VoidCallback completion}) {
  return Stack(
    alignment: AlignmentDirectional.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ThemeIconWidget(
            ThemeIcon.backArrow,
            size: 18,
            color: AppColorConstants.iconColor,
          ).ripple(() {
            Get.back();
          }),
          if (rightBtnTitle != null)
            BodyLargeText(rightBtnTitle.tr, weight: TextWeight.medium)
                .ripple(() {
              completion();
            }),
        ],
      ).setPadding(left: 16, right: 16),
      Positioned(
        left: 0,
        right: 0,
        child: Center(
          child: BodyLargeText(title.tr, weight: TextWeight.medium),
        ),
      )
    ],
  ).bP16;
}

Widget titleNavigationBarWithIcon(
    {required BuildContext context,
    required String title,
    required ThemeIcon icon,
    required VoidCallback completion}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const SizedBox(
        width: 25,
      ),
      BodyLargeText(title.tr, weight: TextWeight.medium),
      ThemeIconWidget(
        icon,
        color: AppColorConstants.iconColor,
        size: 25,
      ).ripple(() {
        completion();
      }),
    ],
  ).setPadding(left: 16, right: 16, top: 8, bottom: 16);
}

Widget titleNavigationBar({
  required BuildContext context,
  required String title,
}) {
  return BodyLargeText(title.tr, weight: TextWeight.medium)
      .setPadding(left: 16, right: 16, top: 8, bottom: 16);
}
