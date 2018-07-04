# Promise wrapped + facade, by @bmeck 

This pattern is a combination of promise-wrapped and ESM facade. It fixes the ESM-safety issue of PWPO by handling the ESM imports in a facade.

- CJS-safe migration: Yes
- ESM-safe migration: Yes
- Safe migration: Yes
- The consumer gets expected results when moving to ESM: Yes, a bit different but still reasonable: CJS consumers must be async but ESM consumers can resolve either statically or dynamically (async)


Your lib needs an implementation file and two entrypoints (one for CJS and one for ESM):
```js
// impl.js
module.exports = {foo: 42};

// lib.js
module.exports = Promise.resole(require("./impl"));

// lib.mjs
import impl from "./impl";
export const foo = impl.foo;
```

Example CJS consumer:
```js
// main.js
require("./lib")
  .then((lib) => {
    console.log(lib.foo);
  });
```

Example ESM consumer
```js
// main.mjs
import {foo} from "./lib": 
console.log(foo);

// main2.mjs
import("./lib")
  .then((lib) => {
    console.log(lib.foo);
  });
```

This pattern forces your CJS consumers to use an async API, this is less convenient.
The upside is that it allows you to do a safe migration of your impl file from CJS to ESM (you are not stuck with a CJS impl as with a simple ESM facade pattern).

Here is how to update your lib once you moved the impl to ESM (you can merge impl with lib.mjs):

```js
// lib.js
module.exports = require("./lib.mjs");

// lib.mjs
export const foo = 42;
```
