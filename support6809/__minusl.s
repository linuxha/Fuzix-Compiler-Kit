;
;	Until we sort out optimizing this in the compiler proper
;
	.export __minusl
	.code

__minusl:
	; Subtract Y:D from TOS
	std ,--s
	sty ,--s
	ldd 6,s		; low
	subd 2,s	; - low
	ldd 4,s
	sbcb 1,s
	sbca 0,s
	ldx 4,s
	leas 8,s
	rts
