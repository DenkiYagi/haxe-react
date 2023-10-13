---
title: Typing your props
---

# Typing your props with haxe-react

One of the points of using Haxe to develop javascript applications is to benefit
from a statically typed language. So, naturally, you'll want your components to
be able to define the type of props they are going to get and are able to use.

## Using `PropTypes`?

In React, this is usually done using [`PropTypes`][react-proptypes], which uses
an object with validators for each prop. These validators are runtime ones (they
can also be used by flow or typescript at compile-time), and are not types but
descriptors of types.

A simplified example from the documentation:

```javascript
MyComponent.propTypes = {
	optionalArray: PropTypes.array,
	optionalBool: PropTypes.bool,
	optionalFunc: PropTypes.func,
	optionalNumber: PropTypes.number,
	requiredFunc: PropTypes.func.isRequired
};
```

You can declare them with haxe-react by using `react.ReactPropTypes`:

```haxe
import react.ReactComponent;
import react.ReactPropTypes as PropTypes;

class MyComponent extends ReactComponent {
	static var propTypes = {
		optionalArray: PropTypes.array,
		optionalBool: PropTypes.bool,
		optionalFunc: PropTypes.func,
		optionalNumber: PropTypes.number,
		requiredFunc: PropTypes.func.isRequired
	};

	// ...
}
```

Note that this won't do any compile-time check, though, as it is not the primary
typing system for props in haxe-react.

## Use real static typing with `TProps`

In Haxe React, props typing is usually done using `TProps`, a typedef typing the
props your component can use and should be called with.

These types are enforced at compile times when using jsx (haxe-react #next only)

The above example would be implemented with something like that:

```haxe
import react.ReactComponent;

typedef MyComponentProps = {
	var requiredFunc:String->Void;
	@:optional var optionalArray:Array<Int>;
	@:optional var optionalBool:Bool;
	@:optional var optionalFunc:Int->String;
	@:optional var optionalNumber:Int;
}

class MyComponent extends ReactComponentOfProps<MyComponentProps> {
	// ...
}
```


[react-proptypes]: https://reactjs.org/docs/typechecking-with-proptypes.html
