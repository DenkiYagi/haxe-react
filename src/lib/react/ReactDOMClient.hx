package react;

import haxe.extern.EitherType;
import js.html.DocumentFragment;
import js.html.Element;
import react.ReactNode;

#if (!react_global)
@:jsRequire("react-dom/client")
#end
@:native("ReactDOMClient")
extern class ReactDOMClient {
	/**
		`createRoot` lets you create a root to display React components inside a
		browser DOM node.

		Notes:
		- If your app is server-rendered, using `createRoot()` is not supported.
		  Use `hydrateRoot()` instead
		- You’ll likely have only one `createRoot` call in your app
		- When you want to render a piece of JSX in a different part of the DOM
		  tree that isn’t a child of your component (for example, a modal or a
		  tooltip), use `ReactDOM.createPortal` instead of `createRoot`

		https://react.dev/reference/react-dom/client/createRoot
	**/
	public static function createRoot(container:EitherType<Element, DocumentFragment>, ?options:RootOptions):RootType;

	/**
		`hydrateRoot` lets you display React components inside a browser DOM
		node whose HTML content was previously generated by `ReactDOMServer`.

		Notes:
		- `hydrateRoot()` expects the rendered content to be identical with the
		  server-rendered content. You should treat mismatches as bugs and fix
		  them
		- In development mode, React warns about mismatches during hydration.
		  There are no guarantees that attribute differences will be patched up
		  in case of mismatches
		- You’ll likely have only one `hydrateRoot` call in your app
		- If your app is client-rendered with no HTML rendered already, using
		  `hydrateRoot()` is not supported. Use `createRoot()` instead

		https://react.dev/reference/react-dom/client/hydrateRoot
	**/
	public static function hydrateRoot(container:Element, element:ReactNode, ?options:HydrationOptions):RootType;
}

typedef ReactDOMClientOptions = {
	?identifierPrefix:String,
	?onRecoverableError:(err:Any)->Void
}

typedef RootOptions = {
    var ?identifierPrefix:String;
    var ?onRecoverableError:(error:Any, errorInfo:ErrorInfo)->Void;
}

typedef HydrationOptions = {
    var ?identifierPrefix:String;
    var ?onRecoverableError:(error:Any, errorInfo:ErrorInfo)->Void;
}

typedef ErrorInfo = {
    var ?digest:String;
    var ?componentStack:String;
}

typedef RootType = {
	function render(node:ReactNode):Void;
	function unmount():Void;
}