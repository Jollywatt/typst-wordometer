#import "/src/lib.typ": *
#set page(width: 15cm, height: auto)

#show heading.where(level: 1): it => pagebreak(weak: true) + it + v(1em)

= Basics

#let el = [
	One two _three_ four *five* six.

	== Seven eight

	#box[Nine #h(1fr) ten eleven $ sqrt(#[don’t mind me]) $ twelve.]

	Thirteen #text(red)[fourteen]
	- fifteen
	- sixteen #box(rotate(-5deg)[seventeen])
	- eighteen!
]

#rect(el)
#word-count-of(el)

= More basics

#let el = [
	#stack(
		dir: ltr,
		spacing: 1fr,
		table(columns: 3, [one], [two], [three #super[four]], [#sub[five] six], [seven]),
		rotate(180deg)[eight],
		circle[nine ten],
		
	)

	#figure(circle(fill: red, [eleven]), caption: [twelve thirteen])
]

#rect(el)
#word-count-of(el)
#map-tree(x => x, el)

= Punctuation

#let el = [
	"One *two*, three!" #text(red)[Four], five.
	#rect[Six, *seven*, eight.]
]

#rect(el)

Raw tree: #map-tree(x => x, el)

Stats: #word-count-of(el)

= Scoped counts

#word-count-callback(stats => box(stroke: blue, inset: 1em)[
	Guess what, this box contains #stats.words words!

	Full statistics: #stats
])

#rect[
	#show: word-count

	One two three four. There are #total-words total words and #total-characters characters.

]


= Master function

#word-count(totals => [
	Hello, stats are in! #totals
])

#block(fill: orange.lighten(90%), inset: 1em)[
	#show: word-count

	One two three four. There are #total-words total words and #total-characters characters.

]

= Sentences

#let el = [
	Pour quoi ? Qu'est-ce que c'est !?

	"I don't know anything."

]

#el
#word-count-of(el)
