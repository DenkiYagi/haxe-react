import haxe.Json;
import haxe.http.HttpStatus;
import haxe.io.Mime;
import haxe.io.Path;
import js.node.Fs;
import js.node.Http;
import js.node.http.IncomingMessage;
import js.node.http.ServerResponse;

import react.ReactDOMServer;
import react.Suspense;
import react.ReactMacro.jsx;

import comp.App;

using StringTools;

class Main {
	static inline var PORT = 8042;
	static inline var HOST = '0.0.0.0';

	static function main() {
		final app = Http.createServer({}, handler);
		app.listen(PORT, HOST, () -> {
			Sys.println('Server ready, waiting on $HOST:$PORT');
		});
	}

	static function handler(req:IncomingMessage, res:ServerResponse):Void {
		function sendFile(path:String) {
			return Fs.readFile(path, function(err, data) {
				if (err != null) {
					res.writeHead(HttpStatus.NotFound);
					return res.end(Json.stringify(err));
				}

				var mimeType:Null<Mime> = switch Path.extension(path) {
					case 'css': TextCss;
					case 'png': ImagePng;
					case _: null; // TODO: handle more needed extensions
				}

				if (mimeType != null) res.setHeader("Content-Type", mimeType);
				res.writeHead(HttpStatus.OK);
				return res.end(data);
			});
		}

		if (req.url.endsWith(".css") || req.url.endsWith(".png")) {
			var path = Path.join(["bin", req.url.substr(1)]);
			sendFile(path);
		} else {
			var chapter = req.url == "/" ? null : req.url;
			var stream = ReactDOMServer.renderToStaticNodeStream(jsx(<App chapter={chapter} />));
			stream.pipe(res);
		}
	}
}
