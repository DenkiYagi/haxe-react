package data;

import js.lib.Promise;
import js.node.Fs.Fs;
import sys.FileSystem;
import sys.io.File;

import markdown.AST;
import yaml.Yaml;
import yaml.util.ObjectMap;

using StringTools;
using haxe.io.Path;

typedef DocChapter = {
	var slug:String;
	var order:Null<Int>;
	var title:Null<String>;
	var parse:Void->String;
}

function sortChapters(chapters:Array<DocChapter>):Array<DocChapter> {
	chapters.sort((c1, c2) -> {
		if (c1.order == null && c2.order == null)
			return c1.title > c2.title ? 1 : -1;

		if (c1.order == null) return 1;
		if (c2.order == null) return -1;
		return c1.order - c2.order;
	});

	return chapters;
}

function loadChapters():Promise<Array<DocChapter>> {
	return new Promise((resolve, reject) -> {
		Fs.readdir("../../doc", (err, files) -> {
			var chapters = (files ?? [])
				.map(f -> loadChapter(Path.join(["..", "..", "doc", f])))
				.filter(f -> f != null);

			resolve(sortChapters(chapters));
		});
	});
}

function loadReadme():Null<DocChapter> {
	var ret = loadChapter(Path.join(["..", "..", "README.md"]));
	if (ret != null) ret.slug = '/';
	return ret;
}

function loadChapter(path:String):Null<DocChapter> {
	if (!FileSystem.exists(path)) return null;
	if (!path.endsWith(".md")) return null;

	var file = path.withoutDirectory();
	var slug = file.withoutExtension();

	var order:Null<Int> = null;
	var md:Null<Array<Node>> = null;
	var title:Null<String> = null;
	var content = File.getContent(path);

	if (content.startsWith("---\n")) {
		var yamlLines = [];
		var lines = content.split("\n");
		lines.shift(); // Remove first "---" line

		var line = lines.shift();
		while (line != null) {
			if (line == "---") break;
			yamlLines.push(line);
			line = lines.shift();
		}

		if (lines.length > 0 && lines[0].trim() == "") lines.shift();
		content = lines.join("\n");

		var yaml:ObjectMap<String, String> = Yaml.parse(yamlLines.join("\n"));
		for (k in yaml.keys()) {
			var strVal:String = yaml.get(k);
			switch (k) {
				case "title": title = strVal;
				case "order": order = Std.parseInt(strVal);
				case _:
			}
		}
	}

	// Get title from markdown if needed
	if (title == null) {
		md = Markdown.markdownToAst(content);

		for (node in md) {
			if (node is ElementNode) {
				var el:ElementNode = cast node;
				if (el.tag == "h1" || el.tag == "h2") {
					var htmlTitle = Markdown.renderHtml(el.children);
					// TODO: sanitize title
					title = htmlTitle;
					break;
				}
			}
		}
	}

	return {
		slug: '/' + slug,
		order: order,
		title: title,
		parse: () -> Markdown.renderHtml(md ?? Markdown.markdownToAst(content))
	};
}
