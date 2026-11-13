import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/color_scheme.dart';

class SearchInput extends StatefulWidget {
  const SearchInput({
    Key? key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.onClear,
  }) : super(key: key);

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(color: lightGreyColor, fontFamily: 'Poppins'),
        decoration: InputDecoration(
          hintText: widget.hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: primaryColor, width: 1.5),
          ),
          hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontFamily: 'Poppins'),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset(
              'assets/icons/search.svg',
              color: lightGreyColor,
              width: 18,
              height: 18,
            ),
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: lightGreyColor, size: 20),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged?.call('');
                    widget.onClear?.call();
                  },
                )
              : null,
          filled: true,
          fillColor: greycolor,
        ),
      ),
    );
  }
}
