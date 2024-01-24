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
    let fn = repr(el.func())
    if fn == "text" { el.text }
    else if fn == "space" { " " }
    else if fn in "linebreak" { "\n" }
    else if fn in "parbreak" { "\n\n" }
    else if fn in "pagebreak" { "\n\n\n\n" }
    else if fn == "smartquote" {
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
/// - exclude (array): List of labels or element names to skip while traversing
///  the tree. Default value includes equations and elements without child
///  content or text:
///  #wordometer.IGNORED_ELEMENTS.sorted().map(repr).map(raw).join([, ],
///  last: [, and ]).
///
///  To exclude figures, but include figure captions, pass the name
///  `"figure-body"` (which is not a real element). To include figure bodies,
///  but exclude their captions, pass the name `"caption"`.
#let map-tree(f, el, exclude: IGNORED_ELEMENTS) = {
  let map-subtree = map-tree.with(f, exclude: exclude)
  
  let fn = repr(el.func())
  let fields = el.fields().keys()

  if fn in exclude {
    none

  } else if el.at("label", default: none) in exclude {
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
      .map(map-subtree)
      .filter(x => x != none)

  } else if fn == "figure" {
    (
      if "figure-body" not in exclude { map-subtree(el.body) },
      map-subtree(el.caption),
    )
      .filter(x => x != none)

  } else if fn == "styled" {
    map-subtree(el.child)

  } else if "body" in fields {
    map-subtree(el.body)

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
/// - exclude (array): Content elements to exclude from word count (see
///    `map-tree()`).
#let word-count-of(el, exclude: (:)) = {
  let exclude-elements = IGNORED_ELEMENTS
  exclude-elements += (exclude,).flatten()

  (map-tree(text-stats, el, exclude: exclude-elements),)
    .filter(x => x != none)
    .flatten()
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
/// - ..options ( ): Additional named arguments:
///   - `exclude`: Content to exclude from word count (see `map-tree()`).
/// -> content
#let word-count-callback(fn, ..options) = {
  let preview-content = [#fn(ZERO_STATS)]
  let stats = word-count-of(preview-content, ..options)
  fn(stats)
}

#let total-words = locate(loc => state("total-words").final(loc))
#let total-characters = locate(loc => state("total-characters").final(loc))

/// Get word count statistics of the given content and store the results in
/// global state. Should only be used once in the document.
///
/// #set raw(lang: "typ")
///
/// The results are accessible anywhere in the document with `#total-words` and
/// `#total-characters`, which are shortcuts for the final values of states of
/// the same name (e.g., `#locate(loc => state("total-words").final(loc))`)
///
/// - el (content):
///   Content to word count.
/// - ..options ( ): Additional named arguments:
///   - `exclude`: Content to exclude from word count (see `map-tree()`).
/// -> content
#let word-count-global(el, ..options) = {
  let stats = word-count-of(el, ..options)
  state("total-words").update(stats.words)
  state("total-characters").update(stats.characters)
  el
}

/// Perform a word count.
/// 
/// Accepts content (see `word-count-global()`) or a callback function (see
/// `word-count-callback()`).
/// - arg (content, fn):
///   Can be:
///   #set raw(lang: "typ")
///   - `content`: A word count is performed for the content and the results are
///    accessible through `#total-words` and `#total-characters`. This uses a
///    global state, so should only be used once in a document (e.g., via a
///    document show rule: `#show: word-count`).
///   - `function`: A callback function accepting a dictionary of word count
///    results and returning content to be word counted. For example:
///    ```typ
///    #word-count(total => [This sentence contains #total.characters letters.])
///    ```
/// - ..options ( ): Additional named arguments:
///   - `exclude`: Content to exclude from word count (see `map-tree()`).
#let word-count(arg, ..options) = {
  if type(arg) == function {
    word-count-callback(arg, ..options)
  } else {
    word-count-global(arg, ..options)
  }
}