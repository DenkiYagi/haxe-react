import react.React;
import react.ReactComponent;
import react.ReactContext;
import react.ReactMacro.jsx;
import react.ReactType;

typedef AppContextData = {
	var staticSite:Bool;
}

typedef AppContextProviderProps = {
	var value:AppContextData;
}

typedef AppContextConsumerProps = {
	var children:AppContextData->ReactFragment;
}

class AppContext {
	public static var Context(get, null):ReactContext<AppContextData>;
	public static var Provider(get, null):ReactTypeOf<AppContextProviderProps>;
	public static var Consumer(get, null):ReactTypeOf<AppContextConsumerProps>;

	static function get_Context() {ensureReady(); return Context;}
	static function get_Provider() {ensureReady(); return Provider;}
	static function get_Consumer() {ensureReady(); return Consumer;}

	static function ensureReady() @:bypassAccessor {
		if (Context == null) {
			Context = React.createContext();
			Context.displayName = "AppContext";
			Consumer = Context.Consumer;
			Provider = Context.Provider;
		}
	}

	public static function wrap(Comp:ReactType):ReactType {
		return function (props:{}) {
			return jsx(
				<Consumer>
					{value ->
						<Comp {...props} staticSite={value.staticSite} />
					}
				</Consumer>);
		}

	}
}
