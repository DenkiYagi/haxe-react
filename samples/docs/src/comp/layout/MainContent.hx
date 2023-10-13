package comp.layout;

private typedef Props = {
	var children:ReactFragment;
}

@:css
class MainContent extends ReactComponent<Props> {
	static var styles:Stylesheet = {
		'_': {
			position: Relative,
			maxWidth: '60em',
			minHeight: 'calc(100vh - 2 * var(--mainBorderWidth))',
			margin: [0, 'auto'],
			paddingTop: Var('mainBorderWidth'),
			paddingBottom: 'calc(var(--mainBorderWidth) + 2em)',
			paddingRight: 'calc(var(--borderPosition) + 1em)',
			paddingLeft: 'calc(var(--borderPosition) + 1em)',
			boxSizing: 'border-box',
			outline: 'none'
		},
		'_::before, _::after': {
			content: '""',
			display: 'block',
			position: Absolute,
			top: 0,
			bottom: 0,
			width: 1,
			background: Var('dark'),
			zIndex: 0
		},
		'_::before': {
			left: Var('borderPosition')
		},
		'_::after': {
			right: Var('borderPosition')
		},
		'_:focus': {
			outline: 'none'
		},
		'_:focus::before, _:focus::after': {
			background: Var('yellow')
		}
	};

	override function render():ReactFragment {
		return jsx(<div className={className} tabIndex={0}>{props.children}</div>);
	}
}
