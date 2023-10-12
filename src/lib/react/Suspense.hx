package react;

import react.ReactComponent.ReactFragment;

typedef SuspenseProps = {
	var fallback:ReactFragment;
	@:optional var children:ReactFragment;
}

/**
	https://react.dev/reference/react/Suspense

	`<Suspense>` lets you display a fallback until its children have finished
	loading.
**/
#if (!react_global)
@:jsRequire("react", "Suspense")
#end
@:native('React.Suspense')
extern class Suspense extends ReactComponent<SuspenseProps> {}
