# Promise-wrapped plain object

`module.exports` is a Promise for a plain object equivalent to an ESM namespace.  I'll abbreviate it as PWPO.

- CJS-safe migration: Yes
- ESM-safe migration: **NO**
- Safe migration: No (breaks ESM consumers)
- The consumer gets expected results when moving to ESM: NO :rotating_light:

I mention this pattern here because it was discussed, but I currently consider it as an _anti_-pattern. Using it enables a CJS-safe migration but if the consumer uses ESM, it breaks in suprising ways.
This ultimately creates a "race-condition" between the lib and consumer when they both try to move to ESM. To move transparently to ESM, the lib must assume that all of its consumer use CJS. If a consumer migrates before the lib, there will be breakage.
This pattern is useful if it already applies to your CJS lib. Do not use it as an intermediate state because it will require you to go through 2 breaking changes (initial to PWPO, then PWPO to something esm-safe).

This pattern relies on the fact that `require("esm")` returns a Promise for the ESM namespace. By setting `module.exports` to a promise for a namespace-like object you can return the same value for `require("./lib")` regardless of the module-type of lib.

```typescript
// Given:
require<Exports>("cjs"): Exports;
require<Ns>("esm"): Promise<Ns>;
// Your CJS consumer can agnostically access a value of type Api if:
type Exports = Promise<Api>;
type Ns = Api;
```

Given the assumptions above, `require("esm")` returns a Promise so it forces us to use promises in the compat API. ESM exposes a namespace object, you cannot export a function directly.

It means that your compat API for CJS consumers is a Promise-wrapped plain object.


CJS lib:
```js
// lib.js
const foo = "fooVal";
const foo = "barVal";
module.exports = Promise.resolve({
  foo,
  bar,
});
```

Is equivalent to the ESM lib:
```js
// lib.mjs
export const foo = "fooVal";
export const bar = "barVal";
```

Example agnostic CJS consumer:

```js
// main.js
require("./lib")
  .then((lib) => {
    console.log(lib.foo);
    console.log(lib.foo);
  })
```

Here is another example exporting a single function, it uses an IIAFE for the promise:

CJS lib:
```js
// lib.js
module.exports = (async () => {
  // Even if you can use `await` here, you should avoid it
  // The ESM equivalent is top-level await (it's still unclear how it would work)
  return {
    default () {
      return 42;
    },
  };
})();
```

ESM lib:
```js
// lib.mjs
export default function () {
  return 42;
}
```

Agnostic CJS  consumer:
```js
// main.js
require("./lib")
  .then((lib) => {
    console.log(lib.default()); // Prints 42, regardless of consumer module type.
  })
```

This pattern is more complex but allows you to migrate your lib to ESM, **if your consumer use CJS**.
As discussed at the beginning, this pattern causes unexpected breaking changes if the consumer moves to ESM.

Here is what would happen if the consumer from the last example moves to ESM:

```js
// main.mjs
import("./lib")
  .then((lib) => {
    console.log(lib);
    // If the lib uses CJS:
    // { default: Promise { { default: [Function: default] } } }
    // If the lib uses ESM:
    // { default: [Function: default] }
  });
```

If the consumer moves to ESM before the lib, two bad things happen:
- The value of the `default` property on the result changes from `Function` to `Promise<{default: Function}>`. **This is highly unexpected and very confusing.**
- Later on, when the library migrates to ESM thinking that it is safe, it will break the consumer: the returned value changes back.

The consumer would need to be very defensive when importing a lib using this pattern, this defeats the goal of allowing a simple migration: the consumer needs to intimately know the lib.

See "Promise-wrapped + facade" for an extension solving ESM-safety.

