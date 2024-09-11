package react;

import haxe.extern.Rest;
import js.lib.Promise;
import js.lib.Symbol;
import react.ReactContext;
import react.ReactElement;
import react.ReactNode;
import react.ReactType;

/**
	- https://react.dev/reference/react/apis
	- https://react.dev/reference/react/hooks
	- https://react.dev/reference/react/legacy
**/
#if (!react_global)
@:jsRequire("react")
#end
@:native('React')
extern class React {
	/**
		https://react.dev/reference/react/createElement
	**/
	static function createElement(type:ReactType, ?attrs:Dynamic, children:Rest<Dynamic>):ReactElement;

	/**
		Warning:
		Using `cloneElement` is uncommon and can lead to fragile code

		https://react.dev/reference/react/cloneElement
	**/
	static function cloneElement(element:ReactElement, ?attrs:Dynamic, children:Rest<Dynamic>):ReactElement;

	/**
		https://react.dev/reference/react/isValidElement
	**/
	static function isValidElement(object:ReactNode):Bool;

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
	static function createContext<TContext>(
		?defaultValue:TContext,
		?calculateChangedBits:TContext->TContext->Int
	):ReactContext<TContext>;

	/**
		https://react.dev/reference/react/createRef

		Note: this API has been introduced in React 16.3
		If you are using an earlier release of React, use callback refs instead
		https://reactjs.org/docs/refs-and-the-dom.html#callback-refs
	**/
	static function createRef<T>():ReactRef<T>;

	/**
		https://react.dev/reference/react/forwardRef
		See also https://react.dev/learn/manipulating-the-dom-with-refs

		Note: this API has been introduced in React 16.3
		If you are using an earlier release of React, use callback refs instead
		https://reactjs.org/docs/refs-and-the-dom.html#callback-refs
	**/
	static function forwardRef<TProps, TRef>(render:(props:TProps, ref:ReactRef<TRef>)->ReactNode):ReactTypeOf<TProps>;

	/**
		Warning
		Using `Children` is uncommon and can lead to fragile code.

		https://react.dev/reference/react/Children
	**/
	static final Children:ReactChildren;

	/**
		https://react.dev/reference/react/lazy
	**/
	static function lazy(loader:Void->Promise<Module<ReactType>>):ReactType;

	/**
		https://react.dev/reference/react/memo
	**/
	static function memo<TProps:{}>(component:ReactTypeOf<TProps>, ?arePropsEqual:(prevProps:TProps, nextProps:TProps)->Bool):ReactTypeOf<TProps>;

	/**
		https://react.dev/reference/react/startTransition
	**/
	static function startTransition(scope:()->Void):Void;

	/**
		https://react.dev/reference/react/useState
	**/
	@:overload(function<T>(initialState:T):ReactState<T> {})
	static function useState<T>(initialState:()->T):ReactState<T>;

	/**
		https://react.dev/reference/react/useReducer
	**/
	@:overload(function<TState>(
		reducer:(prevState:TState)->TState,
		initialArg:TState,
		?init:(arg:TState)->TState
	):ReactReducer<TState, Any> {})
	static function useReducer<TState, TAction>(
		reducer:(prevState:TState, action:TAction)->TState,
		initialArg:TState,
		?init:(arg:TState)->TState
	):ReactReducer<TState, TAction>;

	/**
		https://react.dev/reference/react/useContext
	**/
	static function useContext<T>(context:ReactContext<T>):T;

	/**
		https://react.dev/reference/react/useRef
	**/
	static function useRef<T>(initialValue:T):ReactRef<T>;

	/**
		https://react.dev/reference/react/useImperativeHandle
	**/
	static function useImperativeHandle<T:{}>(ref:ReactRef<T>, createHandle:()->T, ?dependencies:Array<Dynamic>):Void;

	/**
		https://react.dev/reference/react/useEffect
	**/
	@:overload(function (setup:()->Void, ?dependencies:Array<Dynamic>):Void {})
	static function useEffect(setup:()->(()->Void), ?dependencies:Array<Dynamic>):Void;

	/**
		https://react.dev/reference/react/useLayoutEffect
	**/
	@:overload(function (setup:()->Void, ?dependencies:Array<Dynamic>):Void {})
	static function useLayoutEffect(setup:()->(()->Void), ?dependencies:Array<Dynamic>):Void;

	/**
		https://react.dev/reference/react/useInsertionEffect
	**/
	static function useInsertionEffect(setup:()->Void, ?dependencies:Array<Dynamic>):Void;

	/**
		https://react.dev/reference/react/useMemo
	**/
	static function useMemo<T>(calculateValue:()->T, ?dependencies:Array<Dynamic>):T;

	/**
		https://react.dev/reference/react/useCallback
	**/
	static function useCallback<T:haxe.Constraints.Function>(fn:T, ?dependencies:Array<Dynamic>):T;

	/**
		https://react.dev/reference/react/useTransition
	**/
	static function useTransition():ReactTransition;

	/**
		https://react.dev/reference/react/useDeferredValue
	**/
	static function useDeferredValue<T>(value:T):T;

	/**
		https://react.dev/reference/react/useDebugValue
	**/
	static function useDebugValue<T>(value:T, ?format:(value:T)->Dynamic):Void;

	/**
		https://react.dev/reference/react/useId
	**/
	static function useId():String;

	/**
		https://react.dev/reference/react/useSyncExternalStore
	**/
	static function useSyncExternalStore<T>(
		subscribe:(onChange:()->Void)->(()->Void),
		getSnapshot:()->T,
		?getServerSnapshot:()->T
	):T;

	/**
		Utility to use `React.lazy()` on an already loaded `ReactType` (either
		class component or function), mostly to be used with `react.Suspense`.
	**/
	static inline function lazify(t:ReactType):ReactType {
		return lazy(() -> Promise.resolve(React.createModule(t)));
	}

	/**
		Let any `ReactType` pretend to be a module in order to be usable by
		`React.lazy()`. Works with class components, functions, etc.
	**/
	static inline function createModule(t:ReactType):Module<ReactType> return t;

	static final version:String;

	static final Fragment:Symbol;
	static final StrictMode:Symbol;
	static final unstable_AsyncMode:Symbol;
	static final unstable_Profiler:Symbol;

	@:native('__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED')
	static var _internals:ReactSharedInternals;
}

/**
	https://react.dev/reference/react/Children
**/
extern interface ReactChildren {
	/**
		https://react.dev/reference/react/Children#children-map
	**/
	function map(children:Dynamic, fn:Array<ReactNode>->ReactNode):Null<Array<ReactNode>>;

	/**
		https://react.dev/reference/react/Children#children-foreach
	**/
	function foreach(children:Dynamic, fn:ReactNode->Void):Void;

	/**
		https://react.dev/reference/react/Children#children-count
	**/
	function count(children:ReactNode):Int;

	/**
		https://react.dev/reference/react/Children#children-only
	**/
	function only(children:ReactNode):ReactSingleFragment;

	/**
		https://react.dev/reference/react/Children#children-toarray
	**/
	function toArray(children:ReactNode):Array<ReactNode>;
}

@:deprecated
typedef CreateElementType = ReactType;

@:coreType abstract Module<T> {
	@:from
	static function fromT<T>(v:T):Module<T> return cast {"default": v};
}
