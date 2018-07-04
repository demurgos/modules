# Terminology

### Default export
[default-export]: #default-export

The "default export" is the export binding named `default` exported from an ES
module.

You can either export a declaration named `default` or use the
`export default` syntax.

### Export binding
[export-binding]: #export-binding

An "export binding" is a binding exported from an ES module.

The export bindings are "live bindings". When the exporting module changes the
value of an exported binding, then the change is also reflected at the
importing modules.

### mjs

"mjs" ("*.mjs", ".mjs") is a file extension indicating Javascript files with
the _Module_ parse (ES modules).

It may stand for "Modular JavaScript", but people like to call it
"Michael Jackson Script".

### _Module_ parse goal

`Script` corresponds to the original way to handle source code.

### Module resolution
[module-resolution]: #module-resolution

The "module resolution" is the process to find the source text corresponding to
an import, based off the consumer's module and the import specifier.

It corresponds to the [`resolveHook`](https://nodejs.org/docs/latest-v10.x/api/esm.html#esm_resolve_hook)

### Parse goal
[parse-goal]: #parse-goal

A "parse goal" (formally "goal symbol") is the spec term for Javascript's
variants. Each parse goal has different syntax and semantics.

As of 2018, the ES spec defines two parse goals: _Script_ and _Module_.

[Spec](https://www.ecma-international.org/ecma-262/9.0/index.html#sec-ecmascript-language-scripts-and-modules)


### _Script_ parse goal

`Script` corresponds to the original way to handle source code.

### Parse goal determination

The _parse goal determination_ is the mechanism used to decide which [parse goal][parse-goal] to use for a source text.

### Unambiguous grammar
[unambiguous-grammar]


The "unambiguous grammar" was [a proposal](https://github.com/bmeck/UnambiguousJavaScriptGrammar)
to determine the parse goal of a source text only by checking its syntax
(without the need for an out-of-band mechanism).

It relied on the presence or absence of `import` and `export` statements but
was eventually rejected by TC39 because it was easy to make mistakes and get
surprising behavior.




The `Module` parse goal is intended for ECMAScript Modules, the `Script` goal is the orig


The `Script` parse goal is the original 


The different parse goals are parsed differently and have different runtime semantics.



The `Script` goal is the original way to handle Javascript




    Module resolution
    Resolution algorithm
    Module instantiation
    Module Linking
    Export binding
    Named exports
    Circular references
    Function hoisting, TDZ
    Module namespace
    Module record
    Module execution
    Loader hooks
    Dynamic instantiation
    Declarative instantiation
    Dynamic import
    Import meta
    Module format
    Synchronous / Asynchronous execution
    Transparent interop (one-way / two-way)
    Conditional loading
    Unambiguous grammar




