#import "/src/lib.typ": *
#set page(width: 20cm, height: auto)

// The CJK characters will not be displayed. Which is expected.
#set text(font: "Libertinus Serif", fallback: false)

#word-count.with(exclude: raw)(totals => [
	Hello，这里是中文测试。
	#totals
], )

#word-count.with(exclude: raw)(totals => [
	Hello，這裡是中文測試。
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

	一二三四五 six seven eight. 这句话里共有 #total-words 个词与 #total-characters 个字符。
]
