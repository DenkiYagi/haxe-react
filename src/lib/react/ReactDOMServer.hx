package react;

import js.html.AbortSignal;
import js.lib.Promise;
import react.ReactNode;

#if nodejs
import js.node.stream.Readable;
import js.node.stream.Writable;
#end

/**
	The `ReactDOMServer` APIs let you render React components to HTML on the
	server. These APIs are only used on the server at the top level of your app to
	generate the initial HTML. Most of your components don’t need to import or use them.

	https://react.dev/reference/react-dom/server
**/
#if (!react_global)
@:jsRequire('react-dom/server')
#end
@:native('ReactDOMServer')
extern class ReactDOMServer {
	/**
		Note: `renderToString` does not support streaming or waiting for data.
		See the alternatives.

		https://react.dev/reference/react-dom/server/renderToString
	**/
	public static function renderToString(node:ReactNode):String;

	/**
		`renderToStaticMarkup` renders a non-interactive React tree to an HTML
		string.

		Notes:
		- `renderToStaticMarkup` output cannot be hydrated.
		- `renderToStaticMarkup` has limited `Suspense support`. If a component
		  suspends, `renderToStaticMarkup` immediately sends its fallback as HTML.

		https://react.dev/reference/react-dom/server/renderToStaticMarkup
	**/
	public static function renderToStaticMarkup(node:ReactNode):String;

	#if nodejs
	/**
		`renderToPipeableStream` renders a React tree to a pipeable Node.js Stream.

		Note: This API is specific to Node.js.
		Environments with Web Streams should use `renderToReadableStream` instead.

		https://react.dev/reference/react-dom/server/renderToPipeableStream
	**/
	public static function renderToPipeableStream(node:ReactNode, options:{
		?bootstrapScriptContent:String,
		?bootstrapScripts:Array<String>,
		?bootstrapModules:Array<String>,
		?identifierPrefix:String,
		?namespaceURI:String,
		?nonce:String,
		?onAllReady:Void->Void,
		?onError:Any->Void,
		?onShellReady:Void->Void,
		?onShellError:Any->Void,
		?progressiveChunkSize:Int
	}):{
		pipe:IWritable->Void,
		abort:Void->Void
	}

	/**
		`renderToStaticNodeStream` renders a non-interactive React tree to a
		Node.js Readable Stream.

		Notes:
		- `renderToStaticNodeStream` output cannot be hydrated.
		- This method will wait for all `Suspense` boundaries to complete before
		  returning any output.
		- As of React 18, this method buffers all of its output, so it doesn't
		  actually provide any streaming benefits.
		- The returned stream is a byte stream encoded in utf-8

		https://react.dev/reference/react-dom/server/renderToStaticNodeStream
	**/
	public static function renderToStaticNodeStream(node:ReactNode):IReadable;

	/**
		https://react.dev/reference/react-dom/server/renderToNodeStream
	**/
	@:deprecated("Use renderToPipeableStream instead")
	public static function renderToNodeStream(node:ReactNode):IReadable;
	#else
	/**
		`renderToReadableStream` renders a React tree to a Readable Web Stream.

		Note: This API depends on Web Streams.
		For Node.js, use `renderToPipeableStream` instead.

		https://react.dev/reference/react-dom/server/renderToReadableStream
	**/
	public static function renderToReadableStream(node:ReactNode, options:{
		?bootstrapScriptContent:String,
		?bootstrapScripts:Array<String>,
		?bootstrapModules:Array<String>,
		?identifierPrefix:String,
		?namespaceURI:String,
		?nonce:String,
		?onError:Any->Void,
		?progressiveChunkSize:Int,
		?signal:AbortSignal
	}):Promise<Dynamic /* TODO needs to extend non existing haxe std ReadableStream */>;
	#end
}
