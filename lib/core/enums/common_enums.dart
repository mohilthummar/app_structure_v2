library;

///! WARNINGS:
///* =>> Don't change any enum INDEX (Positions)

/// ***********************************************************************************
/// *                                COMMON UI ENUMS                                  *
/// ***********************************************************************************

enum ButtonVariant { contained, outlined, light, dashed, text }

enum ToastType { success, info, warning, error }

enum ModalVariant { center, drawer }

enum InputSize { small, medium, large }

enum CheckboxSize {
  small(16),
  medium(18),
  large(20);

  final double size;
  const CheckboxSize(this.size);
}
