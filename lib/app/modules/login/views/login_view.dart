import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:casa_pointage/core/localization/locale_controller.dart';
import 'package:casa_pointage/core/theme/app_colors.dart';
import 'package:casa_pointage/core/theme/app_theme.dart';
import 'package:casa_pointage/core/widgets/app_button.dart';
import 'package:casa_pointage/core/widgets/app_text_field.dart';
import 'package:casa_pointage/generated/l10n/app_localizations.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Hero(topInset: topInset),
                  // The card overlaps the bottom of the hero banner.
                  Transform.translate(
                    offset: Offset(0, -34.h),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: const _LoginCard(),
                    ),
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              top: topInset + 18,
              end: 18,
              child: const _LanguageToggle(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.topInset});

  final double topInset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Same scale as the illustration, so the banner never ends up shorter than
    // the text + artwork stacked (the artwork only grows on wide screens).
    final scale = math.max(1.0, MediaQuery.sizeOf(context).width / 390);

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 392 * scale + topInset),
      child: ColoredBox(
        color: AppColors.brand,
        child: Stack(
          children: [
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _Illustration(),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, topInset + 22.h, 24.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/logo_cb_w.png',
                    height: 38.h,
                    semanticLabel: 'Casablanca Baïa',
                  ),
                  SizedBox(height: 26.h),
                  Text(
                    l10n.appName,
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    l10n.loginHeroSubtitle,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandText,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    l10n.loginHeroTagline,
                    style: TextStyle(
                      fontSize: 21.sp,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Workers illustration. Drawn on a 390x200 canvas that is scaled to cover the
/// banner width and anchored to the bottom, like the prototype's `slice` fit.
class _Illustration extends StatelessWidget {
  const _Illustration();

  static const double _w = 390;
  static const double _h = 200;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = width > _w ? width * _h / _w : _h;

    return SizedBox(
      width: width,
      height: height,
      child: ExcludeSemantics(
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: _w,
            height: _h,
            child: Stack(
              children: [
                SvgPicture.asset(
                  'assets/images/login_illustration.svg',
                  width: _w,
                  height: _h,
                ),
                const Positioned(left: 222, top: 30, child: _RecognizedBubble()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecognizedBubble extends StatelessWidget {
  const _RecognizedBubble();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: 128,
      height: 38,
      padding: const EdgeInsetsDirectional.only(start: 8, end: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFF2E8B57),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.faceRecognized,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
                Text(
                  l10n.arrivalAt('05:58'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.numberStyle(
                    fontSize: 14,
                    color: AppColors.brand,
                  ).copyWith(height: 1.1, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends GetView<LoginController> {
  const _LoginCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0A0F14),
            blurRadius: 40,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.loginTitle,
              style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 16.h),
            Obx(() {
              final error = controller.error.value;
              if (error == null) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _ErrorBanner(message: _errorText(l10n, error)),
              );
            }),
            AppTextField(
              label: l10n.loginIdLabel,
              controller: controller.idController,
              prefixIcon: Icons.person_outline_rounded,
              autofillHints: const [AutofillHints.username],
              textInputAction: TextInputAction.next,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(height: 16.h),
            Obx(
              () => AppTextField(
                label: l10n.loginPasswordLabel,
                controller: controller.passwordController,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: controller.obscurePassword.value,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => controller.submit(),
                suffix: IconButton(
                  onPressed: controller.togglePasswordVisibility,
                  tooltip: controller.obscurePassword.value
                      ? l10n.loginShowPassword
                      : l10n.loginHidePassword,
                  icon: Icon(
                    controller.obscurePassword.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.pending,
                    size: 20.r,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Obx(
              () => AppButton(
                variant: AppButtonVariant.accent,
                height: 60.h,
                fontSize: 18.sp,
                loading: controller.loading.value,
                label: controller.loading.value
                    ? l10n.loginLoading
                    : l10n.loginSubmit,
                onPressed: controller.submit,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.loginFooter,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _errorText(AppLocalizations l10n, LoginError error) => switch (error) {
        LoginError.both => l10n.loginErrorBoth,
        LoginError.id => l10n.loginErrorId,
        LoginError.password => l10n.loginErrorPassword,
        LoginError.invalid => l10n.loginErrorInvalid,
        LoginError.server => controller.serverMessage.value,
      };
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: AppColors.absentSoft,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 18.r, color: const Color(0xFF8E1B1B)),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF8E1B1B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Get.find<LocaleController>();

    return Obx(() {
      final isArabic = locale.locale.value == LocaleController.ar;
      return _buildToggle(l10n, locale, isArabic);
    });
  }

  Widget _buildToggle(
    AppLocalizations l10n,
    LocaleController locale,
    bool isArabic,
  ) {
    return Semantics(
      button: true,
      label: isArabic ? l10n.languageFrench : l10n.languageArabic,
      child: Material(
        color: Colors.white.withValues(alpha: 0.14),
        shape: StadiumBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: locale.toggle,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: Text(
              isArabic ? 'Francais' : l10n.languageArabic,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
