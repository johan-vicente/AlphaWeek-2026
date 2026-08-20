import 'package:flutter/material.dart';
import '../services/accessibility_service.dart';
import '../utils/app_colors.dart';

class AccessibilityWrapper extends StatelessWidget {
  final Widget child;

  const AccessibilityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AccessibilityService(),
      builder: (context, _) {
        final service = AccessibilityService();

        Widget currentChild = child;

        // Apply Grayscale Filter
        if (service.escalaGrises) {
          currentChild = ColorFiltered(
            colorFilter: const ColorFilter.matrix(<double>[
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0,      0,      0,      1, 0,
            ]),
            child: currentChild,
          );
        }

        // Apply MediaQuery overrides
        final originalData = MediaQuery.of(context);
        currentChild = MediaQuery(
          data: originalData.copyWith(
            textScaler: TextScaler.linear(service.agrandarTexto ? 1.3 : 1.0),
            disableAnimations: service.reducirAnimaciones,
          ),
          child: currentChild,
        );

        // Apply Theme overrides
        final theme = Theme.of(context);
        final colorScheme = service.altoContraste 
            ? const ColorScheme.highContrastLight(primary: AppColors.azulSirena)
            : theme.colorScheme;
        
        final font = service.dislexia ? 'OpenDyslexic' : null;
        final letterSpacing = service.espaciadoTexto ? 1.5 : null;
        final height = service.alturaLinea ? 1.5 : null;

        final newTheme = theme.copyWith(
          colorScheme: colorScheme,
          textTheme: theme.textTheme.apply(
            fontFamily: font,
          ).copyWith(
            bodyLarge: theme.textTheme.bodyLarge?.copyWith(letterSpacing: letterSpacing, height: height, fontFamily: font),
            bodyMedium: theme.textTheme.bodyMedium?.copyWith(letterSpacing: letterSpacing, height: height, fontFamily: font),
            bodySmall: theme.textTheme.bodySmall?.copyWith(letterSpacing: letterSpacing, height: height, fontFamily: font),
            titleLarge: theme.textTheme.titleLarge?.copyWith(letterSpacing: letterSpacing, height: height, fontFamily: font),
            titleMedium: theme.textTheme.titleMedium?.copyWith(letterSpacing: letterSpacing, height: height, fontFamily: font),
            titleSmall: theme.textTheme.titleSmall?.copyWith(letterSpacing: letterSpacing, height: height, fontFamily: font),
            labelLarge: theme.textTheme.labelLarge?.copyWith(letterSpacing: letterSpacing, height: height, fontFamily: font),
            labelMedium: theme.textTheme.labelMedium?.copyWith(letterSpacing: letterSpacing, height: height, fontFamily: font),
            labelSmall: theme.textTheme.labelSmall?.copyWith(letterSpacing: letterSpacing, height: height, fontFamily: font),
          ),
        );

        return Theme(
          data: newTheme,
          child: DefaultTextStyle(
            style: DefaultTextStyle.of(context).style.copyWith(
              fontFamily: font,
              letterSpacing: letterSpacing,
              height: height,
            ),
            child: currentChild,
          ),
        );
      },
    );
  }
}
