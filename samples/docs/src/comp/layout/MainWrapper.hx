package comp.layout;

private typedef Props = {
	var children:ReactFragment;
}

@:css
class MainWrapper extends ReactComponent<Props> {
	static var styles:Stylesheet = {
		'_': {
			paddingLeft: '19em',
			marginRight: 'calc(-1 * var(--mainBorderWidth))',
		},
		'.fullscreen > _': {
			paddingLeft: 0
		}
	};

	static var mediaQueries:Dynamic<Stylesheet> = {
		'max-width: 1079px': {
			'_': {
				paddingLeft: 0,
				paddingRight: 0
			}
		},
		'min-width: 1400px': {
			'_': {
				paddingLeft: "24em",
			}
		}
	}

	override function render():ReactFragment {
		return jsx(<div className={className}>{props.children}</div>);
	}
}
