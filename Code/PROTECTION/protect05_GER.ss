����  >  �  :  a  �  2  ;�  -~  'A  +q
;	*************************************************
;	*	      Cytadela Protection		*
;	*    Re-Coded on 14.06.1995  by KANE of SUSPECT	*
;	*************************************************
;save: wb st en

EXE:	equ	0
LAN:	equ	2

IFNE	EXE
BASE:		equ	$000000
SH:		equ	$100000
ELSE
BASE:		equ	$100000
SH:		equ	0
ENDC

VBR_BASE:	equ	BASE+$7ffee
HASLO:		equ	BASE+$7ffce

TTL		CYTADELA_PROTECTION
ALL:		REG	d0-a6
VBLANK:		MACRO
		cmpi.b	#$ff,6(a0)
		bne.s	*-6
		cmpi.b	#$ff,6(a0)
		beq.s	*-6
		ENDM

		org	BASE+$5a000
		load	BASE+$5a000+SH


s:		bra.w	ss
TEXT
                                                 
 If you wanna crack this, just wait a moment and think!
 Do you want to do this to proove that you are the best, to
 gain fame, money or what? This way you are only destroying
 the AMIGA market! STOP! DON'T DO THIS! Mind that if we don't
 stop this, one day YOUR game may be cracked! So PLEASE DON'T DO THIS!
  Signed: Pawel Matusz, the game programmer, known as KANE / SUSPECT PL
...                                                               
ETEXT
even

ss:		IFEQ	EXE
		move.l	#0,VBR_base
		ENDC

		lea	$dff000,a0
		VBLANK
		move	#$7fff,$96(a0)
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		move	#$00ff,$9e(a0)		;ADKONR
		lea	copper0(pc),a1
		move.l	a1,$80(a0)
		move	#0,$88(a0)

		VBLANK
		lea	HIREScopper(pc),a1
		move.l	a1,$80(a0)
		move	#0,$88(a0)
		move.l	VBR_base,a1
		IFEQ	EXE
		lea	OldLev3(pc),a2
		move.l	$6c(a1),(a2)		;set lev3 interrupt
		lea	OldLev2(pc),a2
		move.l	$68(a1),(a2)		;set lev2 key interrupt
		ENDC
		lea	NewLev3(pc),a2
		move.l	a2,$6c(a1)
		lea	NewLev2(pc),a2
		move.l	a2,$68(a1)
		bsr	Random
		moveq	#0,d1
		move.b	d0,d1
		add	d1,d1
		add	d1,d1
eee:		nop
		dbf	d1,eee
		bsr	Random
		move.b	d0,ran
		VBLANK
		move	#$8380,$96(a0)
		move	#$c028,$9a(a0)

		bsr	clr1
		bsr	clr2
		bsr	clr3
		bsr	SetColors
;---------------
PasswordLoop:	bsr	Random
		andi	#7,d0
		move	d0,pos			;strona
		addi	#$31,d0
		move.b	d0,strona

		bsr	Random
		andi.l	#15,d0
		move	d0,pos+2		;litera
		addq	#1,d0
		divu	#10,d0
		tst	d0
		bne.s	pl2			;nie 0
		move.b	#" ",litera
		bra.s	pl3
pl2:		addi	#$30,d0
		move.b	d0,litera
pl3:		swap	d0
		addi	#$30,d0
		move.b	d0,litera+1


		bsr	clr1
		bsr	clr2
		lea	tekst(pc),a1
		lea	scr1(pc),a2
		bsr	p_PRINT
		lea	scr2+[20*86],a3
		move.b	#-1,(a3)

KeyLoop:	tst	klawisz
		beq.s	KeyLoop
		move	Klawisz,d0
		move	#0,Klawisz

		cmpi	#$77,d0			;return
		beq.w	Sprawdzaj
		cmpi	#$7d,d0			;delete
		bne.s	NieDel
		lea	buf(pc),a1
		moveq	#0,d2
		move.b	(a1)+,d2		;bufor CNT
		beq.s	KeyLoop
		lea	scr2+[20*86],a3
		move.b	#0,(a3,d2.w)
		subq	#1,d2
		move.b	#-1,(a3,d2.w)
		move.b	#-1,(a1,d2.w)
		move.b	d2,-1(a1)
		bra.s	Druk

NieDel:		lea	KEYtab(pc),a1
		moveq	#-1,d1
k1:		addq	#1,d1			;find key in key_tab
		move.b	(a1)+,d2
		beq.s	KeyLoop
		cmp.b	d2,d0
		bne.s	k1

		lea	buf(pc),a1
		moveq	#0,d2
		move.b	(a1)+,d2		;bufor CNT
		cmpi	#8,d2
		beq.s	KeyLoop			;bufor full

		lea	scr2+[20*86],a3
		move.b	#0,(a3,d2.w)

		lea	ASCIItab(pc),a2
		move.b	(a2,d1.w),(a1,d2.w)	;ASCII code
		move.b	d0,8(a1,d2.w)		;key code
		addq	#1,d2
		move.b	d2,-1(a1)

		move.b	#-1,(a3,d2.w)

druk:		movem.l	ALL,-(sp)
		bsr	clr2
		lea	scr2(pc),a2
		bsr	p_PRINT
		movem.l	(sp)+,ALL
		bra.w	KeyLoop

Sprawdzaj:	lea	buf(pc),a1		;sprawdz czy dobrze
		moveq	#0,d2
		move.b	(a1)+,d2
		cmpi	#5,d2			;czy 5 liter?
		bne.s	BLAD
		lea	8(a1),a1

		moveq	#0,d0
		move	pos+2(pc),d0
		divu	#5,d0
		swap	d0
		moveq	#4,d1
		subi	d0,d1
		lea	kopia1-100(pc),a2	;kopia hasla
		move.b	(a1),100(a2)
		move.b	1(a1),101(a2)
		move.b	2(a1),102(a2)
		move.b	3(a1),103(a2)
		move.b	4(a1),104(a2)
		move.b	#$7f,(a1,d1.w)		;potrzebna spacja

		move	pos(pc),d0
		mulu	#41,d0
		addi	pos+2(pc),d0
		lea	tablica(pc),a2
		lea	(a2,d0.w),a2

		move.b	(a1)+,d0
		cmp.b	(a2)+,d0
		bne.s	BLAD
		move.b	(a1)+,d0
		cmp.b	(a2)+,d0
		bne.s	BLAD
		move.b	(a1)+,d0
		cmp.b	(a2)+,d0
		bne.s	BLAD
		move.b	(a1)+,d0
		cmp.b	(a2)+,d0
		bne.s	BLAD
		move.b	(a1)+,d0
		cmp.b	(a2)+,d0
		beq.w	HASLO_OK

BLAD:		VBLANK
		subi.b	#1,pnum
		cmpi.b	#"1",pnum
		bne.w	Nie1
		IFEQ LAN
		move.b	#"A",pnum-2	;zostalA
		move.b	#"A",pnum+6	;probA
		ENDC
		IF LAN=1
		move.b	#" ",pnum+8	;chanceS
		ENDC
		IF LAN=2
		move.b	#" ",pnum+9	;versuchE
		ENDC
Nie1:		cmpi.b	#"0",pnum
		beq.s	Koniec
		bsr	clr1
		bsr	clr2
		bsr	clr3
		lea	proby(pc),a1
		lea	scr1(pc),a2
		bsr	p_PRINT
		moveq	#120,d0
.sss2:		VBLANK
		dbf	d0,.sss2
		lea	buf(pc),a1
		move.b	#0,(a1)+
		REPT	8
		move.b	#-1,(a1)+
		ENDR
		bra	PasswordLoop

Koniec:		bsr	clr1			;zly koniec
		bsr	clr2
		bsr	clr3
		lea	zle(pc),a1
		lea	scr1(pc),a2
		bsr	p_PRINT
		move	#180,d0
.sss3:		VBLANK
		dbf	d0,.sss3
		bsr	FadeColors
		lea	copper0(pc),a1
		move.l	a1,$80(a0)
		move	#0,$88(a0)
		VBLANK
		IFEQ	EXE
		bra.w	quit2
;		bra.w	haslo_ok
		ELSE
		move	#$83c0,$96(a0)		;blit dma on
		move.l	#-1,$44(a0)
		move.l	#$0f3c0000,$40(a0)	;bltcon 0
		move	6(a0),$58(a0)
		move	#200*64,$58(a0)
		reset
eki:		bsr.s	eki
		ENDC

HASLO_OK:	bsr	clr1			;dobry koniec
		bsr	clr2
		bsr	clr3
		lea	ok(pc),a1
		lea	scr1(pc),a2
		bsr	p_PRINT
		move	#30,d0
.sss4:		VBLANK
		dbf	d0,.sss4
		bsr	FadeColors
		VBLANK

;	move	#$83c0,$96(a0)		;blit dma on
;	move	#kopia1/$10000,$50(a0)
;	move	#kopia1&$ffff,$52(a0)
;	move	#HASLO/$10000,$54(a0)
;	move	#HASLO&$ffff,$56(a0)
;	move	#0,$64(a0)
;	move	#0,$66(a0)
;	move	#-1,$44(a0)
;	move	#-1,$46(a0)
;	move	#$5555,$72(a0)		; B DAT
;	move	#0,$72(a0)		; B DAT
;	move	#0,$42(a0)		;bltcon 1
;	move	#$093c,$40(a0)		;bltcon 0
;	move	#5+64,$58(a0)


		lea	BLITcopper(pc),a1
		move.l	a1,$80(a0)
		move	#0,$88(a0)
		bsr	clr2
		VBLANK

quit:		lea	$dff000,a0
		VBLANK
quit2:		lea	copper0(pc),a1
		move.l	a1,$80(a0)
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		IFEQ	EXE
		move.l	VBR_base,a1
		move.l	OldLev2(pc),$68(a1)
		move.l	OldLev3(pc),$6c(a1)
		move	#$83f0,$96(a0)
		move	#$e02c,$9a(a0)
		ENDC
		move.l	kopia1(pc),d0			;haslo na wyjsciu
		move.l	kopia1+4(pc),d1
		move.l	kopia1+8(pc),d2
		rts


;---------------------------------------------------------------------
NewLev3:	movem.l ALL,-(sp)
		subi	#1,flash+2
		bne.s	nl2
		move	#15,flash+2
		eori	#1,flash
		bne.s	nl1
		move	#$ccc,HIREScopper+10
		bra.s	nl2
nl1: 		move	#$222,HIREScopper+10
nl2:		move.b	$dff005,d0
		eori.b	d0,ran
		move	flash+2,d0
		move	flash,d1
		eori	d0,d1
		eori.b	d1,ran
		movem.l	(sp)+,ALL
		move	#$20,$dff09c
		rte

;---------------------------------------------------------------------
klawisz:	dc.w	0

NewLev2:	movem.l	ALL,-(sp)
		moveq	#0,d0
		tst.b	$bfed01
		move.b	$bfec01,d0
		move	#$0008,$dff09c		;zero interrupt
		move	#$0002,$dff02e		;CDANG
		eori.b	d0,ran
		tst	d0
		beq.s	cc_NoKey

		move	d0,klawisz

cc_NoKey:	move.b	#$41,$bfee01
		nop
		nop
		nop
		move.b	#0,$bfec01
		move.b	#0,$bfee01
		move.b	$dff005,d0
		eori.b	d0,ran
		movem.l	(sp)+,ALL
		rte

;-------------------------------------------------------------------
clr1:		movem.l	d0/a1,-(sp)
		lea	scr1(pc),a1
		moveq	#23,d0
c1:		move.l	#0,(a1)
		move.l	#0,4(a1)
		move.l	#0,8(a1)
		move.l	#0,12(a1)
		lea	20(a1),a1
		dbf	d0,c1
		movem.l	(sp)+,d0/a1
		rts

clr2:		movem.l	d0/a1,-(sp)
		lea	scr2(pc),a1
		moveq	#7,d0
c2:		move.l	#0,(a1)
		move.l	#0,4(a1)
		lea	20(a1),a1
		dbf	d0,c2
		movem.l	(sp)+,d0/a1
		rts

clr3:		movem.l	d0/a1,-(sp)
		lea	scr2+[80*20](pc),a1
		moveq	#8,d0
c3:		move.l	#0,(a1)
		move.l	#0,4(a1)
		move	#0,8(a1)
		lea	20(a1),a1
		dbf	d0,c3
		movem.l	(sp)+,d0/a1
		rts

Random:		add.l	#$100,rom
		move	4(a0),d0
		eori	d0,rom+2
		move.l	rom,a1
		move.b	(a1)+,d0
		move.b	(a1)+,d1
		eori.b	d1,d0
		move.b	(a1)+,d1
		eori.b	d1,d0
		move.b	(a1)+,d1
		eori.b	d1,d0
		move.b	(a1)+,d1
		eori.b	d1,d0
		moveq	#0,d1
		move.b	d0,d1
cool:		nop
		dbf	d1,cool
		move.b	4(a0),d1
		eori	d1,d0
		move.b	5(a0),d1
		eori	d1,d0
		move.b	6(a0),d1
		eori	d1,d0
		move.b	7(a0),d1
		eori	d1,d0
		move.b	74(a0),d1
		eori	d1,d0
		move.b	75(a0),d1
		eori	d1,d0
		move.b	76(a0),d1
		eori	d1,d0

		move.b	10(a0),d1
		eori	d1,d0
		move.b	11(a0),d1
		eori	d1,d0
		move.b	12(a0),d1
		eori	d1,d0
		move.b	13(a0),d1
		eori	d1,d0
		move.b	18(a0),d1
		eori	d1,d0
		move.b	19(a0),d1
		eori	d1,d0

		move.b	ran,d1
		eori	d1,d0
		rts

;-------------------------------------------------------------------
;a3 - copper, a4 - color tab, d4 - color nr-1

setcolors:	move	#0,d0
		lea	hirescopper(pc),a3
		lea	screen+6400(pc),a4
		moveq	#15,d4
p_SetC:		lea	(a3),a1			;copper
		lea	(a4),a2			;color tab
		move	d4,d5			;color nr. - 1
p_SC1:		move	(a2)+,d1
		move	d1,d2
		andi	#$f,d2
		mulu	d0,d2
		lsr	#4,d2
		move	d1,d3
		andi	#$f0,d3
		mulu	d0,d3
		lsr	#4,d3
		andi	#$f0,d3
		andi	#$f00,d1
		mulu	d0,d1
		lsr	#4,d1
		andi	#$f00,d1
		or	d3,d1
		or	d2,d1
		move	d1,2(a1)
		lea	4(a1),a1
		dbf	d5,p_SC1
		VBLANK
		VBLANK
		addq	#1,d0
		cmpi	#17,d0
		bne.s	p_SetC
		rts

;a3 - copperlist, d4 - nr.of colors

fadecolors:	move	#16,d0
		lea	hirescopper(pc),a3
		moveq	#15,d4
l_fadcol:	lea	(a3),a1
		move	d4,d3			;no. of colors - 1
l_fad1:		move	2(a1),d1
		andi	#$f,d1
		beq.s	l_fad2
		subi	#1,2(a1)
l_fad2:		move	2(a1),d1
		andi	#$f0,d1
		beq.s	l_fad3
		subi	#$10,2(a1)
l_fad3:		move	2(a1),d1
		andi	#$f00,d1
		beq.s	l_fad4
		subi	#$100,2(a1)
l_fad4:		addi.l	#4,a1
		dbf	d3,l_fad1
		VBLANK
		VBLANK
		dbf	d0,l_fadcol
		rts

;-----------------------------------------------------------------------
;input: a1 - tekst, a2 - screen

p_PRINT:	lea	(a2),a3
		lea	fonts,a4
p_loop:		moveq	#0,d0
		move.b	(a1)+,d0
		bpl.s	p_1
		rts
p_1:		bne.s	p_2
		lea	8*20(a2),a2
		lea	(a2),a3
		bra.s	p_loop
p_2:		subi	#32,d0
		lsl	#3,d0
		move.b	(a4,d0.w),(a3)
		move.b	1(a4,d0.w),20(a3)
		move.b	2(a4,d0.w),2*20(a3)
		move.b	3(a4,d0.w),3*20(a3)
		move.b	4(a4,d0.w),4*20(a3)
		move.b	5(a4,d0.w),5*20(a3)
		move.b	6(a4,d0.w),6*20(a3)
		lea	1(a3),a3
		bra.s	p_loop

;-----------------------------------------------------------------------
KEYtab:
dc.b	$df,$dd,$db,$d9,$d7,$d5,$d3,$d1,$cf,$cd
dc.b	$bf,$bd,$bb,$b9,$b7,$b5,$b3,$b1,$af
dc.b	$9d,$9b,$99,$97,$95,$93,$91,0
ASCIItab:
dc.b	"QWERTYUIOPASDFGHJKLZXCVBNM"
even


	IFEQ LAN
tekst:
dc.b	" WPISZ 5 LITER",0
dc.b	"ZACZYNAJaC OD "
litera:
dc.b	"14",0
dc.b	"  ZE STRONY "
strona:
dc.b	"3",-1

proby:	dc.b	"      BlaD!",0,0
	dc.b	"ZOSTAlY "
pnum:	dc.b	"3 PRoBY!",-1

zle:	dc.b	"  FATALNY BlaD!",0,0
	dc.b	"     zEGNAJ !",-1
	ENDC

	IF LAN=1
tekst:
dc.b	"ENTER 5 LETTERS",0
dc.b	"BEGINING FROM "
litera:
dc.b	"14",0
dc.b	"  FROM PAGE "
strona:
dc.b	"3",-1

proby:	dc.b	"    MISTAKE!",0,0
pnum:	dc.b	"3 CHANCES LEFT!",-1
zle:	dc.b	" FATAL MISTAKE!",0,0
	dc.b	"   FAREWELL!",-1
	ENDC


	IF LAN=2
tekst:
dc.b	" TIPPE 5 BUCHST.",0
dc.b	"ANGEFANGEN MIT"
litera:
dc.b	"14",0
dc.b	"  VON SEITE "
strona:
dc.b	"3",-1

proby:	dc.b	"    FEHLER!",0,0
	dc.b	"NOCH "
pnum:	dc.b	"3 VERSUCHE!",-1
zle:	dc.b	"    FEHLER!",0,0
	dc.b	"    LEBWOHL!",-1
	ENDC


ok:	dc.b	0,"       OK.",-1

buf:	dc.b	0,-1,-1,-1,-1,-1,-1,-1,-1	;CNT, ascii
	dc.b	0,0,0,0,0,0,0,0			;key codes
even

;kopia1:	dc.w	1,2,3		;kopia hasla
;pos:	dc.w	4,5		;poz. Y,X wybranego tekstu

kopia1:	dc.w	0,0,0		;kopia hasla
pos:	dc.w	0,0		;poz. Y,X wybranego tekstu

ran:	dc.w	0
rom:	dc.l	$fc0000
flash:	dc.w	0,1
;-----------------------------------------------------------------------
copper0:dc.l	$1800000,$1000300,-2

HIREScopper:
dc.w	$180,0,$182,0,$184,0,$186,0,$188,0
dc.w	$18A,0,$18C,0,$18E,0,$190,0,$192,0
dc.w	$194,0,$196,0,$198,0,$19A,0,$19C,0
dc.w	$19E,0

dc.w	$108,0,$10a,0
dc.l	$920060,$9400a8
dc.l	$8e3881,$90ffc3
dc.l	$1020000,$1040000
;dc.w	$1fc,0,$106,0,$10c,0

dc.w	$e0,screen/$10000,$e2,screen&$ffff
dc.w	$e4,[screen+1600]/$10000,$e6,[screen+1600]&$ffff
dc.w	$e8,[screen+1600]/$10000,$ea,[screen+2*1600]&$ffff
dc.w	$ec,[screen+1600]/$10000,$ee,[screen+3*1600]&$ffff

dc.l	$7001ff00,$01004300
dc.l	$c001ff00,$01000300
dc.l	-2

BLITcopper:
dc.l	$1800000,$3001ff00,$1000300
dc.w	$96,$83c0		;blit dma on
dc.w	$50,kopia1/$10000
dc.w	$52,kopia1&$ffff
dc.w	$54,HASLO/$10000
dc.w	$56,HASLO&$ffff
dc.w	$64,0
dc.w	$66,0
dc.w	$44,-1
dc.w	$46,-1
dc.w	$72,$5555		; B DAT
;dc.w	$72,0			; B DAT
dc.w	$42,0			;bltcon 1
dc.w	$40,$093c		;bltcon 0
dc.w	$58,5+64
dc.l	-2

;-------------------------------------------------------------------
OldLev2:	dc.l	0
OldLev3:	dc.l	0
;-------------------------------------------------------------------

IFEQ	EXE
fonts:		equ	BASE+$5e000
ELSE
fonts:
ENDC

tablica:	equ	fonts+768
screen:		equ	tablica+[41*8]
end:		equ	screen+6432

scr1:		equ	screen+[27*20]+2
scr2:		equ	screen+[64*20]+6


>extern	"DAT1:store/FONTS01.FNT",fonts+SH,-1
>extern	"DAT1:store/zab2_key.txt",tablica+SH,-1
>extern	"DAT1:store/zabpanel_ENG.raw",screen+SH,-1


;sevbtrlalehtanfoennzmalkfyagebdkslatruvn
;vyhgoreauyewpqwpojvadncuytqwvfnvsliusalf
;zmcjhavfwaytdlwhwqfdqofvsgafggdjkwpretla
;zmdbvcvsacytadelaxcngfsvfklsuayegfvwufvs
;cncbfshgdspapakdhaytaaalfsajuywbvyqmzlai
;ieagdjvnshgefkflelovcvspwauambvncuqgdqii
;ncysjqlkcbwytevdwlgjhstqpqirhzmzbthstrqw
;ppwidnkanenvibygosianiybflfwjhwnbvsnuues


st=s+SH
en=end+SH

