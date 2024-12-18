;
;	Multiply 3,x by sreg:d
;
;
;	Stack on entry
;
;	3-7,x	Argument
;
;
		.export __mull
		.export __mulul

		.code

__mull:
__mulul:
	pshx
	pshx			; working space ,x->3,x
				; moves argument to 6-9,x
	std	@tmp
	tsx
;
;	Do 32bit x low 8bits
;	This gives us a 32bit result plus 8bits discarded
;
	ldaa	9,x
	ldab	@tmp+1
	mul			; calculate low 8 and overflow
	std	2,x		; fill in low 16bits
	ldaa	8,x
	ldab	@tmp+1
	mul
	addb	2,x		; next 16 bits plus carry
	adca	#0
	std	1,x		; and save
	ldaa	7,x
	ldab	@tmp+1
	mul
	addb	1,x		; next 16bits plus carry
	adca	#0
	std	,x		; and save
	ldaa	6,x
	ldab	@tmp+1
	mul			; top 8bits (and overflow is lost)
	addb	,x
	stab	,x
;
;	Now repeat this with the next 8bits but we only need to do 24bits
;	as the top 8 will overflow
;
	ldaa	9,x
	ldab	@tmp
	mul
	addb	2,x		; add in the existing
	adca	1,x
	std	1,x
	bcc	norip16
	inc	,x		; carry into the top byte
norip16:
	ldaa	8,x
	ldab	@tmp	; again
	mul
	addb	1,x
	adca	,x
	std	,x
	ldaa	7,x
	ldab	@tmp
	mul
	addb	,x
	stab	,x	; rest overflows, all of top byte overflows
;
;	Now repeat for the next 8bits but we only need to do 16bit as the
;	top 16 will overflow. Spot a 16bit zero and short cut as this
;	is common (eg for uint * ulong cases)
;
	xgdy		; again (b = sreg + 1)
	ldaa	9,x
	mul
	addb	1,x
	adca	,x
	std	,x
	xgdy
	ldaa	8,x
	mul
	addb	,x
	stab	,x	; rest overflows, all of top byte overflows
;
;	And finally the top 8bits so almost everything overflows
;
	xgdy
	tsta
	beq	is_done
	ldab	9,x
	mul
	addb ,x
	stab ,x		; rest overflows, all of top byte overflows
;
;	Into our working register
;
is_done:
	puly
	pula
	pulb
	pulx
	ins
	ins
	ins
	ins
	jmp ,x
