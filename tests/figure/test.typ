#import "/src/exports.typ": *
#set page(width: 15cm, height: auto)

#let it = [
  One two.
  #figure(
    table[Three][Four][Five],
    caption: [Six seven.]
  )
]
#it
#word-count-of(it).words

#pagebreak()

#let it = [
  One two.
  #figure(
    table[Not][Counted],
    caption: [Three four five.]
  )
]
#it
#word-count-of(it, exclude: "figure-body").words

#pagebreak()

#let it = [
  One two.
  #figure(
    table[Three][Four][Five],
    caption: [Not counted.]
  )
]
#it
#word-count-of(it, exclude: "caption").words

#pagebreak()

#let it = [
  One two.
  #figure(
    table[Nothing][here],
    caption: [is counted.]
  )
]
#it
#word-count-of(it, exclude: figure).words