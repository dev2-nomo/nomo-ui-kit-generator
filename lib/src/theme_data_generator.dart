// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:nomo_ui_generator/src/model_visitor.dart';
import 'package:source_gen/source_gen.dart';

import 'package:nomo_ui_generator/annotations.dart';

const ignore_lints =
    '// ignore_for_file: prefer_constructors_over_static_methods,avoid_unused_constructor_parameters, require_trailing_commas, avoid_init_to_null, use_named_constants, strict_raw_type, prefer_const_constructors, unnecessary_non_null_assertion';

class ComponentThemeDataGenerator
    extends GeneratorForAnnotation<NomoComponentThemeData> {
  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final buffer = StringBuffer();

    final visitor = ModelVisitor();
    element.visitChildren(visitor);

    buffer.writeln(ignore_lints);

    final _className = element.name;
    if (_className == null) throw Exception('Class name is null');

    ///
    /// ColorData
    ///
    final colorDataClassNameNullable = '${_className}ColorDataNullable';
    final colorDataClassName = '${_className}ColorData';

    buffer
      ..write(
        _colorThemeDataNullable(
          className: colorDataClassNameNullable,
          colorFields: visitor.colorFields,
        ),
      )
      ..write(
        _colorThemeData(
          className: colorDataClassName,
          classNameNullable: colorDataClassNameNullable,
          colorFields: visitor.colorFields,
        ),
      );

    ///
    /// SizingData
    ///

    final sizingDataClassNameNullable = '${_className}SizingDataNullable';
    final sizingDataClassName = '${_className}SizingData';

    buffer
      ..write(
        _sizingDataNullable(
          className: sizingDataClassNameNullable,
          sizingFields: visitor.sizingFields,
        ),
      )
      ..write(
        _sizingData(
          className: sizingDataClassName,
          classNameNullable: sizingDataClassNameNullable,
          sizingFields: visitor.sizingFields,
        ),
      );

    ///
    /// Constants
    ///

    final contantsName = '${_className}Constants';
    final contantsNameNullable = '${_className}ConstantsNullable';

    buffer
      ..write(
        _constantsNullable(
          className: contantsNameNullable,
          constants: visitor.constants,
        ),
      )
      ..write(
        _constants(
          className: contantsName,
          constants: visitor.constants,
          classNameNullable: contantsNameNullable,
        ),
      );

    ///
    /// ThemeData
    ///

    final themeDataClassName = '${_className}ThemeData';
    final themeDataNullableClassName = '${_className}ThemeDataNullable';
    final themeOverrideInheritedWidgetClassName = '${_className}ThemeOverride';

    buffer
      ..write(
        _getThemeDataClass(
          className: themeDataClassName,
          colordataClassName: colorDataClassName,
          sizingdataClassName: sizingDataClassName,
          themeDataClassNameNullable: themeDataNullableClassName,
          constantClassName: contantsName,
          colorFields: visitor.colorFields,
          sizingFields: visitor.sizingFields,
          constants: visitor.constants,
        ),
      )
      ..write(
        _getThemeDataNullableClass(
          className: themeDataNullableClassName,
          colordataClassNameNullable: colorDataClassNameNullable,
          sizingdataClassNameNullable: sizingDataClassNameNullable,
          constantsName: contantsNameNullable,
          colorFields: visitor.colorFields,
          sizingFields: visitor.sizingFields,
          constants: visitor.constants,
        ),
      )
      ..write(
        _getThemeOverrideInheritedWidget(
          className: themeOverrideInheritedWidgetClassName,
          themeDataClassName: themeDataNullableClassName,
        ),
      );

    ///
    /// GetFromContext Function
    ///

    final themeName = annotation.read('themeName').stringValue;

    buffer.write(
      _getFromContext(
        widgetName: _className,
        themeDataClassName: themeDataClassName,
        colorDataClassName: colorDataClassName,
        sizingDataClassName: sizingDataClassName,
        themeName: themeName,
        overrideThemeInheritedWidgetClassName:
            themeOverrideInheritedWidgetClassName,
        colorFields: visitor.colorFields,
        sizingFields: visitor.sizingFields,
        constants: visitor.constants,
        constantsName: contantsName,
      ),
    );

    final content = buffer.toString();
    buffer.clear();

    return content;
  }

  String _colorThemeDataNullable({
    required String className,
    required Map<String, FieldInfo> colorFields,
  }) {
    final buffer = StringBuffer()..writeln('class $className {');

    for (final colorfieldEntry in colorFields.entries) {
      buffer.writeln(
        colorfieldEntry.value.nullableFieldDeclaration(colorfieldEntry.key),
      );
    }

    /// Constructor
    buffer.writeln('const $className(');
    if (colorFields.isNotEmpty) {
      buffer.writeln('{');
      for (final name in colorFields.keys) {
        buffer.writeln('this.$name,');
      }

      buffer.writeln('}');
    }
    buffer
      ..writeln(');')
      ..writeln('}');
    final content = buffer.toString();
    buffer.clear();
    return content;
  }

  String _colorThemeData({
    required String className,
    required String classNameNullable,
    required Map<String, FieldInfo> colorFields,
  }) {
    final buffer = StringBuffer()
      ..writeln('class $className implements $classNameNullable{');

    for (final colorfieldEntry in colorFields.entries) {
      buffer
        ..writeln('@override')
        ..writeln(
          colorfieldEntry.value
              .nonNullableFieldDeclaration(colorfieldEntry.key),
        );
    }

    /// Constructor
    buffer.writeln('const $className(');
    if (colorFields.isNotEmpty) {
      buffer.writeln('{');
      for (final colorfieldEntry in colorFields.entries) {
        buffer.writeln(
          colorfieldEntry.value
              .nonNullableConstrcutorFieldDeclaration(colorfieldEntry.key),
        );
      }

      buffer.writeln('}');
    }
    buffer.writeln(');');

    /// Lerp
    // ignore: cascade_invocations
    buffer
      ..writeln(
        'static $className lerp($className a, $className b, double t) {',
      )
      ..writeln(
        "return ${colorFields.entries.isEmpty ? 'const' : ''} $className(",
      );
    for (final entry in colorFields.entries) {
      buffer.writeln(entry.value.lerpFunction(entry.key));
    }
    buffer.writeln(');}');

    /// Override
    // ignore: cascade_invocations
    buffer
      ..writeln('static $className overrideWith(')
      ..writeln('$className base,')
      ..writeln('[$classNameNullable? override]')
      ..writeln(') {')
      ..writeln('return $className(');
    for (final name in colorFields.keys) {
      buffer.writeln('$name: override?.$name ?? base.$name,');
    }
    buffer
      ..writeln(');}')
      ..writeln('}');
    final content = buffer.toString();
    buffer.clear();
    return content;
  }

  String _getThemeOverrideInheritedWidget({
    required String className,
    required String themeDataClassName,
  }) {
    final buffer = StringBuffer()
      ..writeln('class $className extends InheritedWidget {')
      ..writeln('final $themeDataClassName data;')
      ..writeln('const $className({')
      ..writeln('required this.data,')
      ..writeln('required super.child,')
      ..writeln('super.key')
      ..writeln('});')
      ..writeln('''
      static $themeDataClassName of(BuildContext context) {
      final result = context.dependOnInheritedWidgetOfExactType<$className>();
        assert(result != null, 'No ThemeInfo found in context');
        return result!.data;
      }''')
      ..writeln('''
      static $themeDataClassName? maybeOf(BuildContext context) {
      return context
          .dependOnInheritedWidgetOfExactType<$className>()
          ?.data;
      }''')
      ..writeln('''
      @override
      bool updateShouldNotify($className oldWidget) {
      return oldWidget.data != data;
      }''')
      ..writeln('}');

    final content = buffer.toString();
    buffer.clear();
    return content;
  }

  ///
  /// SizingTheme
  ///
  String _sizingDataNullable({
    required String className,
    required Map<String, FieldInfo> sizingFields,
  }) {
    final buffer = StringBuffer()..writeln('class $className {');

    for (final entry in sizingFields.entries) {
      buffer.writeln(entry.value.nullableFieldDeclaration(entry.key));
    }

    /// Constructor
    buffer.writeln('const $className(');
    if (sizingFields.isNotEmpty) {
      buffer.writeln('{');
      for (final name in sizingFields.keys) {
        buffer.writeln('this.$name,');
      }

      buffer.writeln('}');
    }
    buffer
      ..writeln(');')
      ..writeln('}');
    final content = buffer.toString();
    buffer.clear();
    return content;
  }

  String _sizingData({
    required String className,
    required String classNameNullable,
    required Map<String, FieldInfo> sizingFields,
  }) {
    final buffer = StringBuffer()
      ..writeln('class $className implements $classNameNullable{');

    for (final colorfieldEntry in sizingFields.entries) {
      buffer
        ..writeln('@override')
        ..writeln(
          colorfieldEntry.value
              .nonNullableFieldDeclaration(colorfieldEntry.key),
        );
    }

    /// Constructor
    buffer.writeln('const $className(');
    if (sizingFields.isNotEmpty) {
      buffer.writeln('{');
      for (final colorfieldEntry in sizingFields.entries) {
        buffer.writeln(
          colorfieldEntry.value
              .nonNullableConstrcutorFieldDeclaration(colorfieldEntry.key),
        );
      }

      buffer.writeln('}');
    }
    buffer.writeln(');');

    /// Lerp
    // ignore: cascade_invocations
    buffer
      ..writeln(
        'static $className lerp($className a, $className b, double t) {',
      )
      ..writeln(
        "return ${sizingFields.entries.isEmpty ? 'const' : ''} $className(",
      );
    for (final entry in sizingFields.entries) {
      buffer.writeln(entry.value.lerpFunction(entry.key));
    }
    buffer.writeln(');}');

    /// Override
    // ignore: cascade_invocations
    buffer
      ..writeln('static $className overrideWith(')
      ..writeln('$className base,')
      ..writeln('[$classNameNullable? override]')
      ..writeln(') {')
      ..writeln('return $className(');
    for (final name in sizingFields.keys) {
      buffer.writeln('$name: override?.$name ?? base.$name,');
    }
    buffer
      ..writeln(');}')
      ..writeln('}');
    final content = buffer.toString();
    buffer.clear();
    return content;
  }

  ///
  /// THEMEDATA
  ///

  String _getThemeDataClass({
    required String className,
    required String colordataClassName,
    required String sizingdataClassName,
    required String themeDataClassNameNullable,
    required String constantClassName,
    required Map<String, FieldInfo> colorFields,
    required Map<String, FieldInfo> sizingFields,
    required Map<String, FieldInfo> constants,
  }) {
    final buffer = StringBuffer()
      ..writeln(
        'class $className implements $colordataClassName, $sizingdataClassName, $constantClassName{',
      );

    /// Fields
    final fields = {...colorFields, ...sizingFields, ...constants};

    for (final field in fields.entries) {
      final name = field.key;
      buffer
        ..writeln('@override')
        ..writeln(field.value.nonNullableFieldDeclaration(name));
    }

    /// Constructor
    buffer.writeln('const $className(');
    if (fields.isNotEmpty) {
      buffer.writeln('{');
      for (final field in fields.entries) {
        buffer.writeln(
          field.value.nonNullableConstrcutorFieldDeclaration(field.key),
        );
      }
      buffer.writeln('}');
    }
    buffer.writeln(');');

    /// Factory
    // ignore: cascade_invocations
    buffer
      ..writeln('factory $className.from(')
      ..writeln('$colordataClassName colors,')
      ..writeln('$sizingdataClassName sizing,')
      ..writeln('$constantClassName constants,')
      ..writeln(') {')
      ..writeln('return $className(');
    for (final name in colorFields.keys) {
      buffer.writeln('$name: colors.$name,');
    }
    for (final name in sizingFields.keys) {
      buffer.writeln('$name: sizing.$name,');
    }
    for (final name in constants.keys) {
      buffer.writeln('$name: constants.$name,');
    }
    buffer
      ..writeln(');')
      ..writeln('}');

    /// Override
    // ignore: cascade_invocations
    buffer
      ..writeln('$className copyWith([')
      ..writeln('$themeDataClassNameNullable? override')
      ..writeln(']) {')
      ..writeln('return $className(');
    for (final name in [
      ...colorFields.keys,
      ...sizingFields.keys,
      ...constants.keys,
    ]) {
      buffer.writeln('$name: override?.$name ?? $name,');
    }

    buffer
      ..writeln(');')
      ..writeln('}')
      ..writeln('}');

    final content = buffer.toString();
    buffer.clear();
    return content;
  }
}

String _getThemeDataNullableClass({
  required String className,
  required String colordataClassNameNullable,
  required String sizingdataClassNameNullable,
  required String constantsName,
  required Map<String, FieldInfo> colorFields,
  required Map<String, FieldInfo> sizingFields,
  required Map<String, FieldInfo> constants,
}) {
  final buffer = StringBuffer()
    ..writeln(
      'class $className implements $colordataClassNameNullable, $sizingdataClassNameNullable, $constantsName{',
    );

  /// Fields
  final fields = {...colorFields, ...sizingFields, ...constants};

  for (final field in fields.entries) {
    buffer
      ..writeln('@override')
      ..writeln(field.value.nullableFieldDeclaration(field.key));
  }

  /// Constructor
  if (fields.isNotEmpty) {
    buffer.writeln('const $className({');
    for (final name in fields.keys) {
      buffer.writeln('this.$name,');
    }

    buffer.writeln('});');
  }

  buffer.writeln('}');

  final content = buffer.toString();
  buffer.clear();
  return content;
}

String _getFromContext({
  required String widgetName,
  required String themeDataClassName,
  required String sizingDataClassName,
  required String colorDataClassName,
  required String themeName,
  required String overrideThemeInheritedWidgetClassName,
  required String constantsName,
  required Map<String, FieldInfo> colorFields,
  required Map<String, FieldInfo> sizingFields,
  required Map<String, FieldInfo> constants,
}) {
  final buffer = StringBuffer()
    ..writeln('$themeDataClassName getFromContext(')
    ..writeln('BuildContext context,')
    ..writeln('$widgetName widget,')
    ..writeln(') {');

  if (colorFields.isNotEmpty) {
    buffer.writeln(
      'final globalColorTheme = NomoTheme.maybeOf(context)?.componentColors.${themeName}Color ?? const $colorDataClassName();',
    );
  } else {
    buffer.writeln('const globalColorTheme = $colorDataClassName();');
  }
  if (sizingFields.isNotEmpty) {
    buffer.writeln(
      'final globalSizingTheme = NomoTheme.maybeOf(context)?.componentSizes.${themeName}Sizing ?? const $sizingDataClassName();',
    );
  } else {
    buffer.writeln('const globalSizingTheme = $sizingDataClassName();');
  }

  if (constants.isNotEmpty) {
    buffer.writeln(
      'final globalConstants = NomoTheme.maybeOf(context)?.constants.${themeName}Theme ?? const $constantsName();',
    );
  } else {
    buffer.writeln('const globalConstants = $constantsName();');
  }

  buffer
    ..writeln(
      'final themeOverride = $overrideThemeInheritedWidgetClassName.maybeOf(context);',
    )
    ..writeln(
      'final themeData = $themeDataClassName.from(globalColorTheme, globalSizingTheme, globalConstants).copyWith(themeOverride);',
    )
    ..writeln('return $themeDataClassName(');
  for (final name in [
    ...colorFields.keys,
    ...sizingFields.keys,
    ...constants.keys,
  ]) {
    buffer.writeln('$name: widget.$name ?? themeData.$name,');
  }

  buffer
    ..writeln(');')
    ..writeln('}');

  final content = buffer.toString();
  buffer.clear();
  return content;
}

///
/// Constants
///
String _constantsNullable({
  required String className,
  required Map<String, FieldInfo> constants,
}) {
  final buffer = StringBuffer()..writeln('class $className {');

  for (final entry in constants.entries) {
    buffer.writeln(entry.value.nullableFieldDeclaration(entry.key));
  }

  /// Constructor
  buffer.writeln('const $className(');
  if (constants.isNotEmpty) {
    buffer.writeln('{');
    for (final name in constants.keys) {
      buffer.writeln('this.$name,');
    }

    buffer.writeln('}');
  }
  buffer
    ..writeln(');')
    ..writeln('}');
  final content = buffer.toString();
  buffer.clear();
  return content;
}

String _constants({
  required String className,
  required String classNameNullable,
  required Map<String, FieldInfo> constants,
}) {
  final buffer = StringBuffer()
    ..writeln('class $className implements $classNameNullable{');

  for (final colorfieldEntry in constants.entries) {
    buffer
      ..writeln('@override')
      ..writeln(
        colorfieldEntry.value.nonNullableFieldDeclaration(colorfieldEntry.key),
      );
  }

  /// Constructor
  buffer.writeln('const $className(');
  if (constants.isNotEmpty) {
    buffer.writeln('{');
    for (final colorfieldEntry in constants.entries) {
      buffer.writeln(
        colorfieldEntry.value
            .nonNullableConstrcutorFieldDeclaration(colorfieldEntry.key),
      );
    }

    buffer.writeln('}');
  }
  buffer
    ..writeln(');')
    ..writeln('}');
  final content = buffer.toString();
  buffer.clear();
  return content;
}
