#import "@preview/tidy:0.1.0"
#import "/src/lib.typ" as wordometer: *

#set page(numbering: "1")
#set par(justify: true)
#show link: underline.with(stroke: blue.lighten(50%))

#let VERSION = toml("/typst.toml").package.version

#let show-module(path) = {
	show heading.where(level: 3): it => {
		align(center, line(length: 100%, stroke: black.lighten(70%)))
		block(text(1.3em, raw(it.body.text + "()")))
	}
	tidy.show-module(
		tidy.parse-module(
			read(path),
			scope: (wordometer: wordometer)
		),
		show-outline: false,
	)
}



#v(.2fr)

#align(center)[
	#stack(
		spacing: 12pt,
		text(2.7em, `wordometer`),
	)

	#v(30pt)

	A small #link("https://typst.app/")[Typst] package for quick and easy in-document word counts.

	#link("https://github.com/Jollywatt/typst-wordometer")[`github.com/Jollywatt/typst-wordometer`]

	Version #VERSION
]

#set raw(lang: "typc")


#v(1fr)

= Basic usage

```typ
#import "@preview/wordometer:0.1.0": word-count, total-words

#show: word-count

In this document, there are #total-words words all up.

#word-count(total => [
  The number of words in this block is #total.words
  and there are #total.characters letters.
])
```



#v(1fr)

#pagebreak()


#show-module("/src/lib.typ")