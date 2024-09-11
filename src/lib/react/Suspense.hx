package react;

import react.ReactNode;

typedef SuspenseProps = {
	var fallback:ReactNode;
	@:optional var children:ReactNode;
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
