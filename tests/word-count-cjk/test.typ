#import "/src/exports.typ": *
#set page(width: 16cm, height: auto)
#set text(font: (
  "Noto Serif JP",
  "Noto Serif SC",
  "Noto Serif KR",
))

// Word counts don't make much sense for SC/JP without tokenizing,
// so we just treat each character as a word...

#word-count.with(exclude: raw)(totals => [
	这里是中文测试。
	#totals
], )

#word-count.with(exclude: raw)(totals => [
	這裡是中文測試。
	#totals
])

#word-count.with(exclude: raw)(totals => [
	これは日本語のひらがなとカタカナです。
	#totals
])

#word-count.with(exclude: raw)(totals => [
	안녕하세요, 여기는 한국어 테스트입니다.
	#totals
])

#block(fill: orange.lighten(90%), inset: 1em)[
  #show: word-count

  一二三四五 six seven eight. 这句话里共有 #total-words 个词与 #total-characters 个字符.
	一二三四五 six seven eight. 这句话里共有 #total-words 个词与 #total-characters 个字符。
]
