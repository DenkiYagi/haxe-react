package comp.layout;

@:css
class StaticBorderTop extends ReactComponent {
	static var styles:Stylesheet = {
		'_': {
			position: Fixed,
			left: 0,
			top: 0,
			width: '100vw',
			height: Var('mainBorderWidth'),
			padding: '0 var(--mainBorderWidth)', // TODO: fix this in react-css
			background: Var('highlight'),
			backgroundClip: 'content-box', // TODO: enum abstract in css-types
			boxSizing: 'border-box', // TODO: enum abstract in css-types
			zIndex: 100
		},
	};

	override function render():ReactFragment {
		return jsx(<div className={className}></div>);
	}
}
