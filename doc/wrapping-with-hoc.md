---
title: Wrap with HOC
---

# Wrapping your components in HOCs

You can use HOCs with your components (unless they are `@:jsxStatic` components)
by adding `@:wrap` meta.

```haxe
import react.ReactComponent;
import react.ReactMacro.jsx;
import react.router.ReactRouter;
import react.router.Route.RouteRenderProps;

@:wrap(ReactRouter.withRouter)
class MyComponent extends ReactComponentOfProps<RouteRenderProps> {
	override public function render() {
		return jsx('<p>Current path is ${props.location.pathname}</p>');
	}
}
```

You can also combine HOCs for a single component by simply adding more `@:wrap`
meta:

```haxe
import react.ReactComponent;
import react.ReactMacro.jsx;
import react.ReactType;
import react.router.ReactRouter;
import react.router.Route.RouteRenderProps;

private typedef Props = {
	> RouteRenderProps,
	var answer:Int;
}

@:wrap(ReactRouter.withRouter)
@:wrap(uselessHoc(42))
class MyComponent extends ReactComponentOfProps<Props> {
	static function uselessHoc(value:Int):ReactType->ReactType {
		return function(Comp:ReactType) {
			return function(props:Any) {
				return jsx('<$Comp {...props} answer=${value} />');
			};
		};
	}

	override public function render() {
		return jsx('
			<p>
				Current path is ${props.location.pathname} and the answer is ${props.answer}
			</p>
		');
	}
}
```

## `@:publicProps(TProps)`

One thing to note, though: you will loose props type checking in jsx. You can
get this back by separating your component's public and final props:

```haxe
// Final props
private typedef Props = {
	> PublicProps,
	> RouteRenderProps,
}

// Public props, which need to be provided via jsx
private typedef PublicProps = {
	var path:String;
}
```

You can then tell `@:wrap` what public props you are expecting by adding a
`@:publicProps` meta, and get back all the props typing (including missing and
extra props warnings/errors) like a "normal" component:

```haxe
@:publicProps(PublicProps)
@:wrap(ReactRouter.withRouter)
class MyComponent extends ReactComponentOfProps<Props> {
	override public function render() {
		if (props.path != props.location.pathname) return null;

		return jsx('<p>Welcome to ${props.path}!</p>');
	}
}
```

## `@:noPublicProps`

However, sometimes your component doesn't have any public prop. You can then use
`@:noPublicProps` meta to get errors when sending extra props to this component:

```haxe
import react.ReactComponent;
import react.ReactMacro.jsx;
import react.router.ReactRouter;
import react.router.Route.RouteRenderProps;

@:noPublicProps
@:wrap(ReactRouter.withRouter)
class MyComponent extends ReactComponentOfProps<RouteRenderProps> {
	override public function render() {
		return jsx('<p>Current path is ${props.location.pathname}</p>');
	}
}
```

## `-D react_wrap_strict`

You may want to enforce using either `@:publicProps(MyPublicProps)` or
`@:noPublicProps` for all your `@:wrap`-ed components to make sure your jsx
calls are all safe.

By adding the `react_wrap_strict` compilation flag, you will get compilation
warnings when a `@:wrap`-ed component does not expose its public props type.

