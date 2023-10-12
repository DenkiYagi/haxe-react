package react;

import js.Symbol;
import js.lib.Promise;

import react.ReactComponent.ReactElement;
import react.ReactComponent.ReactFragment;
import react.ReactComponent.ReactSingleFragment;
import react.ReactContext;
import react.ReactType;

/**
	https://react.dev/reference/react/apis
	https://react.dev/reference/react/legacy
**/
#if (!react_global)
@:jsRequire("react")
#end
@:native('React')
extern class React {
	/**
		https://react.dev/reference/react/createElement
	**/
	public static function createElement(type:ReactType, ?attrs:Dynamic, children:haxe.extern.Rest<Dynamic>):ReactElement;

	/**
		Warning:
		Using `cloneElement` is uncommon and can lead to fragile code

		https://react.dev/reference/react/cloneElement
	**/
	public static function cloneElement(element:ReactElement, ?attrs:Dynamic, children:haxe.extern.Rest<Dynamic>):ReactElement;

	/**
		https://react.dev/reference/react/isValidElement
	**/
	public static function isValidElement(object:ReactFragment):Bool;

	/**
		https://react.dev/reference/react/createContext

		Creates a `{ Provider, Consumer }` pair.
		When React renders a context `Consumer`, it will read the current
		context value from the closest matching `Provider` above it in the tree.

		The `defaultValue` argument is **only** used by a `Consumer` when it
		does not have a matching Provider above it in the tree. This can be
		helpful for testing components in isolation without wrapping them.

		Note: passing `undefined` as a `Provider` value does not cause Consumers
		to use `defaultValue`.
	**/
	public static function createContext<TContext>(
		?defaultValue:TContext,
		?calculateChangedBits:TContext->TContext->Int
	):ReactContext<TContext>;

	/**
		https://react.dev/reference/react/createRef

		Note: this API has been introduced in React 16.3
		If you are using an earlier release of React, use callback refs instead
		https://reactjs.org/docs/refs-and-the-dom.html#callback-refs
	**/
	public static function createRef<TRef>():ReactRef<TRef>;

	/**
		https://react.dev/reference/react/forwardRef
		See also https://react.dev/learn/manipulating-the-dom-with-refs

		Note: this API has been introduced in React 16.3
		If you are using an earlier release of React, use callback refs instead
		https://reactjs.org/docs/refs-and-the-dom.html#callback-refs
	**/
	public static function forwardRef<TProps, TRef>(render:TProps->ReactRef<TRef>->ReactFragment):ReactType;

	/**
		Warning
		Using `Children` is uncommon and can lead to fragile code.

		https://react.dev/reference/react/Children
	**/
	public static var Children:ReactChildren;

	/**
		https://react.dev/reference/react/lazy
	**/
	public static function lazy(loader:Void->Promise<Module<ReactType>>):ReactType;

	/**
		Utility to use `React.lazy()` on an already loaded `ReactType` (either
		class component or function), mostly to be used with `react.Suspense`.
	**/
	public static inline function lazify(t:ReactType):ReactType {
		return lazy(() -> Promise.resolve(React.createModule(t)));
	}

	/**
		Let any `ReactType` pretend to be a module in order to be usable by
		`React.lazy()`. Works with class components, functions, etc.
	**/
	public static inline function createModule(t:ReactType):Module<ReactType> return t;

	public static var version:String;

	public static var Fragment:Symbol;
	public static var StrictMode:Symbol;
	public static var unstable_AsyncMode:Symbol;
	public static var unstable_Profiler:Symbol;

	@:native('__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED')
	public static var _internals:ReactSharedInternals;
}

/**
	https://react.dev/reference/react/Children
**/
extern interface ReactChildren {
	/**
		https://react.dev/reference/react/Children#children-map
	**/
	function map(children:Dynamic, fn:Array<ReactFragment>->ReactFragment):Null<Array<ReactFragment>>;

	/**
		https://react.dev/reference/react/Children#children-foreach
	**/
	function foreach(children:Dynamic, fn:ReactFragment->Void):Void;

	/**
		https://react.dev/reference/react/Children#children-count
	**/
	function count(children:ReactFragment):Int;

	/**
		https://react.dev/reference/react/Children#children-only
	**/
	function only(children:ReactFragment):ReactSingleFragment;

	/**
		https://react.dev/reference/react/Children#children-toarray
	**/
	function toArray(children:ReactFragment):Array<ReactFragment>;
}

@:deprecated
typedef CreateElementType = ReactType;

@:coreType abstract Module<T> {
	@:from
	static function fromT<T>(v:T):Module<T> return cast {"default": v};
}
