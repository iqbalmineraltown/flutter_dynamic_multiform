import 'package:dynamic_multiform/streamed.dart';

class MainBloc {
  final List<StreamedList<StreamedValue<String>>> fieldStreamedLists =
      List<StreamedList<StreamedValue<String>>>();

  final StreamedList<StreamedValue<String>> nameFieldStreamedList =
      StreamedList<StreamedValue<String>>(initialData: []);

  List<String> get names => nameFieldStreamedList.value
      .where((stream) => stream != null)
      .map((stream) => stream.value)
      .toList();

  void initializeForm(Form form) {
    for (var field in form.fields) {
      fieldStreamedLists
          .add(StreamedList<StreamedValue<String>>(initialData: []));
    }
  }

  void addForm() {}

  StreamedValue<bool> allFieldsValidStreamedValue =
      StreamedValue<bool>(initialData: false);

  void newForm() {
    nameFieldStreamedList.addElement(
        StreamedValue<String>(onError: (e) {})..onChange(checkForm));
    checkForm('');
  }

  void removeForm(int index) {
    nameFieldStreamedList.value[index].dispose();
    nameFieldStreamedList.value[index] = null;

    checkForm('');
  }

  void onSubmit() {
    print(names.toString());
  }

  /// everytime a field changed, this will re-check EVERY fields
  void checkForm(String _) {
    var isValidFieldsTypeName = true;

    for (var item in nameFieldStreamedList.value) {
      if (item != null) {
        if (item.value != null) {
          if (item.value.isEmpty) {
            item.sink.addError('The text must not be empty.');
            isValidFieldsTypeName = false;
          } else if (item.value.contains(RegExp(r'[0-9]'))) {
            item.sink.addError('The text should not contains numbers.');
            isValidFieldsTypeName = false;
          }
        } else {
          item.sink.addError('The text must not be null.');
          isValidFieldsTypeName = false;
        }
      }
    }

    allFieldsValidStreamedValue.value = isValidFieldsTypeName ? true : null;
  }
}

final form = Form()
  ..fields = <Field>[
    Field()
      ..fieldTypeString = 'name'
      ..fieldName = 'Name'
      ..fieldHint = 'Full Name',
  ];

enum FieldTypeEnum {
  name,
  email,
  phone,
}

enum ValidationTypeEnum {
  alphabet,
  numeric,
  email,
  phone,
}

class Field {
  String fieldTypeString;
  String fieldName;
  String fieldHint;
  String validationTypeString;

  FieldTypeEnum fieldType() {
    switch (fieldTypeString) {
      case 'name':
        return FieldTypeEnum.name;
      case 'email':
        return FieldTypeEnum.email;
      case 'phone':
        return FieldTypeEnum.phone;
      default:
        throw UnimplementedError('Unknown Field Type: $fieldTypeString');
    }
  }

  ValidationTypeEnum validationType() {
    switch (validationTypeString) {
      case 'alphabet':
        return ValidationTypeEnum.alphabet;
      case 'numeric':
        return ValidationTypeEnum.numeric;
      case 'email':
        return ValidationTypeEnum.email;
      case 'phone':
        return ValidationTypeEnum.phone;
      default:
        throw UnimplementedError('Unknown Validation Type: $fieldTypeString');
    }
  }
}

class Form {
  List<Field> fields;
}
