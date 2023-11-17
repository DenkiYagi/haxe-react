package react;

import haxe.Constraints.Function;

@:callable
abstract ReactRef<T>(Function) {
	public var current(get, set):T;

	public function get_current():T {
		return untyped this.current;
	}

	public function set_current(value:T):T {
		return untyped this.current = value;
	}
}

