package react;

#if macro
import haxe.ds.Option;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypeTools;
import tink.hxx.Node;
import tink.hxx.Parser;
import tink.hxx.StringAt;
import react.jsx.AriaAttributes;
import react.jsx.JsxLiteral;
import react.jsx.JsxPropsBuilder;
import react.jsx.JsxStaticMacro;
import react.macro.MacroUtil;
import react.macro.PropsValidator;
import react.macro.ReactMeta;
import react.macro.ReactComponentMacro;

using tink.MacroApi;
using StringTools;

#if (haxe_ver < 4)
private typedef ObjectField = {field:String, expr:Expr};
#end
#end

/**
	Provides a simple macro for parsing jsx into Haxe expressions.
**/
@:dce
class ReactMacro
{
	static public macro function jsx(expr:ExprOf<String>):Expr
	{
		if (Context.defined('display')) {
			return switch(expr) {
				case macro @:markup $v{(s:String)}: macro @:pos(expr.pos) untyped $v{s};
				case _: macro @:pos(expr.pos) untyped $e{expr};
			};
		}

		function children(c:Children)
			return switch c.value {
				case [v]: child(v);
				case []: expr.reject('empty jsx');
				default: expr.reject('only one node allowed here');
			};

		return children(
			tink.hxx.Parser.parseRoot(
				expr,
				{
					fragment: 'react.Fragment',
					defaultExtension: 'html',
					treatNested: function(c) return children.bind(c).bounce()
				}
			)
		);
	}

	#if macro
	static var REACT_FRAGMENT_CT = macro :react.ReactComponent.ReactFragment;

	static function children(c:tink.hxx.Children, type:ComplexType)
	{
		var exprs = switch (c) {
			case null | { value: null }: [];

			case _ if (type == REACT_FRAGMENT_CT):
				[for (c in tink.hxx.Generator.normalize(c.value)) macro @:pos(c.pos) (${child(c)}:$type)];

			default:
				[for (c in tink.hxx.Generator.normalize(c.value)) macro @:pos(c.pos) ${child(c)}];
		};

		return {
			individual: exprs,
			compound: switch (exprs) {
				case []: null;
				case [v]: macro @:pos(c.pos) (${v}:$type);
				case a: macro @:pos(c.pos) $a{a};
			}
		};
	}

	static function child(c:Child)
	{
		return switch (c.value) {
			case CText(s):
				#if (react_diagnostics || jsx_warn_for_constant_text)
				if (~/([^a-zA-Z]+)/g.replace(s.value, '').length > 2) {
					var localClass = Context.getLocalClass();
					if (localClass == null || !localClass.get().meta.has(':jsxIgnoreConstantText')) {
						Context.warning('Constant text detected in jsx', s.pos);
					}
				}
				#end

				macro @:pos(s.pos) $v{s.value};

			case CExpr(e): e;
			case CNode(n):
				var type = switch (n.name.value.replace('$', '').split('.')) {
					case [tag] if (tag.charAt(0) == tag.charAt(0).toLowerCase()):
						macro @:pos(n.name.pos) $v{tag};
					case parts:
						macro @:pos(n.name.pos) ${MacroUtil.toFieldExpr(parts, n.name.pos)};
				};

				var isHtml = type.getString().isSuccess(); //TODO: this is a little awkward
				if (!isHtml) JsxStaticMacro.handleJsxStaticProxy(type);

				var checkProp = typeChecker(type, c.pos, isHtml);
				var attrs = new Array<ExtendedObjectField>();
				var spread = [];
				var key = null;
				var ref = null;
				var pos = n.name.pos;
				var neededAttrs = extractNeededAttrs(type);
				var childrenType = extractChildrenType(type);

				function add(name:StringAt, e:Expr)
				{
					attrs.push({
						field: name.value,
						expr: checkProp(name, e),
						isConstant: switch (e.expr) {
							case EConst(_), EParenthesis({expr: EConst(_)}): true;
							case _: false;
						}
					});
				}

				for (attr in n.attributes)
				{
					switch (attr)
					{
						case Splat(e):
							spread.push(e);
							// Spread is not handled, so we assume every needed prop is passed
							neededAttrs = [];

						case Empty(invalid = { value: 'key' | 'ref'}):
							invalid.pos.error('attribute ${invalid.value} must have a value');

						case Empty(name):
							neededAttrs.remove(name.value);
							add(name, macro @:pos(name.pos) true);

						case Regular(name, value):
							neededAttrs.remove(name.value);
							var expr = value.getString()
								.map(function (s) return haxe.macro.MacroStringTools.formatString(s, value.pos))
								.orUse(value);

							switch (name.value)
							{
								case 'key': key = expr;
								case 'ref' if (n.name.value != 'react.Fragment'): ref = expr;
								default: add(name, expr);
							}
					}
				}

				// parse children
				var children = children(n.children, childrenType);
				if (children.compound != null) neededAttrs.remove('children');

				for (attr in neededAttrs)
					Context.warning(
						'Missing prop `$attr` for component `${n.name.value}`',
						c.pos
					);

				// inline declaration or createElement?
				var typeInfo = ReactComponentMacro.getComponentInfo(type);
				JsxStaticMacro.injectDisplayNames(type);
				var useLiteral = JsxLiteral.canUseLiteral(typeInfo, ref);

				if (useLiteral)
				{
					if (children.compound != null)
					{
						attrs.push({field:'children', expr: children.compound });
					}

					var applyDefaultProps:Expr->Expr = function(e) return e;

					if (!isHtml)
					{
						var defaultProps = ReactComponentMacro.getDefaultProps(typeInfo, attrs);
						if (defaultProps != null) {
							// Reproduce react's way of applying defaultProps to
							// make sure we get consistent behavior between
							// debug/non-debug/react_no_inline
							// See https://github.com/facebook/react/blob/d3622d0/packages/react/src/ReactElement.js#L210
							applyDefaultProps = function(e:Expr) {
								var tprops = typeInfo.tprops;

								return macro {
									var __props = $e{tprops != null ? macro ($e :$tprops) : e};
									@:mergeBlock $b{[for (defaultProp in defaultProps) {
										var name = defaultProp.field;
										macro {
											if (untyped __js__('{0} === undefined', __props.$name))
												__props.$name = $e{defaultProp.expr};
										};
									}]};
									__props;
								}
							}
						}
					}

					var props = JsxPropsBuilder.makeProps(spread, attrs, pos);
					props = applyDefaultProps(props);
					JsxLiteral.genLiteral(type, props, ref, key, pos);
				}
				else
				{
					if (ref != null) attrs.unshift({field:'ref', expr:ref});
					if (key != null) attrs.unshift({field:'key', expr:key});

					var props = JsxPropsBuilder.makeProps(spread, attrs, pos);

					var args = [type, props].concat(children.individual);
					macro @:pos(n.name.pos) react.React.createElement($a{args});
				}

			case CSplat(_):
				c.pos.error('jsx does not support child splats');

			case CIf(cond, cons, alt):
				macro @:pos(cond.pos) if ($cond) ${body(cons)} else ${body(alt)};

			case CFor(head, expr):
				macro @:pos(head.pos) ([for ($head) ${body.bind(expr).bounce()}]:Array<ReactFragment>);

			case CSwitch(target, cases):
				ESwitch(target, [for (c in cases) {
					guard: c.guard,
					values: c.values,
					expr: body.bind(c.children).bounce()
				}], null).at(target.pos);

			case CLet(defs, c):
				var vars:Array<Var> = [];
				function add(name, value)
				  vars.push({
					name: name,
					type: null,
					expr: value,
				  });

				for (d in defs) switch d {
				  case Empty(a): a.pos.error('empty attributes not allowed on <let>');
				  case Regular(a, v):
					add(a.value, v);
				  case Splat(e):
					var tmp = MacroApi.tempName();
					add(tmp, e);
					for (f in e.typeof().sure().getFields().sure())
					  if (f.isPublic && !f.kind.match(FMethod(MethMacro)))
						add(f.name, macro @:pos(e.pos) $p{[tmp, f.name]});
				}

				[EVars(vars).at(c.pos), body.bind(c).bounce()].toBlock(c.pos);
		}
	}

	static function body(c:Children)
	{
		if (c == null) return macro null;

		var childrenArr = children(c, REACT_FRAGMENT_CT).individual;
		return switch (childrenArr.length) {
			case 0: macro null;
			case 1: childrenArr[0];
			default:
				macro react.React.createElement($a{
					[macro react.Fragment, macro null].concat(childrenArr)
				});
		};
	}

	static function typeChecker(type:Expr, nodePos:Position, isHtml:Bool):StringAt->Expr->Expr
	{
		function propsFor(placeholder:Expr):StringAt->Expr->Expr
		{
			placeholder = Context.storeTypedExpr(Context.typeExpr(placeholder));

			var isTMono = switch (Context.typeof(placeholder)) {
				case TMono(_.get() => null): true;
				default: false;
			};

			return function (name:StringAt, value:Expr) {
				var field = name.value;
				var target = macro @:pos(name.pos) $placeholder.$field;

				// Handle components accepting more than their own props
				try {
					Context.typeof(target);
				} catch (e:Dynamic) {
					var reg = new EReg('has no field $field($| \\(Suggestion: \\w+\\))', '');
					if (reg.match(e.toString())) {
						switch (Context.typeof(type)) {
							case TType(_.get().type => TAnonymous(_.get() => {
								status: AClassStatics(_.get() => t)
							}), _) if (t.meta.has(ReactMeta.AcceptsMoreProps)):
								var validators = t.meta.extract(ReactMeta.AcceptsMoreProps);
								if (validators[0].params.length > 0) {
									for (v in validators[0].params) {
										var k = MacroUtil.extractMetaString(v);
										if (k == null) {
											Context.error(
												'Unexpected argument. Expected no argument or '
												+ 'an identifier to a registered props validator',
												v.pos
											);
										}

										var validator = PropsValidator.get(k);
										if (validator == null) {
											Context.error(
												'Error: cannot find props validator "$k"',
												v.pos
											);
										} else {
											var validatedValue = validator(field, value);
											if (validatedValue != null) return validatedValue;
										}
									}
								} else {
									return value;
								}

							case TFun([{t: TType(_.toString() => "react.ACCEPTS_MORE_PROPS", _)}], _):
								return value;

							default:
								#if !react_jsx_no_data_for_components
								// Always allow data- props
								if (StringTools.startsWith(field, "data-")) return value;
								#end

								#if (!react_jsx_no_aria || !react_jsx_no_aria_for_components)
								// Always allow valid aria- attributes
								if (StringTools.startsWith(field, "aria-")) {
									var ct = AriaAttributes.map[field];
									if (ct != null) return macro @:pos(value.pos) (${value} :$ct);
								}
								#end
						}
					}
				}

				var t = Context.typeof(macro @:pos(value.pos) {
					var __pseudo = $target;
					__pseudo = $value;
				});

				if (isTMono) {
					#if !react_ignore_failed_props_inference
					Context.warning(
						'Type checking failed: unable to infer '
						+ 'needed props for ${ExprTools.toString(type)}',
						type.pos
					);
					#end

					return value;
				}

				var ct = TypeTools.toComplexType(t);
				if (ct == null) return value;


				var typedExpr = try {
					Context.typeExpr(macro @:pos(value.pos) ($value :$ct));
				} catch (e:haxe.macro.Error) {
					if (StringTools.startsWith(e.message, "Type not found")) {
						var t1 = MacroUtil.tryFollow(t);
						if (t1 == null) t1 = MacroUtil.tryMapFollow(t);
						if (t1 != null) t = t1;

						var ct = TypeTools.toComplexType(t);
						Context.typeExpr(macro @:pos(value.pos) ($value :$ct));
					} else {
						Context.error(e.message, e.pos);
					}
				};

				return Context.storeTypedExpr(typedExpr);
			}
		}

		var t = type.typeof().sure();
		try {
			if (!Context.unify(t, Context.getType('react.ReactType')))
			{
				Context.error(
					'JSX error: invalid node "${ExprTools.toString(type)}"',
					nodePos
				);
			}
		} catch (e:Dynamic) {
			Context.error(
				'JSX error: invalid node "${ExprTools.toString(type)}"',
				nodePos
			);
		}

		return isHtml
			? function(name:StringAt, value:Expr) {
				#if !react_jsx_no_aria
				// Type valid aria- attributes
				// TODO: consider displaying warning for unknown `aria-` props
				var field = name.value;
				if (StringTools.startsWith(field, "aria-")) {
					var ct = AriaAttributes.map[field];
					if (ct != null) return macro @:pos(value.pos) (${value} :$ct);
				}
				#end

				return value;
			}
			: switch (t) {
				case TAbstract(_.toString() => "react.ReactTypeOf", [_.toComplex() => tprops]):
					propsFor(macro @:pos(type.pos) (null:$tprops));

				case TFun(args, _):
					switch (args) {
						case []:
							function (_, e:Expr) {
								e.reject('no props allowed here');
								return e;
							}

						case [v]:
							propsFor(macro @:pos(type.pos) {
								var o = null;
								$type(o);
								o;
							});

						case v:
							throw 'assert'; //TODO: do something meaningful here
					}

				case TInst(_.toString() => "String", []):
					function(_, e:Expr) return e;

				default:
					propsFor(macro @:pos(type.pos) {
						function get<T>(c:Class<T>):T return null;
						@:privateAccess get($type).props;
					});
			}
	}

	static function isReactFragment(type:Null<ComplexType>):Bool {
		if (type == null) return false;

		return switch (type) {
			case TPath({name: "StdTypes", sub: "Null", params: [TPType(type)]}):
				isReactFragment(type);

			case TPath({name: "ReactComponent", sub: "ReactFragment", pack: ["react"]}):
				true;

			default:
				false;
		};
	}

	static function extractChildrenType(type:Expr):ComplexType
	{
		try {
			switch (Context.typeof(type)) {
				case TType(_, _):
					var tprops = Context.storeTypedExpr(Context.typeExpr(macro @:pos(type.pos) {
						function get<T>(c:Class<T>):T return null;
						@:privateAccess get($type).props;
					}));

					switch (Context.typeof(tprops)) {
						case TType(_.get() => _.type => TAnonymous(_.get().fields => fields), _):
							var childType = extractChildrenTypeFromFields(fields);
							if (isReactFragment(childType)) return REACT_FRAGMENT_CT;
							if (childType != null) return childType;

						default:
					}

				case TFun([{t: _ => Context.follow(_) => TAnonymous(_.get().fields => fields)}], _),
				TFun([{t: TType(_.get() => _.type => TAnonymous(_.get().fields => fields), _)}], _):
					var childType = extractChildrenTypeFromFields(fields);
					if (isReactFragment(childType)) return REACT_FRAGMENT_CT;
					if (childType != null) return childType;

				case TAbstract(a, params):
					var childType = extractChildrenTypeFromAbstract(a, params);
					if (isReactFragment(childType)) return REACT_FRAGMENT_CT;
					if (childType != null) return childType;

				case TFun([], _):
				case TInst(_.toString() => "String", []):
				case TFun([{t: TMono(_)}], _):
					// Nothing to do here

				default:
					Context.warning(
						'Cannot get children type for ${ExprTools.toString(type)}',
						type.pos
					);
			}

		} catch (e:Dynamic) {}

		return REACT_FRAGMENT_CT;
	}

	static function extractChildrenTypeFromAbstract(a:Ref<AbstractType>, params:Array<Type>):ComplexType
	{
		switch (a.toString()) {
			case "Null":
				switch (params[0]) {
					case TAbstract(a, params):
						return extractChildrenTypeFromAbstract(a, params);

					default:
				};

			case "react.ReactTypeOf":
				switch (params[0]) {
					case TType(_.get() => {type: TAnonymous(_.get().fields => fields)}, _):
						return extractChildrenTypeFromFields(fields);

					case TInst(_.get().fields.get() => fields, _):
						return extractChildrenTypeFromFields(fields);

					case TAnonymous(_.get().fields => fields):
						return extractChildrenTypeFromFields(fields);

					default:
				}

			case "react.ReactType":
			default:
		};

		return null;
	}

	static function extractChildrenTypeFromFields(
		fields:Array<{name:String, type:Type}>
	):Null<ComplexType>
	{
		for (f in fields)
			if (f.name == 'children')
				return TypeTools.toComplexType(f.type);

		return null;
	}

	static function extractNeededAttrs(type:Expr)
	{
		var neededAttrs = [];

		try {
			switch (Context.typeof(type)) {
				case TType(_, _):
					var tprops = Context.storeTypedExpr(Context.typeExpr(macro @:pos(type.pos) {
						function get<T>(c:Class<T>):T return null;
						@:privateAccess get($type).props;
					}));

					switch (Context.typeof(tprops)) {
						case TType(_.get() => _.type => TAnonymous(_.get().fields => fields), _):
							for (f in fields)
								if (!f.meta.has(':optional'))
									neededAttrs.push(f.name);

						default:
					}

				case TFun([{t: TType(_.get() => _.type => TAnonymous(_.get().fields => fields), _)}], _):
					for (f in fields)
						if (!f.meta.has(':optional'))
							neededAttrs.push(f.name);

				default:
			}

		} catch (e:Dynamic) {}

		return neededAttrs;
	}
	#end
}
