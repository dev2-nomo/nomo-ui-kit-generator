import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:collection/collection.dart';

const colorField = '@NomoColorField';
const sizingField = '@NomoSizingField';
const constantField = '@NomoConstant';

typedef FieldInfo = ({String type, String value, bool lerp});

extension FieldInfoUtil on FieldInfo {
  bool get isNullable => type.contains('?');

  String get typeWithoutNull => isNullable ? type.substring(0, type.length - 1) : type;

  String nullableFieldDeclaration(String name) {
    return 'final ${isNullable ? type : '$type?'} $name;';
  }

  String nonNullableFieldDeclaration(String name) {
    return 'final $type $name;';
  }

  String nonNullableConstrcutorFieldDeclaration(String name) {
    return 'this.$name = $constPrefix $value,';
  }

  String lerpFunction(String name) {
    final dontUseLerp = switch (typeWithoutNull) {
      'bool' => true,
      'BoxShape' => true,
      'Widget' => true,
      'IconData' => true,
      _ => !lerp,
    };
    if (dontUseLerp) {
      return '$name: t < 0.5 ? a.$name : b.$name,';
    }

    final nullAssertion = type.getNullablePostfix(value).contains('?') ? '' : '!';

    if (type == 'double') {
      return '$name: lerpDouble(a.$name, b.$name, t)$nullAssertion,';
    }

    if (type == 'double?') {
      return '$name: lerpDouble(a.$name, b.$name, t),';
    }

    return '$name: $typeWithoutNull.lerp(a.$name, b.$name, t)$nullAssertion,';
  }

  String get constPrefix {
    if (value.contains('(')) {
      return 'const';
    }
    return '';
  }
}

class ModelVisitor extends SimpleElementVisitor<void> {
  String? className;

  Map<String, dynamic> fields = {};

  Map<String, FieldInfo> colorFields = {};

  Map<String, FieldInfo> sizingFields = {};

  Map<String, FieldInfo> constants = {};

  @override
  void visitConstructorElement(ConstructorElement element) {
    className = element.type.returnType.toString();
  }

  @override
  void visitFieldElement(FieldElement element) {
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

        var valueString = colorFieldAnnotation.toSource().replaceAll(colorField, '');

        first_i = valueString.indexOf('>');

        valueString = first_i != -1 ? valueString.substring(first_i + 1) : valueString;

        valueString = valueString.substring(1, valueString.length - 1);

        int last_comma = valueString.lastIndexOf(',');
        final value = valueString.contains('lerp')
            ? valueString.substring(0, last_comma)
            : valueString;

        final lerp = fieldValue.getField('lerp')?.toBoolValue() ?? true;

        colorFields[element.name] = (type: type, value: value, lerp: lerp);
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

      var valueString = sizingFieldAnnotation.toSource().replaceAll(sizingField, '');

      first_i = valueString.indexOf('>');

      valueString = first_i != -1 ? valueString.substring(first_i + 1) : valueString;

      valueString = valueString.substring(1, valueString.length - 1);

      int last_comma = valueString.lastIndexOf(',');
      final value = valueString.contains('lerp')
          ? valueString.substring(0, last_comma)
          : valueString;

      final lerp = fieldValue.getField('lerp')?.toBoolValue() ?? true;

      sizingFields[element.name] = (type: type, value: value, lerp: lerp);

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

      final valueString = constantFieldAnnotation.toSource().replaceAll(sizingField, '');
      first_i = valueString.indexOf('(');
      final value = valueString.substring(first_i + 1, valueString.length - 1);

      constants[element.name] = (type: type, value: value, lerp: false);

      return;
    }

    fields[element.name] = element.type.getDisplayString();
  }
}

extension DartObjectUtil on String {
  String get typeOverride {
    return switch (this) {
      'EdgeInsets' => 'EdgeInsetsGeometry',
      'MaterialColor' => 'Color',
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
