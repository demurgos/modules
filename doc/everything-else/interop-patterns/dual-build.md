# Dual build

This pattern is an extension of the ESM facade pattern. Instead of re-exporting the values defined in CJS, define your values both in CJS and ESM so both files are independent.

- CJS-safe migration: Yes
- ESM-safe migration: Yes
- Safe migration: **Yes**
- The consumer gets expected results when moving to ESM: Yes, assuming both files are synced, **REALLY SYNCED**.

Example lib:
```js
// lib.js
const foo = "fooValue";
const bar = "barValue";
module.exports = {foo, bar};

// lib.mjs
export const foo = "fooValue";
export const bar = "barValue";
export default {foo, bar};
```

The consumers are the same as in the ESM facade:

```js
// main.js
const {foo, bar} = require("./lib");
console.log(foo);
console.log(bar);
```
```js
// main.mjs
import {foo, bar} from "./lib";
console.log(foo);
console.log(bar);
```
```js
// main2.mjs
import lib from "./lib";
console.log(lib.foo);
console.log(lib.bar);
```

Given the current constraints, I feel that this is the pattern providing the best consumer experience: the lib can adopt ESM and drop CJS without breaking the consumers (assuming it leaves time for the consumers to move :stuck_out_tongue: ) and does not depend on the module type of the consumer. The consumer gets expected results when migrating.
The obvious drawback is that both files **MUST** provide the same values to actually ensure the consumer can migrate without surprises. It means that **the lib needs to use tooling** for this use case. This should be easy to achieve if the source-code is transpiled using Typescript or Babel. If you are writing the files manually, it's best to avoid. This also means that this pattern requires you to keep using tooling for the duration of the transition, even if one of the goals of ESM was to allow more use-cases without tools. Native support by ESM will not affect the benefits of using Typescript but some teams may consider removing the Babel overhead.

This is the pattern I settled on for my personal projects, but I spent a lot of time tinkering with my build tools.
