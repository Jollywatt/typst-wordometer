# `wordometer`

[![Manual](https://img.shields.io/badge/docs-manual.pdf-green)](docs/manual.pdf)
![Version](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fgithub.com%2FJollywatt%2Ftypst-wordometer%2Fraw%2Fmaster%2Ftypst.toml&query=package.version&label=latest%20version)
[![Repo](https://img.shields.io/badge/GitHub-repo-blue)](https://github.com/Jollywatt/typst-wordometer)




A small [Typst]("https://typst.app/") package for quick and easy in-document word counts.


## Basic usage

```typ
#import "@preview/wordometer:0.1.5": word-count, total-words

#show: word-count

In this document, there are #total-words words all up.

#word-count(total => [
  The number of words in this block is #total.words
  and there are #total.characters letters.
])
```

## Excluding elements

You can exclude elements by name (e.g., `"caption"`), function (e.g., `figure.caption`), where-selector (e.g., `raw.where(block: true)`), or label (e.g., `<no-wc>`).


```typ
#show: word-count.with(exclude: (heading.where(level: 1), strike))

= This Heading Doesn't Count
== But I do!

In this document #strike[(excluding me)], there are #total-words words all up.

#word-count(total => [
  You can exclude elements by label, too.
  #[That was #total.words, excluding this sentence!] <no-wc>
], exclude: <no-wc>)
```

## Changelog

### v0.1.5

- Count CJK characters as one word each (#9)

### v0.1.4

- Fix deprecated use of `locate()` for Typst `>=0.12.0`

### v0.1.3

(No changes 🤡)

### v0.1.2

- Fix bugs when using labels and where-selectors to exclude elements

### v0.1.1

- Allow excluding elements by passing their element functions
- Add basic `element.where(..)` selectors
- Fix crash for figures without captions

### v0.1.0

- Initial version