package react;

import react.internal.Tuple;

abstract ReactTransition(Tuple2<Bool, StartTransitionFunction>) {
	var isPending(get, never):Bool;
	inline extern function get_isPending() return this.value1;

	var startTransition(get, never):StartTransitionFunction;
	inline extern function get_startTransition() return this.value2;
}

typedef StartTransitionFunction = (fn:()->Void)->Void;
