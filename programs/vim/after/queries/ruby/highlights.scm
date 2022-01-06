(method
  name: (identifier) @custom.method.name)

; Method keyword argument styling
(keyword_parameter
  name: (identifier) @custom.keyword_parameter.name)
(keyword_parameter
  name: (identifier) @custom.keyword_parameter.name
  value: (identifier) @custom.keyword_parameter.value)

; Show the delimeter after a parameter name in the same colour
(keyword_parameter
 name: (identifier)
    ":" @custom.keyword_parameter.name)

; Show the delimeter after a hash_key_symbol in the same colour
(hash_key_symbol)
  ":" @symbol

; The :: between symbols (TSType)
(scope_resolution) @boolean

; The methods called directly on a class
(class (call
    method: (identifier) @custom.class.method.invocation))

; A method called within a block (not assignment)
(do_block
  (identifier) @function)

; foo unless some conditional (make foo a function)
(unless_modifier
  body: (identifier) @function)

; A method on an instance variable or element_reference
; foo.method or thing["foo"].method
; (call
  ; ((instance_variable) (identifier) @custom.method))
; (call
  ; ((element_reference) (identifier) @custom.method))
; (call
  ; ((constant) (identifier) @custom.method))

(call
  ([
    (instance_variable)
    (element_reference)
    (constant)
  ] (identifier) @custom.method))

; Close "end" from conditional with same colour
(if
  "end" @conditional)
(unless
  "end" @conditional)

; Safe traversal delimeter
["&."] @punctuation.delimiter

; Show bang methods as red
((identifier) @boolean
 (#match? @boolean "!$"))
