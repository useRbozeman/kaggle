all: index.html


pandocflags = -s -S -t revealjs -V transition=fade --slide-level 2 --mathjax --parse-raw --include-in-header=custom.css

index.html: index.md ./reveal.js/css/theme/miggy.css custom.css
	pandoc $< -o $@ $(pandocflags)
