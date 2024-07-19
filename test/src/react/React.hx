package react;

import react.ReactType;
import react.ReactComponent.ReactElement;
import react.ReactComponent.ReactFragment;

/**
	STUB
**/
extern class React
{
	/**
		https://facebook.github.io/react/docs/react-api.html#react.proptypes
	**/
	public static var PropTypes(default, null):ReactPropTypes;

	/**
		https://facebook.github.io/react/docs/react-api.html#createelement
	**/
	public inline static function createElement(type:CreateElementType, ?attrs:Dynamic, children:haxe.extern.Rest<Dynamic>):ReactElement
	{
		return untyped { type:'NATIVE' };
	}

	/**
		https://facebook.github.io/react/docs/react-api.html#cloneelement
	**/
	public inline static function cloneElement(element:ReactElement, ?attrs:Dynamic, children:haxe.extern.Rest<Dynamic>):ReactElement
	{
		return untyped { type:'NATIVE' };
	}

	/**
		https://facebook.github.io/react/docs/react-api.html#isvalidelement
	**/
	public static inline function isValidElement(object:Dynamic):Bool
	{
		return true;
	}

	/**
		https://react.dev/reference/react/memo
	**/
	public static inline function memo<TProps:{}>(component:ReactTypeOf<TProps>, ?arePropsEqual:(prevProps:TProps, nextProps:TProps)->Bool):ReactTypeOf<TProps> {
		return component;
	}

	/**
		https://facebook.github.io/react/docs/react-api.html#react.children
	**/
	public static var Children:ReactChildren;
}

/**
	https://facebook.github.io/react/docs/react-api.html#react.children
**/
extern interface ReactChildren
{
	/**
		https://facebook.github.io/react/docs/react-api.html#react.children.map
	**/
	function map(children:Dynamic, fn:ReactFragment->ReactFragment):Dynamic;

	/**
		https://facebook.github.io/react/docs/react-api.html#react.children.foreach
	**/
	function foreach(children:Dynamic, fn:ReactFragment->Void):Void;

	/**
		https://facebook.github.io/react/docs/react-api.html#react.children.count
	**/
	function count(children:Dynamic):Int;

	/**
		https://facebook.github.io/react/docs/react-api.html#react.children.only
	**/
	function only(children:Dynamic):ReactElement;

	/**
		https://facebook.github.io/react/docs/react-api.html#react.children.toarray
	**/
	function toArray(children:Dynamic):Array<Dynamic>;
}

private typedef CET = haxe.extern.EitherType<haxe.extern.EitherType<String, haxe.Constraints.Function>, Class<ReactComponent>>;

abstract CreateElementType(CET) to CET
{
	@:from
	static public function fromString(s:String):CreateElementType
	{
		return cast s;
	}

	@:from
	static public function fromFunction(f:Void->ReactFragment):CreateElementType
	{
		return cast f;
	}

	@:from
	static public function fromFunctionWithProps<TProps>(f:TProps->ReactFragment):CreateElementType
	{
		return cast f;
	}

	@:from
	static public function fromComp(cls:Class<ReactComponent>):CreateElementType
	{
		if (untyped cls.__jsxStatic != null)
			return untyped cls.__jsxStatic;

		return cast cls;
	}
}

