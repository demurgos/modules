# Parse goal determination

## Unambiguous grammar

It was discussed 3 times at TC39:
- [2017-01](https://github.com/tc39/tc39-notes/blob/master/es7/2017-01/jan-25.md#13iia-proposed-grammar-change-to-es-modules)

It was ultimately rejected because it can cause surprising behavior.
Adding a single `export` somewhere in large file turns the parse goal of the
whole file from _Script_ to _Module_. It also means that self-contained
ES-Modules still need to add an empty `export {};` statement to be treated as
modules, forgetting to add it will turn the parse goal into _Script_. 


https://github.com/bmeck/UnambiguousJavaScriptGrammar


https://github.com/rwaldron/tc39-notes/blob/75c7b2f17fefa5bf8753cfb2c8767fdb59962854/es7/2016-11/dec-1.md#12iie-variation-on-unambiguousjavascriptgrammar

https://github.com/rwaldron/tc39-notes/blob/75c7b2f17fefa5bf8753cfb2c8767fdb59962854/es7/2017-01/jan-25.md#13iia-proposed-grammar-change-to-es-modules
