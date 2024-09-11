package react;

import js.Syntax;
import haxe.extern.EitherType;
import react.ReactElement;
import react.ReactNode;

typedef ReactComponentProps = {
	/**
		Children have to be manipulated using React.Children.*
	**/
	@:optional var children:Dynamic;
}

/**
	STUB CLASSES
**/
@:genericBuild(react.macro.ReactComponentMacro.buildVariadic())
class ReactComponent<Rest> {}
typedef ReactComponentOfProps<TProps> = ReactComponentOf<TProps, Empty>;
typedef ReactComponentOfState<TState> = ReactComponentOf<Empty, TState>;

#if react_deprecated_refs
// Keep the old ReactComponentOfPropsAndState typedef available for a few versions
// But now we should use ReactComponentOf<TProps, TState> directly
typedef ReactComponentOfPropsAndState<TProps, TState> = ReactComponentOf<TProps, TState>;
#end

@:autoBuild(react.macro.ReactComponentMacro.build())
class ReactComponentOf<TProps, TState>
{
	static var defaultProps:Dynamic;

	var props(default, null):TProps;
	var state(default, null):TState;

	#if react_deprecated_context
	// It's better to define it in your ReactComponent subclass as needed, with the right typing.
	static var contextTypes:Dynamic;
	var context(default, null):Dynamic;
	#end

	function new(?props:TProps) {}

	/**
		https://facebook.github.io/react/docs/react-component.html#forceupdate
	**/
	function forceUpdate(?callback:Void -> Void):Void {}

	/**
		https://facebook.github.io/react/docs/react-component.html#setstate
	**/
	@:overload(function(nextState:TState, ?callback:Void -> Void):Void {})
	@:overload(function(nextState:TState -> TProps -> TState, ?callback:Void -> Void):Void {})
	function setState(nextState:TState -> TState, ?callback:Void -> Void):Void {}

	/**
		https://facebook.github.io/react/docs/react-component.html#render
	**/
	function render():ReactNode { return null; }

	/**
		https://facebook.github.io/react/docs/react-component.html#componentwillmount
	**/
	function componentWillMount():Void {}

	/**
		https://facebook.github.io/react/docs/react-component.html#componentdidmount
	**/
	function componentDidMount():Void {}

	/**
		https://facebook.github.io/react/docs/react-component.html#componentwillunmount
	**/
	function componentWillUnmount():Void {}

	/**
		https://facebook.github.io/react/docs/react-component.html#componentwillreceiveprops
	**/
	function componentWillReceiveProps(nextProps:TProps):Void {}

	/**
		https://facebook.github.io/react/docs/react-component.html#shouldcomponentupdate
	**/
	dynamic function shouldComponentUpdate(nextProps:TProps, nextState:TState):Bool { return true; }

	/**
		https://facebook.github.io/react/docs/react-component.html#componentwillupdate
	**/
	function componentWillUpdate(nextProps:TProps, nextState:TState):Void {}

	/**
		https://facebook.github.io/react/docs/react-component.html#componentdidupdate
	**/
	function componentDidUpdate(prevProps:TProps, prevState:TState):Void {}

	static function __init__():Void {
		// required magic value to tag literal react elements
		Syntax.code("var $$tre = (typeof Symbol === \"function\" && Symbol.for && Symbol.for(\"react.element\")) || 0xeac7");
	}
}
