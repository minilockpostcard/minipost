default: index.html write.html unlock.html

index.html: miniLockLib.js minipost.js stylesheets/*.css
	echo '<!DOCTYPE HTML><meta charset="UTF-8">' > index.html
	echo '<title>miniLock Postcard</title>' >> index.html
	echo '<meta name="viewport" content="width=1220">' >> index.html
	echo '<link rel="icon" type="image/png" href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAACL0lEQVRYCe1WP2hTcRC+e75UsIiDoKCLIFhBKGj/JIUOhe6dHHxtfehUKE6iIJ26CXVwcFbapCZiN2eHDlITmlqwqHQT/LOItApWIenvvCiXd69y8aUZurwH4e6+u/t+37u8vBxAeh3wBHA/54/ArH86e+6K5+FlJLhEgCcBaZu5NsnBM7fjHhY3JraScLctYCK7mPM8f54be6wDCGgLHdzKV4JHVo3gbQmYzJXGPMSn3HxYCFpZcnS3UAlmWtUkFhAMFC/4h7CCiN0RIf0igiqTbDB2hj+DgHg8yrNH7lq+PL4Qw1SQWEA4VHoOgKPSS0TLNYDrT8rBe8Gu9ua76UjXnIcwLRgQff1Z+352aW3qWxNTTiIBYX/pImTwlfTxd7z+4eXm4DLM1gXTNsyVHvAkbgjGYm8WysF9ibX1dGD5zocxnXP13Snr8EYd7dTusPmiemL9CodEAhDwvGrafrw6WVXxP27hdfiDp7QiiT39Av+xiQTwb/yEdDHxW/ZJYsvy++FNlIv6I+yv5+8FJA76iuqu8ajg/CBm4rkooz1CONZ8wBDNGzUFZLq8d5pQfCYdsHJS0441lbVD0kltKiCdQDqBdALpBOwJEHzq5BWre3kh+ahj7ZsCCKnlf74m+a+PsGbV2ALqMMf7nLMaE+PMQQ0u4zIFLK4GK3z6TEci+PAGR4PLOB+aO4NVEGaLw7xg3ubKfl5GTll1cZw+885UZfH38pXxF/FcGsUn8BsTVaY4f4KXygAAAABJRU5ErkJggg==">' >> index.html
	echo '<!-- Review source code at https://github.com/minilockpostcard/minipost/tree/deploy -->' >> index.html
	echo '<script src="miniLockLib.js" charset="UTF-8"></script>' >> index.html
	echo '<script src="minipost.js" charset="UTF-8"></script>' >> index.html
	echo '<h1 aria-live="polite"></h1>' >> index.html
	echo '<style>' >> index.html
	cat stylesheets/zero.css >> index.html
	cat stylesheets/basics.css >> index.html
	cat stylesheets/typefaces.css >> index.html
	cat stylesheets/postcard.css >> index.html
	cat stylesheets/outputs.css >> index.html
	cat stylesheets/index.css >> index.html
	cat stylesheets/write.css >> index.html
	cat stylesheets/unlock.css >> index.html
	cat stylesheets/paint.css >> index.html
	echo '</style>' >> index.html

unlock.html: index.html
	cp index.html unlock.html

write.html: index.html
	cp index.html write.html

minipost.js: zepto.js underscore.js backbone.js minipost.coffee views/HTML.stamps.coffee models/*.coffee views/*.coffee
	rm -f minipost.js
	cat zepto.js >> minipost.js
	echo ";\n" >> minipost.js
	cat underscore.js >> minipost.js
	echo ";\n" >> minipost.js
	cat backbone.js >> minipost.js
	echo ";\n" >> minipost.js
	browserify --transform coffeeify minipost.coffee >> minipost.js

backbone.js:
	cp node_modules/backbone/backbone.js backbone.js

miniLockLib.js: node_modules/miniLockLib.js
	cp node_modules/miniLockLib.js miniLockLib.js

node_modules/miniLockLib.js:
	curl https://45678.github.io/miniLockLib/miniLockLib.js > node_modules/miniLockLib.js

underscore.js:
	cp node_modules/underscore/underscore.js underscore.js

zepto.js: node_modules/zepto.js
	cp node_modules/zepto.js zepto.js

node_modules/zepto.js:
	curl https://madrobby.github.io/zepto/zepto.js > node_modules/zepto.js

views/HTML.stamps.coffee:
	make $(subst .svg,.coffee,$(wildcard stamps/*.svg))
	cat stamps/*.coffee > $@

stamps/%.coffee: stamps/%.svg
	echo module.exports[\"$(basename $(@F))\"] = \"\"\" > '$@'
	cat '$<' \
		| sed 's/<?xml version="1.0" encoding="UTF-8" standalone="no"?>//' \
		| sed 's/ sketch:type="MSPage"//' \
		| sed 's/ sketch:type="MSArtboardGroup"//' \
		| sed 's/ sketch:type="MSShapeGroup"//' \
		| sed 's/<desc>Created with Sketch.<\/desc>//' \
		| sed 's/ id="radialGradient/ preserve-id="radialGradient/' \
		| sed 's/ id=/ class=/' \
		| sed 's/ preserve-id=/ id=/' \
		| sed 's/radialGradient-/$(basename $(@F))-radialGradient-/' \
		| grep '<' \
		>> '$@'
	echo \"\"\" >> '$(basename $@).coffee'

clean:
	rm -f *.html
	rm -f *.js
	rm -f stamps/*.coffee
	rm -f views/HTML.stamps.coffee

repo:
	rm -rf .git
	git init
	git config user.name "45678"
	git config user.email "undefined@undefined"
	make views/HTML.stamps.coffee
	git add --all
	git commit --message "INIT master branch"
	git checkout -b deploy
	rm .gitignore
	echo "node_modules" >> .gitignore
	echo "stamps" >> .gitignore
	git add .gitignore
	git commit --message "INIT deploy branch"
	git checkout master
	git remote add origin git@github.com:minilockpostcard/minipost.git
	git remote add minipost.site core@minipost.site:spaces/minipost.site.git
	git remote add minilockpostcard.site core@minilockpostcard.site:spaces/minilockpostcard.site.git
	git remote add minilockpostcard.github.io git@github.com:minilockpostcard/minilockpostcard.github.io.git
	git branch

deploy:
	git checkout master
	git checkout deploy
	git merge master
	make index.html unlock.html write.html
	git add --all
	git commit --message "Comitted after merge with 'make deploy'"
	git checkout master

nodes:
	make minilockpostcard.github.io
	make minilockpostcard.site
	make minipost.site
	make deploy_mirror

deploy_mirror:
	git push origin deploy

minipost.site:
	ssh core@minipost.site "mkdir -p spaces/minipost.site; git init --bare spaces/minipost.site.git"
	scp minipost.site.git-post-receive-hook core@minipost.site:spaces/minipost.site.git/hooks/post-receive
	ssh core@minipost.site "chmod +x spaces/minipost.site.git/hooks/post-receive"
	git push minipost.site deploy

minilockpostcard.site:
	ssh core@minilockpostcard.site "mkdir -p spaces/minilockpostcard.site; git init --bare spaces/minilockpostcard.site.git"
	scp minilockpostcard.site.git-post-receive-hook core@minilockpostcard.site:spaces/minilockpostcard.site.git/hooks/post-receive
	ssh core@minilockpostcard.site "chmod +x spaces/minilockpostcard.site.git/hooks/post-receive"
	git push minilockpostcard.site deploy

minilockpostcard.github.io:
	git push minilockpostcard.github.io deploy deploy:master

pow:
	mkdir -p ~/.pow/minipost
	ln -s $(PWD) ~/.pow/minipost/public

unlink_pow:
	rm -rf ~/.pow/minipost
