import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../localization/app_localizations.dart';
import '../settings/app_preferences_controller.dart';
import '../theme/app_theme.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;
  final double size;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final String? semanticLabel;

  const AppAvatar({
    super.key,
    required this.imageUrl,
    required this.fallbackText,
    this.size = 48,
    this.borderRadius,
    this.backgroundColor,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final normalizedUrl = imageUrl?.trim();
    final dataSaverEnabled =
        AppPreferencesScope.maybeOf(context)?.dataSaverEnabled == true;
    final shouldShowImage =
        normalizedUrl != null && normalizedUrl.isNotEmpty && !dataSaverEnabled;
    final radius = borderRadius ?? BorderRadius.circular(size / 2);

    return Semantics(
      label: semanticLabel ?? l10n?.t('userAvatar') ?? 'User avatar',
      image: shouldShowImage,
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          width: size,
          height: size,
          color: backgroundColor ?? AppColors.surfaceVariant,
          alignment: Alignment.center,
          child: shouldShowImage
              ? Image.network(
                  normalizedUrl,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _FallbackInitial(
                      fallbackText: fallbackText,
                      fontSize: size * 0.45,
                    );
                  },
                )
              : _FallbackInitial(
                  fallbackText: fallbackText,
                  fontSize: size * 0.45,
                ),
        ),
      ),
    );
  }
}

class _FallbackInitial extends StatelessWidget {
  final String fallbackText;
  final double fontSize;

  const _FallbackInitial({required this.fallbackText, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final text = fallbackText.trim();
    final initial = text.isNotEmpty ? text[0].toUpperCase() : 'U';

    return Text(
      initial,
      style: GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
  }
}
