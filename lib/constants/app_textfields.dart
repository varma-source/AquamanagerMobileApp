import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superapp/constants/app_colors.dart';
import 'package:superapp/constants/app_mediaquery.dart';

class Inputfield extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final double? borderRadius;
  final double? height;
  final String hinttext;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? Function(String?)? submitFun;
  final String? Function(String?)? onChanged;
  final List<TextInputFormatter>? textInputFormatter;
  final Widget? suffix;
  final Icon? prefixIcon;
  final int? maxLengths;
  final int? maxLetters;
  final Color? borderColor;
  final Color? fillColor;
  final Color? enabledBorder;
  final Color? focusedBorder;
  final Color? textColor;
  final bool isPasswordField;
  final bool? readOnly;
  final VoidCallback? onTap;

  const Inputfield({
    this.textInputFormatter,
    this.controller,
    this.enabledBorder,
    this.focusedBorder,
    this.height,
    this.borderRadius,
    super.key,
    this.label,
    required this.hinttext,
    this.keyboardType,
    this.validator,
    this.suffix,
    this.fillColor,
    this.textColor,
    this.prefixIcon,
    this.maxLengths,
    this.maxLetters,
    this.submitFun,
    this.onChanged,
    this.borderColor,
    this.isPasswordField = false,
    this.readOnly = false,
    this.onTap,
  });

  @override
  _InputfieldState createState() => _InputfieldState();
}

class _InputfieldState extends State<Inputfield> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: widget.height ?? 44,
          decoration: BoxDecoration(
            color: widget.fillColor ?? AppColors.whiteColor,
            border: Border.all(
              color: widget.borderColor ?? AppColors.whiteColor,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 40),
          ),
          child: TextFormField(
            obscureText: widget.isPasswordField ? _obscureText : false,
            onChanged: (text) {
              if (widget.maxLetters != null &&
                  text.length > widget.maxLetters!) {
                final truncatedText = text.substring(0, widget.maxLetters!);
                widget.controller?.text = truncatedText;
                widget.controller?.selection = TextSelection.fromPosition(
                  TextPosition(offset: truncatedText.length),
                );
              }
              if (widget.onChanged != null) {
                widget.onChanged!(text);
              }
              setState(() {});
            },
            textInputAction: TextInputAction.done,
            onFieldSubmitted: widget.submitFun,
            inputFormatters: widget.textInputFormatter,
            maxLines: widget.isPasswordField ? 1 : widget.maxLengths,
            style: GoogleFonts.inter(
              color: widget.textColor ?? AppColors.blackColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: widget.controller,
            validator: widget.validator,
            readOnly: widget.readOnly ?? false,
            onTap: widget.onTap,
            keyboardType: widget.keyboardType,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                left: getProportionateScreenWidth(16),
                top: getProportionateScreenHeight(0),
                right: getProportionateScreenWidth(0),
                bottom: getProportionateScreenHeight(0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: widget.enabledBorder ?? AppColors.greyColor,
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 40),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: widget.focusedBorder ?? AppColors.greyColor,
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 40),
              ),
              fillColor: widget.fillColor ?? AppColors.whiteColor,
              filled: true,
              labelText: widget.label,
              hintText: widget.hinttext,
              hintMaxLines: 1,
              prefixIcon: widget.prefixIcon,
              suffixIcon:
                  widget.isPasswordField
                      ? IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      )
                      : widget.suffix,
              hintStyle: GoogleFonts.inter(
                color: AppColors.greyColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              labelStyle: GoogleFonts.inter(
                color: AppColors.greyColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              floatingLabelStyle: GoogleFonts.robotoFlex(
                color: AppColors.blackColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
        ),
        if (widget.maxLetters != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0, right: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${widget.controller?.text.length ?? 0} / ${widget.maxLetters}',
                style: GoogleFonts.montserrat(
                  color: AppColors.greyColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
