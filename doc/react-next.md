---
order: 0
title: React "next"
---

# Haxe React #next

Branch `#next` of my haxe-react fork aims to move haxe-react forward to `2.0.0+`
with an increased freedom to break things until I get them right.

This version of haxe-react can be considered unstable (even though it is
currently being used in production) due to these huge changes it can go through.
You may want to lock your dependencies to the latest commit of the branch
instead of the branch itself, if you are not willing to update your code every
now and then. I am available in [haxe-react gitter][gitter] if you need help.

Haxe 4 ([preview 4](https://haxe.org/download/version/4.0.0-preview.4/) atm) is
used as the main target version in this fork, but Haxe 3.4.7 should still be
supported.


## Different jsx parser

Based off [back2dos](https://github.com/back2dos)'s [PR #95][PR #95], this
branch uses [`tink_hxx`][tink_hxx] to handle jsx.

### Syntax changes

The change of parser implies some little syntax changes:
* `prop=$42` and such are no longer allowed, use `prop=${42}` or `prop={42}`
* `prop=${true}` can now be expressed as simply `prop`
* Props are type-checked against the component's `TProps`
* You cannot pass props not recognized by the target component
* Haxe 4 inline markup is supported and can replace the jsx string
* Hxx's [control structures][hxx-control-structures]

#### Comments in jsx

You can use `${/* comments */}` / `{/* comments */}` in jsx to add comments
that won't be included in generated javascript.

You can also comment props with `//` inside the opening tag:
```jsx
<input
	type="text"
	// onClick={someFunction}
/>
```

### Further changes added in `#next`

#### [`6e8fe8d`][6e8fe8d] Allow String variables as jsx node

The new parser will resolve `String` variables for node names:

```haxe
var Node = isTitle ? 'h2' : 'p';
return jsx('<$Node>${props.children}</$Node>');
```

**Warning**: it only works for variable names starting with an uppercase letter.

#### [`d173de0`][d173de0] Fix error position when using invalid nodes in jsx

Using an invalid node inside jsx, such as `<$UnknownComponent />`, resulted in
an error inside `haxe.macro.MacroStringTools`.

This fix ensures that the position points to "UnknownComponent" inside the jsx
string.

#### [`578c55d`][578c55d] Disallow invalid values inside jsx when a fragment is expected

For example, the following used to compile:

	jsx('<div>${function() return 42}</div>');

But resulted in a runtime error:

	Warning: Functions are not valid as a React child. This may happen if you
	return a Component instead of <Component /> from render. Or maybe you meant
	to call this function rather than return it.

Or, for objects: `jsx('<div>${{test: 42}}</div>');` resulted in:

	Uncaught Error: Objects are not valid as a React child (found: object with
	keys {test}). If you meant to render a collection of children,
	use an array instead.

Now we get a compilation error (see below for `ReactFragment`):

	src/Index.hx:31: characters 7-17 : { test : Int } should be react.ReactFragment
	src/Index.hx:31: characters 7-17 : For function argument 'children'

#### [`d06bc25`][d06bc25] ... unless in a component allowing another type for its `children` prop

Components can handle their `children` prop any way they want, and so this prop
may be of any type unless it is actually used as a react node.

This commit does two things:
* Partially revert above commit `578c55d` for allowing other values
* Unifies components' children with their `children` prop if any, or with
`ReactFragment` if none is defined

This allows things like that:

```haxe
jsx('<$MyComponent>${() -> 42}</$MyComponent>');

// ...

typedef Props = {
	var children:Void->Int;
}

class MyComponent extends ReactComponentOfProps<Props> {
	override public function render() {
		return jsx('<p>The answer is ${props.children()}</p>');
	}
}
```

While still disallowing above examples.

#### [`425cb6c`][425cb6c] Ensure individual prop typing, allowing abstract props to do their magic

Makes sure each prop resolves to its type, with a `(prop :TypeOfProp)`.

This will trigger abstracts `@:from` / `@:to` which may be needed in some cases
to do their magic.

#### [`150b76d`][150b76d] + [`d2e8dd3`][d2e8dd3] Jsx: display compilation warning on missing props

Tries to extract the list of needed props and adds a compilation warning when
some of them are not passed in a jsx "call".

**Limitations:**
* If you use the spread operator on the props of a component, this test is not
executed (it becomes hard and even sometimes impossible to know what props are
passed through the spread).

#### [`affd6e4`][affd6e4] Jsx: handle data- and aria- props

`aria-` props are type-checked against their [specification][aria-specs], and
enums are provided where necessary (see `react.jsx.AriaAttributes`). They are
enabled by default for both html elements and react components. You can disable
`aria-` props entirely with `-D react_jsx_no_aria`, or only disable it for react
components with `-D react_jsx_no_aria_for_components`.

`data-` props are enabled by default for react components (all unknown props are
already accepted for html elements), with a type of `Dynamic`. They can be
disabled with `-D react_jsx_no_data_for_components`.

#### [`a96398a`][a96398a] + [`8dd1f2b`][8dd1f2b] Jsx: support string interpolation in attributes

Add support for string interpolation in attributes:
`<Comp foo="hello ${target}" />`.

## ReactComponentOf cleanup

Cherry-picked and improved [PR #108][PR #108], which removed the legacy `TRefs`
from `ReactComponent`.

#### So now we have
* `ReactComponentOf<TProps, TState>` (or `ReactComponentOfPropsAndState<TProps, TState>`)
* `ReactComponentOfProps<TProps>`
* `ReactComponentOfState<TState>`
* And still `ReactComponent` which has untyped props and state (`Dynamic`)

#### Strict props & state access

This is actually a big change, since `ReactComponentOfProps` and
`ReactComponentOfState` use `react.Empty` type as `TState` (resp. `TProps`).

`react.Empty` is an empty typedef, disabling state access/update on
`ReactComponentOfProps`, and props access in `ReactComponentOfState`.

#### Type constraints on `TProps` and `TState`

React does not support non-objects (and also does not support arrays) as props
or state for your components. Type parameters constraints have been added to
ensure at compile time that you don't use unsupported types for `TProps` and/or
`TState`.

## `ReactFragment`

`ReactFragment` (in `react.ReactComponent` module) tries to be closer to react
in describing a valid element. It replaces `ReactElement` in most API, allowing
them to use other types allowed by react.

#### `ReactFragment` unifies with either

* `ReactSingleFragment`
* `Array<ReactFragment>`

#### `ReactSingleFragment` being either

* `ReactElement`
* `String`
* `Float` (or `Int`)
* `Bool`

This type can be used when you expect a single element and not a collection of
elements.

#### APIs now using ReactFragment

`react.React`:
```haxe
public static function createElement(type:CreateElementType, ?attrs:Dynamic, children:haxe.extern.Rest<Dynamic>):ReactElement;
public static function isValidElement(object:ReactFragment):Bool;
public static function forwardRef<TProps, TRef>(render:TProps->ReactRef<TRef>->ReactFragment):ReactType;
```

`react.React.Children`:
```haxe
function map(children:Dynamic, fn:ReactFragment->ReactFragment):Null<Array<ReactFragment>>;
function foreach(children:Dynamic, fn:ReactFragment->Void):Void;
function count(children:ReactFragment):Int;
function only(children:ReactFragment):ReactSingleFragment;
function toArray(children:ReactFragment):Array<ReactFragment>;
```

`react.ReactDOM`:
```haxe
public static function render(element:ReactFragment, container:Element, ?callback:Void -> Void):ReactFragment;
public static function hydrate(element:ReactFragment, container:Element, ?callback:Void -> Void):ReactFragment;
public static function createPortal(child:ReactFragment, container:Element):ReactFragment;
```

## `ReactType` and `ReactTypeOf`

`react.ReactType` replaces `CreateElementType` and allows:
* `String`
* `Void->ReactFragment`
* `TProps->ReactFragment`
* `Class<ReactComponent>`
* `@:jsxStatic` components

There is also `ReactTypeOf<TProps>`, for cases when you want a component
accepting some specific props.

`CreateElementType`, still in the `react.React` module, is now **deprecated**
but still available as a proxy to `ReactType`.

`ReactType` was first implemented as `ReactNode`, but has been renamed in
`1.103.0` to avoid confusion with ReactJS names. `ReactNode` is temporarily
available as a proxy to `ReactType`, but will be removed before `2.0.0`.

## Better integrated features

### `@:jsxStatic` components

`@:jsxStatic` has been better integrated with `ReactType`, making it usable
outside jsx like any other component.

See [Static components](./static-components.md).

### `@:wrap` to wrap components in HOC

`@:wrap` has been improved to support strict typing in jsx, and since it is
using `@:jsxStatic` under the hood it also benefits from the fixed usage outside
jsx via `ReactType` abstract.

See [Wrapping your components in HOCs](./wrapping-with-hoc.md) for more
information about wrapping components in HOC.

### PureComponent and `@:pureComponent`

TODO: Documentation for `@:pureComponent`+ `PureComponent` extern, differences
between macro implementation and extern.

## More debug tools

#### [`98233c3`][98233c3] Add warning if ReactComponent's render has no override

Adds a compile-time check for an override of the `render` function in your
components. This helps catching following runtime warning sooner:

	Warning: Index(...): No `render` method found on the returned component
	instance: you may have forgotten to define `render`.

Catching it at compile-time also ensures it does not happen to a component only
visible for a few specific application state.

You can disable this with the `-D react_ignore_empty_render` compilation flag,
or for a specific component by adding `@:ignoreEmptyRender` meta to it.

#### [`ef0b0f1`][ef0b0f1] React runtime warnings: add check for state initialization

React runtime warnings, disabled by default, can be enabled with the
`-D react_runtime_warnings` compilation flag (only when `-debug` is enabled).

They were previously enabled with `-D react_render_warning`, and only added the
warning about avoidable re-renders. Note that this warning can have false
positive due to the legacy context API (react-router for example). You can
disable it for a specific component by adding `@:ignoreRenderWarning` meta to
this component ([`a7860c6`][a7860c6]).

A new warning has been added: if a component having a state does not have a
constructor or has one but doesn't initialize its state in it, you will get a
runtime error warning you about it (instead of an unclear error later when
accessing `state`).

These warnings are now more accurate since the strict props/state types have
been added to `ReactComponentOf` typedefs. Compatibility has been handled
mainly in [`1719431`][1719431] and [`241a13b`][241a13b].

#### [`b3286e1`][b3286e1] Added access and types for React Shared Internals

Access react shared internals via `react.React._internals` during renders to
get debug data (stack, timings, etc.). See `react.ReactSharedInternals`. Note:
this has been based on current react version (16.4.2), and may not be fully
compatible with other versions.

[WIP] Random examples of what is available there:
* `React._internals.ReactDebugCurrentFrame.getCurrentStack()` will list all
parent nodes of current element, up to the root node of the application

#### [`TODO`]() Generate PropTypes for more runtime checks on props

There are already many checks at compile time to ensure you are not doing
obvious mistakes. However, sometimes the compiler cannot see what is really
happening, and only a runtime check can really tell you what went wrong.

[`prop-types`][prop-types] can check a number of things at runtime, roughly
like the haxe compiler would do at compile time. But writing both `TProps` and
`propTypes` for your components would be too much.

This feature, enabled when you compile with both `-debug` and the compilation
flag `-D react_generate_proptypes`, will generate propTypes for your components,
using their `TProps` as a reference.

This does not overwrite manually written propTypes, and ignores completely
extern classes (most react libraries will provide propTypes anyway, probably
more accurate than these).


<!-- Haxe React community -->
[gitter]: https://gitter.im/haxe-react/Lobby
[PR #95]: https://github.com/massiveinteractive/haxe-react/pull/95
[PR #108]: https://github.com/massiveinteractive/haxe-react/pull/108

<!-- Haxelib / GitHub projects -->
[tink_hxx]: https://github.com/haxetink/tink_hxx
[prop-types]: https://github.com/facebook/prop-types
[hxx-control-structures]: https://github.com/haxetink/tink_hxx#control-structures

<!-- MDN resources -->
[aria-specs]: https://www.w3.org/TR/wai-aria-1.1/#state_prop_def

<!-- Commits improving jsx -->
[6e8fe8d]: https://github.com/kLabz/haxe-react/commit/6e8fe8d
[d173de0]: https://github.com/kLabz/haxe-react/commit/d173de0
[578c55d]: https://github.com/kLabz/haxe-react/commit/578c55d
[d06bc25]: https://github.com/kLabz/haxe-react/commit/d06bc25
[425cb6c]: https://github.com/kLabz/haxe-react/commit/425cb6c
[150b76d]: https://github.com/kLabz/haxe-react/commit/150b76d
[d2e8dd3]: https://github.com/kLabz/haxe-react/commit/d2e8dd3
[affd6e4]: https://github.com/kLabz/haxe-react/commit/affd6e4
[a96398a]: https://github.com/kLabz/haxe-react/commit/a96398a
[8dd1f2b]: https://github.com/kLabz/haxe-react/commit/8dd1f2b

<!-- Commits improving debug tools -->
[98233c3]: https://github.com/kLabz/haxe-react/commit/98233c3
[ef0b0f1]: https://github.com/kLabz/haxe-react/commit/ef0b0f1
[a7860c6]: https://github.com/kLabz/haxe-react/commit/a7860c6
[1719431]: https://github.com/kLabz/haxe-react/commit/1719431
[241a13b]: https://github.com/kLabz/haxe-react/commit/241a13b
[b3286e1]: https://github.com/kLabz/haxe-react/commit/b3286e1
