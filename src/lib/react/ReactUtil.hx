package react;

import react.ReactElement;
import react.ReactNode;

typedef ChangesSummary = {
	@:optional var added:Array<String>;
	@:optional var updated:Array<String>;
	@:optional var deleted:Array<String>;
}

class ReactUtil
{
	public static function cx(arrayOrObject:Dynamic)
	{
		var array:Array<Dynamic<Bool>>;
		if (Std.is(arrayOrObject, Array)) array = arrayOrObject;
		else array = [arrayOrObject];
		var classes:Array<String> = [];
		for (value in array)
		{
			if (value == null) continue;
			if (Std.is(value, String))
			{
				classes.push(cast value);
			}
			else
			{
				for (field in Reflect.fields(value))
					if (Reflect.field(value, field) == true)
						classes.push(field);
			}
		}
		return classes.join(' ');
	}

	public static function assign(target:Dynamic, sources:Array<Dynamic>):Dynamic
	{
		for (source in sources)
			if (source != null)
				for (field in Reflect.fields(source))
					Reflect.setField(target, field, Reflect.field(source, field));
		return target;
	}

	public static function copy(source1:Dynamic, ?source2:Dynamic):Dynamic
	{
		var target = {};
		for (field in Reflect.fields(source1))
			Reflect.setField(target, field, Reflect.field(source1, field));
		if (source2 != null)
			for (field in Reflect.fields(source2))
				Reflect.setField(target, field, Reflect.field(source2, field));
		return target;
	}

	public static function copyWithout(source1:Dynamic, source2:Dynamic, fields:Array<String>)
	{
		var target = {};
		for (field in Reflect.fields(source1))
			if (!Lambda.has(fields, field))
				Reflect.setField(target, field, Reflect.field(source1, field));
		if (source2 != null)
			for (field in Reflect.fields(source2))
				if (!Lambda.has(fields, field))
					Reflect.setField(target, field, Reflect.field(source2, field));
		return target;
	}

	public static function mapi<A, B>(items:Array<A>, map:Int -> A -> B):Array<B>
	{
		if (items == null) return null;
		var newItems = [];
		for (i in 0...items.length)
			newItems.push(map(i, items[i]));
		return newItems;
	}

	/**
		Clone opaque children structure, providing additional props to merge:
		- as a object
		- or as a function (child->props)
	**/
	public static function cloneChildren(children:ReactNode, props:Dynamic):ReactNode
	{
		if (Reflect.isFunction(props))
			return React.Children.map(children, function(child) {
				if (!React.isValidElement(child)) return child;
				return React.cloneElement((cast child :ReactElement), props(child));
			});
		else
			return React.Children.map(children, function(child) {
				if (!React.isValidElement(child)) return child;
				return React.cloneElement((cast child :ReactElement), props);
			});
	}

	/**
		https://facebook.github.io/react/docs/pure-render-mixin.html

		Implementing a simple shallow compare of next props and next state
		similar to the PureRenderMixin react addon
	**/
	public static function shouldComponentUpdate(component:Dynamic, nextProps:Dynamic, nextState:Dynamic):Bool
	{
		return !shallowCompare(component.props, nextProps) || !shallowCompare(component.state, nextState);
	}

	public static function shallowCompare(a:Dynamic, b:Dynamic):Bool
	{
		var aFields = Reflect.fields(a);
		var bFields = Reflect.fields(b);
		if (aFields.length != bFields.length)
			return false;
		for (field in aFields)
			if (!Reflect.hasField(b, field) || Reflect.field(b, field) != Reflect.field(a, field))
				return false;
		return true;
	}

	public static function shallowChanges<T>(
		obj:T,
		obj2:T,
		?ignoreEqual:Bool
	):Null<ChangesSummary> {
		var keys1 = getKeys(obj);
		var keys2 = getKeys(obj2);

		var added = [];
		var deleted = [];
		var updated = [];
		var hasRet = false;

		for (i in 0...keys1.length) {
			var key = keys1[i];

			if (Lambda.has(keys2, key)) {
				if (Reflect.field(obj, key) != Reflect.field(obj2, key)) {
					updated.push(key);
					hasRet = true;
				}
			} else {
				deleted.push(key);
				hasRet = true;
			}
		}

		for (i in 0...keys2.length) {
			var key = keys2[i];

			if (!Lambda.has(keys1, key)) {
				added.push(key);
				hasRet = true;
			}
		}

		if (!hasRet) return null;
		var ret:ChangesSummary = {};
		if (added.length > 0) ret.added = added;
		if (deleted.length > 0) ret.deleted = deleted;
		if (updated.length > 0) ret.updated = updated;
		return ret;
	}

	public static function getKeys<T>(obj:T):Array<String> {
		return Reflect.fields(obj).filter(k -> Reflect.field(obj, k) != null);
	}
}
