package react.jsx;

#if macro
import haxe.macro.Expr.ComplexType;
#end

class AriaAttributes {
	#if macro
	static public var map:Map<String, ComplexType> = [
		"aria-activedescendant" => macro :react.jsx.AriaAttributes.IdReference,
		"aria-atomic" => macro :Bool,
		"aria-autocomplete" => macro :react.jsx.AriaAttributes.AriaAutoComplete,
		"aria-busy" => macro :Bool,
		"aria-checked" => macro :react.jsx.AriaAttributes.TriState,
		"aria-colcount" => macro :Int,
		"aria-colindex" => macro :Int,
		"aria-colspan" => macro :Int,
		"aria-controls" => macro :react.jsx.AriaAttributes.IdReferenceList,
		"aria-current" => macro :react.jsx.AriaAttributes.AriaCurrent,
		"aria-describedby" => macro:react.jsx.AriaAttributes.IdReferenceList,
		"aria-details" => macro :react.jsx.AriaAttributes.IdReference,
		"aria-disabled" => macro :Bool,
		"aria-errormessage" => macro :react.jsx.AriaAttributes.IdReference,
		"aria-expanded" => macro :Bool,
		"aria-flowto" => macro :react.jsx.AriaAttributes.IdReferenceList,
		"aria-haspopup" => macro :react.jsx.AriaAttributes.AriaHasPopup,
		"aria-hidden" => macro :Bool,
		"aria-invalid" => macro :react.jsx.AriaAttributes.AriaInvalid,
		"aria-keyshortcuts" => macro :String,
		"aria-label" => macro :String,
		"aria-labelledby" => macro :react.jsx.AriaAttributes.IdReferenceList,
		"aria-level" => macro :Int,
		"aria-live" => macro :react.jsx.AriaAttributes.AriaLive,
		"aria-modal" => macro :Bool,
		"aria-multiline" => macro :Bool,
		"aria-multiselectable" => macro :Bool,
		"aria-orientation" => macro :react.jsx.AriaAttributes.AriaOrientation,
		"aria-owns" => macro :react.jsx.AriaAttributes.IdReferenceList,
		"aria-placeholder" => macro :String,
		"aria-posinset" => macro :Int,
		"aria-pressed" => macro :react.jsx.AriaAttributes.TriState,
		"aria-readonly" => macro :Bool,
		"aria-relevant" => macro :react.jsx.AriaAttributes.AriaRelevant,
		"aria-required" => macro :Bool,
		"aria-roledescription" => macro :String,
		"aria-rowcount" => macro :Int,
		"aria-rowindex" => macro :Int,
		"aria-rowspan" => macro :Int,
		"aria-selected" => macro :Bool,
		"aria-setsize" => macro :Int,
		"aria-sort" => macro :react.jsx.AriaAttributes.AriaSort,
		"aria-valuemax" => macro :Float,
		"aria-valuemin" => macro :Float,
		"aria-valuenow" => macro :Float,
		"aria-valuetext" => macro :String
	];
	#end
}

typedef IdReference = String;
typedef IdReferenceList = String;

enum abstract TriState(Dynamic) from Bool {
	var Mixed = "mixed";
}

enum abstract AriaAutoComplete(String) {
	var Inline = "inline";
	var List = "list";
	var Both = "both";
	var None = "none";
}

enum abstract AriaCurrent(Dynamic) from Bool {
	var Page = "page";
	var Step = "step";
	var Location = "location";
	var Date = "date";
	var Time = "time";
}

enum abstract AriaHasPopup(Dynamic) from Bool {
	var Menu = "menu";
	var Listbox = "listbox";
	var Tree = "tree";
	var Grid = "grid";
	var Dialog = "dialog";
}

enum abstract AriaInvalid(Dynamic) from Bool {
	var Grammar = "grammar";
	var Spelling = "spelling";
}

enum abstract AriaLive(String) {
	var Assertive = "assertive";
	var Off = "off";
	var Polite = "polite";
}

enum abstract AriaOrientation(String) {
	var Horizontal = "horizontal";
	var Vertical = "vertical";
}

enum abstract AriaRelevant(String) {
	var Additions = "additions";
	var AdditionsText = "additions text";
	var All = "all";
	var Removals = "removals";
	var Text = "text";
}

enum abstract AriaSort(String) {
	var Ascending = "ascending";
	var Descending = "descending";
	var None = "none";
	var Other = "other";
}
