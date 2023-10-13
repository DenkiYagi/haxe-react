package comp;

import comp.layout.*;
import data.DocChapter;

private typedef PublicProps = {
	var chapter:Null<String>;
	@:optional var staticSite:Bool;
}

private typedef Props = {
	> PublicProps,
	var home:DocChapter;
	var chapters:Array<DocChapter>;
}

@:css
@:publicProps(PublicProps)
@:wrap(App.wrap)
class App extends ReactComponent<Props> {
	static var styles:Stylesheet = {
		'_': {
			height: '100vh',
			width: '100vw',
			maxWidth: Unset,
			padding: Var('mainBorderWidth'),
			overflowY: Scroll,
			overflowX: Hidden,
			background: Var('bg'),
			backgroundClip: 'content-box',
			'scrollbar-color': 'var(--orange) var(--highlight)',
			boxSizing: 'border-box',
		},
		'_::-webkit-scrollbar': {
			width: Var('mainBorderWidth'),
			backgroundColor: 'transparent',
		},
		'_::-webkit-scrollbar-track': {
			display: 'none',
			borderRadius: 0,
			'-webkit-box-shadow': 'none'
		},
		'_::-webkit-scrollbar-thumb': {
			borderRadius: 0,
			border: 'var(--mainBorderWidth) solid var(--orange)',
			borderLeft: 'none',
			borderTopColor: 'transparent',
			borderBottomColor: 'transparent',
			'-webkit-box-shadow': 'none'
		}
	};

	static function wrap(Comp) {
		return function(props:Props) {
			var LazyComp = React.lazy(() ->
				loadChapters()
				.then(chapters -> (_) -> jsx(
					<Comp
						{...props}
						home={loadReadme()}
						chapters={chapters}
					/>
				))
				.then(type -> React.createModule(type))
			);

			return jsx(<LazyComp />);
		};
	}

	override function render():ReactFragment {
		return jsx(
			<html>
				<head>
					<meta charSet="utf-8" />
					<meta name="HandheldFriendly" content="True" />
					<meta name="viewport" content="width=device-width, initial-scale=1.0" />
					<meta name="referrer" content="no-referrer-when-downgrade" />

					<title>Haxe react-next docs</title>
					<meta name="description" content="Documentation for react-next haxelib" />
					<link rel="stylesheet" href="/styles.css" />
					<link rel="icon" type="image/png" href="/favicon.png" />
				</head>

				<body>
					<div className={className}>
						<AppContext.Provider value={{staticSite: props.staticSite}}>
							<StaticBorderTop />

							<SidePanel chapter={props.chapter} chapters={props.chapters} />

							<MainWrapper>
								<MainContent>
									<MainContentContainer>
										<Article chapter={extractChapter()} />
									</MainContentContainer>
								</MainContent>
							</MainWrapper>

							<StaticBorderBottom />
						</AppContext.Provider>
					</div>
				</body>
			</html>
		);
	}

	function extractChapter():Null<DocChapter> {
		if (props.chapter == null) return props.home;
		return Lambda.find(props.chapters, f -> f.slug == props.chapter);
	}
}
