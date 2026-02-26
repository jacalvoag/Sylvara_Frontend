import 'package:flutter/material.dart';

/// Campo de texto personalizado para formularios de autenticación
class CustomTextField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    required this.placeholder,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label del campo
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0E3520),
            fontFamily: 'Montserrat',
            height: 1.46,
          ),
        ),
        // Campo de texto
        Container(
          height: 24,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF0E3520),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0E3520),
              fontFamily: 'Montserrat',
              height: 1.56,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0E3520).withOpacity(0.75),
                fontFamily: 'Montserrat',
                height: 1.56,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8.84,
                vertical: 4.56,
              ),
              border: InputBorder.none,
              suffixIcon: suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: suffixIcon,
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
