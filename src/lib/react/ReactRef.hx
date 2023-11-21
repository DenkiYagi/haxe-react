package react;

abstract ReactRef<T>({current:T}) {
	public var current(get, never):T;
	inline extern function get_current() return this.current;
}
