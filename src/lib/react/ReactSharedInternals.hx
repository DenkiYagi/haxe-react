package react;

#if debug
import react.ReactComponent.ReactSource;
#end

extern interface ReactSharedInternals
{
	var ReactCurrentOwner:{
		current: Null<ReactFiber>,
		currentDispatcher: Null<ReactDispatcher>
	};

	#if debug
	var ReactDebugCurrentFrame:{
		getCurrentStack:Null<Void->String>,
		getStackAddendum:Void->String
	};
	#end
}

/**
	https://github.com/facebook/react/blob/master/packages/shared/ReactWorkTags.js
**/
enum abstract WorkTag(Int) from Int to Int
{
	var FunctionalComponent = 0;
	var FunctionalComponentLazy = 1;
	var ClassComponent = 2;
	var ClassComponentLazy = 3;
	var IndeterminateComponent = 4; // Before we know whether it is functional or class
	var HostRoot = 5; // Root of a host tree. Could be nested inside another node.
	var HostPortal = 6; // A subtree. Could be an entry point to a different renderer.
	var HostComponent = 7;
	var HostText = 8;
	var Fragment = 9;
	var Mode = 10;
	var ContextConsumer = 11;
	var ContextProvider = 12;
	var ForwardRef = 13;
	var ForwardRefLazy = 14;
	var Profiler = 15;
	var PlaceholderComponent = 16;
}

extern interface Instance {
	// Tag identifying the type of fiber.
	var tag:WorkTag;

	// Unique identifier of this child.
	var key:Null<String>;

	// The function/class/module associated with this fiber.
	var type:Any;

	// The local state associated with this fiber.
	var stateNode:Any;
}

extern interface ReactFiber extends Instance {

	// The Fiber to return to after finishing processing this one.
	// This is effectively the parent, but there can be multiple parents (two)
	// so this is only the parent of the thing we're currently processing.
	// It is conceptually the same as the return address of a stack frame.
	@:native("return")
	var _return:Null<ReactFiber>;

	// Singly Linked List Tree Structure.
	var child:Null<ReactFiber>;
	var sibling:Null<ReactFiber>;
	var index:Int;

	// The ref last used to attach this node.
	// I'll avoid adding an owner field for prod and model that as functions.
	// ref: null | (((handle: mixed) => void) & {_stringRef: ?string}) | RefObject,
	var ref:Null<Dynamic>;

	// Input is the data coming into process this fiber. Arguments. Props.
	var pendingProps:Any; // This type will be more specific once we overload the tag.
	var memoizedProps:Any; // The props used to create the output.

	// A queue of state updates and callbacks.
	var updateQueue:Null<UpdateQueue<Any>>;

	// The state used to create the output
	var memoizedState:Any;

	// A linked-list of contexts that this fiber depends on
	var firstContextDependency:Null<ContextDependency<Dynamic>>;

	// Bitfield that describes properties about the fiber and its subtree. E.g.
	// the AsyncMode flag indicates whether the subtree should be async-by-
	// default. When a fiber is created, it inherits the mode of its
	// parent. Additional flags can be set at creation time, but after that the
	// value should remain unchanged throughout the fiber's lifetime, particularly
	// before its child fibers are created.
	var mode:TypeOfMode;

	// Effect
	var effectTag:SideEffectTag;

	// Singly linked list fast path to the next fiber with side-effects.
	var nextEffect:Null<ReactFiber>;

	// The first and last fiber with side-effect within this subtree. This allows
	// us to reuse a slice of the linked list when we reuse the work done within
	// this fiber.
	var firstEffect:Null<ReactFiber>;
	var lastEffect:Null<ReactFiber>;

	// Represents a time in the future by which this work should be completed.
	// Does not include work found in its subtree.
	var expirationTime:Float;

	// This is used to quickly determine if a subtree has no pending changes.
	var childExpirationTime:Float;

	// This is a pooled version of a Fiber. Every fiber that gets updated will
	// eventually have a pair. There are cases when we can clean up pairs to save
	// memory if we need to.
	var alternate:Null<ReactFiber>;

	// Time spent rendering this Fiber and its descendants for the current update.
	// This tells us how well the tree makes use of sCU for memoization.
	// It is reset to 0 each time we render and only updated when we don't bailout.
	// This field is only set when the enableProfilerTimer flag is enabled.
	@:optional var actualDuration:Float;

	// If the Fiber is currently active in the "render" phase,
	// This marks the time at which the work began.
	// This field is only set when the enableProfilerTimer flag is enabled.
	@:optional var actualStartTime:Float;

	// Duration of the most recent render time for this Fiber.
	// This value is not updated when we bailout for memoization purposes.
	// This field is only set when the enableProfilerTimer flag is enabled.
	@:optional var selfBaseDuration:Float;

	// Sum of base times for all descedents of this Fiber.
	// This value bubbles up during the "complete" phase.
	// This field is only set when the enableProfilerTimer flag is enabled.
	@:optional var treeBaseDuration:Float;

	#if debug
	@:optional var debugID:Float;
	@:optional var debugSource:Null<ReactSource>;
	@:optional var debugOwner:Null<ReactFiber>;
	@:optional var debugIsCurrentlyTiming:Bool;
	#end
}

extern interface Update<State>
{
	var expirationTime:Float;

	var tag:UpdateTag;
	var payload:Any;
	var callback:Null<Void->Dynamic>;

	var next:Null<Update<State>>;
	var nextEffect:Null<Update<State>>;
}

extern interface UpdateQueue<State>
{
	var baseState:State;

	var firstUpdate:Null<Update<State>>;
	var lastUpdate:Null<Update<State>>;

	var firstCapturedUpdate:Null<Update<State>>;
	var lastCapturedUpdate:Null<Update<State>>;

	var firstEffect:Null<Update<State>>;
	var lastEffect:Null<Update<State>>;

	var firstCapturedEffect:Null<Update<State>>;
	var lastCapturedEffect:Null<Update<State>>;
}

enum abstract UpdateTag(Int) from Int to Int
{
	var UpdateState = 0;
	var ReplaceState = 1;
	var ForceUpdate = 2;
	var CaptureUpdate = 3;
}

enum abstract TypeOfMode(Int) from Int to Int
{
	var NoContext = 0;
	var AsyncMode = 1;
	var StrictMode = 2;
	var ProfileMode = 3;
}

enum abstract SideEffectTag(Int) from Int to Int
{
	var NoEffect = 0;
	var PerformedWork = 1;

	var Placement = 2;
	var Update = 4;
	var PlacementAndUpdate = Placement & Update;
	var Deletion = 8;
	var ContentReset = 16;
	var Callback = 32;
	var DidCapture = 64;
	var Ref = 128;
	var Snapshot = 256;
	var LifecycleEffectMask = Update & Callback & Ref & Snapshot;

	// Union of all host effects
	var HostEffectMask = 511;

	var Incomplete = 512;
	var ShouldCapture = 1024;
}

extern interface ContextDependency<T>
{
	var context:ReactContext<T>;
	var observedBits:Int;
	var next:Null<ContextDependency<Any>>;
}

typedef ReactDispatcher = {
	var readContext:haxe.Constraints.Function;
}
