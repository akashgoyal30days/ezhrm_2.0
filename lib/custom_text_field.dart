import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    Key? key,
    @required this.hint,
    this.isPassword = false,
    this.callBack,
    this.controller,
    this.enabled = true,
    this.textInputType = TextInputType.name,
  }) : super(key: key);
  final bool isPassword, enabled;
  final String? hint;
  final VoidCallback? callBack;
  final TextInputType textInputType;
  final TextEditingController? controller;
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword ? obscureText : false,
        cursorColor: const Color(0x33072a99),
        keyboardType: widget.textInputType,
        onSubmitted: widget.callBack != null ? (_) => widget.callBack!() : null,
        textInputAction: widget.callBack != null
            ? TextInputAction.done
            : TextInputAction.next,
        style: const TextStyle(color: Color(0xff072a99)),
        enabled: widget.enabled,
        decoration: InputDecoration(
          suffixIcon: widget.isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                  icon: obscureText
                      ? const Icon(
                          Icons.visibility_off,
                          color: Color(0xff072a99),
                        )
                      : const Icon(
                          Icons.visibility,
                          color: Color(0xff072a99),
                        ))
              : null,
          fillColor: Colors.grey.shade300,
          filled: true,
          contentPadding: const EdgeInsets.all(10),
          hintText: widget.hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
