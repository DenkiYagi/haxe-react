import haxe.io.Path;
import js.lib.Promise;
import js.node.Fs.Fs;
import sys.FileSystem;
import sys.io.File;

import data.DocChapter;
import react.ReactDOMServer;
import react.ReactMacro.jsx;

import comp.App;

class StaticGenerator {
	static inline var OUT = "bin/static";

	static function main() {
		FileSystem.createDirectory(OUT);
		for (f in FileSystem.readDirectory(OUT)) FileSystem.deleteFile(Path.join([OUT, f]));

		loadChapters().then(chapters -> {
			chapters.unshift(loadReadme());
			Promise.all(chapters.map(renderChapter)).then(_ -> {
				File.copy('bin/styles.css', '$OUT/styles.css');
				Sys.println('Generated html and css files in $OUT');
			});
		});
	}

	static function renderChapter(chapter:DocChapter):Promise<Void> {
		return new Promise((resolve, reject) -> {
			var slug = chapter.slug == "/" ? null : chapter.slug;
			var path = '$OUT${slug ?? "/index"}.html';
			var fileWriter = Fs.createWriteStream(path);
			var stream = ReactDOMServer.renderToStaticNodeStream(jsx(<App chapter={slug} staticSite />));
			stream.on('end', resolve);
			stream.on('error', resolve);
			stream.pipe(fileWriter);
		});
	}
}
