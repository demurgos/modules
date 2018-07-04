# Nodejs/modules

An answer to Node, ESM and everything else.

Initially written in July 2018 by demurgos.

## Introduction

The goal of these documents is to provide a complete picture of the effort to support the ECMAScript Modules specification in Node.js.
It is intended for Node users, library authors, tools developpers, and participants to the design and implementation effort.

## Related documents

### Proposals

https://github.com/nodejs/node-eps/blob/master/002-es-modules.md

### Articles

- [ES modules: A cartoon deep-dive](https://hacks.mozilla.org/2018/03/es-modules-a-cartoon-deep-dive/), by [Lin Clark](http://code-cartoons.com/), 2018-03-28


## Terminology


### Parse goal
[parse-goal]: #parse-goal

A _parse goal_ is the spec term indicating how a Javascript source code should be interpreted.
The parse goal defines both parsing rules and runtime semantics.
It means that the same block of source code may produce different results if depending on the parse goal.

The current ES spec defines two parse goals: `Script` and `Module`.

Deciding which parse goal to use is called the [parse goal determination][parse-goal-determination].

### `Script` parse goal

`Script` corresponds to the original way to handle source code.


### Parse goal determination

The _parse goal determination_ is the mechanism used to decide which [parse goal][parse-goal] to use for a source text.

### Unambiguous grammar







The `Module` parse goal is intended for ECMAScript Modules, the `Script` goal is the orig


The `Script` parse goal is the original 


The different parse goals are parsed differently and have different runtime semantics.



The `Script` goal is the original way to handle Javascript













    Module resolution
    Resolution algorithm
    Module instantiation
    Module Linking
    Export binding
    Default export
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
    "mjs"
    Unambiguous grammar




