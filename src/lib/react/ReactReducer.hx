package react;

import react.internal.Tuple;

abstract ReactReducer<TState, TAction>(Tuple2<TState, DispatchActionFunction<TAction>>) {
	public var current(get, never):TState;
	inline extern function get_current() return this.value1;

	public var dispatch(get, never):DispatchActionFunction<TAction>;
	inline extern function get_dispatch() return this.value2;
}

typedef DispatchActionFunction<TAction> = (action:TAction)->Void;
