package react;

import react.ReactNode;
import tink.core.Noise;

typedef BaseProps<TChildren> = {
	var children:TChildren;
}

typedef BasePropsOpt<TChildren> = {
	@:optional var children:TChildren;
}

typedef BasePropsWithChildren = BaseProps<ReactNode>;
typedef BasePropsWithChild = BaseProps<ReactSingleNode>;

typedef BasePropsWithoutChildren = BasePropsOpt<Noise>;

typedef BasePropsWithOptChildren = BasePropsOpt<ReactNode>;
typedef BasePropsWithOptChild = BasePropsOpt<ReactSingleNode>;
