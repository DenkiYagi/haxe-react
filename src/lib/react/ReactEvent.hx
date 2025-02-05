package react;

import js.html.Element;
import js.html.Event;
import js.html.EventTarget;
import js.html.DataTransfer;
import js.html.TouchList;

typedef ReactBaseSyntheticEvent<E = {}, C = Dynamic, T = Dynamic> = {
	final nativeEvent:E;
	final currentTarget:C;
	final target:T;
	final bubbles:Bool;
	final cancelable:Bool;
	final defaultPrevented:Bool;
	final eventPhase:Int;
	final isTrusted:Bool;
	function preventDefault():Void;
	function isDefaultPrevented():Bool;
	function stopPropagation():Void;
	function isPropagationStopped():Bool;
	function persist():Void;
	final timeStamp:Float;
	final type:String;
}

typedef ReactSyntheticEvent<T = Element, E = Event> = ReactBaseSyntheticEvent<E, EventTarget & T, EventTarget> & {}

typedef ReactClipboardEvent<T = Element> = ReactSyntheticEvent<T, js.html.ClipboardEvent> & {
	final clipboardData:DataTransfer;
}

typedef ReactCompositionEvent<T = Element> = ReactSyntheticEvent<T, js.html.CompositionEvent> & {
	final data:String;
}

typedef ReactDragEvent<T = Element> = ReactMouseEvent<T, js.html.DragEvent> & {
	final dataTransfer:DataTransfer;
}

enum abstract PointerType(String) to String {
	var Mouse = "mouse";
	var Pen = "pen";
	var Touch = "touch";
}

typedef ReactPointerEvent<T = Element> = ReactMouseEvent<T, js.html.PointerEvent> & {
	final pointerId:Int;
	final pressure:Float;
	final tangentialPressure:Float;
	final tiltX:Float;
	final tiltY:Float;
	final twist:Int;
	final width:Float;
	final height:Float;
	final pointerType:PointerType;
	final isPrimary:Bool;
}

typedef ReactFocusEvent<Target = Element, RelatedTarget = Element> = ReactSyntheticEvent<Target, js.html.FocusEvent> & {
	final relatedTarget:Null<RelatedTarget>;
	final target:Target;
}

typedef ReactFormEvent<T = Element> = ReactSyntheticEvent<T> & { }

typedef ReactInvalidEvent<T = Element> = ReactSyntheticEvent<T> & {
	final target:T;
}

typedef ReactChangeEvent<T = Element> = ReactSyntheticEvent<T> & {
	final target:T;
}

enum abstract ModifierKey(String) {
	var Alt = "Alt";
	var AltGraph = "AltGraph";
	var CapsLock = "CapsLock";
	var Control = "Control";
	var Fn = "Fn";
	var FnLock = "FnLock";
	var Hyper = "Hyper";
	var Meta = "Meta";
	var NumLock = "NumLock";
	var ScrollLock = "ScrollLock";
	var Shift = "Shift";
	var Super = "Super";
	var Symbol = "Symbol";
	var SymbolLock = "SymbolLock";
}

typedef ReactKeyboardEvent<T = Element> = ReactUIEvent<T, js.html.KeyboardEvent> & {
	final altKey:Bool;
	/** @deprecated */
	final charCode:Int;
	final ctrlKey:Bool;
	final code:String;
	function getModifierState(key:ModifierKey):Bool;
	final key:String;
	/** @deprecated */
	final keyCode:Int;
	final locale:String;
	final location:Int;
	final metaKey:Bool;
	final repeat:Bool;
	final shiftKey:Bool;
	/** @deprecated */
	final which:Int;
}

typedef ReactMouseEvent<T = Element, E = js.html.MouseEvent> = ReactUIEvent<T, E> & {
	final altKey:Bool;
	final button:Int;
	final buttons:Int;
	final clientX:Int;
	final clientY:Int;
	final ctrlKey:Bool;
	function getModifierState(key:ModifierKey):Bool;
	final metaKey:Bool;
	final movementX:Float;
	final movementY:Float;
	final pageX:Int;
	final pageY:Int;
	final relatedTarget:Null<EventTarget>;
	final screenX:Int;
	final screenY:Int;
	final shiftKey:Bool;
}

typedef ReactTouchEvent<T = Element> = ReactUIEvent<T, js.html.TouchEvent> & {
	final altKey:Bool;
	final changedTouches:TouchList;
	final ctrlKey:Bool;
	function getModifierState(key:ModifierKey):Bool;
	final metaKey:Bool;
	final shiftKey:Bool;
	final targetTouches:TouchList;
	final touches:TouchList;
}

typedef ReactUIEvent<T = Element, E = js.html.UIEvent> = ReactSyntheticEvent<T, E> & {
	final detail:Int;
	final view:Dynamic;
}

typedef ReactWheelEvent<T = Element> = ReactMouseEvent<T, js.html.WheelEvent> & {
	final deltaMode:Int;
	final deltaX:Float;
	final deltaY:Float;
	final deltaZ:Float;
}

typedef ReactAnimationEvent<T = Element> = ReactSyntheticEvent<T, js.html.AnimationEvent> & {
	final animationName:String;
	final elapsedTime:Float;
	final pseudoElement:String;
}

enum abstract ToggleState(String) to String {
	var Closed = "closed";
	var Open = "open";
}

typedef ToggleEventInit = {
	var oldState:ToggleState;
	var newState:ToggleState;
}

@:native("ToggleEvent")
extern class ToggleEvent extends Event {
	final oldState:ToggleState;
	final newState:ToggleState;

	/** @throws DOMError */
	function new(type:String, ?eventInitDict:ToggleEventInit):Void;
}

typedef ReactToggleEvent<T = Element> = ReactSyntheticEvent<T, ToggleEvent> & {
	final oldState:ToggleState;
	final newState:ToggleState;
}

typedef ReactTransitionEvent<T = Element> = ReactSyntheticEvent<T, js.html.TransitionEvent> & {
	final elapsedTime:Float;
	final propertyName:String;
	final pseudoElement:String;
}
