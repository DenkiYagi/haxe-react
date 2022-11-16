package react.macro;

import haxe.macro.Context;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypeTools;

using haxe.macro.Tools;

typedef ComponentTypes = {
	@:optional var tprops:ComplexType;
	@:optional var tstate:ComplexType;
}

@:dce
class MacroUtil {
	static public function isEmpty(type:ComplexType):Bool
	{
		return switch (type) {
			case TPath({name: "Dynamic", sub: null, pack: [], params: []}):
				true;

			case TPath({name: "Empty", sub: null, pack: ["react"], params: []}):
				true;

			default:
				false;
		};
	}

	static public function toFieldExpr(sl:Array<String>, pos:Position = null):Expr
	{
		if (pos == null) pos = Context.currentPos();

		return Lambda.fold(
			sl,
			function(s, e) {
				return e == null
					? (macro @:pos(pos) $i{s})
					: (macro @:pos(pos) $e.$s);
			},
			null
		);
	}

	// TODO: add some cache
	static public function extractComponentTypes(inClass:ClassType):ComponentTypes
	{
		var ret = {tprops: null, tstate: null};

		switch (inClass.superClass)
		{
			case {params: params, t: _.toString() => cls}
			if (cls == 'react.ReactComponentOf' || cls == 'react.PureComponentOf'):
				ret.tprops = TypeTools.toComplexType(params[0]);
				ret.tstate = TypeTools.toComplexType(params[1]);

			default:
		}

		return ret;
	}

	static public function testType(t:Type):Bool
	{
		if (t == null) return false;

		return try {
			var ct = TypeTools.toComplexType(t);
			testComplexType(ct);
		} catch (e:Dynamic) {
			false;
		}
	}

	static public function testComplexType(ct:ComplexType):Bool
	{
		if (ct == null) return false;

		return try {
			compileComplexType(ct);
			true;
		} catch (e:Dynamic) {
			false;
		}
	}

	static function compileType(t:Type):Void
	{
		compileComplexType(t.toComplexType());
	}

	static function compileComplexType(ct:ComplexType):Void
	{
		Context.typeExpr(macro (null :$ct));
	}

	static public function tryFollow(t:Type):Type
	{
		return try {
			var t1 = t.follow();
			compileType(t1);
			t1;
		} catch (e:Dynamic) {
			null;
		};
	}

	static public function tryMapFollow(t:Type):Type
	{
		return try {
			var t1 = t.map(function(t) return t.follow());
			compileType(t1);
			t1;
		} catch (e:Dynamic) {
			null;
		};
	}

	static public function getField(fields:Array<Field>, name:String)
	{
		for (field in fields)
			if (field.name == name)
				return field;

		return null;
	}

	static public function extractMetaString(metaExpr:Expr):Null<String>
	{
		return switch (metaExpr.expr) {
			case EConst(CString(str)): str;
			case EConst(CIdent(ident)): ident;
			default: null;
		};
	}

	static public function functionToType(fun:haxe.macro.Function):Type
	{
		return TFun(fun.args.map(funArgToTFunArg), ComplexTypeTools.toType(fun.ret));
	}

	static public function funArgToTFunArg(arg:FunctionArg):{t:Type, opt:Bool, name:String}
	{
		return {
			t: ComplexTypeTools.toType(arg.type),
			opt: arg.opt,
			name: arg.name
		};
	}
}

class PositionTools {
	public static function or(pos:Position, fallback:Position):Position {
		if (pos == null) return fallback;
		if (haxe.macro.PositionTools.getInfos(pos).min == -1) return fallback;
		return pos;
	}
}
