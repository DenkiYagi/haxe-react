package react;

import react.ReactElement;

/**
	Represents all of the things React can render.
**/
@:pure @:coreType abstract ReactNode
	from ReactSingleNode
	from Array<ReactNode>
	from Array<ReactElement>
	from Array<String>
	from Array<Float>
	from Array<Int>
	from Array<Bool>
	from Array<ReactSingleNode> {}

@:pure @:coreType abstract ReactSingleNode
	from String
	from Float
	from Bool
	from ReactElement {}
