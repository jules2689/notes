# Constant Lookup

This it the flowchart that Ruby follows to look up a constant.
The source for this flowchart was parse from the [defintion for `const_get` from Ruby 2.1.0](https://ruby-doc.org/core-2.1.0/Module.html#method-i-const_get).


<!---
```diagram
graph TD

subgraph Entry
  ARG[argc = num args, argv = args, mod = Module Called From]
end

subgraph Return
  Return[return module]
end

subgraph ArgsParsing
  ARG -- argc = 1 -\->NAME[name=arg, recursive=true]
  ARG -- argc > 1 -\->   rb_scan_args[name, recursive = pull from args]
end

subgraph Errors
  rb_eNameError[rb_eNameError wrong constant name]
  rb_name_error[rb_name_error: wrong constant name]
  rb_eTypeError[rb_eTypeError: does not refer to class/module]
  rv_name_error2[rb_name_error: uninitialized constant]
end

subgraph SYMBOL_P
  NAME -\-> SYMBOL_P?
  rb_scan_args -\-> SYMBOL_P?

  SYMBOL_P? -- name is symbol -\->   rb_is_const_id[is constant a method id?]
  rb_is_const_id -- false -\-> rb_name_error
  rb_is_const_id -- true -\-> RTEST[mod = RTEST ? rb_const_get : rb_const_get_at]
  RTEST-\->Return
end

subgraph Encoding
  SYMBOL_P? -- name is not a symbol -\->CheckEncoding[path = name, encoding from path]
  CheckEncoding -- Not ASCII Compatible -\-> rb_eNameError
end

subgraph FindIDLoop
  Loop[pointer < p_end]--false-\->Return
  Loop--true-\->Loop2

  Loop2--true, pointer += 1-\->Loop2

  Loop2--false-\->CheckforColon[pointer == p_begin, aka is the first character still ':']
  CheckforColon--true-\->rb_name_error
  CheckforColon--false-\->rb_check_id_cstr[rb_check_id_cstr TODO, id = something]
  rb_check_id_cstr-\->CheckPointer2[pointer not at the end? and first char is :]
  CheckPointer2--true-\->CheckPointer2_1[pointer + 2 is > end or the second char is not ':']
  CheckPointer2_1--true-\->rb_name_error
  CheckPointer2_1--false-\->SkipDoubleColon[pointer += 2, p_begin = pointer]
  SkipDoubleColon-\->ClassModuleCheck[is mod a class or module?]
  CheckPointer2-\->ClassModuleCheck
  ClassModuleCheck--false-\->rb_eTypeError
  ClassModuleCheck--true-\->IdCheck[is id nil?]
  IdCheck--false-\->idConstCheck[is id a constant?]
  idConstCheck--false-\->rb_name_error
  idConstCheck--true-\->ResolveMod[mod = rb_const_get OR rb_const_get_at]
  IdCheck--true-\->ConstCheckId[part is uppercase OR part is not a constant]
  ConstCheckId--false-\->CheckClassForConst[is const defined in class?]
  ConstCheckId--true-\->rb_name_error
  CheckClassForConst--true-\->SetIdPart[id = part]
  SetIdPart-\->idConstCheck
  CheckClassForConst--false-\->rv_name_error2
  ResolveMod-\->Loop
end

subgraph DirectConstant
  DirectConstantCheck[Check if first 2 chars are ::]--true-\->SetDirect[pointer += 2, p_begin = pointer, mod = Object. Basically remove the ::, set beginning after. This implies the module will be Object]
  SetDirect-\->Loop
  DirectConstantCheck--false-\->Loop
end

CheckEncoding-\->InitalizePathVars[pointer=beginning of path, p_begin = pointer, p_eng = pointer + length of path]

subgraph CheckLength??TODO
  InitalizePathVars-\->PathLength[Path is empty or nil?]
  PathLength --true-\-> rb_eNameError
  PathLength --false-\-> DirectConstantCheck
end

%% Styling
classDef error fill:#FFCCCC;
class rb_name_error error;
class rb_eNameError error;
class rb_eTypeError error;
class rv_name_error2 error;
```
--->

<img src='https://jules2689.github.io/gitcdn/images/website/const_get.png' alt='diagram image' class="full-width">
