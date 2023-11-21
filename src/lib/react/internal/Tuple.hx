package react.internal;

abstract Tuple2<T1, T2>(Array<Any>) {
	public var value1(get, never):T1;
	inline extern function get_value1():T1 return this[0];

	public var value2(get, never):T2;
	inline extern function get_value2():T2 return this[1];
}
