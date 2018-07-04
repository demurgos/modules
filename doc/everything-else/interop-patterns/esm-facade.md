# ESM facade

Use two files for the lib module: `.js` for the implementation and CJS API, `.mjs` for the ESM API.

- CJS-safe migration: Yes
- ESM-safe migration: Yes
- Safe migration: **Yes**
- The consumer gets expected results when moving to ESM: Yes, assuming both files are synced.

This relies on the resolution algorithm to pick the right file depending on the module-type of the caller. This means that it relies on `.mjs` or any other mechanism that lets you have two versions for the same module. You can start using this pattern without native ESM support (the `.mjs` will be ignored) but if you decide to add it afterwards, it may be a breaking change if `default` in `.mjs` does not have the same value as `module.exports` in `.js`.

You need both files in the lib:
```js
// lib.js
module.exports = function() {
  return 42;
}

// lib.mjs
import lib from "./lib.js";  // The extension forces to resolve the CJS module
export default lib.default;
```

CJS consumer:
```js
const lib = require("./lib");
console.log(lib()); // 42

```

The consumer can move to ESM and get expected results:
```js
import lib from "./lib";
console.log(lib()); // 42
```

Your `.mjs` facade file can also expose named exports. I recommend to keep the `default` export set to the default value of the lib.

Lib:
```js
// lib.js
const foo = "fooValue";
const bar = "barValue";
module.exports = {foo, bar};

// lib.mjs
import lib from "./lib.js";  // The extension forces to resolve the CJS module
export const foo = lib.default.foo
export const bar = lib.default.bar;
export default lib.default;
```

CJS consumer:
```js
// main.js
const {foo, bar} = require("./lib");
console.log(foo);
console.log(bar);

```

The consumer can move to ESM and get expected results:
```js
// main.mjs
import {foo, bar} from "./lib";
console.log(foo);
console.log(bar);
// main2.mjs
import lib from "./lib";
console.log(lib.foo);
console.log(lib.bar);
```

This relies on the fact the ESM lib module is picked first if the consumer uses ESM. `lib.mjs` acts as a static facade defining the named exports of the lib and allowing it participate in the ESM resolution.
I use this kind of pattern to also expose named exports in my own projects. It probably deserves more documentation (easier to author/consume than the promise-wrapped plain object).
This scenario is an important reason for both `.js` and `.mjs`.

This pattern is nice, but unless you use the `.mjs` file for named exports, it boils down to manually doing what Node is doing automatically with `--experimental-modules`. You still need to write your implementation in CJS and cannot migrate. The goal of this pattern is actually to update your API to expose named exports so your consumers can migrate to use named exports. To get rid of CJS, you'll need to go a step further and use the dual build pattern or promise-wrapped+facade.
