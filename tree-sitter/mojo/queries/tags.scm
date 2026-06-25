(class_definition
  name: (identifier) @name) @definition.class

(trait_definition
  name: (identifier) @name) @definition.interface

(function_definition
  name: (identifier) @name) @definition.function

(type_alias_statement
  left: (type (identifier) @name)) @definition.constant

(parameterized_alias_statement
  name: (identifier) @name) @definition.constant

(assignment
  "var"
  left: (pattern (identifier) @name)) @definition.variable

(call
  function: [
    (identifier) @name
    (attribute
      attribute: (identifier) @name)
  ]) @reference.call
