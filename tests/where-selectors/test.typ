#import "/src/lib.typ": *
#set page(width: 15cm, height: auto)

#let el = [
	
	== One
	=== Not me!
	==== Two three four five

]
#el

#rect(el)
#word-count-of(el, exclude: heading.where(level: 3)))