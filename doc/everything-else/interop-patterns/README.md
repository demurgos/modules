**Edit**: This post ended up pretty long, I hope it depicts a relatively complete picture of the current state of native CJS/ESM interop.

# Introduction

Hi,
Following the current discussions around defining a better term instead of "transparent interop" (#137, #138), it seems that most of it revolves around allowing libraries to migrate to ESM without impacting the consumer ("agnostic consumer"). I'd like to do a summary of the migration path I see given the current state of the discussion. I'll base it around "patterns" enabling libraries to safely migrate to ESM.
This relates to the feature [Transparent migration (#105)](https://github.com/nodejs/modules/issues/105) and the use-cases 18, 20, 39, 40.

I'll leave aside the discussion around detecting the module type: commonJs (CJS) or ESM. To indicate the type of the module, I will either include `cjs` or `esm` in its name or use file extensions (`.js` for CJS, `.mjs` for ESM). Other module types (`.json`, `.node`, `.wasm`, etc.) are not discussed (they can be reduced to CJS or ESM).

I'll use a Typescript-like notation in some places to explain the types of the values.

I expect the modules to move forward from CJS to either CJS+ESM or ESM-only and won't focus on moving backward from ESM to CJS.

I'll focus on solutions, without loaders or @jdalton's `esm` package. In the rest of this post, `esm` always refer to "some module with the ES goal", not the `esm` package.

---

Here are my assumptions regarding the various ways to import the modules:

- `require("cjs")` continues to work unchanged.
  If `module.exports` has the type `Exports`, it returns `Exports`.
- `import ... from "esm"` and `import("esm")` works as defined by the spec: statically import bindings or get a promise for a namespace object.
  If the ESM namespace has the type `Ns`, `import("esm")` returns `Promise<Ns>`.
- `import ... from "cjs"` exposes a namespace with a single export named `default`. It has the value of `module.exports` in `cjs.js`.
- Similarly, `import("cjs")` returns a promise for a namespace object with a single key `default` set to the value of `module.exports`. It has the same behavior whether it is used from CJS or ESM.
  If `module.exports` has the type `Exports`, `import("cjs")` returns `Promise<{default: Exports}>`
- `require("esm")` returns a promise for the namespace of `esm`. Synchronous resolution is discussed later (but from what I understood it is not likely to happen due to timing issues).
  If the ESM namespace has the type `Ns`, it returns `Promise<Ns>`.

```typescript
// By abusing Typescript's notation, we have:
require<Exports>("cjs"): Exports;
require<Ns>("esm"): Promise<Ns>;
import<Exports>("cjs"): Promise<{default: Exports}>;
import<Ns>("esm"): Promise<Ns>;
import * as mod from <Exports>"cjs"; mod: {default: Exports};
import * as mod from <Ns>"esm"; mod: Ns;
```

---

Today, Node only supports CJS. It means that we have a CJS lib and a CJS consumer. We want to move to ESM lib & ESM consumer. In the general case, converting both modules at the same time is not possible (for example they are in different packages). It means that the transition will go through a phase where we have either ESM lib & CJS consumer, or CJS lib & ESM consumer.

It is important to support both cases to allow libraries and consumers to transition independently. Creating a dependency between the lib and consumers transition was the main failure of the Python 2-3 transition and we want to avoid it. Python finally managed to transition by finding a shared subset between both version. Similarly, the Node transition from CJS to ESM may need to pass through an intermediate phase where an API uses the intersection between CJS and ESM to facilitate the migration.

Specifically, I am interested in the following two goals:
- **A library can switch internally from CJS to ESM without breaking its consumers.**
- **A consumer can switch from CJS to ESM and get expected values when importing its dependencies.**

The first point is about enabling the migration of libs, the second about the migration of consumers.
Both are important even if this post is more intended for libs.

It helps to further break down the requirements for lib migrations:
- **CJS-safe lib migration**: A lib module can switch between CJS and ESM without breaking CJS consumers.
- **ESM-safe lib migration**: A lib module can switch between CJS and ESM without breaking ESM consumers.
- **safe lib migration**: A lib module that can switch between CJS and ESM without breaking any of its consumers (CJS or ESM).

When a consumer moves from CJS to ESM, I consider that he gets expected results if one of the following is true:
- `module.exports` in CJS becomes the `default` export in ESM. It keeps the same value:
  ```js
  // main.js
  const foo = require("./lib");
  // main.mjs
  import foo from "./lib";
  import("./lib")
    .then(({default: foo}) => { /* ... */ });
  ```
- `module.exports` in CJS is a plain object, its properties become ESM exports. They keep the same values:
  ```js
  // main.js
  const {foo, bar} = require("./lib");
  // main.mjs
  import {foo, bar} from "./lib";
  import("./lib")
    .then(({foo, bar}) => { /* ... */ });
  ```

The consumer expects that its migration will happen as one of the two cases above. Any other result is surprising. This is what consumers expect today: `--experimental-modules` introduced the first case, Babel and Typescript started with the second case. The actual way to migrate is left to lib documentation or consumer research. The consumer is active at this moment: we want to reduce its overhead but a small amount of work can be tolerated. Any other result when the consumer moves from CJS to ESM is surprising: we need to avoid it. Especially, we need to avoid returning values of different types when there are strong expectations that they'll be the same.

From a library point of view, here is a migration path that allows a progressive process:
1. Current CJS lib. Its API may not allow it to do a _safe migration_ (without breaking its consumers). This is the case of most libraries today. For example, a CJS lib exposing a function as its `module.exports` cannot move to ESM-only without breaking its CJS consumers.
2. Breaking change to an API allowing a _safe migration_. This change should future-proof the lib API, implementing this API should not require the use ESM ideally.
3. Patch update to internally migrate from CJS to ESM.

This path emerged during the discussions as something that we would like to support. It enables to dissociate the API changes from the migration. It allows libraries to prepare for ESM before native ESM support.

Once a lib reached ESM and most of its consumers migrated, it may decide to do a breaking change and drop the compat API if maintaining compat it is no longer worth the cost (depends on the lib...).
The library may be initially authored using ESM and transpiled to CJS. In this case the step 3 corresponds to stopping the transpilation and directly publishing the ESM version.

---

| Pattern | CJS-safe | ESM-safe | CJS API | ESM API | Consumer migration | Lib migration | Lib tooling | Uses `mjs` + `js` | 
| ------- | --------- | --------- | -------- | -------- | ---------------------- | -------------- | ---- | ---- |
| Default export                  | No | Yes | N/A                    | `{default: Api}` |  N/A     |  OK     |        | No |
| PWPO                              | Yes | No | `Promise<Api>`  | N/A                 | Unsafe |  OK    |         | No |
| ESM facade                       | Yes | Yes | `Api`                  | `Api`                | OK       | No     | Optional | Yes |
| Promise wrapper + facade | Yes | Yes | `Promise<Api>` | `Api`               | OK       | OK     | Optional | Yes |
| Dual build                         | Yes | Yes | `Api`                   | `Api`               | OK       | OK    | Required | Yes |
| Default Promise                | Yes | Yes | `Promise<{default: Promise<Api>}>` | `{default: Promise<Api>}` | OK | OK |   | No |

---



# Transparent interop

Hehe, you'd like it. Unfortunately I don't know how to achieve it today, but at least I can give you a definition of a transparent interop pattern.
Transparent interop would be a library pattern (meaning the libraries may need to change their code) such that:
- The lib can do a CJS-safe migration: the lib moves from CJS to ESM without breaking its CJS consumers
- The lib can do an ESM-safe migration: the lib moves from CJS to ESM without breaking its ESM consumers
- The consumers can migrate from CJS to ESM and get expected results:
  "Importing `default` is the same as the CJS `module.exports`" and/or "Named imports are the same as the CJS properties of `module.exports`"

If any of those is not achieved then we can't call it transparent interop and the migration will be measured in decades.
Ideally it would be simpler to maintain than "Dual Build" and less user-hostile than "Default Promise".

# Forewords

## Ecosystem migration bias

The current path to migrate the ecosystem from CJS to ESM has a dependency between the lib and consumer. The migration is biased in favor of the consumer: he can migrate more easily than its libraries.

## Sync `require("esm")`

If we had sync `require("esm")`, the situation would be:

```typescript
// By abusing Typescript's notation, we have:
require<Exports>("cjs"): Exports;
require<Ns>("esm"): Ns;
import<Exports>("cjs"): Promise<{default: Exports}>;
import<Ns>("esm"): Promise<Ns>;
import * as mod from <Exports>"cjs"; mod: {default: Exports};
import * as mod from <Ns>"esm"; mod: Ns;
```

A migration-safe solution exists using something like:
```typescript
Ns = Api & {default: Api};
Exports = Api;
```

CJS lib:
```
// lib.js
const foo = 42;
module.export = {foo};
```
And the equivalent ESM implementation
```
// lib.mjs
export const foo = 42;
export default {foo};
```

You can use it this way:

```js
// main.js
const lib = require("./lib");
console.log(lib.foo);
// If lib is CJS, `lib.foo` corresponds to `module.exports.foo = 42;`
// If lib is ESM, `lib.foo` corresponds to `export const foo = 42;` (enable by sync require(esm))
```

```js
// main.mjs
import lib from "./lib";
console.log(lib.foo);
// If lib is CJS, `lib.foo` corresponds to `module.exports.foo = 42;`
// If lib is ESM, `lib.foo` corresponds to `export default {foo};`
```

But sync `require("esm")` is impossible due to timing issues.
Again, I'm hoping that someone can find a pattern for "transparent interop" without sync require or a way around the timing issues.

## require("esm")

**Edit**: I wrote this before knowing about "promise-wrapper and facade", I am less worried about the use cases now.

I am not sure about the use case for an async `require("esm")`.
It enables the Promise-Wrapped Plain Object pattern for CJS-safe lib migration, but using it this way is a footgun because of the surprising behaviors and breaking changes if the consumer uses ESM.

If you remove the "transparent interop" use case, I see:
- I am a first party consumer and actually want to import an ESM module dynamically. What's the point of using `require("esm")` instead of `import` here? You already know specifically that the lib uses ESM, and if your runtime supports ESM then it also supports `import(...)`.
- You are a third-party consumer that needs to load modules dynamically, the module specifiers are provided to you and you don't know anything about the result. You need to work across various versions of Node (you have no control over it). Because of this, you cannot use `import(...)` reliably so you can backport it using `Promise.resolve(require("esm"))`. But then you need to deal with a whole can of worms anyway to actually understand what's going on in the module. My example for this use case is a lib like `mocha`: it wants to import test specs that may be written in CJS or ESM, and has to work on versions where using `import(...)` throws an error. Actually, `mocha` had a PR to handle ESM: it simply used `eval(import(specifier))`. Still, we are talking about very specific use cases where I expect implementors to be familiar with Node's module system and already have to deal with edge-cases. `require("esm")` may be nice for them, but there are already workarounds.

I am not convinced that `require("esm")` has use cases that aren't better served by `import(...)`, even considering interop. I'd be happy to hear more about it.

## @jdalton's `esm` package and other tools

@jdalton did some great work with his `esm` package. I deliberately chose to not talk about loaders or other advanced features here, but until we get true native ESM everywhere using tools like this will definitely help. The situation is not that bad. It may require a bit more work by the consumer but at some point it's unavoidable.