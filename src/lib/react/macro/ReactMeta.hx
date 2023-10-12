package react.macro;

enum abstract ReactMeta(String) to String {
	// Components specification

	/**
		Wrap current component (must extend `ReactComponent`) in a HOC.

		See [Wrapping your components in HOCs](https://github.com/kLabz/haxe-react/tree/next/doc/wrapping-with-hoc.md)
	*/
	var Wrap = ':wrap';

	/**
		`@:jsxStatic(method)`

		Create a static component that you can use in jsx (and where "real"
		components are expected) from a static function from a class (**not** a
		`ReactComponent` class).

		See [Static components](https://github.com/kLabz/haxe-react/tree/next/doc/static-components.md).
	*/
	var JsxStatic = ':jsxStatic';

	/**
		TODO: Documentation for macro context API
	*/
	var ContextMeta = ':context';

	/**
		TODO: Documentation for macro implementation of pure components.
	*/
	var PureComponent = ':pureComponent';

	/**
		To be used with `@:wrap`.

		`@:publicProps(TProps)`
		Set public props type to ensure jsx type checking.

		See [Wrapping your components in HOCs](https://github.com/kLabz/haxe-react/tree/next/doc/wrapping-with-hoc.md)
	*/
	var PublicProps = ':publicProps';

	/**
		To be used with `@:wrap`.

		`@:noPublicProps`
		Disallow public props for this component when used in jsx.

		See [Wrapping your components in HOCs](https://github.com/kLabz/haxe-react/tree/next/doc/wrapping-with-hoc.md)
	*/
	var NoPublicProps = ':noPublicProps';

	/**
		See [`@:acceptsMoreProps`](https://github.com/kLabz/haxe-react/blob/next/doc/custom-meta.md#acceptsmoreprops)
	*/
	var AcceptsMoreProps = ':acceptsMoreProps';

	// Debug config

	/**
		There is a compile-time check for an override of the `render` function
		in your components. This helps catching following runtime warning:

			Warning: Index(...): No `render` method found on the returned
			component instance: you may have forgotten to define `render`.

		Catching it at compile-time also ensures it does not happen to a
		component only visible for a few specific application state.

		You can disable this with the `-D react_ignore_empty_render`
		compilation flag, or for a specific component by adding
		`@:ignoreEmptyRender` meta to it.
	*/
	var IgnoreEmptyRender = ':ignoreEmptyRender';

	/**
		TODO: Documentation for runtime warnings.
	*/
	var IgnoreRenderWarning = ':ignoreRenderWarning';

	/**
		TODO: Documentation for runtime warnings.
	*/
	var WhyRender = ':whyRender';

	// Internal metas

	/**
		This special meta is added by the `@:wrap` macro for internal use, do
		not set it if you don't want to break the functionality.
	*/
	var WrappedByMacro = ':wrapped_by_macro';

	/**
		This special meta is added by the `@:pureComponent` macro for internal
		use, do not set it if you don't want to break the functionality.
	*/
	var PureComponentInjected = ':pureComponent_injected';
}
