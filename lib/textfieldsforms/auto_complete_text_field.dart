import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SimpleAutoCompleteTextFormField extends StatefulWidget {
  final List suggestions;
  final GlobalKey<FormState> formKey;
  final Comparator itemSorter;
  final bool submitOnSuggestionTap, clearOnSubmit;
  final InputDecoration decoration;
  final TextStyle style;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final FocusNode focusNode;
  final FocusNode focusNodeNext;
  final TextInputType textInputType;
  final Color fillColor;
  final String hintText;
  final String labelText;
  final VoidCallback onEditingComplete;
  final TextEditingController textEditingController;
  final bool obscureText;
  final FormFieldValidator<String> validator;
  final FormFieldSetter<String> onSaved;
  final bool autoValidate;
  final bool enabled;
  final String initialValue;
  final SuggestionsCallback suggestionsCallback;
  final SuggestionSelectionCallback onSuggestionSelected;

  SimpleAutoCompleteTextFormField(
      {Key key,
      this.suggestions,
      this.formKey,
      this.itemSorter,
      this.submitOnSuggestionTap,
      this.clearOnSubmit,
      this.decoration,
      this.style,
      this.keyboardType,
      this.initialValue,
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
      this.suggestionsCallback,
      this.onSuggestionSelected})
      : super(key: key);

  @override
  _SimpleAutoCompleteTextFormFieldState createState() =>
      new _SimpleAutoCompleteTextFormFieldState();
}

class _SimpleAutoCompleteTextFormFieldState
    extends State<SimpleAutoCompleteTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      autovalidate: widget.autoValidate,
      child: Container(
        padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
        child: Column(
          children: <Widget>[
            TypeAheadFormField(
              errorBuilder: (BuildContext context, Object error) => Text(
                  '$error',
                  style: TextStyle(color: Theme.of(context).errorColor)),
              textFieldConfiguration: TextFieldConfiguration(
                onEditingComplete: () => widget.onEditingComplete,
                keyboardType: widget.textInputType,
                focusNode: widget.focusNode,
                textInputAction: widget.textInputAction,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(1.0))),
                  filled: false,
                  fillColor: widget.fillColor,
                  hintText: widget.hintText,
                  labelText: widget.labelText,
                  contentPadding: EdgeInsets.all(12.0),
                ),
                //decoration: InputDecoration(labelText: widget.labelText),
                controller: widget.textEditingController,
              ),
              validator: widget.validator,
              onSaved: widget.onSaved,
              suggestionsCallback: widget.suggestionsCallback,
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              onSuggestionSelected: widget.onSuggestionSelected,
            ),
          ],
        ),
      ),
    );
  }
}
