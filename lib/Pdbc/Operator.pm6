enum Operator (
  EQUAL => ['=', True],
  NOT_EQUAL => ['<>', True],
  LIKE => ['LIKE', True, sub ($value) { return "%$value%";}],
  IS_NULL => ['IS NULL', False],
  IS_NOT_NULL => ['IS NOT NULL', False]
)
