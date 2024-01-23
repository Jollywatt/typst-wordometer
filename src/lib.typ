#let ZERO_STATS  = (
  characters: 0,
  words: 0,
  sentences: 0,
)

#let fold-stats(a, b) = (
  characters: a.characters + b.characters,
  words: a.words + b.words,
  sentences: a.sentences + b.sentences,
)

#let text-stats(string) = (
  characters: string.replace(" ", "").len(),
  words: string.matches(regex("\b[\w'’]+\b")).len(),
  sentences: string.matches(regex("\w+\s*[.?!]\W*")).len(),
)

/// Simplify an array of content by concatenating adjacent text elements.
/// 
/// Doesn't preserve content exactly; `smartquote`s are replaced with `'` or
/// `"`. This is used on `sequence` elements because it improves word counts for
/// cases like "Digby's", which should count as one word.
///
/// For example, the content #rect[Qu'est-ce *que* c'est !?] is structured as:
/// 
/// #[Qu'est-ce *que* c'est !?].children
/// 
/// This function simplifies this to:
/// 
/// #wordometer.concat-adjacent-text([Qu'est-ce *que* c'est !?].children)
///
/// - children (array): Array of content to simplify.
#let concat-adjacent-text(children) = {
  if children.len() == 0 { return () }
  let squashed = (children.at(0),)

  let as-text(el) = {
    if el.func() == text { el.text }
    else if repr(el.func()) == "space" { " " }
    else if repr(el.func()) == "smartquote" {
      if el.double { "\"" } else { "'" }
    }
  }

  let last-text = as-text(squashed.at(-1))
  for child in children.slice(1) {
    if last-text == none {
        squashed.push(child)
        last-text = as-text(child)

    } else {
      let this-text = as-text(child)
      if this-text == none {
        squashed.push(child)
        last-text = as-text(child)
      } else {
        last-text = last-text + this-text
        squashed.at(-1) = text(last-text)
      }
    }
  }

  squashed
}



#let TEXTUAL_ELEMENTS = (
  "raw",
  "text",
)

#let IGNORED_ELEMENTS = (
  "display",
  "equation",
  "h",
  "hide",
  "image",
  "line",
  "linebreak",
  "locate",
  "metadata",
  "pagebreak",
  "parbreak",
  "path",
  "polygon",
  "repeat",
  "smartquote",
  "space",
  "update",
  "v",
)

/// Traverse a content tree and apply a function to texual leaf nodes.
///
/// Descends into elements until reaching a textual element (`text` or `raw`)
/// and calls `f` on the contained text, returning a (nested) array of all the
/// return values.
///
/// - f (function): Unary function to pass text to.
/// - el (content): Content element to traverse.
#let map-tree(f, el) = {
  
  let fn = repr(el.func())
  let fields = el.fields().keys()

  if fn in IGNORED_ELEMENTS {
    none

  } else if fn in TEXTUAL_ELEMENTS {
    f(el.text)

  } else if "children" in fields {
    let children = el.children

    if fn == "sequence" {
      // don't do this for, e.g., grid or stack elements
      children = concat-adjacent-text(children)
    }

    children
      .map(map-tree.with(f))
      .filter(x => x != none)

  } else if fn == "figure" {
    (map-tree(f, el.body), map-tree(f, el.caption))

  } else if fn == "styled" {
    map-tree(f, el.child)

  } else if "body" in fields {
    map-tree(f, el.body)

  } else {
    panic(fn, el.fields())

  }

}

/// Get word count statistics of a content element.
///
/// Returns a results dictionary, not the content passed to it.
///
/// - el (content):
/// -> dictionary
#let word-count-of(el) = {
  (map-tree(text-stats, el),)
    .flatten()
    .filter(x => x != none)
    .fold(ZERO_STATS, fold-stats)
}

/// Simultaneously take a word count of some content and insert it into that
/// content.
/// 
/// It works by first passing in some dummy results to `fn`, performing a word
/// count on the content returned, and finally returning the result of passing
/// the word count retults to `fn`. This happens once --- it doesn't keep
/// looping until convergence or anything!
///
/// For example:
/// ```typst
/// #word-count-callback(stats => [There are #stats.words words])
/// ```
///
/// - fn (function): A function accepting a dictionary and returning content to
///  perform the word count on.
#let word-count-callback(fn) = {
  let preview-content = [#fn(ZERO_STATS)]
  let stats = word-count-of(preview-content)
  fn(stats)
}

#let total-words = locate(loc => state("total-words").final(loc))
#let total-characters = locate(loc => state("total-characters").final(loc))

/// Get word count statistics of some content and store the results is a global
/// state.
///
/// #set raw(lang: "typ")
///
/// The results are accessible anywhere in the document with `#total-words` and
/// `#total-characters`.
///
/// - el (content):
#let set-word-count-state(el) = {
  let stats = word-count-of(el)
  state("total-words").update(stats.words)
  state("total-characters").update(stats.characters)
  el
}

/// Perform a word count.
/// 
/// Accepts content (in which case results are accessible with `#total-words`
/// and `#total-characters`) or a callback function (see
/// `word-count-callback()`).
///
/// Passing content only works if you do it once in your document, because the
/// results are stored in a global state. For multiple word counts, use the
/// callback style.
/// - arg (content, fn):
#let word-count(arg) = {
  if type(arg) == function {
    word-count-callback(arg)
  } else {
    set-word-count-state(arg)
  }
}