.SILENT:

setup:
	haxelib newrepo
	haxelib dev react-next ../..
	haxelib install --skip-dependencies --always install.hxml
	npm i

server:
	node bin/server.js

static:
	haxe build-static.hxml
	node bin/static-gen.js

serve-static:
	cd bin/static && python -m http.server 8043
