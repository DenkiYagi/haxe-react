package react.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

typedef Builder = ClassType -> Array<Field> -> Array<Field>;

class ReactComponentMacro {
	static var builders:Array<Builder> = [
		react.ReactMacro.buildComponent,
		ReactTypeMacro.alterComponentSignatures,
		react.jsx.JsxStaticMacro.disallowInReactComponent,
		ReactWrapperMacro.buildComponent,
		PureComponentMacro.buildComponent,

		#if !react_ignore_empty_render
		ReactTypeMacro.ensureRenderOverride,
		#end

		#if (debug && react_runtime_warnings)
		ReactDebugMacro.buildComponent,
		#end
	];

	static public function appendBuilder(builder:Builder):Void builders.push(builder);
	static public function prependBuilder(builder:Builder):Void builders.unshift(builder);

	static public function build():Array<Field>
	{
		var inClass = Context.getLocalClass().get();

		return Lambda.fold(
			builders,
			function(builder, fields) return builder(inClass, fields),
			Context.getBuildFields()
		);
	}
}
#end
