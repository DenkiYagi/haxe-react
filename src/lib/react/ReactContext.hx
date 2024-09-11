package react;

import react.ReactNode;
import react.ReactType;

@:forward
abstract ReactContext<T>(IReactContext<T>) from IReactContext<T> to IReactContext<T> {
	@:to
	public function toReactType():ReactTypeOf<{children:T->ReactNode}> {
		return cast this;
	}
}

extern interface IReactContext<T> {
	var displayName:String;
	var Consumer:ReactContext<T>;
	var Provider:ReactProviderType<T>;

	var unstable_read:Void->T;
	var _calculateChangedBits:Null<T->T->Int>;

	var _currentValue:T;
	var _currentValue2:T;

	#if debug
	@:optional var _currentRenderer:Null<Dynamic>;
	@:optional var _currentRenderer2:Null<Dynamic>;
	#end
}

@:pure @:coreType
abstract ReactProviderType<T>
from IReactProviderType<T>
to IReactProviderType<T>
to ReactTypeOf<{value:T}> {}

extern interface IReactProviderType<T> {
	var _context:ReactContext<T>;
}
