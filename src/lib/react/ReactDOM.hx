package react;

import haxe.extern.EitherType;
import js.html.DocumentFragment;
import js.html.Element;
import react.ReactNode;
import react.ReactPortal;

/**
	https://react.dev/reference/react-dom
**/
#if (!react_global)
@:jsRequire("react-dom")
#end
@:native('ReactDOM')
extern class ReactDOM
{
	/**
		https://react.dev/reference/react-dom/createPortal
	**/
	public static function createPortal(children:ReactNode, container:EitherType<Element, DocumentFragment>, ?key:String):ReactPortal;

	/**
		Warning:
		Using flushSync is uncommon and can hurt the performance of your app.

		https://react.dev/reference/react-dom/flushSync
	**/
	public static function flushSync(callback:Void->Void):Void;
}
