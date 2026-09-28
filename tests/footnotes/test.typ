#import "/src/exports.typ": *
#set page(width: 15cm, height: auto)
#show: word-count

In this document, there are #total-words words all up.

#word-count(total => [
  The number of words in this block is #total.words
  and there are #total.characters letters.
])

Test #footnote[This is a test] <test>.

We use the footnote again #footnote(<test>).