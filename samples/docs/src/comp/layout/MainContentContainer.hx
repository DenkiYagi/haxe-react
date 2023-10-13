package comp.layout;

private typedef Props = {
	var children:ReactFragment;
}

class MainContentContainer extends ReactComponent<Props> {
	override function render():ReactFragment {
		return jsx(<div className="container">{props.children}</div>);
	}
}
