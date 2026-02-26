import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// 精美输入框
class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final bool autofocus;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.autofocus = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _isFocused = false;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.subtitle.copyWith(
              color: _isFocused ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: AppAnimations.fast,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(
              color: _isFocused
                  ? AppColors.primary
                  : _hasError
                      ? AppColors.error
                      : Colors.transparent,
              width: 2,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            autofocus: widget.autofocus,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.textTertiary,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? AnimatedContainer(
                      duration: AppAnimations.fast,
                      child: IconTheme(
                        data: IconThemeData(
                          color: _isFocused ? AppColors.primary : AppColors.textTertiary,
                          size: AppDimensions.iconMedium,
                        ),
                        child: widget.prefixIcon!,
                      ),
                    )
                  : null,
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingMedium,
              ),
            ),
            onTap: () => setState(() => _isFocused = true),
            onFieldSubmitted: (_) => setState(() => _isFocused = false),
            onChanged: widget.onChanged,
            validator: (value) {
              final result = widget.validator?.call(value);
              setState(() => _hasError = result != null);
              return result;
            },
          ),
        ),
      ],
    );
  }
}

/// 日期选择器按钮
class DatePickerButton extends StatefulWidget {
  final DateTime? selectedDate;
  final String label;
  final void Function(DateTime) onDateSelected;

  const DatePickerButton({
    super.key,
    this.selectedDate,
    required this.label,
    required this.onDateSelected,
  });

  @override
  State<DatePickerButton> createState() => _DatePickerButtonState();
}

class _DatePickerButtonState extends State<DatePickerButton> {
  bool _isPressed = false;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate ?? DateTime.now(),
      firstDate: DateTime(AppConstants.minBirthYear),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      widget.onDateSelected(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _pickDate();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: AppAnimations.fast,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingMedium,
          ),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(
              color: widget.selectedDate != null
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: widget.selectedDate != null
                    ? AppColors.primary
                    : AppColors.textTertiary,
                size: AppDimensions.iconMedium,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.selectedDate != null
                          ? '${widget.selectedDate!.year}年${widget.selectedDate!.month}月${widget.selectedDate!.day}日'
                          : '请选择日期',
                      style: AppTextStyles.body.copyWith(
                        color: widget.selectedDate != null
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: AppDimensions.iconMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 分段选择器
class SegmentedSelector<T> extends StatelessWidget {
  final List<T> options;
  final List<String> labels;
  final T selectedValue;
  final void Function(T) onSelected;

  const SegmentedSelector({
    super.key,
    required this.options,
    required this.labels,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Row(
        children: List.generate(options.length, (index) {
          final isSelected = options[index] == selectedValue;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(options[index]),
              child: AnimatedContainer(
                duration: AppAnimations.normal,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
