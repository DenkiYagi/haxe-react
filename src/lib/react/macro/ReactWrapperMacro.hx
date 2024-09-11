package react.macro;

import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.TypeTools;
import react.jsx.JsxStaticMacro;

@:dce
class ReactWrapperMacro
{
	static public inline var WRAP_BUILDER = 'Wrap';

	@:deprecated static public inline var WRAP_META = ReactMeta.Wrap;
	@:deprecated static public inline var PUBLIC_PROPS_META = ReactMeta.PublicProps;
	@:deprecated static public inline var NO_PUBLIC_PROPS_META = ReactMeta.NoPublicProps;

	static public function buildComponent(inClass:ClassType, fields:Array<Field>):Array<Field>
	{
		if (inClass.meta.has(ReactMeta.WrappedByMacro)) return fields;
		if (!inClass.meta.has(ReactMeta.Wrap)) return fields;

		if (inClass.meta.has(JsxStaticMacro.META_NAME))
			Context.fatalError(
				'Cannot use @${ReactMeta.Wrap} and @${JsxStaticMacro.META_NAME} on the same component',
				inClass.pos
			);

		var wrapperExpr = null;
		var wrappersMeta = inClass.meta.extract(ReactMeta.Wrap);
		wrappersMeta.reverse();

		var publicProps = extractPublicProps(inClass.meta, wrappersMeta[0].pos);
		if (publicProps != null && inClass.meta.has(ReactMeta.AcceptsMoreProps)) {
			publicProps = macro :react.ReactComponent.ACCEPTS_MORE_PROPS<$publicProps>;
		}

		var fieldType = publicProps == null
			? null
			: macro :$publicProps->react.ReactNode;

		Lambda.iter(wrappersMeta, function(m) {
			if (m.params.length == 0)
				Context.fatalError(
					'Invalid number of parameters for @${ReactMeta.Wrap}; '
					+ 'expected 1 parameter (hoc expression).',
					m.pos
				);

			var e = m.params[0];
			wrapperExpr = wrapperExpr == null
				? macro @:pos(e.pos) ${e}($i{inClass.name})
				: macro @:pos(e.pos) ${e}(${wrapperExpr});
		});

		var fieldName = '_renderWrapper';
		fields.push({
			access: [APublic, AStatic],
			name: fieldName,
			kind: FVar(fieldType, macro cast (${wrapperExpr} :react.ReactType)),
			doc: null,
			meta: null,
			pos: inClass.pos
		});

		inClass.meta.add(JsxStaticMacro.META_NAME, [macro $v{fieldName}], inClass.pos);
		inClass.meta.add(ReactMeta.WrappedByMacro, [], inClass.pos);

		return fields;
	}

	static function extractPublicProps(meta:MetaAccess, wrapPos:Position):Null<ComplexType>
	{
		if (meta.has(ReactMeta.PublicProps))
		{
			var publicProps = meta.extract(ReactMeta.PublicProps)[0];
			if (publicProps.params.length == 0)
				Context.fatalError(
					'Invalid number of parameters for @${ReactMeta.PublicProps}; '
					+ 'expected 1 parameter (props type identifier).',
					publicProps.pos
				);

			var e = publicProps.params[0];
			var tprops = try {
				Context.getType(switch (e.expr) {
					case EConst(CString(str)), EConst(CIdent(str)): str;
					case EField(_, _): ExprTools.toString(e);

					default:
						Context.error(
							'@${ReactMeta.PublicProps}: unsupported argument; '
							+ 'expected a type identifier.',
							publicProps.pos
						);
				});
			} catch (e:String) {
				Context.error(e, publicProps.params[0].pos);
			}

			return TypeTools.toComplexType(tprops);
		}

		if (meta.has(ReactMeta.NoPublicProps)) return macro :{};

		#if react_wrap_strict
		Context.warning(
			'@${ReactMeta.Wrap}: missing @${ReactMeta.PublicProps} meta required by '
			+ 'strict mode (`-D react_wrap_strict`).',
			wrapPos
		);
		#end

		return null;
	}
}

