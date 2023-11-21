package react;

abstract ReactMutableRef<T>({current:T}) {
	public var current(get, set):T;
	public function get_current():T return this.current;
	public function set_current(value:T):T return this.current = value;

	@:to public inline extern function toReactRef():ReactRef<T> return cast this;
}

