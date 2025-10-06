import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Breakpoints pour différentes tailles d'écran
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
  static const double largeDesktopBreakpoint = 1440;

  // Déterminer le type d'appareil
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else if (width < desktopBreakpoint) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  // Obtenir la taille de police responsive
  static double getResponsiveFontSize(BuildContext context, {
    required double mobileSize,
    double? tabletSize,
    double? desktopSize,
    double? largeDesktopSize,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobileSize;
      case DeviceType.tablet:
        return tabletSize ?? mobileSize * 1.1;
      case DeviceType.desktop:
        return desktopSize ?? mobileSize * 1.2;
      case DeviceType.largeDesktop:
        return largeDesktopSize ?? desktopSize ?? mobileSize * 1.3;
    }
  }

  // Obtenir le padding responsive
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16);
      case DeviceType.tablet:
        return const EdgeInsets.all(24);
      case DeviceType.desktop:
        return const EdgeInsets.all(32);
      case DeviceType.largeDesktop:
        return const EdgeInsets.all(40);
    }
  }

  // Obtenir la largeur de conteneur responsive
  static double getResponsiveContainerWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    final screenWidth = MediaQuery.of(context).size.width;

    switch (deviceType) {
      case DeviceType.mobile:
        return screenWidth;
      case DeviceType.tablet:
        return screenWidth * 0.9;
      case DeviceType.desktop:
        return screenWidth * 0.8;
      case DeviceType.largeDesktop:
        return screenWidth * 0.7;
    }
  }

  // Grille responsive pour les cartes
  static int getResponsiveGridCount(BuildContext context) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
      case DeviceType.largeDesktop:
        return 4;
    }
  }

  // Espacement responsive
  static double getResponsiveSpacing(BuildContext context) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return 12;
      case DeviceType.tablet:
        return 16;
      case DeviceType.desktop:
        return 20;
      case DeviceType.largeDesktop:
        return 24;
    }
  }

  // Taille de bouton responsive
  static double getResponsiveButtonHeight(BuildContext context) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return 48;
      case DeviceType.tablet:
        return 52;
      case DeviceType.desktop:
        return 56;
      case DeviceType.largeDesktop:
        return 60;
    }
  }
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

// Widget responsive pour le texte
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final double? mobileSize;
  final double? tabletSize;
  final double? desktopSize;
  final double? largeDesktopSize;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.mobileSize,
    this.tabletSize,
    this.desktopSize,
    this.largeDesktopSize,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      mobileSize: mobileSize ?? 16,
      tabletSize: tabletSize,
      desktopSize: desktopSize,
      largeDesktopSize: largeDesktopSize,
    );

    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(fontSize: fontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

// Widget responsive pour les conteneurs
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? maxWidth;
  final AlignmentGeometry? alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.maxWidth,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    final screenWidth = MediaQuery.of(context).size.width;

    double? effectiveMaxWidth = maxWidth;
    if (effectiveMaxWidth == null) {
      switch (deviceType) {
        case DeviceType.mobile:
          effectiveMaxWidth = screenWidth;
          break;
        case DeviceType.tablet:
          effectiveMaxWidth = screenWidth * 0.9;
          break;
        case DeviceType.desktop:
          effectiveMaxWidth = screenWidth * 0.8;
          break;
        case DeviceType.largeDesktop:
          effectiveMaxWidth = screenWidth * 0.7;
          break;
      }
    }

    return Container(
      width: width,
      constraints: BoxConstraints(maxWidth: effectiveMaxWidth ?? double.infinity),
      padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
      margin: margin,
      alignment: alignment,
      child: child,
    );
  }
}

// Widget responsive pour les grilles
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveUtils.getResponsiveGridCount(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: 1.0,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}