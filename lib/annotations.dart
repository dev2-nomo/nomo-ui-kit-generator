class NomoComponentThemeData {
  final String themeName;

  const NomoComponentThemeData(this.themeName);
}

class NomoColorField<T> {
  final T value;
  final bool lerp;

  const NomoColorField(this.value, {this.lerp = true});
}

class NomoSizingField<T> {
  final T value;
  final bool lerp;

  const NomoSizingField(this.value, {this.lerp = true});
}

class NomoConstant<T extends Object> {
  final T value;

  const NomoConstant(this.value);
}

class NomoThemeUtils {
  final String name;

  const NomoThemeUtils(this.name);
}

class StaticFieldsList {
  const StaticFieldsList();
}
