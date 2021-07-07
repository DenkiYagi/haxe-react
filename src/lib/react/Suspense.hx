package react;

import react.ReactComponent.ReactFragment;

typedef SuspenseProps = {
	var fallback:ReactFragment;
	@:optional var children:ReactFragment;
}

#if (!react.ssr)
#if (!react_global)
@:jsRequire("react", "Suspense")
#end
@:native('React.Suspense')
extern class Suspense extends ReactComponent<SuspenseProps> {}
#else
class Suspense extends ReactComponent<SuspenseProps> {
	override function render():ReactFragment return props.fallback;
}
#end
