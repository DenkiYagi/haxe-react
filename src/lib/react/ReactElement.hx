package react;

typedef ReactElement = {
	type:ReactType,
	props:Dynamic,
	?key:Dynamic,
	?ref:Dynamic,
	// ?_owner:Dynamic,

	// #if debug
	// ?_store:{validated:Bool},
	// ?_shadowChildren:Dynamic,
	// ?_source:ReactSource,
	// #end
}
