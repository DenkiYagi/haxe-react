package react;

import haxe.macro.ComplexTypeTools;
#if macro
import haxe.ds.Option;
import haxe.macro.Compiler;
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

using react.macro.MacroUtil;
using tink.MacroApi;
using StringTools;

#if (haxe_ver < 4)
private typedef ObjectField = {field:String, expr:Expr};
#end

typedef ComponentReflection = {
	children:Void->ComplexType,
	propsType:Null<Expr>,
	neededAttrs:Array<String>,
	typeChecker:StringAt->Expr->Expr
};
#end

/**
	Provides a simple macro for parsing jsx into Haxe expressions.
**/
@:dce
class ReactMacro
{
	static public macro function jsx(expr:ExprOf<String>):Expr {
		return _jsx(expr);
	}

	#if macro
	static var REACT_FRAGMENT_CT = macro :react.ReactNode;

	public static function _jsx(expr:Expr):Expr {
		function children(c:Children)
			return switch c.value {
				case [v]: child(v);
				case []: expr.reject('empty jsx');
				default: expr.reject('only one node allowed here');
			};

		try {
			return children(tink.hxx.Parser.parseRoot(
				expr,
				{
					fragment: 'react.Fragment',
					defaultExtension: 'html',
					treatNested: function(c) return children.bind(c).bounce()
				}
			));
		} catch (e:HxxEscape) {
			return e.expr;
		}
	}

	static function children(c:tink.hxx.Children, getChildrenType:Void->ComplexType) {
		var lazyType:ComplexType = null;

		var exprs = switch (c) {
			case null | { value: null }: [];

			default:
				lazyType = getChildrenType();

				if (lazyType == REACT_FRAGMENT_CT)
					[for (c in tink.hxx.Generator.normalize(c.value)) macro (${child(c)}:$lazyType)];
				else
					[for (c in tink.hxx.Generator.normalize(c.value)) macro ${child(c)}];
		};

		return {
			individual: exprs,
			compound: switch (exprs) {
				case []: null;
				case [v]:
					if (lazyType == null) lazyType = getChildrenType();
					macro (${v}:$lazyType);

				case a: macro ($a{a} :Array<$REACT_FRAGMENT_CT>);
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

				function handleTagDisplay(pos) {
					if (isHtml) {
						// Try to resolve corresponding html element
						// (note all html elements have a dedicated js.html.*Element class)
						var typeStr = type.getString().sure().toLowerCase();

						var typeExpr = switch (typeStr) {
							case "p": macro js.html.ParagraphElement;
							case "h1" | "h2" | "h3" | "h4" | "h5" | "h6": macro js.html.HeadingElement;
							// TODO: other special cases

							case _:
								var tagClass = typeStr.charAt(0).toUpperCase() + typeStr.substr(1) + "Element";
								var ct = macro :js.html.$tagClass;
								try {
									Context.typeof(macro (null:$ct));
									macro js.html.$tagClass;
								} catch (_) {
									macro js.html.Element;
								}
						};

						typeExpr.pos = pos;
						throw new HxxEscape({pos: pos, expr: EDisplay(typeExpr, DKMarked)});
					}

					throw new HxxEscape({
						pos: n.name.pos,
						expr: EDisplay(macro @:pos(n.name.pos) $e{type}, DKMarked)
					});
				}

				if (Context.containsDisplayPosition(n.name.pos)) {
					handleTagDisplay(n.name.pos);
				} else if (n.closing != null && Context.containsDisplayPosition(n.closing)) {
					handleTagDisplay(n.closing);
				}

				if (!isHtml) JsxStaticMacro.handleJsxStaticProxy(type);
				var component = componentReflection(type, n.name.pos, isHtml);
				var checkProp = component.typeChecker;
				var childrenType = component.children;
				var neededAttrs = component.neededAttrs.copy();

				var attrs = new Array<ExtendedObjectField>();
				var spread = [];
				var key = null;
				var ref = null;

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
							if (Context.containsDisplayPosition(name.pos)) {
								if (component.propsType != null) {
									var prop = name.value;

									throw new HxxEscape({
										pos: name.pos,
										expr: EDisplay(macro @:pos(name.pos) $e{component.propsType}.$prop, DKMarked)
									});
								}
							}

							neededAttrs.remove(name.value);
							add(name, macro @:pos(name.pos) true);

						case Regular(name, value):
							if (Context.containsDisplayPosition(name.pos)) {
								if (component.propsType != null) {
									var prop = name.value;

									throw new HxxEscape({
										pos: name.pos,
										expr: EDisplay(macro @:pos(name.pos) $e{component.propsType}.$prop, DKMarked)
									});
								}
							}

							if (Context.containsDisplayPosition(value.pos)) {
								// TODO: recurse to pinpoint the most precise expression possible
								// TODO: handle recursive jsx here.. somehow..
								throw new HxxEscape({pos: value.pos, expr: EDisplay(value, DKMarked)});
							}

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

				// TODO: uh well need to be sure we're not inside a value either..
				if (Context.containsDisplayPosition(n.opening) && !Context.getDisplayMode().match(Hover)) {
					if (component.propsType != null) {
						// TODO: make an util out of this
						var rawPos = Compiler.getDisplayPos();
						var pos = haxe.macro.PositionTools.make({file: rawPos.file, min: rawPos.pos, max: rawPos.pos});

						// TODO: delay that process and only give missing props
						throw new HxxEscape({
							pos: pos,
							expr: EDisplay({pos: pos, expr: EField(component.propsType, "sa")}, DKDot)
						});
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

				// TODO: find a way to restrict to ReactType
				// TODO: handle html tags too
				// TODO: check hxx parser for <| completion requests
				if (Context.containsDisplayPosition(c.pos)) {
					// TODO: make an util out of this
					var rawPos = Compiler.getDisplayPos();
					var pos = haxe.macro.PositionTools.make({file: rawPos.file, min: rawPos.pos, max: rawPos.pos});

					throw new HxxEscape({
						pos: pos,
						expr: EDisplay(macro @:pos(pos) (null:react.ReactType), DKMarked)
					});
				}

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
											#if haxe4
											if (js.Syntax.code('{0} === undefined', __props.$name))
											#else
											if (untyped __js__('{0} === undefined', __props.$name))
											#end
												__props.$name = @:privateAccess $e{typeInfo.ref}.defaultProps.$name;
										};
									}]};
									__props;
								}
							}
						}
					}

					var pos = (macro null).pos;
					var props = JsxPropsBuilder.makeProps(spread, attrs, pos);
					props = applyDefaultProps(props);
					JsxLiteral.genLiteral(type, props, ref, key, pos);
				}
				else
				{
					if (ref != null) attrs.unshift({field:'ref', expr:ref});
					if (key != null) attrs.unshift({field:'key', expr:key});

					var pos = (macro null).pos;
					var props = JsxPropsBuilder.makeProps(spread, attrs, pos);
					var args = [type, props].concat(children.individual);
					macro react.React.createElement($a{args});
				}

			case CSplat(_):
				c.pos.error('jsx does not support child splats');

			case CIf(cond, cons, alt):
				macro @:pos(cond.pos) if ($cond) ${body(cons)} else ${body(alt)};

			case CFor(head, expr):
				macro @:pos(head.pos) ([for ($head) ${body.bind(expr).bounce()}]:Array<$REACT_FRAGMENT_CT>);

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

		var childrenArr = children(c, function() return REACT_FRAGMENT_CT).individual;
		return switch (childrenArr.length) {
			case 0: macro null;
			case 1: childrenArr[0];
			default:
				macro react.React.createElement($a{
					[macro react.Fragment, macro null].concat(childrenArr)
				});
		};
	}

	static function componentReflection(
		type:Expr,
		nodePos:Position,
		isHtml:Bool
	):ComponentReflection {
		function propsFor(placeholder:Expr):StringAt->Expr->Expr {
			placeholder = Context.storeTypedExpr(Context.typeExpr(placeholder));

			var isTMono = switch (Context.typeof(placeholder)) {
				case TMono(_.get() => null): true;
				default: false;
			};

			return function (name:StringAt, value:Expr) {
				var field = name.value;
				// Position is used for invalid prop name
				var target = macro @:pos(name.pos) $placeholder.$field;

				// Handle components accepting more than their own props
				try {
					Context.typeof(target);
				} catch (e:Dynamic) {
					var reg = new EReg('has no field $field($| \\(Suggestion: \\w+\\))', '');
					if (reg.match(Std.string(e))) {
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

				// Support "import as"
				function deepFollow(t:Type) {
					if (t == null) return null;
					return TypeTools.map(Context.follow(t), deepFollow);
				}

				var t = deepFollow(Context.typeof(macro {
					var __pseudo = $target;
					// Position used for value type mismatch
					@:pos(value.pos) __pseudo = $value;
				}));

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

						try {
							var ct = TypeTools.toComplexType(t);
							Context.typeExpr(macro @:pos(value.pos) ($value :$ct));
						} catch (e:haxe.macro.Error) {
							Context.error(e.message, e.pos.or(value.pos));
						}
					} else {
						Context.error(e.message, e.pos.or(value.pos));
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

		function resolveHtmlTag(tag:String):Null<Expr> {
			for (kind in ["normal", "opaque", "void"]) {
				try {
					var e = macro (null:tink.domspec.Tags).$kind.$tag;
					Context.typeof(e);
					return e;
				} catch (_) {}
			}

			return null;
		}

		return isHtml
			? {
				children: function() return REACT_FRAGMENT_CT,
				#if tink_domspec
				// See below in typeChecker about needed special handling
				propsType: resolveHtmlTag(type.getString().sure()),
				#else
				propsType: null,
				#end
				neededAttrs: [],
				typeChecker: function(name:StringAt, value:Expr) {
					var prop = name.value;

					// data-* attributes are all possible, with (iirc) String type?
					if (StringTools.startsWith(prop, "data-")) return macro @:pos(value.pos) ($value :String);

					#if !react_jsx_no_aria
					// Type valid aria- attributes
					// TODO: consider displaying warning for unknown `aria-` props
					if (StringTools.startsWith(prop, "aria-")) {
						var ct = AriaAttributes.map[prop];
						if (ct != null) return macro @:pos(value.pos) (${value} :$ct);
					}
					#end

					#if (css_types && !react_jsx_no_css_types)
					if (name.value == "style")
						return macro @:pos(value.pos) (${value} :haxe.extern.EitherType<css.Properties, String>);
					#end

					#if tink_domspec
						var tagExpr = resolveHtmlTag(type.getString().sure());

						if (tagExpr != null) {
							// Be forgiving about compatibility with tink_domspec, because:
							// - some things don't work the same (event handlers, react-specific attributes, etc.)
							// - some attributes are still missing (input.form, a.name, ...)
							// TODO: add special handling for dangerouslSetInnerHTML etc.
							try {
								var prop = name.value;
								Context.typeof(macro $tagExpr.$prop);

								var check = () -> {
									Context.typeof(macro {
										var o = null;
										o = $tagExpr.$prop;
										// Position used for value type mismatch
										@:pos(value.pos) o = $value;
										$value;
									});

									return macro {};
								};

								return macro {
									${check.bounce()}
									$value;
								};
							} catch (e) {
								#if react.debugDomspec
								Context.warning(e.message, name.pos);
								#end
							}
						}
					#end

					return value;
				}
			}
			: switch (t) {
				case TAbstract(_.toString() => "react.ReactTypeOf", [tProps])
				| TAbstract(_.toString() => "Null", [TAbstract(_.toString() => "react.ReactTypeOf", [tProps])]):
					var ctProps = TypeTools.toComplexType(tProps);
					{
						children: extractChildrenType(macro @:pos(nodePos) (null:$ctProps).children),
						propsType: macro (null:$ctProps),
						neededAttrs: extractNeededAttrs(tProps),
						typeChecker: propsFor(macro (null:$ctProps))
					};
				case TAbstract(_.toString() => "react.ReactProviderType", [tProps])
				| TAbstract(_.toString() => "Null", [TAbstract(_.toString() => "react.ReactProviderType", [tProps])]):
					var ctProps = ComplexType.TAnonymous([
						{
							name: "value",
							pos:  Context.currentPos(),
							kind: FVar(TypeTools.toComplexType(tProps)),
							meta: []
						}
					]);
					{
						children: extractChildrenType(macro @:pos(nodePos) (null:$ctProps).children),
						propsType: macro (null:$ctProps),
						neededAttrs: extractNeededAttrs(ComplexTypeTools.toType(ctProps)),
						typeChecker: propsFor(macro (null:$ctProps))
					};
				case TFun(args, ret):
					switch (args) {
						case []:
							{
								children: function() return macro :react.Empty,
								propsType: macro (null:react.Empty),
								neededAttrs: [],
								typeChecker: function (_, e:Expr) {
									e.reject('no props allowed here');
									return e;
								}
							};

						case [v]:
							var propsType = macro {
								var o = null;
								$type(o);
								o;
							};

							{
								children: extractChildrenType(macro @:pos(nodePos) {
									var o = null;
									$type(o);
									o.children;
								}),
								neededAttrs: extractNeededAttrs(v.t),
								propsType: propsType,
								typeChecker: propsFor(propsType)
							};

						case v:
							throw 'assert'; //TODO: do something meaningful here
					}

				case TInst(_.toString() => "String", []):
					{
						propsType: null,
						children: function() return macro :react.Empty,
						neededAttrs: [],
						typeChecker: function(_, e:Expr) return macro $e
					};

				default:
					var typeExpr = macro {
						function get<T>(c:Class<T>):T return null;
						@:privateAccess get($type).props;
					};

					{
						propsType: typeExpr,
						children: extractChildrenType(macro @:pos(nodePos) {
							function get<T>(c:Class<T>):T return null;
							@:privateAccess get($type).props.children;
						}),
						neededAttrs: extractNeededAttrs(Context.typeof(typeExpr)),
						typeChecker: propsFor(typeExpr)
					};
			}
	}

	static function extractChildrenType(type:Expr):Void->ComplexType {
		return function() {
			try {
				var t = Context.typeof(type);
				return TypeTools.toComplexType(t);
			} catch (e:Dynamic) {}

			return REACT_FRAGMENT_CT;
		}
	}

	static var neededAttrsCache:Map<String, Array<String>> = new Map();
	static function extractNeededAttrs(type:Type) {
		var key = Std.string(type);
		if (neededAttrsCache.exists(key)) return neededAttrsCache.get(key);

		var neededAttrs = [];
		var skipCache = false;

		function hasEmptyAttrs(name:String):Bool {
			return switch (name) {
				case "react.Empty": true;
				case "react.BasePropsWithoutChildren": true;
				case "react.BasePropsWithOptChild": true;
				case "react.BasePropsWithOptChildren": true;
				case _: false;
			};
		}

		function hasOnlyChildren(name:String):Bool {
			return switch (name) {
				case "react.BasePropsWithChild": true;
				case "react.BasePropsWithChildren": true;
				case _: false;
			};
		}

		switch (type) {
			case TDynamic(null):
			case TType(_.toString() => name, []) if (hasEmptyAttrs(name)):
			case TType(_.toString() => name, []) if (hasOnlyChildren(name)):
				neededAttrs.push("children");

			case TAnonymous(_.get().fields => fields) |
			TType(_.get() => _.type => TAnonymous(_.get().fields => fields), _):
				skipCache = true;
				for (f in fields) if (!f.meta.has(':optional')) neededAttrs.push(f.name);

			default:
		}

		if (!skipCache) neededAttrsCache.set(key, neededAttrs);
		return neededAttrs;
	}
	#end
}

#if macro
class HxxEscape {
	public var expr:Expr;
	public function new(expr:Expr) this.expr = expr;
}
#end
