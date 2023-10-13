package comp;

import data.DocChapter;

private typedef Props = {
	var chapter:Null<DocChapter>;
}

class Article extends ReactComponent<Props> {
	override function render():ReactFragment {
		if (props.chapter == null) return "404";

		// TODO: use proper custom html renderer, handle internal/external links
		return jsx(
			<div dangerouslySetInnerHTML={{__html: props.chapter.parse()}} />
		);
	}
}
