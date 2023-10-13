package comp.html;

private typedef Props = {
	var href:String;
	var children:ReactFragment;
}

class ExternalLink extends ReactComponent<Props> {
	override function render():ReactFragment {
		return jsx(
			<a href={props.href} target="_blank" rel="noopener noreferrer">
				{props.children}
			</a>
		);
	}
}
