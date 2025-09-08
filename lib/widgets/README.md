# Widgets Documentation for TredPlus App

This folder contains reusable, high-performance widgets designed for the TredPlus app. Each widget is optimized for performance, ease of use, and consistency with the app's design system.

## Table of Contents
- [AppTextField](#apptextfield) - Enhanced text input field
- [AppButton](#appbutton) - Flexible button component
- [AppDropDown](#appdropdown) - Customizable dropdown selector
- [Other Widgets](#other-widgets) - Additional components

---

## AppTextField

A customizable, performant text field with label, prefix/suffix icons, and error handling. Optimized for better performance and easier usage.

### Features
- **Label Support:** Optional label above the field
- **Icon Support:** Prefix and suffix icons (SVG/PNG assets or widgets)
- **Error Handling:** Built-in error display and validation
- **Focus Management:** Automatic focus state handling
- **Performance:** Optimized rebuilds and state management
- **Type Safety:** Strong typing for all parameters
- **Accessibility:** Full accessibility support

### Usage

#### Basic Text Field
```dart
AppTextField(
  controller: myController,
  label: 'Email',
  hintText: 'Enter your email',
  prefixIcon: AppAssets.icEmail,
  onChanged: (value) => print(value),
)
```

#### Password Field
```dart
AppTextField(
  controller: passwordController,
  label: 'Password',
  hintText: 'Enter your password',
  prefixIcon: AppAssets.icPassword,
  obscureText: true,
  suffixIcon: isPasswordVisible ? AppAssets.icEye : AppAssets.icEyeClose,
  onSuffixIconTap: () => togglePasswordVisibility(),
)
```

#### Phone Number with Country Code
```dart
AppTextField(
  controller: phoneController,
  label: 'Mobile Number',
  hintText: 'Enter mobile number',
  prefixIcon: Row(
    children: [
      CountryCodePicker(),
      VerticalDivider(),
    ],
  ),
  keyboardType: TextInputType.phone,
  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  maxLength: 10,
)
```

#### Multi-line Text Field
```dart
AppTextField(
  controller: descriptionController,
  label: 'Description',
  hintText: 'Enter description',
  maxLines: 5,
  minLines: 3,
)
```

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `controller` | `TextEditingController?` | `null` | Controls the text being edited |
| `label` | `String?` | `null` | Label displayed above the field |
| `prefixIcon` | `dynamic` | `null` | Icon at the start (asset path or widget) |
| `suffixIcon` | `dynamic` | `null` | Icon at the end (asset path or widget) |
| `onSuffixIconTap` | `VoidCallback?` | `null` | Called when suffix icon is tapped |
| `validator` | `String? Function(String?)?` | `null` | Field validation function |
| `hintText` | `String?` | `null` | Placeholder text |
| `errorText` | `String?` | `null` | Error text to display |
| `textStyle` | `TextStyle?` | `null` | Style for input text |
| `hintStyle` | `TextStyle?` | `null` | Style for hint text |
| `textAlign` | `TextAlign` | `TextAlign.start` | Text alignment |
| `textInputAction` | `TextInputAction` | `TextInputAction.next` | Keyboard action button |
| `inputFormatters` | `List<TextInputFormatter>?` | `null` | Input formatters |
| `keyboardType` | `TextInputType` | `TextInputType.text` | Keyboard type |
| `maxLines` | `int` | `1` | Maximum lines |
| `minLines` | `int` | `1` | Minimum lines |
| `maxLength` | `int?` | `null` | Maximum input length |
| `obscureText` | `bool` | `false` | Hide text (for passwords) |
| `onChanged` | `ValueChanged<String>?` | `null` | Called when text changes |
| `onTap` | `VoidCallback?` | `null` | Called when field is tapped |
| `onSubmitted` | `ValueChanged<String>?` | `null` | Called on submit |
| `enabled` | `bool` | `true` | Whether field is enabled |
| `readOnly` | `bool` | `false` | Whether field is read-only |
| `autofocus` | `bool` | `false` | Auto-focus the field |
| `suffixIconColor` | `Color?` | `null` | Color for suffix icon |

### Performance Optimizations
- **Efficient Focus Handling:** Only rebuilds when focus state actually changes
- **Optimized Icon Building:** Icons are built once and reused
- **Reduced Rebuilds:** Minimal setState calls
- **Memory Management:** Proper disposal of focus nodes

### Error Handling
The widget supports two types of error display:
1. **Validator Errors:** Use the `validator` parameter for form validation
2. **Manual Errors:** Use the `errorText` parameter to show custom errors

```dart
// Using validator
AppTextField(
  validator: (value) {
    if (value?.isEmpty ?? true) {
      return 'This field is required';
    }
    return null;
  },
)

// Using manual error text
AppTextField(
  errorText: hasError ? 'Invalid input' : null,
)
```

---

## AppButton

A high-performance, flexible, and easy-to-use button widget for Flutter, designed for the TredPlus app. It supports elevated, outlined, gradient, custom, and safe area variants, and is fully compatible with the app's design system.

### Features
- **Variants:** Elevated, Outlined, Gradient, Custom, SafeArea
- **Loading State:** Built-in loader for async actions
- **Disabled State:** Easily disable button
- **Custom Content:** Use your own child widget
- **Icon/Image Support:** Add icons or images before/after label
- **Flexible Styling:** Colors, gradients, border radius, padding, etc.
- **Performance:** Stateless, leverages Flutter's native buttons
- **Consistent Design:** Uses app's typography and color system

### Usage

#### 1. Elevated Button (default)
```dart
AppButton(
  label: 'Sign In',
  onPressed: () {},
)
```

#### 2. Outlined Button
```dart
AppButton.outlined(
  label: 'Cancel',
  onPressed: () {},
)
```

#### 3. Gradient Button
```dart
AppButton.gradient(
  label: 'Continue',
  onPressed: () {},
)
```

#### 4. Custom Child Button
```dart
AppButton.custom(
  onPressed: () {},
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.star),
      SizedBox(width: 8),
      Text('Custom'),
    ],
  ),
)
```

#### 5. SafeArea Button
```dart
AppButton.safeArea(
  label: 'Submit',
  onPressed: () {},
)
```

### Main Properties
| Property         | Type                | Description                                      |
|-----------------|---------------------|--------------------------------------------------|
| `label`         | String?             | Button text label                                |
| `onPressed`     | VoidCallback?       | Tap callback                                     |
| `onLongPress`   | VoidCallback?       | Long press callback                              |
| `isLoading`     | bool                | Show loading spinner                             |
| `disable`       | bool                | Disable the button                               |
| `child`         | Widget?             | Custom child (overrides label/icon/image)         |
| `icon`          | IconData?           | Icon before label                                |
| `image`         | String?             | Asset image (SVG/PNG) before/after label         |
| `imageAlign`    | ImageAlign?         | Where to show image (start/end/startTitle/endTitle)|
| `buttonType`    | ButtonType          | elevated, outline, gradient                      |
| `gradient`      | bool                | Enable gradient background                       |
| `outlined`      | bool                | Enable outlined style                            |
| `safeArea`      | bool                | Wrap in SafeArea                                 |
| `minimumSize`   | Size?               | Minimum button size                              |
| `borderRadius`  | BorderRadiusGeometry?| Custom border radius                             |
| `backgroundColor`| Color?              | Background color                                 |
| `color`         | Color?              | Text/icon color                                  |
| `borderColor`   | Color?              | Border color (outlined)                          |
| `customGradient`| Gradient?           | Custom gradient                                  |
| `padding`       | EdgeInsetsGeometry? | Button padding                                   |
| `margin`        | EdgeInsetsGeometry? | Outer margin                                     |
| `loaderColor`   | Color?              | Loader color                                     |
| `topLayerWidget`| Widget?             | Widget overlaid on top (e.g. badge)              |

### Example: Button with Icon and Loader
```dart
AppButton(
  label: 'Download',
  icon: Icons.download,
  isLoading: isDownloading,
  onPressed: startDownload,
)
```

### Performance
- Stateless design for fast rebuilds
- Uses Flutter's native button widgets
- Only rebuilds loader/child as needed

### Customization
- Easily extend or wrap for more complex use cases
- All colors, radii, and paddings are theme-aware

---

## AppDropDown

A customizable, performant dropdown widget for selecting from a list of items. Optimized for ease of use, performance, and seamless integration with forms.

### Features
- **Label Support:** Optional label above the dropdown
- **Prefix Icon:** Optional SVG/PNG icon before the dropdown
- **Loading State:** Show a loader instead of the dropdown arrow
- **Validation:** Built-in validator for form usage
- **Performance:** Stateless, efficient item building
- **Consistent Design:** Matches app's color and typography system

### Usage

#### Basic Dropdown
```dart
AppDropDown(
  items: myItems,
  value: selectedItem,
  onChanged: (item) => setState(() => selectedItem = item),
  hintText: 'Select an option',
)
```

#### With Label and Prefix Icon
```dart
AppDropDown(
  items: myItems,
  value: selectedItem,
  onChanged: (item) => setState(() => selectedItem = item),
  label: 'Account Type',
  prefixIcon: AppAssets.icBank,
  hintText: 'Choose account type',
)
```

#### With Validation
```dart
AppDropDown(
  items: myItems,
  value: selectedItem,
  onChanged: (item) => setState(() => selectedItem = item),
  validator: (item) => item == null ? 'Please select an option' : null,
  hintText: 'Select an option',
)
```

### Properties
| Property         | Type                                  | Default   | Description                                      |
|-----------------|---------------------------------------|-----------|--------------------------------------------------|
| `items`         | List<DropDownModel>                   | required  | List of items to display                         |
| `value`         | DropDownModel?                        | `null`    | Currently selected value                         |
| `onChanged`     | ValueChanged<DropDownModel?>?         | `null`    | Callback when a new item is selected             |
| `hintText`      | String?                               | `null`    | Placeholder text                                 |
| `label`         | String?                               | `null`    | Optional label above the dropdown                |
| `prefixIcon`    | String? (SVG/PNG asset path)          | `null`    | Optional icon before the dropdown                |
| `isLoading`     | bool                                  | `false`   | Show loader instead of dropdown arrow            |
| `validator`     | String? Function(DropDownModel?)?      | `null`    | Validator for form usage                         |
| `hintTextColor` | Color?                                | `null`    | Custom color for the hint text                   |

### Performance
- Stateless for fast rebuilds
- Efficient item mapping and rendering
- Minimal widget tree for dropdown

### Customization
- Add a label or prefix icon for context
- Use with forms for validation
- Show loading state for async data

---

## Other Widgets

### AppPinCodeField
A PIN code input field with customizable length and styling.

### AppImageView
An optimized image widget with placeholder and error handling.

### AppContainer
A flexible container widget with customizable styling.

### AppAppBar
A consistent app bar widget with back button and title.

### AppIconButton
A simple icon button with customizable styling.

### BottomBorderContainer
A container with bottom border styling for text fields.

### EnterAmountWidget
A specialized widget for entering monetary amounts.

### DealStatusWidget
A widget for displaying deal status with appropriate styling.

### FilterItemWidget
A widget for filter items with selection states.

### NoteWithMessageWidget
A widget for displaying notes with messages.

### BottomSheetHeader
A consistent header for bottom sheets.

### BottomSheetFrame
A frame widget for bottom sheet content.

### AppAnimatedClipRect
An animated clip rect widget for smooth transitions.

### DealLoadingWidget
A loading widget specifically for deal-related screens.

### InvestedSummary
A widget for displaying investment summaries.

### PasswordUpdateSuccessfullyDialogs
Dialog widgets for password update success states.

### EnterAmountTextField
A specialized text field for entering amounts.

---

## Best Practices

### Performance
- Use `const` constructors where possible
- Avoid unnecessary rebuilds
- Dispose of controllers and listeners properly
- Use appropriate widget types (Stateless vs Stateful)

### Accessibility
- Provide meaningful labels and hints
- Use semantic labels for screen readers
- Ensure proper contrast ratios
- Support keyboard navigation

### Consistency
- Follow the app's design system
- Use consistent spacing and typography
- Maintain color scheme consistency
- Follow naming conventions

### Testing
- Write unit tests for widget logic
- Test different states and configurations
- Verify accessibility features
- Test performance with large datasets

---

For more details, see the individual widget files in this directory. 