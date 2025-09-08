# TredPlus App Theme System

This document provides a comprehensive guide to using the theme system in the TredPlus Flutter application. The theme system is designed to provide consistent styling across the entire application with support for both light and dark themes.

## 📋 Table of Contents

- [Overview](#overview)
- [Theme Components](#theme-components)
- [Text System](#text-system)
- [Spacing & Layout](#spacing--layout)
- [Color System](#color-system)
- [Component Themes](#component-themes)
- [Best Practices](#best-practices)
- [Examples](#examples)
- [Migration Guide](#migration-guide)

## 🎨 Overview

The TredPlus theme system consists of several interconnected components:

- **AppTheme**: Main theme configuration with light and dark variants
- **AppText**: Customizable text widget with predefined styles
- **AppStyle**: Responsive spacing and sizing utilities
- **AppColors**: Centralized color definitions

### Key Features

- ✅ **Responsive Design**: All spacing and sizing adapts to different screen sizes
- ✅ **Dark/Light Theme Support**: Complete theme switching capability
- ✅ **Consistent Typography**: Predefined text styles with proper hierarchy
- ✅ **Component Themes**: Built-in themes for buttons, cards, inputs, etc.
- ✅ **Accessibility**: Proper contrast ratios and touch targets
- ✅ **Custom Font**: Uses "OpenSans" font family throughout

## 🧩 Theme Components

### 1. AppTheme (`lib/theme/app_theme.dart`)

The main theme configuration class that provides both light and dark themes.

```dart
// Basic usage
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.light, // or ThemeMode.dark
)

// Helper methods
ThemeData currentTheme = AppTheme.getTheme(Brightness.light);
ThemeData oppositeTheme = AppTheme.getOppositeTheme(Brightness.light);
```

### 2. AppText (`lib/theme/app_text.dart`)

A customizable text widget that provides consistent typography across the app.

```dart
// Basic usage
AppText(
  'Hello World',
  textSize: TextSize.large_16,
  textWeight: TextWeight.w500,
  textColor: Colors.blue,
)

// Multi-line text
AppText.multiLine(
  'Long text that wraps to multiple lines',
  textSize: TextSize.medium_14,
  maxLines: 3,
  overflow: TextOverflow.fade,
)
```

### 3. AppStyle (`lib/theme/app_style.dart`)

Responsive spacing and sizing utilities that automatically adapt to screen sizes.

```dart
// Spacing values
double padding = defaultPadding; // 14.h
double smallPadding = defaultSmallPadding; // 10.h
double radius = defaultRadius; // 10.r

// Spacing widgets
AppSpacing.verticalSpace
AppSpacing.horizontalSpace

// Border radius utilities
AppRadius.standard
AppRadius.large
AppRadius.topOnly

// Edge insets utilities
AppEdgeInsets.all
AppEdgeInsets.horizontal
AppEdgeInsets.vertical
```

## 📝 Text System

### TextSize Enum

Available text sizes with their corresponding font sizes:

```dart
enum TextSize {
  extraSmall_10,  // 10sp - Captions, labels
  small_12,       // 12sp - Body text, descriptions
  medium_14,      // 14sp - Subheadings, important text
  large_16,       // 16sp - Section headers
  title_18,       // 18sp - Page titles
  largeTitle_20,  // 20sp - Large titles
  headline_24     // 24sp - Main headlines
}
```

### TextWeight Enum

Available font weights:

```dart
enum TextWeight {
  w400,  // Normal weight
  w500,  // Medium weight
  w600   // Semi-bold weight
}
```

### Usage Examples

```dart
// Headline text
AppText(
  'Welcome to TredPlus',
  textSize: TextSize.headline_24,
  textWeight: TextWeight.w600,
  textColor: AppColors.primaryTextColor,
)

// Body text
AppText(
  'This is the main content of your app.',
  textSize: TextSize.medium_14,
  textWeight: TextWeight.w400,
  textColor: AppColors.darkGreyTextColor,
)

// Caption text
AppText(
  'Updated 2 hours ago',
  textSize: TextSize.extraSmall_10,
  textWeight: TextWeight.w400,
  textColor: AppColors.lightGreyTextColor,
)
```

## 📏 Spacing & Layout

### Responsive Spacing Values

All spacing values are responsive and automatically adapt to screen sizes:

```dart
// Padding values
defaultPadding          // 14.h - Standard padding
defaultSmallPadding     // 10.h - Compact padding
defaultLargePadding     // 20.h - Spacious padding
defaultExtraLargePadding // 32.h - Very spacious padding

// Border radius values
defaultRadius           // 10.r - Standard radius
defaultSmallRadius      // 6.r - Small radius
defaultLargeRadius      // 16.r - Large radius
defaultExtraLargeRadius // 24.r - Extra large radius

// Safe area padding
defaultTopPadding       // Status bar + padding
defaultBottomPadding    // Bottom bar + padding
```

### Spacing Utilities

```dart
// Vertical spacing widgets
AppSpacing.verticalSpace      // SizedBox(height: defaultPadding)
AppSpacing.verticalSmallSpace // SizedBox(height: defaultSmallPadding)
AppSpacing.verticalLargeSpace // SizedBox(height: defaultLargePadding)

// Horizontal spacing widgets
AppSpacing.horizontalSpace      // SizedBox(width: defaultPadding)
AppSpacing.horizontalSmallSpace // SizedBox(width: defaultSmallPadding)
AppSpacing.horizontalLargeSpace // SizedBox(width: defaultLargePadding)
```

### Edge Insets Utilities

```dart
// Common padding patterns
AppEdgeInsets.all              // EdgeInsets.all(defaultPadding)
AppEdgeInsets.horizontal       // EdgeInsets.symmetric(horizontal: defaultPadding)
AppEdgeInsets.vertical         // EdgeInsets.symmetric(vertical: defaultPadding)
AppEdgeInsets.topBottom        // EdgeInsets.only(top: defaultPadding, bottom: defaultPadding)
AppEdgeInsets.leftRight        // EdgeInsets.only(left: defaultPadding, right: defaultPadding)
```

## 🎨 Color System

### AppColors (`lib/core/constants/app_colors.dart`)

Centralized color definitions used throughout the app:

```dart
// Primary colors
AppColors.primaryColor         // Main brand color
AppColors.primaryTextColor     // Primary text color
AppColors.whiteTextColor       // White text color

// Text colors
AppColors.darkGreyTextColor    // Secondary text color
AppColors.lightGreyTextColor   // Tertiary text color
AppColors.hintColor           // Input hint color

// Background colors
AppColors.backgroundColor      // Main background color
AppColors.containerFillColor   // Container background color

// Status colors
AppColors.profitColor         // Positive/green color
AppColors.lossColor           // Negative/red color
AppColors.dayLeftColor        // Warning/orange color

// Utility colors
AppColors.disableColor        // Disabled state color
AppColors.dividerAndBorderColor // Border and divider color
```

## 🧩 Component Themes

### Button Themes

The theme includes predefined styles for all button types:

```dart
// Elevated button (default style)
ElevatedButton(
  onPressed: () {},
  child: Text('Primary Action'),
)

// Outlined button
OutlinedButton(
  onPressed: () {},
  child: Text('Secondary Action'),
)

// Text button
TextButton(
  onPressed: () {},
  child: Text('Tertiary Action'),
)
```

### Input Decoration Theme

All text fields automatically use the theme's input decoration:

```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
  ),
)
```

### Card Theme

Cards automatically use the theme's card styling:

```dart
Card(
  child: Padding(
    padding: AppEdgeInsets.all,
    child: Text('Card content'),
  ),
)
```

### Bottom Sheet Theme

Bottom sheets automatically use the theme's styling:

```dart
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    padding: AppEdgeInsets.all,
    child: Text('Bottom sheet content'),
  ),
)
```

## ✅ Best Practices

### 1. Use AppText Instead of Text

❌ **Don't do this:**
```dart
Text(
  'Hello World',
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryTextColor,
  ),
)
```

✅ **Do this instead:**
```dart
AppText(
  'Hello World',
  textSize: TextSize.large_16,
  textWeight: TextWeight.w500,
  textColor: AppColors.primaryTextColor,
)
```

### 2. Use Responsive Spacing

❌ **Don't do this:**
```dart
Container(
  padding: EdgeInsets.all(14),
  margin: EdgeInsets.symmetric(vertical: 10),
)
```

✅ **Do this instead:**
```dart
Container(
  padding: AppEdgeInsets.all,
  margin: AppEdgeInsets.verticalSmall,
)
```

### 3. Use Theme Colors

❌ **Don't do this:**
```dart
Container(
  color: Color(0xFF264653),
  child: Text('Content'),
)
```

✅ **Do this instead:**
```dart
Container(
  color: AppColors.primaryColor,
  child: AppText('Content'),
)
```

### 4. Use Border Radius Utilities

❌ **Don't do this:**
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10),
  ),
)
```

✅ **Do this instead:**
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: AppRadius.standard,
  ),
)
```

### 5. Use Spacing Widgets

❌ **Don't do this:**
```dart
Column(
  children: [
    Text('First item'),
    SizedBox(height: 14),
    Text('Second item'),
  ],
)
```

✅ **Do this instead:**
```dart
Column(
  children: [
    AppText('First item'),
    AppSpacing.verticalSpace,
    AppText('Second item'),
  ],
)
```

## 📚 Examples

### Complete Card Example

```dart
Card(
  child: Padding(
    padding: AppEdgeInsets.all,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Card Title',
          textSize: TextSize.title_18,
          textWeight: TextWeight.w600,
          textColor: AppColors.primaryTextColor,
        ),
        AppSpacing.verticalSmallSpace,
        AppText(
          'This is the card content with proper spacing and typography.',
          textSize: TextSize.medium_14,
          textWeight: TextWeight.w400,
          textColor: AppColors.darkGreyTextColor,
        ),
        AppSpacing.verticalSpace,
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: AppText('Primary Action'),
              ),
            ),
            AppSpacing.horizontalSpace,
            OutlinedButton(
              onPressed: () {},
              child: AppText('Secondary Action'),
            ),
          ],
        ),
      ],
    ),
  ),
)
```

### Form Field Example

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    AppText(
      'Email Address',
      textSize: TextSize.small_12,
      textWeight: TextWeight.w500,
      textColor: AppColors.darkGreyTextColor,
    ),
    AppSpacing.verticalSmallSpace,
    TextField(
      decoration: InputDecoration(
        hintText: 'Enter your email',
        prefixIcon: Icon(Icons.email),
      ),
    ),
  ],
)
```

### List Item Example

```dart
Container(
  padding: AppEdgeInsets.horizontal,
  margin: AppEdgeInsets.verticalSmall,
  decoration: BoxDecoration(
    color: AppColors.containerFillColor,
    borderRadius: AppRadius.standard,
  ),
  child: Row(
    children: [
      Icon(Icons.star, color: AppColors.primaryColor),
      AppSpacing.horizontalSpace,
      Expanded(
        child: AppText(
          'List item with icon',
          textSize: TextSize.medium_14,
          textWeight: TextWeight.w500,
        ),
      ),
      Icon(Icons.arrow_forward_ios, color: AppColors.lightGreyTextColor),
    ],
  ),
)
```

## 🔄 Migration Guide

### Updating Existing Code

If you have existing code that doesn't use the theme system, here's how to migrate:

#### 1. Replace Text with AppText

```dart
// Before
Text(
  'Hello World',
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  ),
)

// After
AppText(
  'Hello World',
  textSize: TextSize.large_16,
  textWeight: TextWeight.w500,
  textColor: AppColors.primaryTextColor,
)
```

#### 2. Replace Hardcoded Padding

```dart
// Before
Container(
  padding: EdgeInsets.all(14),
  margin: EdgeInsets.symmetric(vertical: 10),
)

// After
Container(
  padding: AppEdgeInsets.all,
  margin: AppEdgeInsets.verticalSmall,
)
```

#### 3. Replace Hardcoded Colors

```dart
// Before
Container(
  color: Color(0xFF264653),
  child: Text('Content'),
)

// After
Container(
  color: AppColors.primaryColor,
  child: AppText('Content'),
)
```

#### 4. Replace Hardcoded Border Radius

```dart
// Before
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10),
  ),
)

// After
Container(
  decoration: BoxDecoration(
    borderRadius: AppRadius.standard,
  ),
)
```

## 🚀 Advanced Usage

### Custom Theme Extensions

You can extend the theme system for custom components:

```dart
// Custom button style
class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  
  const CustomButton({
    required this.onPressed,
    required this.text,
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteTextColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.standard,
        ),
        padding: AppEdgeInsets.horizontal,
      ),
      child: AppText(
        text,
        textSize: TextSize.medium_14,
        textWeight: TextWeight.w500,
        textColor: AppColors.whiteTextColor,
      ),
    );
  }
}
```

### Theme-Aware Components

Create components that automatically adapt to the current theme:

```dart
class ThemeAwareContainer extends StatelessWidget {
  final Widget child;
  
  const ThemeAwareContainer({required this.child});
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: AppEdgeInsets.all,
      decoration: BoxDecoration(
        color: isDark ? AppColors.containerFillColor : AppColors.backgroundColor,
        borderRadius: AppRadius.standard,
        border: Border.all(
          color: isDark ? AppColors.dividerAndBorderColor : AppColors.primaryColor,
        ),
      ),
      child: child,
    );
  }
}
```

## 📱 Responsive Design

The theme system is built with responsive design in mind:

- All spacing values use `flutter_screenutil` for automatic scaling
- Text sizes are responsive and adapt to different screen sizes
- Component themes automatically adjust for different screen densities
- Safe area handling for devices with notches and home indicators

## 🎯 Accessibility

The theme system includes accessibility considerations:

- Proper contrast ratios for text and background colors
- Adequate touch target sizes for interactive elements
- Semantic color usage for status indicators
- Support for system font scaling

## 🔧 Troubleshooting

### Common Issues

1. **Text not appearing**: Make sure you're using `AppText` instead of `Text`
2. **Spacing issues**: Use `AppEdgeInsets` utilities instead of hardcoded values
3. **Theme not applying**: Ensure you're using `AppTheme.lightTheme` or `AppTheme.darkTheme`
4. **Colors not matching**: Use `AppColors` constants instead of hardcoded colors

### Debug Tips

- Use Flutter Inspector to check if theme properties are being applied
- Verify that `flutter_screenutil` is properly initialized
- Check that the custom font is included in `pubspec.yaml`

## 📖 Additional Resources

- [Flutter Material Design Guidelines](https://material.io/design)
- [Flutter Theme Documentation](https://docs.flutter.dev/ui/advanced/themes)
- [flutter_screenutil Documentation](https://pub.dev/packages/flutter_screenutil)

---

**Note**: This theme system is designed to be maintainable and scalable. Always use the provided utilities and constants instead of hardcoding values to ensure consistency across the application. 