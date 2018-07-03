# Standards

This document lists the standards relevant to Node's modules.

## ECMAScript language

[ES2018, section 15 - ECMAScript Language: Scripts and Modules](https://www.ecma-international.org/ecma-262/9.0/index.html#sec-ecmascript-language-scripts-and-modules)

The ECMAScript spec defines how Javascript works.
The section _ECMAScript Language: Scripts and Modules_ is the core piece of
the standard related to modules.

It defines exports, static imports, dynamic imports, parse goals, and related
operations (resolve, instantiate, evaluate).

## Node.js modules

[Node.js API - Modules](https://nodejs.org/api/modules.html)

This more an implementation-defined standard. Node's traditional module
system is documented in its API. It is based off CommonJs (see below).
Each file is a module, you can use `module.exports` to expose _values_ and
`require` to import values.

This is a loose implementation of CommonJs: you can overwrite `module.exports`
itself to export a single function for example.

Node also injects the `__filename` and `__dirname` meta variables in each
module. They contain the system-dependent absolute path for the corresponding
JS file and its parent directory.

## CommonJs Modules

[CommonJs/Modules 1.1.1](http://wiki.commonjs.org/wiki/Modules/1.1.1)

This is listed mainly for historical reasons (early work on server-side JS
modules).
This standard defines the minimal CommonJs modules system. Node's implementation
has many extensions and is the defacto reference for "CommonJs" modules.

In this spec, `exports` and `module` are independent variables. You can
only add properties to `exports`: it remains a plain object, and can't be
defined as a function for example.
