package;

import react.ReactDOM;
import react.ReactMacro.jsx;
import js.Browser;
import view.TodoApp;

class Main
{
	public static function main()
	{
		var root = ReactDOMClient.createRoot(Browser.document.getElementById('app'));
		root.render(jsx('<$TodoApp/>'));
	}
}
