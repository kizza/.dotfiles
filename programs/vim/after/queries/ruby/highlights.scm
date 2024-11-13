;; extends

; ; Custom method name
; (method
;   name: (identifier) @custom.method.name)

; Show the delimeter after a hash_key_symbol in the same colour
(hash_key_symbol)
  ":" @symbol

; Method keyword argument styling
(keyword_parameter
  name: (identifier) @custom.keyword_parameter.name)
(keyword_parameter
  name: (identifier) @custom.keyword_parameter.name
  value: (identifier) @custom.keyword_parameter.value)

; Show the delimeter after a parameter name in the same colour
(keyword_parameter
 name: (identifier)
    ":" @parameter)
    ; ":" @custom.keyword_parameter.name)

; The :: between symbols (TSType)
(scope_resolution) @boolean

; The class level methods (before_actoin or layout)
(class
  (body_statement
    (call
      (identifier) @custom.class.called.methods)))

; Conditionals within class level methods (validates :foo, *if:* :somthing
(call
  (argument_list
    (pair
      (hash_key_symbol) @custom.class.called.conditional
        (#any-of? @custom.class.called.conditional "if" "unless")
          (":") @custom.class.called.conditional.symbol
      )
  )
)

; ; The methods called directly on a class
; (class (call
;     method: (identifier) @custom.class.method.invocation))

; ; A method called within a block (not assignment)
; (do_block
;   (identifier) @function)

; foo unless some conditional (make foo a function)
(unless_modifier
  condition: (identifier) @function)

; ; A method on an instance variable or element_reference
; ; foo.method or thing["foo"].method
; ; (call
;   ; ((instance_variable) (identifier) @custom.method))
; ; (call
;   ; ((element_reference) (identifier) @custom.method))
; ; (call
;   ; ((constant) (identifier) @custom.method))

; (call
;   ([
;     (instance_variable)
;     (element_reference)
;     (constant)
;   ] (identifier) @custom.method))

; ; Close "end" from conditional with same colour
; (if
;   "end" @conditional)
; (unless
;   "end" @conditional)

; Safe traversal delimeter
["&."] @symbol

; ; Mapping to "&:to_s" showing the & as a sumbol (nor operator)
; Not sure if I like this
; (argument_list
;  (block_argument
;   (simple_symbol)) @symbol)

; ; Show bang methods as red
((identifier) @boolean
 (#match? @boolean "!$"))
