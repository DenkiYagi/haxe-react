package comp;

import AppContext;
import data.DocChapter;

private typedef PublicProps = {
	var chapter:Null<String>;
	var chapters:Array<DocChapter>;
}

private typedef Props = {
	> PublicProps,
	> AppContextData,
}

@:css
@:publicProps(PublicProps)
@:wrap(AppContext.wrap)
class SidePanel extends ReactComponent<Props> {
	static var styles:Stylesheet = {
		'_': {
			position: Fixed,
			top: '4em',
			left: '2em',
			width: '17em',
		},
		'_ a': {
			lineHeight: 1.5,
			textDecoration: "none",
			textTransform: UpperCase,
			color: Var("fg"),
		},
		'_ a.active': {
			color: Var("orange")
		},
		'_ a:hover': {
			textDecoration: "none",
			borderBottom: "none",
			color: Var("yellow")
		},
		'_ > a': {
			display: "block",
			fontSize: "2em",
			lineHeight: 1,
			color: Var("fg"),
			marginTop: "1rem"
		},
		'_ > a::before': {
			content: '"/"',
			display: "none"
		},
		'_ > a:hover::before, _ > a.active::before': {
			display: "inline"
		},
		'_ > a.active': {
			color: Var("yellow")
		},
	}

	static var mediaQueries:Dynamic<Stylesheet> = {
		// TODO: toggle
		'max-width: 1079px': {
			'_': {
				display: 'none'
			}
		},
		'min-width: 1400px': {
			'_': {
				width: '20em',
				left: '3.5em'
			}
		}
	};

	override function render():ReactFragment {
		var ext = props.staticSite ? '.html' : '';
		return jsx(
			<div className={className}>
				<a href="/" className={classNames({"active": props.chapter == null})}>Home</a>

				<a className={classNames({"active": props.chapter != null})}>Docs</a>
				<div className="subnav">
					<for {chapter in props.chapters}>
						<div key={chapter.slug}>
							<a href={chapter.slug + ext} className={chapter.slug == props.chapter ? "active" : null}>
								{chapter.title}
							</a>
						</div>
					</for>
				</div>
			</div>
		);
	}
}
