#import "/src/exports.typ": *
#set page(width: 15cm, height: auto)

#let c = [
	Hello, what is your name?
].children

#c

#utils.concat-adjacent-text(c)

#let c = [
	A want this to be separate. #[From this.] <some-label> Not this either.
].children
#c

#utils.concat-adjacent-text(c)
