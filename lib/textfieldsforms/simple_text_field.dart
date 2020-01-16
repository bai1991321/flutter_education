import 'package:flutter/material.dart';

class SimpleTextField extends StatefulWidget {
  final FocusNode focusNode;
  final FocusNode focusNodeNext;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final Color fillColor;
  final String hintText;
  final String labelText;
  final VoidCallback onEditingComplete;
  final TextEditingController textEditingController;
  final bool obscureText;
  final FormFieldValidator<String> validator;
  final FormFieldSetter<String> onSaved;
  final GlobalKey<FormState> formKey;
  final bool autoValidate;
  final TextCapitalization textCapitalization;
  final bool enabled;
  final bool autoFocus;
  final String initialValue;
  final ValueChanged<String> onFieldSubmitted;
  final int maxLenght;
  final int maxLines;

  SimpleTextField(
      {Key key,
      this.initialValue,
      this.formKey,
      this.focusNode,
      this.focusNodeNext,
      this.textInputType = TextInputType.text,
      this.textInputAction = TextInputAction.done,
      this.textCapitalization = TextCapitalization.none,
      this.fillColor = Colors.grey,
      this.hintText = '',
      this.labelText = '',
      this.onEditingComplete,
      this.textEditingController,
      this.validator,
      this.onSaved,
      this.obscureText = false,
      this.autoValidate = false,
      this.enabled = true,
      this.autoFocus = false,
      this.onFieldSubmitted,
      this.maxLenght,
      this.maxLines})
      : super(key: key);

  @override
  _SimpleTextFieldState createState() => new _SimpleTextFieldState();
}

class _SimpleTextFieldState extends State<SimpleTextField> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      autovalidate: widget.autoValidate,
      child: Container(
        padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
        child: TextFormField(
          //initialValue: widget.initialValue,
          focusNode: widget.focusNode,
          onFieldSubmitted: (term) {
            if (widget.focusNodeNext != null) {
              FocusScope.of(context).requestFocus(widget.focusNodeNext);
            } else {
              widget.focusNode.unfocus();
            }
          },
          onEditingComplete: () => widget.onEditingComplete,
          controller: widget.textEditingController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(1.0))),
            filled: false,
            fillColor: widget.fillColor,
            hintText: widget.hintText,
            labelText: widget.labelText,
            contentPadding: EdgeInsets.all(12.0),
          ),
          obscureText: widget.obscureText,
          keyboardType: widget.textInputType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onSaved: widget.onSaved,
          textCapitalization: widget.textCapitalization,
          //autofocus: true|false,
          enabled: widget.enabled,
          autofocus: widget.autoFocus,
          style: new TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.normal,
            color: Colors.black,
            fontFamily: 'nova',
          ),
          maxLength: widget.maxLenght,
          maxLines: widget.maxLines,
        ),
      ),
    );
  }
}
