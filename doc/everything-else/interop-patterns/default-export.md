# default export

The lib replaces its CJS `module.exports` by `export default` in ESM.
**This pattern enables the migration of lib only if its consumers already use ESM.**

- CJS-safe migration: **NO**
- ESM-safe migration: Yes
- Safe migration: No (breaks CJS consumers)
- The consumer gets expected results when moving to ESM: N/A, this pattern is available to the lib only if its consumer already uses ESM

This pattern relies on Node's ESM facade generation for CJS when importing them from an ESM consumer.

```typescript
// Given:
import<Exports>("cjs"): Promise<{default: Exports}>;
import<Ns>("esm"): Promise<Ns>;
// Your ESM consumer can agnostically access a value of type Api if:
type Exports = Api;
type Ns = {default: Api}
// This is also true for static `import` statements
```

Examples:

CJS lib:
```js
// lib.js
module.exports = function() { return 42; };
```

Equivalent ESM lib:
```js
// lib.mjs
export default function() { return 42; };
```

Example agnostic ESM consumer (=does not know the module type used by `lib`):

```js
// main.mjs
import lib from "./lib";
console.log(lib()); // prints `42`, regardless of the module type of `lib`
```

Since `exports` is an alias for `module.exports` in CJS, the following are also equivalent:
```js
// lib.js
module.exports.foo = "fooValue";
module.exports.bar = "barValue";
```
```js
// lib.mjs
const foo = "fooValue";
const bar = "barValue";
export default {foo, bar};
```

Agnostic ESM consumer:
```js
// main.mjs
import lib from "./lib";
console.log(lib.foo);
console.log(lib.bar);
```

The **default export** pattern allows library authors to have a common subset between their CJS and ESM implementation. Once they moved to ESM, they can do a minor update to extend their API using named exports. This may be useful to provide a more convenient access to the properties of the `default` export. The previous example can be extended as:

```js
// lib.mjs
export const foo = "fooValue";
export const bar = "barValue";
export default {foo, bar};
```

ESM consumer
```js
// main.mjs
import lib, {foo, bar} from "./lib";
console.log(lib.foo);
console.log(lib.bar);
console.log(foo);
console.log(bar);
```

As mentioned at the beginning, this pattern allows libraries to migrate without breaking its consumers **ONLY IF ITS CONSUMERS ALREADY USE ESM**. This is the primary pattern available today with `--experimental-modules`.
This means that the ecosystem migration using this pattern would have to start at the consumers and move up the dependency tree. (If you want to avoid breaking changes). It's good to have this option but it is not enough for the ecosystem to move quickly: it requires the lib to control its consumers.
This case is still relevant. Internal projects can use this to update: migrate the consumer, update the lib API, migrate the lib, repeat.
After thinking more about it, this pattern is also relevant in situation where you can rely on transpilation at the lib and consumer side. I mostly see it for front-end related frameworks, for example for Angular strongly encouraging Typescript. The lib can be authored using this pattern and transpiled to CJS, a consumer can then configure its build tool to import this lib and automatically get the default export (in Typescript, use `esModuleInterop` with `allowSyntheticDefaultImports`, I think that Babel has something similar). This is not a true ESM migration because it still uses CJS under the hood, but the source code should be compatible.

