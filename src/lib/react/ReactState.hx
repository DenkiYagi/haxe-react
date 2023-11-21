package react;

import react.internal.Tuple;
import haxe.extern.EitherType;

abstract ReactState<T>(Tuple2<T, SetStateFunction<T>>) {
	public var current(get, never):T;
	inline extern function get_current() return this.value1;

	public var set(get, never):SetStateFunction<T>;
	inline extern function get_set() return this.value2;
}

typedef SetStateFunction<T> = (nextState:EitherType<T, T->T>)->Void;
