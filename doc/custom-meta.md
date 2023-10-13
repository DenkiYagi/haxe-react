---
title: Custom metadata
---

# Custom meta used by haxe-react

## `@:wrap(hoc)`

Wrap current component (must extend `ReactComponent`) in a HOC.

See [Wrapping your components in HOCs](./wrapping-with-hoc.md) for more
information about this meta and the following related meta:

#### `@:publicProps(TProps)`

Set public props type to ensure jsx type checking.

#### `@:noPublicProps`

Disallow public props for this component when used in jsx.

#### `@:wrapped_by_macro`

This special meta is added by the `@:wrap` macro for internal use, do not set it
if you don't want to break the functionality.

## `@:jsxStatic(method)`

Create a static component that you can use in jsx (and where "real" components
are expected) from a static function from a class (**not** a `ReactComponent`
class).

See [Static components](./static-components.md).

## `@:ignoreEmptyRender`

There is a compile-time check for an override of the `render` function in your
components. This helps catching following runtime warning sooner:

	Warning: Index(...): No `render` method found on the returned component
	instance: you may have forgotten to define `render`.

Catching it at compile-time also ensures it does not happen to a component only
visible for a few specific application state.

You can disable this with the `-D react_ignore_empty_render` compilation flag,
or for a specific component by adding `@:ignoreEmptyRender` meta to it.

## `@:pureComponent`

TODO: Documentation for macro implementation of pure components.

## `@:ignoreRenderWarning`

TODO: Documentation for runtime warnings.

## `@:acceptsMoreProps`

Some components accept specific props, but also any number of additional props
that are usually passed down to an unknown child component.

This is not the safest pattern out there, but you might have to write or use
externs for this kind of components. Haxe React jsx parser being very strict
with the props, this meta was needed to define this behavior.

```haxe
typedef Props = { /* define your props here */ }

@:acceptsMoreProps
class MyComponent extends ReactComponentOfProps<Props> {}
```

### Custom props validators with `@:acceptsMoreProps('validator_key')`

(New in react-next 1.105.0)

Sometimes, especially when dealing with externs, you want to be able to validate
props in a way that is not really possible with haxe type system.

You can register custom props validator (at macro level) for your component with
an initialization macro in your `.hxml`:

```
--macro pack.InitMacro.registerValidator()
```

This macro will look like this:

```haxe
package pack;

import haxe.macro.Expr;
import react.macro.PropsValidator;

class InitMacro {
	// Initialization macro doing the registration
	public static function registerValidator() {
		PropsValidator.register('my_very_unique_key', validator);
	}

	// The actual validator
	public static function validator(name:String, expr:Expr):Null<Expr> {
		if (some_condition) {
			// Ok, I recognize this prop!
			// Add an `ECheckType` around the expr to validate the props typing
			// Note: just return `expr` if you don't want to check its type
			var expectedType:ComplexType = macro :ExpectedType;
			return macro @:pos(expr.pos) (${expr}:$expectedType);
		}

		// This prop isn't known by the validator, let jsx throw the usual error
		return null;
	}
}
```

Your component can the use `@:acceptsMoreProps` to tell the jsx macro how to
validate extra props:

```haxe
private typedef Props = {
	var normalProp:String;
	@:optional var normalOptionalProp:Int;
}

@:acceptsMoreProps('my_very_unique_key')
class MyComponent extends ReactComponentOfProps<Props> {
	// ...
}
```

Note that you will have to avoid validator key conflict yourself, so make sure
your keys will likely be unique (by namespacing, for example), especially if you
use this feature in a library.
