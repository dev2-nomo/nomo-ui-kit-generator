import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';

const colorField = "@NomoColorField";
const sizingField = "@NomoSizingField";
const constantField = "@NomoConstant";

class ModelVisitor extends SimpleElementVisitor {
  String? className;

  Map<String, dynamic> fields = {};

  Map<String, (String, String, bool)> colorFields = {};

  Map<String, (String, String, bool)> sizingFields = {};

  Map<String, (String, String, bool)> constants = {};

  @override
  visitConstructorElement(ConstructorElement element) {
    className = element.type.returnType.toString();
  }

  @override
  visitFieldElement(FieldElement element) {
    final colorFieldAnnotation = element.metadata.singleWhereOrNull(
      (annotation) => annotation.toSource().startsWith(colorField),
    );

    if (colorFieldAnnotation != null) {
      final fieldValue = colorFieldAnnotation.computeConstantValue();

      if (fieldValue != null) {
        final typeString = colorFieldAnnotation.element.toString();
        int first_i = typeString.indexOf('<');
        int last_i = typeString.lastIndexOf('>');
        final type = typeString.substring(first_i + 1, last_i).typeOverride;

        var valueString =
            colorFieldAnnotation.toSource().replaceAll(colorField, '');

        first_i = valueString.indexOf('>');

        valueString =
            first_i != -1 ? valueString.substring(first_i + 1) : valueString;

        valueString = valueString.substring(1, valueString.length - 1);

        int last_comma = valueString.lastIndexOf(',');
        final value = valueString.contains('lerp')
            ? valueString.substring(0, last_comma)
            : valueString;

        final lerp = fieldValue.getField('lerp')?.toBoolValue() ?? true;

        colorFields[element.name] = (type, value, lerp);
      }

      return;
    }

    final sizingFieldAnnotation = element.metadata.singleWhereOrNull(
      (annotation) => annotation.toSource().startsWith(sizingField),
    );

    if (sizingFieldAnnotation != null) {
      final fieldValue = sizingFieldAnnotation.computeConstantValue();

      if (fieldValue == null) return;

      final typeString = sizingFieldAnnotation.element.toString();

      int first_i = typeString.indexOf('<');
      int last_i = typeString.lastIndexOf('>');
      final type = typeString.substring(first_i + 1, last_i).typeOverride;

      var valueString =
          sizingFieldAnnotation.toSource().replaceAll(sizingField, '');

      first_i = valueString.indexOf('>');

      valueString =
          first_i != -1 ? valueString.substring(first_i + 1) : valueString;

      valueString = valueString.substring(1, valueString.length - 1);

      int last_comma = valueString.lastIndexOf(',');
      final value = valueString.contains('lerp')
          ? valueString.substring(0, last_comma)
          : valueString;

      final lerp = fieldValue.getField('lerp')?.toBoolValue() ?? true;

      sizingFields[element.name] = (type, value, lerp);

      return;
    }

    final constantFieldAnnotation = element.metadata.singleWhereOrNull(
      (annotation) => annotation.toSource().startsWith(constantField),
    );

    if (constantFieldAnnotation != null) {
      final typeString = constantFieldAnnotation.element.toString();

      int first_i = typeString.indexOf('<');
      int last_i = typeString.lastIndexOf('>');
      final type = typeString.substring(first_i + 1, last_i).typeOverride;

      final valueString =
          constantFieldAnnotation.toSource().replaceAll(sizingField, '');
      first_i = valueString.indexOf('(');
      final value = valueString.substring(first_i + 1, valueString.length - 1);

      constants[element.name] = (type, value, false);

      return;
    }

    fields[element.name] =
        element.type.getDisplayString(withNullability: false);
  }
}

extension DartObjectUtil on String {
  String get typeOverride {
    return switch (this) {
      "EdgeInsets" => "EdgeInsetsGeometry",
      "MaterialColor" => "Color",
      _ => this,
    };
  }

  String getNullablePostfix(String value) {
    return "$this${switch (value) {
      "null" || "Null" => "?",
      _ => "",
    }}";
  }
}

extension DartTypeUtil on (String, String) {
  String get constPrefix {
    return switch (this) {
      (_, String val) when !val.contains('(') => "",
      _ => "const",
    };
  }
}
