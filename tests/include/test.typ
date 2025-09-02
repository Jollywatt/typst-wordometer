#import "/src/lib.typ": *
#set page(width: 15cm, height: auto)

There are #total-words words.

#rect[
  #show: word-count
  One two three four
]


I declare a thumb war

#rect[
  #show: word-count
  Five six seven
]

eight nine ten

#pagebreak()

#let it = rect[
  Start again!
]

#it
#word-count-of(it)