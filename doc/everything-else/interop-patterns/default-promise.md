# Default Promise

This pattern gives you full compat without relying on "js + mjs", at the cost of having a user-hostile API.

- CJS-safe migration: Yes
- ESM-safe migration: Yes
- Safe migration: Yes
- The consumer gets expected results when moving to ESM: Yes


CJS lib
```js
module.exports = Promise.resolve({
  default: module.exports,
  foo: 42,
});
```
ESM lib
```js
export const foo = 42;
export const default = Promise.resolve({
  default,
  foo
});
```

CJS consumer:
```js
require("./lib").then({default} => default)
  .then(lib => {
    console.log(lib.foo);
  });
```
ESM consumer
```js
import("./lib").then({default} => default)
  .then(lib => {
    console.log(lib.foo);
  });
```

I found it by combining the constraints of both "default export" and PWPO.
This pattern allows you to support any combination of lib and consumer module type, using a single file.

It's good to know that this exists, but the API is so bad (you need to await a promise twice) that I hope that nobody will have to use this. Still, it offers an escape hatch if resolution based on the consumer (mjs+js) is not available.
