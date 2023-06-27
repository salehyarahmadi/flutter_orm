const Map<String, String> builtInTypes = {
  'int': 'INTEGER NOT NULL',
  'int?': 'INTEGER',
  'num': 'REAL NOT NULL',
  'num?': 'REAL',
  'String': 'TEXT NOT NULL',
  'String?': 'TEXT',
  'Uint8List': 'BLOB NOT NULL',
  'Uint8List?': 'BLOB',
};

const String convertersHelperClassName = 'ConvertersHelper';
const String predefinedConvertersHelperClassName = 'PredefinedConvertersHelper';