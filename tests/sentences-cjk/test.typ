#import "/src/lib.typ": *
#set page(width: 15cm, height: auto)

// The CJK characters will not be displayed. Which is expected.
#set text(font: "Libertinus Serif", fallback: false)

#let el = [
	滚滚长江东逝水。

	吾輩は猫である。名前はまだない。

	하늘을 우러러 한 점 부끄럼이 없기를.

	This should be, uhh... *five* sentences.
]

#el
#word-count-of(el)