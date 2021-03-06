����  :  Vs  s4  ��  �� �� 4[ � �� ��
;	*************************************************
;	*	      Cytadela Main Server		*
;	*    Coded on 26.06.1995  by KANE of SUSPECT	*
;	*************************************************
;save: wb st en

EXE:		equ	0
do_LOAD:	equ	0
do_protect:	equ	0
do_loadAnim:	equ	0

IFEQ	EXE
BASE:		equ	$100000
BASEF:		equ	$700000		;A1200 + 2Mb PCMCIA
LOADB:		equ	$0
ELSE
BASE:		equ	$000000
LOADB:		equ	$100000
ENDC

;MEMORY:	equ	BASE+$7fff8
;VBR_BASE:	equ	BASE+$7ffee
;HASLO:		equ	BASE+$7ffce
;ADDMEM:	equ	BASE+$7ffea
;MC68000:	equ	BASE+$7fff2
;STRUCTURE:	equ	BASE+$7f800
;SAVEGAMES:	equ	BASE+$7f880	;5

MEMORY:		equ	$7fff8
VBR_BASE:	equ	$7ffee
HASLO:		equ	$7ffce
ADDMEM:		equ	$7ffea
MC68000:	equ	$7fff2
STRUCTURE:	equ	$7f800
SAVEGAMES:	equ	$7f880		;5


TTL		CYTADELA_SERVER
ALL:		REG	d0-a6
VBLANK:		MACRO
		cmpi.b	#$ff,6(a0)
		bne.s	*-6
		cmpi.b	#$ff,6(a0)
		beq.s	*-6
		ENDM

WAITKLIK:	MACRO
.w\@:		tst	el_DIR+8
		beq.s	.w\@
		move	#0,el_dir+8
		ENDM



		org	BASE+$5100
		load	BASE+LOADB+$5100

s:		IFEQ	EXE
		move.l	#0,VBR_base
;		move.l	#0,VBR_base-BASE
		move.l	#BASEF,MEMORY
		move	#1,MC68000
		move.l	#BASEF+$81000,ADDMEM

		lea	structure,a1
;		move	#-10,8(a1)
;		move	#257,10(a1)
;		move	#[5*3600]+[48*60]+3,12(a1)
		move	#5,60(a1)
;		move	#1,62(a1)
		move.l	#-1,64(a1)
		move	#-1,68(a1)

		move.l	#$d5bdb3df,d0
		move.l	#$af000006,d1
		move	#$0002,d2
		move.l	#$80e8e68a,HASLO
		move.l	#$fa555553,HASLO+4
		move	#$5557,HASLO+8
		ENDC

		lea	$dff000,a0
		VBLANK
		move	#$7fff,$96(a0)
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		move	#$00ff,$9e(a0)		;ADKONR
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)

		tst	HasloFlag
		bne.s	NieHaslo
		move	#1,HasloFlag
		lea	PoczHaslo(pc),a1
		swap	d1
		move.l	d0,(a1)
		move	d1,4(a1)
		swap	d1
		mulu	#41,d1
		add	d2,d1
		moveq	#4,d2
		lea	ZabTab,a2
		lea	(a2,d1.w),a2
.testit:	move.b	(a1)+,d0
		move.b	(a2)+,d1
		cmp.b	d0,d1
		bne.s	.ByloZle
		dbf	d2,.testit
		bra.s	NieHaslo
.ByloZle:	lea	MainServer(pc),a1
		move	#$5000,d0
.Fuj1:		eor	d0,(a1)+
		dbf	d0,.Fuj1

NieHaslo:
		VBLANK
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
		VBLANK
		move	#$8380,$96(a0)

		IFNE	do_LOAD
;bra www
		lea	mt_data,a0
		move.l	#"CYT4",d1
		moveq	#4,d3
		bsr	dl_check
		move.l	#copper0,$dff080
		move	#0,$dff088

		lea	mt_data+$200,a0		;copy savegames
		lea	STRUCTURE,a1
		move	#191,d0
.copsav:	move.l	(a0)+,(a1)+
		dbf	d0,.copsav
		move.l	#-1,dl_DataArea_s
		move.l	#-1,dl_DataArea_s+4
		lea	mt_data-$200,a0		;main music
		lea	dl_buffer,a1
		move	dl_disk(pc),d0
		moveq	#1*2*11,d1
		move	#11*2*11,d2
		move	#$8000,d3
		bsr	dl_START_s
		lea	mt_data-$200,a0
		lea	mt_data,a1
		bsr	decrunch

		lea	iff_screen-$100,a0	;hangar pic
		lea	dl_buffer,a1
		move	dl_disk(pc),d0
		move	#18*2*11,d1
		move	#3*2*11,d2
		move	#$8000,d3
		bsr	dl_START_s
		lea	iff_screen-$100,a0
		lea	iff_screen,a1
		bsr	decrunch
www:
		ENDC

		lea	STRUCTURE,a1		;make copy of zero prefs
		lea	$300(a1),a2
		moveq	#31,d0
.copst:		move.l	(a1)+,(a2)+
		dbf	d0,.copst

		lea	OptSav(pc),a2
		tst	(a2)
		beq.s	.NieOpt
		lea	STRUCTURE,a1
		lea	2(a2),a2
		move	(a2),(a1)
		move	2(a2),2(a1)
		move	4(a2),4(a1)
.NieOpt:
		LEA	mt_data,A0
		bsr	mt_init
		lea	$dff000,a0
		move	#$c028,$9a(a0)


;---------------
;		bsr	CREDIT_PART

		bsr	END_PART2

;		bsr	ENDLEVEL_PART

;		bsr	DEATHSEQ

;		bsr	MAPA

bra	wwww
nop

;---------------------------------------------------------------------
;main server part...
MainServer:
		lea	$dff000,a0
		move.l	#MAINcopper,$80(a0)
		move	#0,$88(a0)
		lea	MAINcopper,a3
		lea	iff_screen+48000,a4
		moveq	#31,d4
		bsr	se_setcolors
		move	#0,KeyMode
		move	#0,Kropa
		VBLANK
		move.l	#0,el_DIR
		move.l	#0,el_DIR+4
		move	#0,el_DIR+8
		lea	SERoff,a1
		lea	SERscr,a2
		lea	SERbuf,a3
		move	#611,d0
.kopdobuf:	move.l	(a1),d1			;copy to main buffer
		move.l	d1,(a2)+
		move.l	d1,(a3)+
		move.l	4(a1),d1
		move.l	d1,(a2)+
		move.l	d1,(a3)+
		move.l	8(a1),d1
		move.l	d1,(a2)+
		move.l	d1,(a3)+
		move.l	12(a1),d1
		move.l	d1,(a2)+
		move.l	d1,(a3)+
		lea	40(a1),a1
		dbf	d0,.kopdobuf
		lea	iff_screen+[53*40*6]+11,a1
		lea	SERlepr,a2
		lea	iff_screen+[53*40*6]+28,a3
		lea	SERlepr+$264,a4
		move	#$263,d0
.koplr:		move.b	(a1),(a2)+
		lea	40(a1),a1
		move.b	(a3),(a4)+
		lea	40(a3),a3
		dbf	d0,.koplr

RysujMain:	lea	s_ScrMain1(pc),a4
		bsr	DrukTekst
		move	#0,el_dir+8

Main01:		WAITKLIK
		move	Kropa(pc),d0
		IFEQ	EXE
		cmpi	#4,d0
		beq	KoniecTego
		ELSE
		cmpi	#4,d0
		beq.s	Main01
		ENDC

		cmpi	#5,d0			;INFO PART
		bne.s	r_Nie5
		move	#0,do_flash
		lea	MAINcopper,a3
		moveq	#31,d4
		bsr	fadecolors
		bsr	CREDIT_PART
		bsr	CzyscBoki
		lea	MAINcopper,a3
		move.l	a3,$80(a0)
		move	#0,$88(a0)
		lea	iff_screen+48000,a4
		moveq	#31,d4
		bsr	se_setcolors
		move	#0,el_dir+8
		bra	RysujMain
r_Nie5:		cmpi	#1,d0			;LOAD PART
		bne.s	r_Nie1
		bsr	WczytajStan
		bpl	RysujMain		;if poniechaj
		bra	StartGame		;if chosen
;		bra	RysujMain

r_Nie1:		cmpi	#2,d0			;OPTIONS
		bne.s	r_Nie2
		bsr	UstawOpcje
		bra	RysujMain

r_nie2:		cmpi	#0,d0			;START
		bne.s	r_Nie0
		bra	StartGame

r_nie0:		cmpi	#3,d0			;TRENING PART
		bne.s	r_Nie3
		bsr	Trening
		bpl	RysujMain		;if poniechaj
		bra	LoadTrening		;if chosen
r_nie3:
		bra	RysujMain


KoniecTego:	move	#0,do_flash
		lea	MAINcopper,a3
		moveq	#31,d4
		bsr	fadecolors
		bra	wwww

;---------------
;tekst in a4
DrukTekst:	movem.l	ALL,-(sp)
		lea	$dff000,a0
		VBLANK
		move	#0,do_flash
		lea	SERlepr,a1
		lea	iff_screen+[53*40*6]+11,a2
		lea	SERlepr+$264,a3
		move	#$263,d0
.koplr:		move.b	(a1)+,(a2)
		move.b	(a3)+,17(a2)
		lea	40(a2),a2
		dbf	d0,.koplr

		lea	SERbuf,a1
		lea	SERscr,a2
		move	#$990-1,d0
.buftoscr:	move.l	(a1)+,(a2)+		;copy buffer to scrbuf
		dbf	d0,.buftoscr

		lea	(a4),a1			;text
		lea	SERscr+8*16*6,a5
		moveq	#5,d7
m_Druk1:	moveq	#15,d6
		lea	(a5),a2
		move.b	(a1)+,d0
		sne	d5
m_DrukLoop:	moveq	#0,d0
		move.b	(a1)+,d0
		lea	(a2),a3
		lea	KaneFont,a4
		subi	#32,d0
		cmpi	#32,d0
		bmi.s	.m_d3
		subq	#1,d0
.m_d3:		move	d0,d1			;fix 8*16 font
		andi	#1,d1
		lsr	d0
		lsl	#5,d0
		or	d1,d0
		lea	(a4,d0.w),a4
		moveq	#12,d2
		tst.b	d5
		bne.s	m_CopFont2
m_CopFont:	move.b	(a4),d0
		move	d0,d1
		not.b	d1
		and.b	d1,(a3)
		or.b	d0,1*16(a3)
		and.b	d1,2*16(a3)
		and.b	d1,3*16(a3)
		or.b	d0,4*16(a3)
		and.b	d1,5*16(a3)
		lea	2(a4),a4
		lea	16*6(a3),a3
		dbf	d2,m_CopFont
		bra.s	m_ECF

m_CopFont2:	moveq	#0,d0
		move.b	(a4),d0
		move	d0,d1
		not	d1
		ror	#4,d0
		ror	#4,d1
		and.b	d1,(a3)
		or.b	d0,1*16(a3)
		and.b	d1,2*16(a3)
		and.b	d1,3*16(a3)
		or.b	d0,4*16(a3)
		and.b	d1,5*16(a3)
		lsr	#8,d0
		lsr	#8,d1
		and.b	d1,1(a3)
		or.b	d0,1*16+1(a3)
		and.b	d1,2*16+1(a3)
		and.b	d1,3*16+1(a3)
		or.b	d0,4*16+1(a3)
		and.b	d1,5*16+1(a3)
		lea	2(a4),a4
		lea	16*6(a3),a3
		dbf	d2,m_CopFont2

m_ECF:		lea	1(a2),a2
		dbf	d6,m_DrukLoop
		lea	15*16*6(a5),a5
		dbf	d7,m_Druk1

		lea	HangTab,a1
		lea	SERscr,a2
		lea	SERoff,a3
		move	#-1,(a3)
		move	#[816/32]-1,d7
		lea	$dff000,a0
przedruk:	VBLANK
		moveq	#31,d6
		bsr	prz2
		dbf	d7,przedruk
		moveq	#15,d6
		bsr	prz2
		bra.s	JuzPrz

prz2:		move	(a1)+,d0
		move	d0,d1
		lsr	#4,d0
		move	d0,d2
		mulu	#16*6,d0
		andi	#15,d1
		add	d1,d0		;X pos in buf
		mulu	#40*6,d2
		add	d1,d2		;X pos on screen
		lea	(a2,d0.w),a4
		lea	(a3,d2.w),a5
		move.b	(a4),(a5)
		move.b	1*16(a4),1*40(a5)
		move.b	2*16(a4),2*40(a5)
		move.b	3*16(a4),3*40(a5)
		move.b	4*16(a4),4*40(a5)
		move.b	5*16(a4),5*40(a5)
		lea	51*16*6(a4),a4
		lea	51*40*6(a5),a5
		move.b	(a4),(a5)
		move.b	1*16(a4),1*40(a5)
		move.b	2*16(a4),2*40(a5)
		move.b	3*16(a4),3*40(a5)
		move.b	4*16(a4),4*40(a5)
		move.b	5*16(a4),5*40(a5)
		dbf	d6,prz2
		rts
JuzPrz:
		move.l	#0,el_DIR
		bsr	PostawKropa
		move	#1,do_flash
		movem.l	(sp)+,ALL
		rts

;---------------
PostawKropa:	movem.l	ALL,-(sp)
		bsr	CzyscBoki
		
		lea	iff_screen+[63*40*6]+11,a1
		lea	KropaDat(pc),a3
		move	kropa,d0
		mulu	#40*15*6,d0
		lea	(a1,d0.w),a1
		moveq	#7,d0
.CopKropa:	move.b	(a3)+,d1
		move	d1,d2
		not.b	d2
		or.b	d1,(a1)
		or.b	d1,17(a1)
		and.b	d2,1*40(a1)
		and.b	d2,1*40+17(a1)
		and.b	d2,2*40(a1)
		and.b	d2,2*40+17(a1)
		and.b	d2,3*40(a1)
		and.b	d2,3*40+17(a1)
		and.b	d2,4*40(a1)
		and.b	d2,4*40+17(a1)
		and.b	d2,5*40(a1)
		and.b	d2,5*40+17(a1)
		lea	6*40(a1),a1
		dbf	d0,.CopKropa
		movem.l	(sp)+,ALL
		rts

CzyscBoki:	movem.l	a1/a2/a3/d0,-(sp)
		lea	SERlepr,a1
		lea	iff_screen+[53*40*6]+11,a2
		lea	SERlepr+$264,a3
		move	#$263,d0
.koplr:		move.b	(a1)+,(a2)
		move.b	(a3)+,17(a2)
		lea	40(a2),a2
		dbf	d0,.koplr
		movem.l	(sp)+,a1/a2/a3/d0
		rts

Kropadat:	dc.b	%00111100
		dc.b	%01111110
		dc.b	%11111111
		dc.b	%11111111
		dc.b	%11111111
		dc.b	%11111111
		dc.b	%01111110
		dc.b	%00111100

s_scrMain1:	dc.b	1,"     START      "
		dc.b	1,"    WCZYTAJ     "
		dc.b	1,"     OPCJE      "
		dc.b	1,"    TRENING     "
		dc.b	0,"                "
		dc.b	0,"      INFO      "

s_scrLOAD:	dc.b	0,"                "
		dc.b	0,"                "
		dc.b	0,"                "
		dc.b	0,"                "
		dc.b	0,"                "
		dc.b	0,"      MENU      "

s_scrOPCJE:	dc.b	1," TRUDNOsc DUzA  "
		dc.b	1,"WIELKOsc OKNA 1 "
		dc.b	1,"DETALE MAKSIMUM "
		dc.b	1,"  PODlOGI TAK   "
		dc.b	0,"                "
		dc.b	0,"      MENU      "

s_scrTRENING:	dc.b	1,"   PODZIEMIA    "
		dc.b	0,"   MAGAZYNY 1   "
		dc.b	0,"   MAGAZYNY 2   "
		dc.b	1,"  LABORATORIA   "
		dc.b	0,"     KANAlY     "
		dc.b	0,"      MENU      "


Kropa:		dc.w	0

;---------------------------------------------------------------------
wwww:		IFEQ	EXE
		lea	$dff000,a0
		VBLANK
	bra	wwwww
		lea	SERoff,a2
		lea	SERbuf,a1
		move	#611,d0
.kopdobuf:	move.l	(a1)+,(a2)			;copy to main buffer
		move.l	(a1)+,4(a2)
		move.l	(a1)+,8(a2)
		move.l	(a1)+,12(a2)
		lea	40(a2),a2
		dbf	d0,.kopdobuf
		bsr	CzyscBoki
wwwww:
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		bsr	mt_end
		lea	$dff000,a0
		move.l	VBR_base,a1
		move.l	OldLev2(pc),$68(a1)
		move.l	OldLev3(pc),$6c(a1)
		move	#$83f0,$96(a0)
		move	#$e02c,$9a(a0)
		ENDC
		rts


;---------------------------------------------------------------------
;skroluj1:	dc.w	0,0

NewLev3:	movem.l ALL,-(sp)
		bsr	mt_music

		bsr	GetDirs

;		eori	#1,skroluj1+2
;		bne.s	.el_nl0
;		move	#1,skroluj1
;.el_nl0:
		tst	do_flash		;czesc MAIN servera
		beq.s	.nl_nie
		lea	el_DIR(pc),a1
		tst	(a1)
		beq.s	.nl1
		move	#0,(a1)
		subi	#1,Kropa
		bpl.s	.nl3
		move	#5,Kropa
		bra.s	.nl3
.nl1:		tst	2(a1)
		beq.s	.nl4
		move	#0,2(a1)
		addi	#1,Kropa
		cmpi	#6,Kropa
		bne.s	.nl3
		move	#0,Kropa
.nl3:		bsr	PostawKropa

.nl4:
		eori	#1,do_flash+2
		beq.s	.nl_nie
		lea	FlashTab(pc),a1
		move	(a1),d0
		addq	#2,d0
		andi	#31,d0
		move	d0,(a1)
		move	2(a1,d0.w),Maincopper+6
.nl_nie:	movem.l	(sp)+,ALL
		move	#$20,$dff09c
		rte

do_flash:	dc.w	0,0
;---------------------------------------------------------------------
NewLev2:	movem.l	ALL,-(sp)
		moveq	#0,d0
		tst.b	$bfed01
		move.b	$bfec01,d0
		move	#$0008,$dff09c		;zero interrupt
		tst	d0
		beq.w	cc_NoKey

		move	KeyMode,d1		;program klawiatury
		beq.w	cc_EndLevel
		cmpi	#1,d1
		beq.s	cc_Credits
		cmpi	#2,d1
		beq.s	cc_Koniec2
		cmpi	#3,d1
		beq.w	cc_EndLevel
		cmpi	#4,d1
		beq.s	cc_suwaj

cc_m:		cmpi.b	#$75,d0			;ESC - quit
		bne.s	cc_suwak
;		move	#1,DoQuit
		bra	cc_NoKey

cc_suwak:	nop


		bra.w	cc_NoKey
;---------------
cc_Credits:	cmpi.b	#$75,d0
		beq.s	cc_c1
		cmpi.b	#$77,d0
		beq.s	cc_c1
		cmpi.b	#$79,d0
		bne.s	cc_c2
cc_c1:		move	#1,cp_Twait+2
		bra.w	cc_NoKey
cc_c2:		cmpi.b	#$7f,d0
		bne.s	cc_c3
		move	#1,cp_Twait
		bra.w	cc_NoKey
cc_c3:		cmpi.b	#$7e,d0
		bne.s	cc_c4
		move	#0,cp_Twait
		bra.w	cc_NoKey
cc_c4:
		bra.w	cc_NoKey

;---------------
cc_Koniec2:	andi	#1,d0
		bne.s	cc_k1
		move	#0,ko_Twait
		bra.w	cc_NoKey
cc_k1:		move	#1,ko_Twait
		bra.w	cc_NoKey

;---------------
cc_suwaj:	cmpi.b	#$bd,d0			;s - przesuw
		beq.s	cc_s0
		cmpi.b	#$7f,d0			;spacja - przesuw
		beq.s	cc_s0
		cmpi.b	#$4d,d0			;F10 - przesuw
		bne.s	cc_pauseq
cc_s0:		lea	suwak+31,a1
		move	#[198/2]-1,d1
cc_s1:		eori.b	#$11,(a1)
		lea	32(a1),a1
		dbf	d1,cc_s1
cc_pauseq:	bra.w	cc_NoKey

;---------------


cc_EndLevel:	cmpi.b	#$75,d0
		beq.s	cc_e1
		cmpi.b	#$77,d0
		beq.s	cc_e1
		cmpi.b	#$7f,d0
		beq.s	cc_e1
		cmpi.b	#$79,d0
		bne.s	cc_e2
cc_e1:		move	#1,el_DIR+8		;enter
		bra.s	cc_NoKey
cc_e2:		cmpi.b	#$67,d0
		bne.s	cc_e3
		move	#1,el_DIR
		bra.s	cc_NoKey
cc_e3:		cmpi.b	#$65,d0
		bne.s	cc_e4
		move	#1,el_DIR+2
		bra.s	cc_NoKey
cc_e4:		cmpi.b	#$61,d0
		bne.s	cc_e5
		move	#1,el_DIR+4
		bra.s	cc_NoKey
cc_e5:		cmpi.b	#$63,d0
		bne.s	cc_e6
		move	#1,el_DIR+6
		bra.s	cc_NoKey
cc_e6:
		bra.s	cc_NoKey

		nop
cc_NoKey:	move.b	#$41,$bfee01
		nop
		nop
		nop
		move.b	#0,$bfec01
		move.b	#0,$bfee01
		movem.l	(sp)+,ALL
		rte

KeyMode:	dc.w	0
;-------------------------------------------------------------------
; czesc z kreditsami i pozdrowieniami
CREDIT_PART:
		movem.l	ALL,-(sp)
		move	#1,KeyMode

		lea	$dff000,a0
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)

		lea	mt_pic,a0
		lea	CREDscr,a1
		bsr	decrunch

		lea	SCROLL1scr,a1
		moveq	#0,d0
		move	#4360-1,d1
.clrs:		move.l	d0,(a1)+
		dbf	d1,.clrs
		lea	CREDITcopper+64+2,a1
		moveq	#15,d0
.setY:		move	#$0fe0,(a1)
		lea	4(a1),a1
		dbf	d0,.setY

		lea	$dff000,a0
		move.l	#CREDITcopper,$80(a0)
		move	#0,$88(a0)
		lea	CREDITcopper,a3
		lea	CREDscr+32000,a4
		moveq	#15,d4
		bsr	se_setcolors

;---------------
cp_TextLoop:
;		tst	skroluj1
;		beq.s	cp_TextLoop
;		move	#0,skroluj1

		VBLANK
		VBLANK
		btst.b	#2,$16(a0)
		beq.s	cp_TextLoop
		tst	cp_Twait
		bne.s	cp_TextLoop

		tst	cp_Twait+2
		bne.w	cp_GoAway
		btst.b	#6,$bfe001
		beq.w	cp_GoAway
		btst.b	#7,$bfe001
		beq.w	cp_GoAway

		subi	#1,cp_Tsuw
		beq.s	cp_Dodrukuj
		
cp_Suwaj:	lea	SCRscr(pc),a1
		move.l	(a1),d0
		move.l	4(a1),d1
		move.l	d0,4(a1)
		move.l	d1,(a1)
		lea	CredChg(pc),a2
		move	d1,6(a2)
		swap	d1
		move	d1,2(a2)
		swap	d1
		addi.l	#40,d1
;cp_wbl:		btst.b	#14-8,$2(a0)
;		bne.s	cp_wbl
cp_wbl1:	btst.b	#14,$2(a0)
		bne.s	cp_wbl1
		move	#$83c0,$96(a0)		;blit dma on
		move.l	d1,$50(a0)
		move.l	d0,$54(a0)
		move.l	#0,$64(a0)
		move.l	#-1,$44(a0)
		move.l	#$09f00000,$40(a0)	;bltcon 0
		move	#20+[215*64],$58(a0)
		bra.w	cp_TextLoop

cp_Dodrukuj:	move	#16,cp_Tsuw
		move.l	SCRscr+4(pc),a1
		lea	8000(a1),a1
		lea	(a1),a2
		moveq	#0,d0
		move	#15,d1
cp_clr1:	REPT	10
		move.l	d0,(a1)+
		ENDR
		dbf	d1,cp_clr1

cp_DrukLoop:	move.l	cp_Tadr(pc),a1
cp_DrukLoop2:	moveq	#0,d0
		move.b	(a1)+,d0
		bne.s	cp_d1
		move.l	a1,cp_Tadr		;koniec linii
		bra.w	cp_Suwaj
cp_d1:		bpl.s	cp_d2			;od poczatku
		move.l	#Kreditsy,cp_Tadr
		bra.s	cp_DrukLoop
cp_d2:		lea	(a2),a3
		lea	KaneFont,a4
		subi	#32,d0
		beq.s	cp_dalej
		cmpi	#32,d0
		bmi.s	cp_d3
		subq	#1,d0
cp_d3:		move	d0,d1			;fix 8*16 font
		andi	#1,d1
		lsr	d0
		lsl	#5,d0
		or	d1,d0
		lea	(a4,d0.w),a4
		moveq	#12,d0
cp_CopFont:	move.b	(a4),(a3)
		lea	2(a4),a4
		lea	40(a3),a3
		dbf	d0,cp_CopFont
cp_dalej:	lea	1(a2),a2
		bra.s	cp_DrukLoop2

;---------------
cp_GoAway:	lea	CREDITcopper,a3
		moveq	#31,d4
		bsr	fadecolors
		move	#0,KeyMode
		move.l	#0,cp_Twait
		move.l	#Kreditsy,cp_Tadr
		move	#18,cp_Tsuw
		movem.l	(sp)+,ALL
		rts

cp_Tadr:	dc.l	kreditsy
cp_Tsuw:	dc.w	16
cp_Twait:	dc.w	0,0		;wait, quit

;-------------------------------------------------------------------
WczytajStan:
		movem.l	ALL,-(sp)
		lea	s_scrLOAD+1(pc),a1
		moveq	#4,d7
.doc1:		moveq	#15,d6
.doc2:		move.b	#$20,(a1)+
		dbf	d6,.doc2
		lea	1(a1),a1
		dbf	d7,.doc1

		lea	SAVEGAMES+72,a1			;kopiuj tytuly
		lea	s_scrLOAD+1(pc),a2
		moveq	#4,d7
.copsn:		lea	(a1),a3
		lea	(a2),a4
.csn1:		move.b	(a3)+,d0
		cmpi.b	#"@",d0
		beq.s	.csn2
		move.b	d0,(a4)+
		bra.s	.csn1
.csn2:		lea	128(a1),a1
		lea	17(a2),a2
		dbf	d7,.copsn

		move	#0,Kropa
		lea	s_scrLOAD(pc),a4
		bsr	DrukTekst
		move	#0,el_dir+8

loadp:		WAITKLIK
		move	Kropa(pc),d0
		cmpi	#5,d0
		beq	l_poniechaj
		lea	SAVEGAMES+88,a1			;kopiuj tytuly
		mulu	#128,d0
		tst	(a1,d0.w)
		beq.s	loadp

		lea	-88(a1,d0.w),a1			;load old game
		lea	STRUCTURE,a2
		moveq	#31,d0
.copsav:	move.l	(a1)+,(a2)+
		dbf	d0,.copsav

		move	#1,Kropa
		movem.l	(sp)+,ALL
		moveq	#-1,d0
		rts

l_poniechaj:	move	#1,Kropa
		movem.l	(sp)+,ALL
		moveq	#1,d0
		rts

;-------------------------------------------------------------------
Trening:	move	#0,Kropa
		lea	s_scrTRENING(pc),a4
		bsr	DrukTekst
		move	#0,el_dir+8

t_loop:		WAITKLIK
		lea	STRUCTURE,a1
		move	Kropa(pc),d0
;		cmpi	#3,d0
;		beq.s	t_loop
;		cmpi	#4,d0
;		beq.s	t_loop
		cmpi	#5,d0
		bne.s	t_l2
		move	#3,Kropa
		move	#1,d0		;if poniechaj
		rts
t_l2:		move	#3,Kropa
		move	#-1,d1		;other
		rts


;---------------
LoadTrening:	bsr	LoadFirstData
		movem.l	ALL,-(sp)
		lea	iff_screen+$1000,a0	;find disk 5
		move.l	#"CYT5",d1
		moveq	#5,d3
		bsr	dl_check
		move.l	#copper0,$dff080
		move	#0,$dff088
		movem.l	(sp)+,ALL

		lea	FileStructure2(pc),a1
		mulu	#48,d0
		lea	(a1,d0.w),a1
		bsr	LoadFiles		;load gfx

		move	dl_disk(pc),d0
		addi	#48,d0
		move.b	d0,42(a1)		;map drive

		lea	40(a1),a0
		lea	iff_screen+$1000,a1
		lea	dl_buffer,a2
		jsr	FileLoader		;load map
		moveq	#0,d0
		move	d1,d0
		lea	iff_screen+$1000,a0
		lea	$2b600,a1
		bsr	decrunch2

		lea	ENGINE,a0		;decomp. engine
		move.l	MEMORY,a1
		addi.l	#$6000,a1
		lea	(a1),a2
		bsr	decrunch

		jsr	(a2)			;RUN GAME!!!
		lea	$dff000,a0
		VBLANK
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)
		move	#$7fff,$96(a0)
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		move	#$00ff,$9e(a0)
		move	#$8380,$96(a0)

		bsr	RememberOpt
		tst	d0
		beq	s			;if ESC - quit !
		bpl	s
		bsr	DEATHSEQ		;if dead
		bra	s

;---------------
FileStructure2:	dc.b	"DF0:W1A",0
		dc.b	"DF0:W1B",0
		dc.b	"DF0:E1T",0
		dc.b	"DF0:E1B",0
		dc.b	"DF0:C1A",0
MAPname2:	dc.b	"DF0:M1T",0

		dc.b	"DF0:W3A",0
		dc.b	"DF0:W3B",0
		dc.b	"DF0:E3A",0
		dc.b	"DF0:E3B",0
		dc.b	"DF0:C3A",0
		dc.b	"DF0:M3T",0

		dc.b	"DF0:W3A",0
		dc.b	"DF0:W3B",0
		dc.b	"DF0:E3A",0
		dc.b	"DF0:E3B",0
		dc.b	"DF0:C3A",0
		dc.b	"DF0:M3K",0

		dc.b	"DF0:W5A",0
		dc.b	"DF0:W5B",0
		dc.b	"DF0:E5A",0
		dc.b	"DF0:E5B",0
		dc.b	"DF0:C5A",0
		dc.b	"DF0:M5T",0

		dc.b	"DF0:W6A",0
		dc.b	"DF0:W6B",0
		dc.b	"DF0:E6A",0
		dc.b	"DF0:E6B",0
		dc.b	"DF0:C6A",0
		dc.b	"DF0:M6T",0


;-------------------------------------------------------------------
UstawOpcje:
		movem.l	ALL,-(sp)
		move	#0,Kropa

uo_loop:	bsr	u_poustawiaj
		lea	s_scrOPCJE(pc),a4
		bsr	DrukTekst
		move	#0,el_dir+8
		
uo_loop1:	WAITKLIK
		lea	STRUCTURE,a1
		move	Kropa(pc),d0
		bne.s	uo1
		eori	#1,50(a1)
		bra.s	uo_loop
uo1:		cmpi	#1,d0
		bne.s	uo2
		addi	#1,(a1)
		cmpi	#7,(a1)
		bne.s	uo_loop
		move	#2,(a1)
		bra.s	uo_loop
uo2:		cmpi	#2,d0
		bne.s	uo3
		addi	#1,4(a1)
		cmpi	#3,4(a1)
		bne.s	uo_loop
		move	#0,4(a1)
		bra.s	uo_loop
uo3:		cmpi	#3,d0
		bne.s	uo4
		eori	#1,2(a1)
		bra.s	uo_loop
uo4:		cmpi	#4,d0
		beq.s	uo_loop1
		cmpi	#5,d0
		bne.w	uo_loop

u_menu:		move	#2,Kropa
		movem.l	(sp)+,ALL
		rts

u_Poustawiaj:	lea	STRUCTURE,a3
		lea	ut1(pc),a1		;trudnosc
		moveq	#10,d0
		tst	50(a3)
		beq.s	.p1
		lea	5(a1),a1
.p1:		bsr	u_Druk
		lea	ut2(pc),a1		;okno
		moveq	#31,d0
		move	(a3),d1
		subi	#2,d1
		add	d1,d1
		lea	(a1,d1.w),a1
		bsr	u_Druk
		lea	ut3(pc),a1		;detale
		moveq	#41,d0
		move	4(a3),d1
		beq.s	.p2
		cmpi	#1,d1
		bne.s	.p3
		lea	9(a1),a1
		beq	.p2
.p3:		lea	18(a1),a1
.p2:		bsr	u_Druk
		lea	ut4(pc),a1		;podlogi
		moveq	#61,d0
		tst	2(a3)
		bne.s	.p4
		lea	4(a1),a1
.p4:		bsr	u_Druk
		rts

u_Druk:		lea	s_scrOPCJE+1(pc),a2
		lea	(a2,d0.w),a2
.u_d1:		move.b	(a1)+,d0
		beq.s	.u_d2
		move.b	d0,(a2)+
		bra.s	.u_d1
.u_d2:		rts

ut1:	dc.b	"DUzA",0,"MAlA",0
ut2:	dc.b	"1",0,"2",0,"3",0,"4",0,"5",0
ut3:	dc.b	"MAKSIMUM",0,"sREDNIE ",0,"MINIMUM ",0
ut4:	dc.b	"TAK",0,"NIE",0
EVEN
;-------------------------------------------------------------------
CountCRC:	movem.l	ALL,-(sp)
		lea	CRCsum(pc),a1
		moveq.l	#0,d0
		add.l	(a1)+,d0
		add.l	(a1)+,d0
		add.l	(a1)+,d0
		add.l	(a1)+,d0
		add.l	(a1)+,d0
		cmpi.l	#$c4aa4a41,d0
		beq.s	CRCok
		lea	Stukaj(pc),a0
		move	#$3000,d0
.kuku9:		eor	d0,(a0)+
		dbf	d0,.kuku9
CRCok:		movem.l	(sp)+,ALL
		rts

;-------------------------------------------------------------------
MAPA:		movem.l	ALL,-(sp)
		move	#1,CzyArrow
		lea	$dff000,a0
		VBLANK
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)
		VBLANK
		move	#$7fff,$96(a0)
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		move	#$00ff,$9e(a0)		;ADKONR
		move.l	VBR_base,a1
		lea	map_NewLev3(pc),a2
		move.l	a2,$6c(a1)
		lea	NewLev2(pc),a2
		move.l	a2,$68(a1)
		VBLANK
		move	#0,KeyMode
		move	#$8380,$96(a0)
;tu load
		IFNE	do_load
		lea	MAPApic,a0
		move.l	#"CYT5",d1
		moveq	#5,d3
		bsr	dl_check
		move.l	#copper0,$dff080
		move	#0,$dff088

		move.l	#-1,dl_DataArea_s
		move.l	#-1,dl_DataArea_s+4
		move	dl_disk(pc),d0
		addi	#48,d0
		move.b	d0,MAPKAname+2
		move.b	d0,MUSname+2		;DFx
		lea	MAPKAname(pc),a0
		lea	dl_buffer,a2
		lea	MAPApic-$400,a1
		jsr	FileLoader		;MAPKA
		moveq	#0,d0
		move	d1,d0
		lea	MAPApic-$400,a0
		lea	MAPApic,a1
		bsr	decrunch2
		lea	MUSname(pc),a0
		lea	dl_buffer,a2
		lea	MAPAmus-$400,a1
		jsr	FileLoader		;MODUL
		moveq	#0,d0
		move	d1,d0
		lea	MAPAmus-$400,a0
		lea	MAPAmus,a1
		bsr	decrunch2
		ENDC

		LEA	MAPAmus,A0
		bsr	mt_init
		lea	$dff000,a0
		move	#$c028,$9a(a0)

		bsr	ma_clr
		lea	MAPAcopper,a3
		move.l	a3,$80(a0)
		move	#0,$88(a0)
		lea	MAPApic+46080,a4
		moveq	#31,d4
		bsr	se_setcolors

		lea	STRUCTURE,a1
		move	60(a1),d0
		subq	#1,d0
		move.b	#1,64(a1,d0.w)		;kompleks ukonczony
		addi	#1,98(a1)

		lea	Kon1Tab(pc),a2
		moveq	#0,d1
		move.b	(a2,d0.w),d1		;numer dla mapki
		move	d1,wybor
		bsr	Zachowaj

;-----
		move	#0,CzyArrow
		bsr	Printnij
		move.l	#0,el_DIR
		move.l	#0,el_DIR+4
		move	#0,el_DIR+8
		lea	$dff000,a0
ma_MainLoop:	VBLANK
		lea	el_DIR(pc),a1
		tst	(a1)
		bne.s	ma_odejmij
		tst	6(a1)
		beq.s	ma_dod
ma_odejmij:	subi	#1,wybor
		bpl.s	ma_sprawdz
		move	#6,wybor
		bra.s	ma_sprawdz
ma_dod:		tst	2(a1)
		bne.s	ma_dodaj
		tst	4(a1)
		beq.s	ma_fire
ma_dodaj:	addi	#1,wybor
		cmpi	#7,wybor
		bne.s	ma_sprawdz
		move	#0,wybor
ma_sprawdz:
		move	#1,CzyArrow
		bsr	ClrArrow
		move	#0,CzyArrow
		bsr	Printnij
		move.l	#0,el_DIR
		move.l	#0,el_DIR+4
		move	#0,el_DIR+8
		bra.w	ma_MainLoop
ma_fire:	tst	8(a1)
		beq.w	ma_MainLoop
		move	#0,el_DIR+8

		move	stan(pc),d0
		beq.s	ma_wybrany
		bmi.s	ma_niedost
		bsr	ma_out
		bsr	ma_clr
		lea	ZBADText(pc),a1
		bsr	ma_draw
		bsr	ma_in
		bra.s	ma_uf
ma_niedost:	bsr	ma_out
		bsr	ma_clr
		lea	NIEDText(pc),a1
		bsr	ma_draw
		bsr	ma_in
ma_uf:		move	#110,d0
		lea	$dff000,a0
.ma_1:		VBLANK
		dbf	d0,.ma_1
		bsr	Printnij
		move.l	#0,el_DIR
		move.l	#0,el_DIR+4
		move	#0,el_DIR+8
		bra.w	ma_MainLoop

;-----

ma_wybrany:	cmpi	#6,Wybor
		bne.s	ma_NieCen
		lea	STRUCTURE,a1
		cmpi	#7,98(a1)
		beq.s	ma_Cen1
ma_Cen2:	bsr	ma_out
		bsr	ma_clr
		lea	CENTText(pc),a1
		bsr	ma_draw
		bsr	ma_in
		bra.s	ma_uf
ma_Cen1:	cmpi	#-12,8(a1)
		bne.s	ma_Cen2

ma_NieCen:	move	Wybor(pc),d0
		moveq	#9+11,d1
		Lea	OKText(pc),a1
		lea	KompNames2(pc),a2
		bsr	ma_CopIt
		bsr	ma_out
		bsr	ma_clr
		lea	OKText(pc),a1
		bsr	ma_draw
		bsr	ma_in

		move	#150,d0
		lea	$dff000,a0
.ma_1:		VBLANK
		dbf	d0,.ma_1


		move	Wybor(pc),d0
		lea	Kon2Tab(pc),a2
		move.b	(a2,d0.w),d0		;numer dla struktury
		lea	STRUCTURE,a1
		move	d0,60(a1)
		move	#0,62(a1)


		bsr	ma_out
		lea	MAPAcopper,a3
		moveq	#31,d4
		bsr	fadecolors
		move	#1,CzyArrow
		bsr	ClrArrow
		bsr	mt_end
		lea	$dff000,a0
		VBLANK
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)
		VBLANK
		move	#$7fff,$96(a0)
		move	#$7fff,$9a(a0)
		VBLANK
		move	#$8380,$96(a0)
		movem.l	(sp)+,ALL
		rts




;---------------
Printnij:	movem.l	ALL,-(sp)
		move	Wybor(pc),d0
		moveq	#9,d1
		Lea	KomplexTexts(pc),a1
		lea	KompNames(pc),a2
		bsr	ma_CopIt

		moveq	#8,d0			;zbadany
		move	#1,stan
		move	Wybor(pc),d1
		lea	Kon2Tab(pc),a2
		move.b	(a2,d1.w),d1		;numer dla struktury
		lea	STRUCTURE,a2
		tst.b	64-1(a2,d1.w)
		bne.s	ma_p1
		moveq	#7,d0			;niezbadany
		move	#0,stan

		moveq	#3,d3
		lea	Kolejnosc(pc),a1
ma_p2:		move	(a1)+,d2
		tst.b	64-1(a2,d2.w)
		bne.s	ma_p2
		cmp	d1,d2
		beq.s	ma_p1
		subi	#1,d3
		bne.s	ma_p2
		moveq	#9,d0			;niedostepny
		move	#-1,stan
ma_p1:		moveq	#28,d1
		Lea	KomplexTexts(pc),a1
		lea	KompNames(pc),a2
		bsr	ma_CopIt

		bsr	ma_out
		lea	KomplexTexts(pc),a1
		bsr	ma_draw
		bsr	ma_in

		movem.l	(sp)+,ALL
		rts

;---------------
ma_draw:	movem.l	ALL,-(sp)
		lea	MAPAscr,a2
		lea	Font8,a3
ma_d1:		moveq	#0,d0
		move.b	(a1)+,d0
		beq.s	ma_d3
		subi	#32,d0
		lsl	#3,d0
		lea	(a3,d0.w),a4
		moveq	#6,d0
		lea	(a2),a5
.ma_d2:		move.b	(a4)+,(a5)
		lea	40(a5),a5
		dbf	d0,.ma_d2
		lea	1(a2),a2
		bra.s	ma_d1
ma_d3:		movem.l	(sp)+,ALL
		rts

;---------------
ma_clr:		movem.l	ALL,-(sp)
		lea	MAPAscr,a1		;clr text
		move	#[10*6*7]-1,d1
		moveq	#0,d0
.ma_c1:		move.l	d0,(a1)+
		dbf	d1,.ma_c1
		movem.l	(sp)+,ALL
		rts

ma_out:		movem.l	ALL,-(sp)
		move	#$eee,d0		;fade colors
		lea	$dff000,a0
.ma_o:		VBLANK
		move	d0,ma_col+2
		subi	#$222,d0
		bpl.s	.ma_o
		movem.l	(sp)+,ALL
		rts

ma_in:		movem.l	ALL,-(sp)
		move	#$222,d0		;set colors
		lea	$dff000,a0
.ma_s:		VBLANK
		move	d0,ma_col+2
		addi	#$222,d0
		cmpi	#$eee,d0
		bne.s	.ma_s
		move	d0,ma_col+2
		movem.l	(sp)+,ALL
		rts

;d0 - name nr, d1 - offset, a1 - text, a2 - names
ma_CopIt:	movem.l	ALL,-(sp)
		lea	(a1,d1.w),a1
		mulu	#11,d0
		lea	(a2,d0.w),a2
		moveq	#10,d1
.ma_c2:		move.b	(a2)+,(a1)+
		dbf	d1,.ma_c2
		movem.l	(sp)+,ALL
		rts

;---------------
Zachowaj:	movem.l ALL,-(sp)
		lea	MAPApic,a1
		lea	ArrowPos(pc),a2
		lea	MAPAbuf,a3
		moveq	#6,d7
zaloop:		move.l	(a2)+,d0
		lea	(a1,d0.l),a4
		moveq	#[20*6]-1,d1
.za_l1:		move	(a4),(a3)+
		lea	40(a4),a4
		dbf	d1,.za_l1
		dbf	d7,zaloop

		lea	strzalka,a1		;make arrow mask
		moveq	#10,d7
.za_l2:		moveq	#0,d0
		REPT	6
		move	(a1)+,d1
		or	d1,d0
		ENDR
		not	d0
		move	d0,(a3)+
		dbf	d7,.za_l2
		movem.l	(sp)+,ALL
		rts

;---------------
DrukArrow:	movem.l ALL,-(sp)
		lea	MAPApic,a1
		lea	ArrowPos(pc),a2
		lea	MAPAbuf,a3
		move	Wybor,d0
		move	d0,d1
		add	d0,d0
		add	d0,d0
		lea	ArrowPos(pc),a2
		move.l	(a2,d0.w),d0
		lea	(a1,d0.l),a1		;screen pos
		move.l	a1,-(sp)
		mulu	#$f0,d1
		lea	(a3,d1.w),a3		;buf pos
		moveq	#[20*6]-1,d1
.za_l1:		move	(a3)+,(a1)
		lea	40(a1),a1
		dbf	d1,.za_l1

		move.l	(sp)+,a1
		lea	MAPAbuf+$690,a3
		move	ArrowWys,d0
		mulu	#40*6,d0
		lea	(a1,d0.w),a1		;add offset
		lea	strzalka,a2		;arrow , a3 - mask
		moveq	#10,d7
.za_l2:		move	(a3)+,d0		;mask
		REPT	6
		and	d0,(a1)
		move	(a2)+,d1
		or	d1,(a1)
		lea	40(a1),a1
		ENDR
		dbf	d7,.za_l2
		movem.l	(sp)+,ALL
		rts


ClrArrow:	lea	MAPApic,a1
		lea	ArrowPos(pc),a2
		lea	MAPAbuf,a3
		moveq	#6,d7
.Naloop:	move.l	(a2)+,d0
		lea	(a1,d0.l),a4
		moveq	#[20*6]-1,d1
.za_l1:		move	(a3)+,(a4)
		lea	40(a4),a4
		dbf	d1,.za_l1
		dbf	d7,.Naloop
		rts

;---------------
map_NEWLEV3:	movem.l ALL,-(sp)
		tst	CzyArrow
		bne.s	map_nl1
		lea	Asinus(pc),a1
		addi	#1,(a1)
		andi	#31,(a1)
		move	(a1),d0
		moveq	#0,d1
		move.b	2(a1,d0.w),d1
		move	d1,ArrowWys
		bsr	DrukArrow
map_nl1:	bsr	mt_music
		bsr	GetDirs
		movem.l	(sp)+,ALL
		move	#$20,$dff09c
		rte

CzyArrow:	dc.w	0
;---------------
Asinus:
dc.w	0
DC.B	$00,$01,$02,$03,$04,$05,$05,$06,$07,$07,$08,$08,$08,$09,$09,$09
DC.B	$09,$09,$09,$08,$08,$08,$07,$07,$06,$05,$05,$04,$03,$02,$01,$00
EVEN

ArrowPos:	dc.l	[119*40*6]+32
		dc.l	[58*40*6]+34
		dc.l	[2*40*6]+26
		dc.l	[15*40*6]+10
		dc.l	[32*40*6]+2
		dc.l	[93*40*6]+6
		dc.l	[60*40*6]+20

Wybor:		dc.w	0
stan:		dc.w	0		;0 - niezb, 1 - zbad, -1 -nied
ArrowWys:	dc.w	0

KomplexTexts:	dc.b	"KOMPLEKS:            STATUS:            ",0
OKtext:		dc.b	"           WYBRAlEs             ",0
ZBADtext:	dc.b	" TEN KOMPLEKS ZOSTAl JUz SPENETROWANY!",0
NIEDtext:	dc.b	" TEN KOMPLEKS JEST JESZCZE NIEDOSTePNY!",0
CENTtext:	dc.b	"  MUSISZ MIEc CAla BOMBe ABY TU WEJsc!",0
KompNames:	dc.b	"WIeZIENIE  "
		dc.b	"HANGAR     "
		dc.b	"ELEKTROWNIA"
		dc.b	"MAGAZYNY   "
		dc.b	"LABORATORIA"
		dc.b	"KANAlY     "
		dc.b	"CENTRUM    "

		dc.b	"NIEZBADANY "
		dc.b	"ZBADANY    "
		dc.b	"NIEDOSTePNY"

KompNames2:	dc.b	"WIeZIENIE  "
		dc.b	"HANGAR     "
		dc.b	"ELEKTROWNIe"
		dc.b	"MAGAZYNY   "
		dc.b	"LABORATORIA"
		dc.b	"KANAlY     "
		dc.b	"CENTRUM    "

EVEN
Kolejnosc:	dc.w	2,5,6,3,4,7,8

EVEN
Kon1Tab:	dc.b	6,2,3,1,4,5,0,6

Kon2Tab:	dc.b	7,4,2,3,5,6,8,1

MAPKAname:	dc.b	"DF0:MAP",0
MUSname:	dc.b	"DF0:MOD",0

EVEN
;-------------------------------------------------------------------
;ddd:	dc.l	0

; Czesc koncowa 2 - scroll
END_PART2:	movem.l	ALL,-(sp)
		lea	$dff000,a0
		VBLANK
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)
		VBLANK
		move	#$7fff,$96(a0)
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		move	#$00ff,$9e(a0)		;ADKONR
		move.l	VBR_base,a1
		lea	ko_NewLev3(pc),a2
		move.l	a2,$6c(a1)
		lea	NewLev2(pc),a2
		move.l	a2,$68(a1)
		VBLANK
		move	#4,KeyMode
		move	#$8380,$96(a0)

		IFNE	do_LOADanim
		lea	mt_data2,a0
		move.l	#"CYT4",d1
		moveq	#4,d3
		bsr	dl_check
		move.l	#copper0,$dff080
		move	#0,$dff088

		move.l	#-1,dl_DataArea_s
		move.l	#-1,dl_DataArea_s+4
		lea	mt_data2-$800,a0	;good end music
		lea	dl_buffer,a1
		move	dl_disk(pc),d0
		move	#12*2*11,d1
		move	#6*2*11,d2
		move	#$8000,d3
		bsr	dl_START_s
		lea	mt_data2-$800,a0
		lea	mt_data2,a1
		bsr	decrunch

		move.l	MEMORY,a3		;load anim
		addi.l	#Anim1,a3
		lea	KONC1scr,a0
;move.l	a0,ddd
		lea	dl_buffer,a1
		move	dl_disk(pc),d0
		move	#43*2*11,d1
		move	#17*2*11,d2
		move	#$8000,d3
		bsr	dl_START_s
		move	#$2ec0-1,d0
		bsr	ep_copy

		lea	KONC1scr,a0
		lea	dl_buffer,a1
		move	dl_disk(pc),d0
		move	#60*2*11,d1
		move	#18*2*11,d2
		move	#$8000,d3
		bsr	dl_START_s
		move	#$3180-1,d0
		bsr	ep_copy
		ENDC

		LEA	mt_data2,A0
		bsr	mt_init
		lea	$dff000,a0
		move	#$c028,$9a(a0)

;tu ladowanie i odpalenie animki

		lea	$dff000,a0
		VBLANK
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)


		move.l	MEMORY,a1		;anim 001
		addi.l	#anim2,a1
		move.l	AnimsAdr,a2
		move.l	a1,(a2)
		bsr	ReplayPart
		move.l	MEMORY,a1		;anim 002
		addi.l	#anim1,a1
		move.l	AnimsAdr,a2
		move.l	a1,(a2)
		bsr	ReplayPart
		move.l	MEMORY,a1		;anim 003
		addi.l	#anim3,a1
		move.l	AnimsAdr,a2
		move.l	a1,(a2)
		bsr	ReplayPart

		bra	ko_scroll

;---------------
ko_NewLev3:	movem.l ALL,-(sp)
		bsr	mt_music

 	tst	kal
	beq.s	.dupa
	subi	#1,licznik
	bpl.s	.dupa
	move	#0,kal
.dupa:

.nl0:		tst	DoReplay
		beq.s	.nl1
		subi	#1,iff_timer
		bne.s	.nl1
		move.l	iff_speed,a1
		subi	#1,iff_timer+2
		bne.s	.nl2
		lea	8(a1),a1
		move.l	a1,iff_speed
		move	6(a1),iff_timer+2
.nl2:		move	2(a1),iff_timer
		move	#1,ok_go
.nl1:
		movem.l	(sp)+,ALL
		move	#$20,$dff09c
		rte

DoReplay:	dc.w	0		;1 - replay anim
;---------------------------------------------------------------------
kal:		dc.w	0
licznik:	dc.w	0

ReplayPart:	move.l	AnimsAdr,a2		;part to be raplayed
		move.l	(a2)+,d0
		move.l	d0,a1
		move.l	(a2)+,d0
		move	d0,licznik		;ramkowanie
		move	2(a2),iff_timer
		move	6(a2),iff_timer+2
		move.l	a2,iff_speed

		move	#1,kal
		move.l	a2,-(sp)
		bsr	iff_REPLAY		;main routine
		move.l	(sp)+,a2
		move	#0,DoReplay

.al1:		move.l	(a2)+,d0
		bpl.s	.al1
		move.l	a2,AnimsAdr
		lea	$dff000,a0
		VBLANK
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)

		moveq	#8,d0
.alala:		VBLANK
		dbf	d0,.alala

.dupa:	tst	kal
	bne.s	.dupa
		rts



;-----------------------------------------------
;end part II - scroll
ko_scroll:	lea	$dff000,a0
		VBLANK
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)
		move	#0,DoReplay
		move	#2,KeyMode

		VBLANK
		lea	KONC1scr,a1
		moveq	#0,d0
		move	#3000-1,d1
.clrs:		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		dbf	d1,.clrs

		moveq	#70,d0
.blala:		VBLANK
		dbf	d0,.blala

		lea	$dff000,a0
		move.l	#KONC2copper,$80(a0)
		move	#0,$88(a0)

;bra	ko_Goaway
;---------------
ko_TextLoop:
;		tst	skroluj
;		beq.s	ko_TextLoop
;		move	#0,skroluj

		VBLANK
		VBLANK
		VBLANK
	IFEQ	EXE
	btst.b	#6,$bfe001
	beq.w	ko_GoAway
	ENDC
		btst.b	#2,$16(a0)
		beq.s	ko_TextLoop
		btst.b	#6,$bfe001
		beq.s	ko_TextLoop
		btst.b	#7,$bfe001
		beq.s	ko_TextLoop
		tst	ko_Twait
		bne.s	ko_TextLoop

		subi	#1,ko_Tsuw
		beq.s	ko_Dodrukuj
		
ko_Suwaj:	lea	KONscr(pc),a1
		move.l	(a1),d0
		move.l	4(a1),d1
		move.l	d0,4(a1)
		move.l	d1,(a1)
		lea	KONChg(pc),a2
		move	d1,6(a2)
		swap	d1
		move	d1,2(a2)
		swap	d1
		addi.l	#40,d1
ko_wbl:		btst.b	#14-8,$2(a0)
		bne.s	ko_wbl
		move	#$83c0,$96(a0)		;blit dma on
		move.l	d1,$50(a0)
		move.l	d0,$54(a0)
		move.l	#0,$64(a0)
		move.l	#-1,$44(a0)
		move.l	#$09f00000,$40(a0)	;bltcon 0
		move	#20+[217*64],$58(a0)
		bra.w	ko_TextLoop

ko_Dodrukuj:	move	#16,ko_Tsuw
		move.l	KONscr+4(pc),a1
		lea	8000(a1),a1
		lea	(a1),a2
		moveq	#0,d0
		move	#15,d1
ko_clr1:	REPT	10
		move.l	d0,(a1)+
		ENDR
		dbf	d1,ko_clr1

ko_DrukLoop:	move.l	ko_Tadr(pc),a1
ko_DrukLoop2:	moveq	#0,d0
		move.b	(a1)+,d0
		bne.s	ko_d1
		move.l	a1,ko_Tadr		;koniec linii
		bra.w	ko_Suwaj
ko_d1:		bpl.s	ko_d2			;od poczatku
		move.l	#Koncowka,ko_Tadr
		bra.s	ko_GoAway
ko_d2:		lea	(a2),a3
		lea	KaneFont,a4
		subi	#32,d0
		beq.s	ko_dalej
		cmpi	#32,d0
		bmi.s	ko_d3
		subq	#1,d0
ko_d3:		move	d0,d1			;fix 8*16 font
		andi	#1,d1
		lsr	d0
		lsl	#5,d0
		or	d1,d0
		lea	(a4,d0.w),a4
		moveq	#12,d0
ko_CopFont:	move.b	(a4),(a3)
		lea	2(a4),a4
		lea	40(a3),a3
		dbf	d0,ko_CopFont
ko_dalej:	lea	1(a2),a2
		bra.s	ko_DrukLoop2

;---------------
ko_GoAway:	VBLANK
		btst.b	#2,$16(a0)
		beq.s	ko_MYK
		btst.b	#6,$bfe001
		beq.s	ko_MYK
		btst.b	#7,$bfe001
		beq.s	ko_MYK
		tst	ko_Twait
		beq.s	ko_GoAway
ko_MYK:
		move.l	#0,ko_Twait
		move.l	#Koncowka,ko_Tadr
		move	#18,ko_Tsuw
		lea	$dff000,a0
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		bsr	mt_end
		move	#0,KeyMode
		movem.l	(sp)+,ALL
		rts

ep_copy:	lea	KONC1scr,a1
.ep_c:		move.l	(a1)+,(a3)+
		move.l	(a1)+,(a3)+
		move.l	(a1)+,(a3)+
		move.l	(a1)+,(a3)+
		dbf	d0,.ep_c
		rts

ko_Tadr:	dc.l	koncowka
ko_Tsuw:	dc.w	18
ko_Twait:	dc.w	0


;-------------------------------------------------------------------
; fragment miedzy etapami
ENDLEVEL_PART:
		movem.l	ALL,-(sp)
		move	#3,KeyMode

		lea	$dff000,a0
		VBLANK
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)
		VBLANK
		move	#$7fff,$96(a0)
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		move	#$00ff,$9e(a0)		;ADKONR
		lea	mt_pic,a0
		bsr	CountCRC
Stukaj:		lea	ENDLEVrys,a1
		bsr	decrunch
		lea	mt_ENDLEV,a0
		lea	ENDLEVmus,a1
		bsr	decrunch
		LEA	ENDLEVmus,A0
		bsr	mt_init
		lea	$dff000,a0
		move.l	VBR_base,a1
		lea	EL_NewLev3(pc),a2
		move.l	a2,$6c(a1)
		lea	NewLev2(pc),a2
		move.l	a2,$68(a1)
		VBLANK
		move	$dff00a,el_oldmouse
		move	#$8380,$96(a0)
		move	#$c028,$9a(a0)

		lea	ENDLEVscr,a1
		moveq	#0,d0
		move	#2000-1,d1
.clrs:		move.l	d0,(a1)+
		dbf	d1,.clrs
		lea	ENDLEVcopper+64+2,a1
		moveq	#15,d0
.setY:		move	#$0fe0,(a1)
		lea	4(a1),a1
		dbf	d0,.setY

		move.l	#ENDLEVcopper,$80(a0)
		move	#0,$88(a0)

		lea	el_Text+4(pc),a1
		lea	NazwyPoziomow(pc),a2
		move	STRUCTURE+60,d0
		subq	#1,d0
		mulu	#12,d0
		lea	(a2,d0.w),a2
		move.l	(a2)+,(a1)
		move.l	(a2)+,4(a1)
		move.l	(a2)+,8(a1)
		move	STRUCTURE+62,d0
		addi	#48,d0
		move.b	d0,el_poz

		move	STRUCTURE+10,d0		;killed
		moveq	#2,d1
		lea	el_zab(pc),a1
		bsr	el_Przelicz
		move	STRUCTURE+8,d0		;bomb
		neg	d0
		lsr	d0
		moveq	#0,d1
		lea	el_bmb(pc),a1
		bsr	el_Przelicz

		moveq	#0,d0
		move	STRUCTURE+12,d0		;hours
		divu	#3600,d0
		cmpi	#9,d0
		beq.s	.el_1
		bmi.s	.el_1
		move	#9,d0
.el_1:		moveq	#0,d1
		lea	el_tim(pc),a1
		bsr	el_Przelicz
		moveq	#0,d0
		move	STRUCTURE+12,d0		;mins
		divu	#3600,d0
		swap	d0
		andi.l	#$ffff,d0
		divu	#60,d0
		moveq	#1,d1
		lea	el_tim+2(pc),a1
		bsr	el_Przelicz
		moveq	#0,d0
		move	STRUCTURE+12,d0		;secs
		divu	#60,d0
		swap	d0
		moveq	#1,d1
		lea	el_tim+5(pc),a1
		bsr	el_Przelicz


		lea	el_Text(pc),a1
		bsr	el_Drukuj

		move	#-13,el_RamkaPos
		move	#176,el_RamkaPos+2
		move	#3,el_RamkaPos+4
		move	#13,el_RamkaPos+6
		move	#176,el_RamkaPos+8
		move	#3,el_RamkaPos+10
		move	#0,el_r1
		move	#1,el_Rflag
		move	#0,el_Rflag+2
		move	#0,el_postab

		lea	ENDLEVcopper,a3
		lea	ENDLEVrys+32000,a4
		moveq	#15,d4
		bsr	se_setcolors
		move	#13,el_RamkaPos

		move.l	#0,el_DIR
		move.l	#0,el_DIR+4
		move	#0,el_DIR+8
;---------------
		lea	$dff000,a0
el_savloop1:	VBLANK
		tst.l	el_DIR+4
		beq.s	.el_sl1
		eori	#1,el_r1
		bne.s	.el_sl2
		move	#13,el_RamkaPos
		bra.s	.el_sl1
.el_sl2:	move	#25,el_RamkaPos
		bra.w	.el_sl1
.el_sl1:	move.l	#0,el_DIR
		move.l	#0,el_DIR+4
		tst	el_DIR+8
		beq.s	el_savloop1
		move	#0,el_DIR+8

		tst	el_r1
		beq.w	el_MYK			;jesli 'NIE'

;---------------
		move	#12,el_Ramkapos
		move	#48,el_Ramkapos+2
		move	#16,el_Ramkapos+4

		lea	ENDLEVscr,a1
		moveq	#0,d0
		move	#2000-1,d1
.clrs:		move.l	d0,(a1)+
		dbf	d1,.clrs

		lea	SAVEGAMES+72,a1			;kopiuj tytuly
		lea	el_st1+3(pc),a2
		moveq	#4,d7
.copsn:		lea	(a1),a3
		lea	(a2),a4
.csn1:		move.b	(a3)+,d0
		cmpi.b	#"@",d0
		beq.s	.csn2
		move.b	d0,(a4)+
		bra.s	.csn1
.csn2:		lea	128(a1),a1
		lea	19(a2),a2
		dbf	d7,.copsn

		lea	el_saText(pc),a1
		bsr	el_Drukuj
		move	#0,el_dir+8

		lea	$dff000,a0
		moveq	#40,d0
.kio:		VBLANK
		dbf	d0,.kio
		move	#0,el_DIR+8

		lea	el_PosTab(pc),a1
		lea	el_DIR(pc),a2
		lea	el_RamkaPos(pc),a3
el_savloop2:	VBLANK
		tst	(a2)			;up
		beq.s	.el_sl1
		subi	#1,(a1)
		bpl.s	.el_sl1
		move	#5,(a1)
.el_sl1:	tst	2(a2)			;down
		beq.s	.el_sl2
		addi	#1,(a1)
		cmpi	#6,(a1)
		bne.s	.el_sl2
		move	#0,(a1)
.el_sl2:	move	(a1),d0
		mulu	#6,d0
		move.l	2(a1,d0.w),(a3)
		move	6(a1,d0.w),4(a3)
		move.l	#0,el_DIR
		move.l	#0,el_DIR+4
		tst	el_DIR+8
		beq.s	el_savloop2
		move	#0,el_DIR+8

		cmpi	#5,(a1)
		beq.w	el_MYK			;jesli 'PONIECHAJ'
;---------------
		move	(a1),d0
		lea	el_st1(pc),a1
		move	d0,d1
		mulu	#19,d1
		lea	3(a1,d1.w),a1		;screen title
		moveq	#15,d1
.wow:		move.b	#32,(a1,d1.w)		;clr screen title
		dbf	d1,.wow
		move	d0,d1
		mulu	#128,d1
		lea	SAVEGAMES,a2
		lea	(a2,d1.w),a3		;slot addr
		lea	72(a3),a2		;slot title
		lea	NazwyPoziomow2(pc),a4
		move	STRUCTURE+60,d0
		subq	#1,d0
		mulu	#14,d0
		lea	(a4,d0.w),a4		;nazwa poziomu

		move	#1,88(a5)		;set zajete
		lea	STRUCTURE,a5		;copy slot
		moveq	#31,d0
.copst:		move.l	(a5)+,(a3)+
		dbf	d0,.copst

.allela:	move.b	(a4)+,d0		;copy level name
		cmpi.b	#"@",d0
		beq.s	.all2
		move.b	d0,(a1)+		;screen
		move.b	d0,(a2)+		;slot
		bra.s	.allela
.all2:		move.b	el_poz(pc),d0
		move.b	d0,(a1)+
		move.b	d0,(a2)+
		move.b	#"@",(a2)+
		
		lea	el_saText(pc),a1
		bsr	el_Drukuj

		lea	iff_screen,a1
		lea	STRUCTURE+$300,a2	;copy start slot
		moveq	#31,d0
.copst1:	move.l	(a2)+,(a1)+
		dbf	d0,.copst1
		lea	SAVEGAMES,a2		;copy all slots
		move	#160-1,d0
.copst2:	move.l	(a2)+,(a1)+
		dbf	d0,.copst2

;---------------

		lea	$100(a1),a0
		move.l	#"CYT4",d1
		moveq	#4,d3
		bsr	dl_check
		move.l	#ENDLEVcopper,$80(a0)
		move	#0,$88(a0)

el_Slooop:	move.l	#-1,dl_DataArea_s
		move.l	#-1,dl_DataArea_s+4
		move	dl_disk,d0		;DRIVe
		move	#1,d1			;START SECTOR (0-1760)
		moveq	#2,d2			;NR OF SECTORS_s
		move	#$8001,d3		;1 - save, 0 - load
		lea	iff_screen,a0		;what
		lea	dl_buffer,a1		;buffer ($3200)
		bsr.w	dl_START_s
		lea	$dff000,a0

		tst	d0
		beq.s	el_wozOK
		move	#-1,el_RamkaPos		;if save error

		lea	ENDLEVscr,a1
		moveq	#0,d0
		move	#2000-1,d1
.clrs:		move.l	d0,(a1)+
		dbf	d1,.clrs
		lea	el_erText(pc),a1
		bsr	el_Drukuj
		move	#0,el_DIR+8

.klawaj:	tst	el_DIR+8
		beq.s	.klawaj
		bra.s	el_Slooop


el_wozOK:	move	#-1,el_RamkaPos		;if save error
		lea	ENDLEVscr,a1
		moveq	#0,d0
		move	#2000-1,d1
.clrs2:		move.l	d0,(a1)+
		dbf	d1,.clrs2
		lea	el_okText(pc),a1
		bsr	el_Drukuj

		lea	$dff000,a0
		moveq	#80,d0
.kio:		VBLANK
		dbf	d0,.kio

;---------------
;el_GoAway:	VBLANK
;		btst.b	#2,$16(a0)
;		beq.s	el_MYK
;		btst.b	#6,$bfe001
;		beq.s	el_MYK
;		btst.b	#7,$bfe001
;		beq.s	el_MYK
;		bra.s	el_GoAway

el_MYK:

		move	#0,el_DIR+8
		lea	ENDLEVcopper,a3
		moveq	#31,d4
		bsr	fadecolors
		lea	$dff000,a0
		VBLANK
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		bsr	mt_end
		move	#0,KeyMode
		movem.l	(sp)+,ALL
		rts

;---------------
;a1 - dest, d0 - num, d1 - ilosc cyfr
el_Przelicz:	lea	1(a1,d1.w),a1
el_p1:		moveq	#0,d2
		move	d0,d2
		divu	#10,d2
		swap	d2
		addi	#48,d2
		move.b	d2,-(a1)
		swap	d2
		move	d2,d0
		dbf	d1,el_p1
		rts

;---------------
el_Drukuj:	movem.l	ALL,-(sp)
		lea	ENDLEVscr,a5
el_DrukLoop:	moveq	#0,d0
		move.b	(a1)+,d0
		bne.s	el_d1
		move.b	(a1)+,d0		;new pos
		moveq	#0,d1
		move.b	(a1)+,d1
		mulu	#40,d1
		add	d0,d1
		lea	(a5,d1.w),a2
		bra.s	el_DrukLoop
el_d1:		bmi.s	el_EndDruk
el_d2:		lea	(a2),a3
		lea	KaneFont,a4
		subi	#32,d0
		cmpi	#32,d0
		bmi.s	el_d3
		subq	#1,d0
el_d3:		move	d0,d1			;fix 8*16 font
		andi	#1,d1
		lsr	d0
		lsl	#5,d0
		or	d1,d0
		lea	(a4,d0.w),a4
		moveq	#15,d0
el_CopFont:	move.b	(a4),(a3)
		lea	2(a4),a4
		lea	40(a3),a3
		dbf	d0,el_CopFont
		lea	1(a2),a2
		bra.s	el_DrukLoop
el_EndDruk:	movem.l	(sp)+,ALL
		rts

;---------------
;---------------
;Skroluj:	dc.w	1,2

EL_NewLev3:	movem.l ALL,-(sp)
		bsr	mt_music

		bsr	GetDirs

;		subi	#1,skroluj+2
;		bpl.s	.el_nl0
;		move	#2,skroluj+2
;		move	#1,skroluj
;.el_nl0:
		lea	el_RamkaPos(pc),a1
		lea	ENDLEVscr,a2
		move	2(a1),d1
		move	(a1),d0
		bmi.w	el_n1
		cmp	6(a1),d0
		bne.s	el_nNewPos
		cmp	8(a1),d1
		bne.w	el_nNewPos

		subi	#1,el_Rflag
		bne.s	el_n1
		move	#20,el_Rflag
		move	(a1),d0
		move	2(a1),d1
		move	4(a1),d2
		eori	#1,el_Rflag+2
		bne.s	el_n2
		bsr	el_nUsun
		bra.s	el_n1
el_n2:		bsr	el_nPostaw
		bra.s	el_n1

el_nNewPos:	move	6(a1),d0
		move	8(a1),d1
		move	10(a1),d2
		bsr	el_nUsun
		lea	ENDLEVscr,a2
		move	(a1),d0
		move	2(a1),d1
		move	4(a1),d2
		move	d0,6(a1)
		move	d1,8(a1)
		move	d2,10(a1)
		bsr	el_nPostaw
		move	#1,el_Rflag
		move	#0,el_Rflag+2
el_n1:
		movem.l	(sp)+,ALL
		move	#$20,$dff09c
		rte

el_nUsun:	mulu	#40,d1
		add	d1,d0
		subq	#1,d0
		lea	(a2,d0.w),a2
		move	d2,d1
		lea	1(a2),a3
		lea	[40*16]+1(a2),a4
		subq	#1,d1
.el_nu1:	move.b	#0,(a3)+
		move.b	#0,(a4)+
		dbf	d1,.el_nu1
		moveq	#14,d1
.el_nu2:	move.b	#0,40(a2)
		move.b	#0,41(a2,d2.w)
		lea	40(a2),a2
		dbf	d1,.el_nu2
		rts

el_nPostaw:	mulu	#40,d1
		add	d1,d0
		subq	#1,d0
		lea	(a2,d0.w),a2
		move	d2,d1
		lea	1(a2),a3
		lea	[40*16]+1(a2),a4
		subq	#1,d1
.el_nu1:	move.b	#-1,(a3)+
		move.b	#-1,(a4)+
		dbf	d1,.el_nu1
		moveq	#14,d1
.el_nu2:	move.b	#1,40(a2)
		move.b	#$80,41(a2,d2.w)
		lea	40(a2),a2
		dbf	d1,.el_nu2
		rts

;---------------
el_oldmouse:	dc.w	0
el_pos:		dc.w	0,0

GetDirs:	lea	el_DIR(pc),a1
		lea	el_oldmouse(pc),a3
		move	$dff00a,d0
		move	d0,d1
		andi	#$ff,d0			;x
		lsr	#8,d1			;y
		move.b	1(a3),d2
		move.b	(a3),d3
		move.b	d0,1(a3)
		move.b	d1,(a3)
		sub.b	d2,d0
		sub.b	d3,d1
		ext	d0
		ext	d1
		add	d0,el_pos
		add	d1,el_pos+2
		move	el_pos,d0
		move	el_pos+2,d1
		tst.b	d1
		bmi.s	el_m1
		cmpi.b	#30,d1
		bmi.s	el_m2
		move	#1,2(a1)		;down
		move	#0,el_pos+2
		bra.s	el_m2
el_m1:		neg	d1
		cmpi.b	#30,d1
		bmi.s	el_m2
		move	#1,(a1)			;up
		move	#0,el_pos+2
el_m2:		tst.b	d0
		bmi.s	el_m3
		cmpi.b	#50,d0
		bmi.s	el_m0
		move	#1,6(a1)		;right
		move	#0,el_pos
		bra.s	el_m0
el_m3:		neg	d0
		cmpi.b	#50,d0
		bmi.s	el_m0
		move	#1,4(a1)		;left
		move	#0,el_pos
el_m0:

		tst	el_odczekaj
		beq.s	el_check
		subi	#1,el_odczekaj
		bra.w	el_joy_no

el_check:	move	$c(a0),d2
		btst	#1,d2
		beq.s	el_joy_left
		move	#1,6(a1)
		move	#10,el_odczekaj
el_joy_left:	btst	#9,d2
		beq.s	el_joy_up
		move	#1,4(a1)
		move	#10,el_odczekaj
el_joy_up:	move	d2,d3
		lsr	d3
		eori	d2,d3
		move	d3,d2
		andi	#$100,d3
		beq.s	el_joy_down
		move	#1,(a1)
		move	#10,el_odczekaj
		bra.s	el_joy_no
el_joy_down:	andi	#1,d2
		beq.s	el_joy_no
		move	#1,2(a1)
		move	#10,el_odczekaj
el_joy_no:
		lea	$dff000,a0
		btst.b	#2,$16(a0)
		beq.s	el_nl1
		btst.b	#6,$bfe001
		beq.s	el_nl1
		btst.b	#7,$bfe001
		bne.s	el_nl2
el_nl1:		move	#1,el_DIR+8
el_nl2:
		IFNE	do_protect
		PRINTT	," INTERRUPT PROTECTION ON.",
		move.l	VBR_base,a1
		lea	-20(a1),a1
		addi	#3,$24+20+2(a1)
		moveq	#7,d7
.sc_act1:	addi	#1,$a0+20+2(a1)
		lea	4(a1),a1
		dbf	d7,.sc_act1
		ENDC
		rts
;---------------

el_RamkaPos:	dc.w	-13,176,3,13,176,3		;posX, posY, szer
el_Rflag:	dc.w	1,0

el_Dir:		dc.w	0,0,0,0,0		;up,down,left,right,enter
el_r1:		dc.w	0			;0 - left(NIE), 1 - right
el_odczekaj:	dc.w	0
;---------------

el_text:
dc.b	0,6,25,"              POZIOM "
el_poz:	dc.b	"  UKOnCZONY!"
dc.b	0,1,85,"ILOsc ZABITYCH PRZECIWNIKoW: "
el_zab:	dc.b	"   "
dc.b	0,1,100,"CZAS PRZECHODZENIA:          "
el_tim:	dc.b	" :  :  "
dc.b	0,1,115,"POSIADANE CZesCI BOMBY:      "
el_bmb:	dc.b	" "
dc.b	0,6,160,"CZY CHCESZ ZAPISAc STAN GRY?"
dc.b	0,13,178,"NIE         TAK"
dc.b	-1

el_satext:
dc.b	0,8,20,"WYBIERZ POZYCJe DO ZAPISU"
el_st1:
dc.b	0,12,50,"                "
dc.b	0,12,70,"                "
dc.b	0,12,90,"                "
dc.b	0,12,110,"                "
dc.b	0,12,130,"                "
dc.b	0,15,160,"PONIECHAJ"
dc.b	-1

el_ertext:
dc.b	0,10,80,"ODBEZPIECZ DYSK 4 !!!"
dc.b	-1

el_oktext:
dc.b	0,19,80,"OK !"
dc.b	-1

EVEN
el_postab:
dc.w	0
dc.w	12,48,16
dc.w	12,68,16
dc.w	12,88,16
dc.w	12,108,16
dc.w	12,128,16
dc.w	15,158,9

;-------------------------------------------------------------------
;deat sequence - from $52000
DEATHSEQ:	movem.l	ALL,-(sp)
		lea	$dff000,a0
		VBLANK
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)
		VBLANK
		move	#$7fff,$96(a0)
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		move	#$00ff,$9e(a0)		;ADKONR
		move	#$8380,$96(a0)

		lea	DeathMEM,a0
		move.l	#"CYT5",d1
		moveq	#5,d3
		bsr	dl_check
		move.l	#copper0,$dff080
		move	#0,$dff088
		lea	$dff000,a0
		VBLANK

		lea	DETname(pc),a0
		move	dl_disk(pc),d0
		addi	#48,d0
		move.b	d0,2(a0)		;drive
		lea	DeathMEM-$2000,a1	;load death seq
		lea	dl_buffer,a2
		jsr	FileLoader		;load map

;		lea	DeathMEM-$2000,a0	;load death seq
;		moveq	#34*2,d0
;		moveq	#9*2,d1
;		bsr	dl_START

		lea	DeathMEM-$2000,a0
		lea	DeathMEM,a1
		bsr	decrunch

		jsr	DeathMEM
		lea	$dff000,a0
		VBLANK
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)
		VBLANK
		move	#$7fff,$96(a0)
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		move	#$00ff,$9e(a0)		;ADKONR
		move	#$8380,$96(a0)
		movem.l	(sp)+,ALL
		rts

DETname:	dc.b	"DF0:DET",0

;-------------------------------------------------------------------
;NIE ZMIENIAC NIC!!! sprawdzanie sumy!!!

SprawdzZab:	movem.l	ALL,-(sp)
		lea	ProtCode,a0		;run PROT again
		lea	$5a000,a1
		lea	(a1),a2
		bsr	decrunch
		jsr	(a2)
rura:		lea	$dff000,a0
		VBLANK
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)
		move	#$7fff,$96(a0)
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		move	#$00ff,$9e(a0)
		move	#$8380,$96(a0)
		movem.l	(sp)+,ALL
		rts

;-------------------------------------------------------------------
;NIE ZMIENIAC NIC!!! sprawdzanie sumy!!!
StartGame:	bsr	LoadFirstData
		move	#1,LoadGfx

LevelLoop:	lea	STRUCTURE,a2
		lea	ETAPY,a3
		move	60(a2),d0		;kompleks (1,2,...)
		subq	#1,d0
		add	d0,d0
		add	d0,d0
		lea	(a3,d0.w),a3
		addi	#1,62(a2)		;jump to next level
		move	62(a2),d0		;level in komplex (1,2,3)

;sprawdzana suma kontrolna !!!
CRCsum:		subq	#1,d0
		move.b	(a3,d0.w),d1
		beq.s	WybierzNext
		cmpi.b	#2,d1
		bne.s	NieNastepny1
		bsr	SprawdzZab
		moveq	#0,d0
WybierzNext:	bra.s	wyb1
NieNastepny1:	bra.s	NieNastepny
;az do tad nie zmieniac - suma kontrolna!!!

wyb1:
;wywalic !
;  addi	#1,60(a2)
;  cmpi	#9,60(a2)
;  bne.s	pluk
;  move	#1,60(a2)
;  pluk:
;bsr do wyboru poziomu... zachowaj rejestry !
		bsr	MAPA

		move.l	#copper0,$dff080
		move	#0,$dff088
;		move	#0,62(a2)
		move	#1,LoadGfx
		bra.s	LevelLoop

NieNastepny:	cmpi.b	#1,d1
		bne.s	NieKoniec
		bsr	END_PART2		;koniec!!!
		bra	s

NieKoniec:	cmpi.b	#1,1(a3,d0.w)
		bne.s	nk2
		move.l	#"KANE",92(a2)		;indicate last level
nk2:
		move.b	d1,MAPname+6		;map A,B,C

		movem.l	ALL,-(sp)
		lea	iff_screen+$1000,a0	;find disk 5
		move.l	#"CYT5",d1
		moveq	#5,d3
		bsr	dl_check
		move.l	#copper0,$dff080
		move	#0,$dff088
		movem.l	(sp)+,ALL

		tst	LoadGfx
		beq.s	NieLoadGFX
		move	#0,LoadGfx
		cmpi	#8,STRUCTURE+60
		bne.s	fufaj
		bsr	SprawdzZab2		;zabezpieczenie
fufaj:		lea	FileStructure1(pc),a1
		move	60(a2),d0		;kompleks nr
		addi	#48,d0
		move.b	d0,5(a1)
		move.b	d0,8+5(a1)
		move.b	d0,16+5(a1)
		move.b	d0,24+5(a1)
		move.b	d0,32+5(a1)
		move.b	d0,40+5(a1)		;fix map nr. too
		bsr	LoadFiles
NieLoadGFX:
		move	dl_disk(pc),d0
		addi	#48,d0
		move.b	d0,MAPname+2
;---------------
		lea	MAPname(pc),a0
		lea	iff_screen+$1000,a1
		lea	dl_buffer,a2
		jsr	FileLoader		;load map
		moveq	#0,d0
		move	d1,d0
		lea	iff_screen+$1000,a0
		lea	$2b600,a1
		bsr	decrunch2

		lea	ENGINE,a0		;decomp. engine
		move.l	MEMORY,a1
		addi.l	#$6000,a1
		lea	(a1),a2
		bsr	decrunch
;bra wwww
		jsr	(a2)			;RUN GAME!!!
		lea	$dff000,a0
		VBLANK
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)
		move	#$7fff,$96(a0)
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		move	#$00ff,$9e(a0)
		move	#$8380,$96(a0)

;---------------
		bsr	RememberOpt
		tst	d0
		beq	s			;if ESC - quit !
		bpl.s	GoodExit
		bsr	DEATHSEQ		;if dead
		bra	s
GoodExit:	lea	STRUCTURE,a1
		move	10(a1),d0
		add	d0,90(a1)		;total enemies killed
		bsr	ENDLEVEL_PART
		bra.w	LevelLoop


ETAPY:	dc.b	"AB",2,0	;1	0-to next level, 1-end!
	dc.b	"ABC",0		;2
	dc.b	"ABC",0		;3
	dc.b	"ABC",0		;4
	dc.b	"ABC",0		;5
	dc.b	"ABC",0		;6
	dc.b	"ABC",0		;7
	dc.b	"A",1,0,0	;8

FileStructure1:	dc.b	"DF0:W1A",0
		dc.b	"DF0:W1B",0
		dc.b	"DF0:E1A",0
		dc.b	"DF0:E1B",0
		dc.b	"DF0:C1A",0
MAPname:	dc.b	"DF0:M1A",0

LoadGfx:	dc.w	0
;-------------------------------------------------------------------
RememberOpt:	movem.l	ALL,-(sp)
		lea	STRUCTURE,a1
		lea	OptSav(pc),a2
		move	#1,(a2)+
		move	(a1),(a2)
		move	2(a1),2(a2)
		move	4(a1),4(a2)
		movem.l	(sp)+,ALL
		rts

OptSav:		dc.w	0		;1-opts remembered
		dc.w	0,0,0

;-------------------------------------------------------------------
LoadFirstData:	movem.l	ALL,-(sp)
		lea	$dff000,a0
		VBLANK
		move	#0,do_flash
		lea	MAINcopper,a3
		moveq	#31,d4
		bsr	fadecolors

		move.l	#copper0,$80(a0)
		move	#0,$88(a0)
		VBLANK
		move	#$7fff,$96(a0)
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		move	#$00ff,$9e(a0)		;ADKONR
		move	#$8380,$96(a0)
		bsr	mt_end

		lea	iff_screen,a0
		move.l	#"CYT4",d1
		moveq	#4,d3
		bsr	dl_check
		move.l	#copper0,$dff080
		move	#0,$dff088

		move.l	#-1,dl_DataArea_s
		move.l	#-1,dl_DataArea_s+4
		lea	iff_screen,a0		;IWT tab
		lea	dl_buffer,a1
		move	dl_disk(pc),d0
		move	#21*2*11,d1
		move	#3*2*11,d2
		move	#$8000,d3
		bsr	dl_START_s
		lea	iff_screen,a0		;IWT tab
		lea	iff_screen+$2000,a1
		bsr	decrunch

		lea	iff_screen+$2000,a1
		move.l	MEMORY,a2
		add.l	#$52c40,a2		;items
		move	#7019,d0
.copI:		move.l	(a1)+,(a2)+
		dbf	d0,.copI
		lea	$71a00,a2		;window
		move	#9999,d0
.copW:		move.l	(a1)+,(a2)+
		dbf	d0,.copW
		lea	$7d642,a2		;text
		move	#1700,d0
.copT:		move.l	(a1)+,(a2)+
		dbf	d0,.copT

		lea	iff_screen,a0		;ST tab
		lea	dl_buffer,a1
		move	dl_disk(pc),d0
		move	#24*2*11,d1
		move	#10*2*11,d2
		move	#$8000,d3
		bsr	dl_START_s
		lea	iff_screen,a0		;ST tab
		lea	$34e58,a1
		bsr	decrunch
		move.l	#0,$595ec		;erase "KANE"

		movem.l	(sp)+,ALL
		rts


;-------------------------------------------------------------------
;input: a1 - file structure: WA,WB,EA,EB,C
;load walls, enemies, colors
LoadFiles:	movem.l	ALL,-(sp)
		move.l	a1,-(sp)

;		lea	iff_screen+$1000,a0
;		move.l	#"CYT5",d1
;		moveq	#5,d3
;		bsr	dl_check
;		move.l	#copper0,$dff080
;		move	#0,$dff088

		move	dl_disk(pc),d0
		addi	#48,d0
		move.l	(sp),a1
		move.b	d0,2(a1)		;fix drive num
		move.b	d0,8+2(a1)
		move.b	d0,16+2(a1)
		move.b	d0,24+2(a1)
		move.b	d0,32+2(a1)

		move.l	(sp)+,a3
		lea	(a3),a0
		lea	dl_buffer,a2
		lea	iff_screen+$1000,a1
		jsr	FileLoader		;WALLS A
		moveq	#0,d0
		move	d1,d0

		move.l	MEMORY,a4
		lea	iff_screen+$1000,a0
		addi.l	#$10c00,a4
		lea	(a4),a1
		bsr	decrunch2

		lea	8(a3),a0
		lea	iff_screen+$1000,a1
		jsr	FileLoader		;WALLS B
		moveq	#0,d0
		move	d1,d0

		lea	iff_screen+$1000,a0
		addi.l	#83200,a4
		lea	(a4),a1
		bsr	decrunch2

		lea	16(a3),a0
		lea	iff_screen+$1000,a1
		jsr	FileLoader		;ENEMY A
		moveq	#0,d0
		move	d1,d0

		lea	iff_screen+$1000,a0
		addi.l	#83200,a4
		lea	(a4),a1
		bsr	decrunch2

		lea	24(a3),a0
		bsr	TestHaslo		;sprawdz haslo!!!
		lea	iff_screen+$1000,a1
		jsr	FileLoader		;ENEMY B
		moveq	#0,d0
		move	d1,d0

		lea	iff_screen+$1000,a0
		addi.l	#52000,a4
		lea	(a4),a1
		bsr	decrunch2

		lea	32(a3),a0
		lea	$7d600,a1
		jsr	FileLoader		;COLORS

		bsr	TestHaslo
		movem.l	(sp)+,ALL
		rts


;-------------------------------------------------------------------
;a3 - copper, a4 - color tab, d4 - color nr-1

setcolors:	move	#0,d0
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


;a3 - copper, a4 - color tab, d4 - color nr-1

se_SETCOLORS:	move	#15,d0
se_setcol:	lea	(a3),a1
		lea	(a4),a2
		move	d4,d3				;color nr. - 1
se_scol1:	move	(a2),d1
		andi	#$f,d1
		move	2(a1),d2
		andi	#$f,d2
		cmpi	d1,d2
		beq.s	se_scol2
		addi	#1,2(a1)
se_scol2:	move	(a2),d1
		andi	#$f0,d1
		move	2(a1),d2
		andi	#$f0,d2
		cmpi	d1,d2
		beq.s	se_scol3
		addi	#$10,2(a1)
se_scol3:	move	(a2)+,d1
		andi	#$f00,d1
		move	2(a1),d2
		andi	#$f00,d2
		cmpi	d1,d2
		beq.s	se_scol4
		addi	#$100,2(a1)
se_scol4:	addi.l	#4,a1
		dbf	d3,se_scol1
		VBLANK
		VBLANK
		dbf	d0,se_setcol
		rts

;a3 - copperlist, d4 - nr.of colors

fadecolors:	move	#16,d0
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
TestHaslo:	movem.l	ALL,-(sp)
		lea	HASLO,a2
		lea	MAMCIA(pc),a1
		move.l	#$55555555,d0
		move.l	(a2),d1
		eor.l	d0,d1
		move.l	d1,(a1)
		move.l	4(a2),d1
		eor.l	d0,d1
		move.l	d1,4(a1)
		move	8(a2),d1
		eor	d0,d1
		move	d1,8(a1)

		move	6(a1),d1
		move	8(a1),d2
		mulu	#41,d1
		add	d2,d1
		moveq	#4,d2
		lea	ZabTab,a2
		lea	(a2,d1.w),a2
.testit:	move.b	(a1)+,d0
		move.b	(a2)+,d1
		cmp.b	d0,d1
		bne.s	.ByloZle
		dbf	d2,.testit
		bra.s	.ByloOK
.ByloZle:	lea	Engine-1000,a1
		move.l	#-1,d0
		move.l	d0,1000(a1)
		move.l	d0,1004(a1)
		move.l	d0,1008(a1)
.ByloOK:	lea	mamcia(pc),a1
		move.l	#0,(a1)
		move.l	#0,4(a1)
		move	#0,8(a1)
		movem.l	(sp)+,ALL
		rts

mamcia:		dc.w	0,0,0,0,0
;-------------------------------------------------------------------

****************************************************
*** PowerPacker 2.0 FAST decrunch routine (v1.5) ***
*** Resourced by BC/LUZERS			 ***

;a0.l - crunched data
;a1.l - buffer

Decrunch2:	;length in d0
	movem.l	d1-d7/a2-a6,-(sp)
	bra.s	dupa1

Decrunch:
	movem.l	d1-d7/a2-a6,-(sp)
	move.l	(a0),d0			;dlugosc
dupa1:	lea	4(a0),a2
	add.l	d0,a0
	lea	l0494(pc),a5
	moveq	#$18,d6
	moveq	#0,d4
	move.w	#$00FF,d7
	moveq	#1,d5
	move.l	a1,a4
	move.l	-(a0),d1
	tst.b	d1
	beq.s	l0266
	lsr.l	#1,d5
	beq.s	l02A2
l0262:	subq.b	#1,d1
	lsr.l	d1,d5
l0266:	lsr.l	#8,d1
	add.l	d1,a1
l026A:	lsr.l	#1,d5
	beq.s	l02A8
l026E:	bcs	l0310
	moveq	#0,d2
l0274:	moveq	#0,d1
	lsr.l	#1,d5
	beq.s	l02AE
l027A:	roxl.w	#1,d1
	lsr.l	#1,d5
	beq.s	l02B4
l0280:	roxl.w	#1,d1
	add.w	d1,d2
	subq.w	#3,d1
	beq.s	l0274
	moveq	#0,d0
l028A:	move.b	d5,d4
	lsr.l	#8,d5
	beq.s	l02C6
l0290:	move.b	-$0080(a5,d4.w),d0
	move.b	d0,-(a1)
	dbra	d2,l028A

	cmp.l	a1,a4
	bcs.s	l0310
	bra	l03F0

l02A2:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l0262

l02A8:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l026E

l02AE:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l027A

l02B4:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l0280

l02BA:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l0316

l02C0:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l031C

l02C6:	move.b	$007F(a5,d4.w),d0
	move.l	-(a0),d5
	move.w	d5,d3
	lsl.w	d0,d3
	bchg	d0,d3
	eor.w	d3,d4
	and.w	d7,d4
	moveq	#8,d1
	sub.w	d0,d1
	lsr.l	d1,d5
	add.w	d6,d0
	bset	d0,d5
	bra.s	l0290

l02E2:	move.b	$007F(a5,d4.w),d0
	move.l	-(a0),d5
	move.w	d5,d3
	lsl.w	d0,d3
	bchg	d0,d3
	eor.w	d3,d4
	and.w	d7,d4
	moveq	#8,d1
	sub.w	d0,d1
	lsr.l	d1,d5
	add.w	d6,d0
	bset	d0,d5
	bra.s	l0324

l02FE:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l035E

l0304:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l0364

l030A:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l036A

l0310:	moveq	#0,d2
	lsr.l	#1,d5
	beq.s	l02BA
l0316:	roxl.w	#1,d2
	lsr.l	#1,d5
	beq.s	l02C0
l031C:	roxl.w	#1,d2
	move.b	d5,d4
	lsr.l	#8,d5
	beq.s	l02E2
l0324:	moveq	#0,d3
	move.b	-$0080(a5,d4.w),d3
	cmp.w	#3,d2
	bne.s	l03AC
	bclr	#7,d3
	beq.s	l037E
	moveq	#13,d0
	sub.b	0(a2,d2.w),d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,d0
	jmp	l035A(pc,d0.w)

l0348:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l0370

l034E:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l0376

l0354:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l037C

l035A:	lsr.l	#1,d5
	beq.s	l02FE
l035E:	roxl.w	#1,d3
	lsr.l	#1,d5
	beq.s	l0304
l0364:	roxl.w	#1,d3
	lsr.l	#1,d5
	beq.s	l030A
l036A:	roxl.w	#1,d3
	lsr.l	#1,d5
	beq.s	l0348
l0370:	roxl.w	#1,d3
	lsr.l	#1,d5
	beq.s	l034E
l0376:	roxl.w	#1,d3
	lsr.l	#1,d5
	beq.s	l0354
l037C:	roxl.w	#1,d3
l037E:	moveq	#0,d1
	lsr.l	#1,d5
	beq.s	l039A
l0384:	roxl.w	#1,d1
	lsr.l	#1,d5
	beq.s	l03A0
l038A:	roxl.w	#1,d1
	lsr.l	#1,d5
	beq.s	l03A6
l0390:	roxl.w	#1,d1
	add.w	d1,d2
	subq.w	#7,d1
	beq.s	l037E
	bra.s	l03DC

l039A:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l0384

l03A0:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l038A

l03A6:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l0390

l03AC:	moveq	#13,d0
	sub.b	0(a2,d2.w),d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,d0
	jmp	l03BE(pc,d0.w)

l03BE:	lsr.l	#1,d5
	beq.s	l03F6
l03C2:	roxl.w	#1,d3
	lsr.l	#1,d5
	beq.s	l03FC
l03C8:	roxl.w	#1,d3
	lsr.l	#1,d5
	beq.s	l0402
l03CE:	roxl.w	#1,d3
	lsr.l	#1,d5
	beq.s	l0408
l03D4:	roxl.w	#1,d3
	lsr.l	#1,d5
	beq.s	l040E
l03DA:	roxl.w	#1,d3
l03DC:	move.b	0(a1,d3.w),-(a1)
l03E0:	move.b	0(a1,d3.w),-(a1)
	dbra	d2,l03E0

	cmp.l	a1,a4
	bcs	l026A
l03F0:	movem.l	(sp)+,d1-d7/a2-a6
	rts

l03F6:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l03C2

l03FC:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l03C8

l0402:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l03CE

l0408:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l03D4

l040E:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l03DA

	or.l	#$40C020A0,d0
	bra.s	l03FC

	dc.l	$109050D0,$30B070F0,$088848C8,$28A868E8,$189858D8
	dc.l	$38B878F8,$048444C4,$24A464E4,$149454D4,$34B474F4
	dc.l	$0C8C4CCC,$2CAC6CEC,$1C9C5CDC,$3CBC7CFC,$028242C2
	dc.l	$22A262E2,$129252D2,$32B272F2,$0A8A4ACA,$2AAA6AEA
	dc.l	$1A9A5ADA,$3ABA7AFA,$068646C6,$26A666E6,$169656D6
	dc.l	$36B676F6,$0E8E4ECE,$2EAE6EEE,$1E9E5EDE,$3EBE7EFE
l0494:	dc.l	$018141C1,$21A161E1,$119151D1,$31B171F1,$098949C9
	dc.l	$29A969E9,$199959D9,$39B979F9,$058545C5,$25A565E5
	dc.l	$159555D5,$35B575F5,$0D8D4DCD,$2DAD6DED,$1D9D5DDD
	dc.l	$3DBD7DFD,$038343C3,$23A363E3,$139353D3,$33B373F3
	dc.l	$0B8B4BCB,$2BAB6BEB,$1B9B5BDB,$3BBB7BFB,$078747C7
	dc.l	$27A767E7,$179757D7,$37B777F7,$0F8F4FCF,$2FAF6FEF
	dc.l	$1F9F5FDF,$3FBF7FFF,$00010102,$02020203,$03030303
	dc.l	$03030304,$04040404,$04040404,$04040404,$04040405
	dc.l	$05050505,$05050505,$05050505,$05050505,$05050505
	dc.l	$05050505,$05050505,$05050506,$06060606,$06060606
	dc.l	$06060606,$06060606,$06060606,$06060606,$06060606
	dc.l	$06060606,$06060606,$06060606,$06060606,$06060606
	dc.l	$06060606,$06060606,$06060606,$06060607,$07070707
	dc.l	$07070707,$07070707,$07070707,$07070707,$07070707
	dc.l	$07070707,$07070707,$07070707,$07070707,$07070707
	dc.l	$07070707,$07070707,$07070707,$07070707,$07070707
	dc.l	$07070707,$07070707,$07070707,$07070707,$07070707
	dc.l	$07070707,$07070707,$07070707,$07070707,$07070707
	dc.l	$07070707,$07070707,$07070707,$07070707,$07070707
	dc.l	$07070700

;-------------------------------------------------------------------
SprawdzZab2:	movem.l	ALL,-(sp)
		lea	ProtCode,a0		;run PROT again
		lea	$5a000,a1
		lea	(a1),a2
		bsr	decrunch
		jsr	(a2)
		bra	rura

;-------------------------------------------------------------------
mt_init:MOVE.L	A0,mt_SongDataPtr
	LEA	250(A0),A1
	MOVE.W	#511,D0
	MOVEQ	#0,D1
mtloop:	MOVE.L	D1,D2
	SUBQ.W	#1,D0
mtloop2:	MOVE.B	(A1)+,D1
	CMP.W	D2,D1
	BGT.S	mtloop
	DBRA	D0,mtloop2
	ADDQ	#1,D2

	MOVE.W	D2,D3
	MULU	#128,D3
	ADD.L	#766,D3
	ADD.L	mt_SongDataPtr(PC),D3
	MOVE.L	D3,mt_LWTPtr

	LEA	mt_SampleStarts(PC),A1
	MULU	#128,D2
	ADD.L	#762,D2
	ADD.L	(A0,D2.L),D2
	ADD.L	mt_SongDataPtr(PC),D2
	ADDQ.L	#4,D2
	MOVE.L	D2,A2
	MOVEQ	#30,D0
mtloop3:	MOVE.L	A2,(A1)+
	MOVEQ	#0,D1
	MOVE.W	(A0),D1
	ADD.L	D1,D1
	ADD.L	D1,A2
	LEA	8(A0),A0
	DBRA	D0,mtloop3

	OR.B	#2,$BFE001
	lea	mt_speed(PC),A4
	MOVE.B	#6,(A4)
	CLR.B	mt_counter-mt_speed(A4)
	CLR.B	mt_SongPos-mt_speed(A4)
	CLR.W	mt_PatternPos-mt_speed(A4)
mt_end:	LEA	$DFF096,A0
	CLR.W	$12(A0)
	CLR.W	$22(A0)
	CLR.W	$32(A0)
	CLR.W	$42(A0)
	MOVE.W	#$F,(A0)
	RTS

mt_music:
	MOVEM.L	D0-D4/D7/A0-A6,-(SP)
	ADDQ.B	#1,mt_counter
	MOVE.B	mt_counter(PC),D0
	CMP.B	mt_speed(PC),D0
	BLO.S	mt_NoNewNote
	CLR.B	mt_counter
	TST.B	mt_PattDelTime2
	BEQ.S	mt_GetNewNote
	BSR.S	mt_NoNewAllChannels
	BRA.W	mt_dskip

mt_NoNewNote:
	BSR.S	mt_NoNewAllChannels
	BRA.W	mt_NoNewPosYet

mt_NoNewAllChannels:
	LEA	$DFF090,A5
	LEA	mt_chan1temp-44(PC),A6
	BSR.W	mt_CheckEfx
	BSR.W	mt_CheckEfx
	BSR.W	mt_CheckEfx
	BRA.W	mt_CheckEfx

mt_GetNewNote:
	MOVE.L	mt_SongDataPtr(PC),A0
	LEA	(A0),A3
	LEA	122(A0),A2	;pattpo
	LEA	762(A0),A0	;patterndata
	CLR.W	mt_DMACONtemp

	LEA	$DFF090,A5
	LEA	mt_chan1temp-44(PC),A6
	BSR.S	mt_DoVoice
	BSR.S	mt_DoVoice
	BSR	mt_DoVoice
	BSR	mt_DoVoice
	BRA.W	mt_SetDMA

mt_DoVoice:
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	mt_SongPos(PC),D0
	LEA	128(A2),A2
	MOVE.B	(A2,D0.W),D1
	MOVE.W	mt_PatternPos(PC),D2
	LSL	#7,D1
	LSR.W	#1,D2
	ADD.W	D2,D1
	LEA	$10(A5),A5
	LEA	44(A6),A6

	TST.L	(A6)
	BNE.S	mt_plvskip
	BSR.W	mt_PerNop
mt_plvskip:
	MOVE.W	(A0,D1.W),D1
	LSL.W	#2,D1
	MOVE.L	A0,-(sp)
	MOVE.L	mt_LWTPtr(PC),A0
	MOVE.L	(A0,D1.W),(A6)
	MOVE.L	(sp)+,A0
	MOVE.B	2(A6),D2
	AND.L	#$F0,D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	AND.B	#$F0,D0
	OR.B	D0,D2
	BEQ	mt_SetRegs
	MOVEQ	#0,D3
	LEA	mt_SampleStarts(PC),A1
	SUBQ	#1,D2
	MOVE	D2,D4
	ADD	D2,D2
	ADD	D2,D2
	LSL	#3,D4
	MOVE.L	(A1,D2.L),4(A6)
	MOVE.W	(A3,D4.W),8(A6)
	MOVE.W	(A3,D4.W),40(A6)
	MOVE.W	2(A3,D4.W),18(A6)
	MOVE.L	4(A6),D2	; Get start
	MOVE.W	4(A3,D4.W),D3	; Get repeat
	BEQ.S	mt_NoLoop
	MOVE.W	D3,D0		; Get repeat
	ADD.W	D3,D3
	ADD.L	D3,D2		; Add repeat
	ADD.W	6(A3,D4.W),D0	; Add replen
	MOVE.W	D0,8(A6)

mt_NoLoop:
	MOVE.L	D2,10(A6)
	MOVE.L	D2,36(A6)
	MOVE.W	6(A3,D4.W),14(A6)	; Save replen
	MOVE.B	19(A6),9(A5)	; Set volume
mt_SetRegs:
	MOVE.W	(A6),D0
	AND.W	#$0FFF,D0
	BEQ.W	mt_CheckMoreEfx	; If no note

	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0E50,D0
	BEQ.S	mt_DoSetFineTune

	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#3,D0	; TonePortamento
	BEQ.S	mt_ChkTonePorta
	CMP.B	#5,D0
	BEQ.S	mt_ChkTonePorta
	CMP.B	#9,D0	; Sample Offset
	BNE.S	mt_SetPeriod
	BSR.W	mt_CheckMoreEfx
	BRA.S	mt_SetPeriod

mt_ChkTonePorta:
	BSR.W	mt_SetTonePorta
	BRA.W	mt_CheckMoreEfx

mt_DoSetFineTune:
	BSR.W	mt_SetFineTune

mt_SetPeriod:
	MOVEM.L	D1/A1,-(SP)
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1

mt_SetPeriod2:
	LEA	mt_PeriodTable(PC),A1
	MOVEQ	#36,D7
mt_ftuloop:
	CMP.W	(A1)+,D1
	BHS.S	mt_ftufound
	DBRA	D7,mt_ftuloop
mt_ftufound:
	MOVEQ	#0,D1
	MOVE.B	18(A6),D1
	LSL	#3,D1
	MOVE	D1,D0
	LSL	#3,D1
	ADD	D0,D1
	MOVE.W	-2(A1,D1.W),16(A6)

	MOVEM.L	(SP)+,D1/A1

	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0ED0,D0 ; Notedelay
	BEQ.W	mt_CheckMoreEfx

	MOVE.W	20(A6),$DFF096
	BTST	#2,30(A6)
	BNE.S	mt_vibnoc
	CLR.B	27(A6)
mt_vibnoc:
	BTST	#6,30(A6)
	BNE.S	mt_trenoc
	CLR.B	29(A6)
mt_trenoc:
	MOVE.L	4(A6),(A5)	; Set start
	MOVE.W	8(A6),4(A5)	; Set length
	MOVE.W	16(A6),6(A5)	; Set period
	MOVE.W	20(A6),D0
	OR.W	D0,mt_DMACONtemp
	BRA.W	mt_CheckMoreEfx
 
mt_SetDMA:
	OR.W	#$8000,mt_DMACONtemp
	bsr.w	mt_WaitDMA

	MOVE.W	mt_dmacontemp(pc),$DFF096
	bsr.w	mt_WaitDMA

	LEA	$DFF0A0,A5
	LEA	mt_chan1temp(PC),A6
	MOVE.L	10(A6),(A5)
	MOVE.W	14(A6),4(A5)
	MOVE.L	54(A6),$10(A5)
	MOVE.W	58(A6),$14(A5)
	MOVE.L	98(A6),$20(A5)
	MOVE.W	102(A6),$24(A5)
	MOVE.L	142(A6),$30(A5)
	MOVE.W	146(A6),$34(A5)

mt_dskip:
	lea	mt_speed(PC),A4
	ADDQ.W	#4,mt_PatternPos-mt_speed(A4)
	MOVE.B	mt_PattDelTime-mt_speed(A4),D0
	BEQ.S	mt_dskc
	MOVE.B	D0,mt_PattDelTime2-mt_speed(A4)
	CLR.B	mt_PattDelTime-mt_speed(A4)
mt_dskc:	TST.B	mt_PattDelTime2-mt_speed(A4)
	BEQ.S	mt_dska
	SUBQ.B	#1,mt_PattDelTime2-mt_speed(A4)
	BEQ.S	mt_dska
	SUBQ.W	#4,mt_PatternPos-mt_speed(A4)
mt_dska:	TST.B	mt_PBreakFlag-mt_speed(A4)
	BEQ.S	mt_nnpysk
	SF	mt_PBreakFlag-mt_speed(A4)
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	CLR.B	mt_PBreakPos-mt_speed(A4)
	LSL	#2,D0
	MOVE.W	D0,mt_PatternPos-mt_speed(A4)
mt_nnpysk:
	CMP.W	#256,mt_PatternPos-mt_speed(A4)
	BLO.S	mt_NoNewPosYet
mt_NextPosition:
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	LSL	#2,D0
	MOVE.W	D0,mt_PatternPos-mt_speed(A4)
	CLR.B	mt_PBreakPos-mt_speed(A4)
	CLR.B	mt_PosJumpFlag-mt_speed(A4)
	ADDQ.B	#1,mt_SongPos-mt_speed(A4)
	AND.B	#$7F,mt_SongPos-mt_speed(A4)
	MOVE.B	mt_SongPos(PC),D1
	MOVE.L	mt_SongDataPtr(PC),A0
	CMP.B	248(A0),D1
	BLO.S	mt_NoNewPosYet
	CLR.B	mt_SongPos-mt_speed(A4)
mt_NoNewPosYet:	
	lea	mt_speed(PC),A4
	TST.B	mt_PosJumpFlag-mt_speed(A4)
	BNE.S	mt_NextPosition
	MOVEM.L	(SP)+,D0-D4/D7/A0-A6
	RTS

mt_CheckEfx:
	LEA	$10(A5),A5
	LEA	44(A6),A6
	BSR.W	mt_UpdateFunk
	MOVE.W	2(A6),D0
	AND.W	#$0FFF,D0
	BEQ.S	mt_PerNop
	MOVE.B	2(A6),D0
	MOVEQ	#$0F,D1
	AND.L	D1,D0
	BEQ.S	mt_Arpeggio
	SUBQ	#1,D0
	BEQ.W	mt_PortaUp
	SUBQ	#1,D0
	BEQ.W	mt_PortaDown
	SUBQ	#1,D0
	BEQ.W	mt_TonePortamento
	SUBQ	#1,D0
	BEQ.W	mt_Vibrato
	SUBQ	#1,D0
	BEQ.W	mt_TonePlusVolSlide
	SUBQ	#1,D0
	BEQ.W	mt_VibratoPlusVolSlide
	SUBQ	#8,D0
	BEQ.W	mt_E_Commands
SetBack:	MOVE.W	16(A6),6(A5)
	ADDQ	#7,D0
	BEQ.W	mt_Tremolo
	SUBQ	#3,D0
	BEQ.W	mt_VolumeSlide
mt_Return2:
	RTS

mt_PerNop:
	MOVE.W	16(A6),6(A5)
	RTS

mt_Arpeggio:
	MOVEQ	#0,D0
	MOVE.B	mt_counter(PC),D0
	DIVS	#3,D0
	SWAP	D0
	TST.W	D0
	BEQ.S	mt_Arpeggio2
	SUBQ	#2,D0
	BEQ.S	mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	LSR.B	#4,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio2:
	MOVE.W	16(A6),6(A5)
	RTS

mt_Arpeggio1:
	MOVE.B	3(A6),D0
	AND.W	#15,D0
mt_Arpeggio3:
	ADD.W	D0,D0
	LEA	mt_PeriodTable(PC),A0

	MOVEQ	#0,D1
	MOVE.B	18(A6),D1
	LSL	#3,D1
	MOVE	D1,D2
	LSL	#3,D1
	ADD	D2,D1
	ADD.L	D1,A0

	MOVE.W	16(A6),D1
	MOVEQ	#36,D7
mt_arploop:
	CMP.W	(A0)+,D1
	BHS.S	mt_Arpeggio4
	DBRA	D7,mt_arploop
	RTS

mt_Arpeggio4:
	MOVE.W	-2(A0,D0.W),6(A5)
	RTS

mt_FinePortaUp:
	TST.B	mt_counter
	BNE.S	mt_Return2
	MOVE.B	#$0F,mt_LowMask
mt_PortaUp:
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	SUB.W	D0,16(A6)
	MOVE.W	16(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#113,D0
	BPL.S	mt_PortaUskip
	AND.W	#$F000,16(A6)
	OR.W	#113,16(A6)
mt_PortaUskip:
	MOVE.W	16(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS	
 
mt_FinePortaDown:
	TST.B	mt_counter
	BNE.W	mt_Return2
	MOVE.B	#$0F,mt_LowMask
mt_PortaDown:
	CLR.W	D0
	MOVE.B	3(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	ADD.W	D0,16(A6)
	MOVE.W	16(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#856,D0
	BMI.S	mt_PortaDskip
	AND.W	#$F000,16(A6)
	OR.W	#856,16(A6)
mt_PortaDskip:
	MOVE.W	16(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS

mt_SetTonePorta:
	MOVE.L	A0,-(SP)
	MOVE.W	(A6),D2
	AND.W	#$0FFF,D2
	LEA	mt_PeriodTable(PC),A0

	MOVEQ	#0,D0
	MOVE.B	18(A6),D0
	ADD	D0,D0
	MOVE	D0,D7
	ADD	D0,D0
	ADD	D0,D0
	ADD	D0,D7
	LSL	#3,D0
	ADD	D7,D0
	ADD.L	D0,A0

	MOVEQ	#0,D0
mt_StpLoop:
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_StpFound
	ADDQ	#2,D0
	CMP.W	#37*2,D0
	BLO.S	mt_StpLoop
	MOVEQ	#35*2,D0
mt_StpFound:
	BTST	#3,18(A6)
	BEQ.S	mt_StpGoss
	TST.W	D0
	BEQ.S	mt_StpGoss
	SUBQ	#2,D0
mt_StpGoss:
	MOVE.W	(A0,D0.W),D2
	MOVE.L	(SP)+,A0
	MOVE.W	D2,24(A6)
	MOVE.W	16(A6),D0
	CLR.B	22(A6)
	CMP.W	D0,D2
	BEQ.S	mt_ClearTonePorta
	BGE.W	mt_Return2
	MOVE.B	#1,22(A6)
	RTS

mt_ClearTonePorta:
	CLR.W	24(A6)
	RTS

mt_TonePortamento:
	MOVE.B	3(A6),D0
	BEQ.S	mt_TonePortNoChange
	MOVE.B	D0,23(A6)
	CLR.B	3(A6)
mt_TonePortNoChange:
	TST.W	24(A6)
	BEQ.W	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	23(A6),D0
	TST.B	22(A6)
	BNE.S	mt_TonePortaUp
mt_TonePortaDown:
	ADD.W	D0,16(A6)
	MOVE.W	24(A6),D0
	CMP.W	16(A6),D0
	BGT.S	mt_TonePortaSetPer
	MOVE.W	24(A6),16(A6)
	CLR.W	24(A6)
	BRA.S	mt_TonePortaSetPer

mt_TonePortaUp:
	SUB.W	D0,16(A6)
	MOVE.W	24(A6),D0
	CMP.W	16(A6),D0
	BLT.S	mt_TonePortaSetPer
	MOVE.W	24(A6),16(A6)
	CLR.W	24(A6)

mt_TonePortaSetPer:
	MOVE.W	16(A6),D2
	MOVE.B	31(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_GlissSkip
	LEA	mt_PeriodTable(PC),A0

	MOVEQ	#0,D0
	MOVE.B	18(A6),D0
	LSL	#3,D0
	MOVE	D0,D1
	LSL	#3,D0
	ADD	D1,D0
	ADD.L	D0,A0

	MOVEQ	#0,D0
mt_GlissLoop:
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_GlissFound
	ADDQ	#2,D0
	CMP.W	#36*2,D0
	BLO.S	mt_GlissLoop
	MOVEQ	#35*2,D0
mt_GlissFound:
	MOVE.W	(A0,D0.W),D2
mt_GlissSkip:
	MOVE.W	D2,6(A5) ; Set period
	RTS

mt_Vibrato:
	MOVE.B	3(A6),D0
	BEQ.S	mt_Vibrato2
	MOVE.B	26(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_vibskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_vibskip:
	MOVE.B	3(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_vibskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_vibskip2:
	MOVE.B	D2,26(A6)
mt_Vibrato2:
	MOVE.B	27(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVE.B	30(A6),D2
	AND.W	#$03,D2
	BEQ.S	mt_vib_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_vib_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_vib_set
mt_vib_rampdown:
	TST.B	27(A6)
	BPL.S	mt_vib_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_rampdown2:
	MOVE.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_sine:
	MOVE.B	0(A4,D0.W),D2
mt_vib_set:
	MOVE.B	26(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#7,D2
	MOVE.W	16(A6),D0
	TST.B	27(A6)
	BMI.S	mt_VibratoNeg
	ADD.W	D2,D0
	BRA.S	mt_Vibrato3
mt_VibratoNeg:
	SUB.W	D2,D0
mt_Vibrato3:
	MOVE.W	D0,6(A5)
	MOVE.B	26(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,27(A6)
	RTS

mt_TonePlusVolSlide:
	BSR.W	mt_TonePortNoChange
	BRA.W	mt_VolumeSlide

mt_VibratoPlusVolSlide:
	BSR.S	mt_Vibrato2
	BRA.W	mt_VolumeSlide

mt_Tremolo:
	MOVE.B	3(A6),D0
	BEQ.S	mt_Tremolo2
	MOVE.B	28(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_treskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_treskip:
	MOVE.B	3(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_treskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_treskip2:
	MOVE.B	D2,28(A6)
mt_Tremolo2:
	MOVE.B	29(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	30(A6),D2
	LSR.B	#4,D2
	AND.B	#$03,D2
	BEQ.S	mt_tre_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_tre_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_tre_set
mt_tre_rampdown:
	TST.B	27(A6)
	BPL.S	mt_tre_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_rampdown2:
	MOVE.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_sine:
	MOVE.B	0(A4,D0.W),D2
mt_tre_set:
	MOVE.B	28(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	19(A6),D0
	TST.B	29(A6)
	BMI.S	mt_TremoloNeg
	ADD.W	D2,D0
	BRA.S	mt_Tremolo3
mt_TremoloNeg:
	SUB.W	D2,D0
mt_Tremolo3:
	BPL.S	mt_TremoloSkip
	CLR.W	D0
mt_TremoloSkip:
	CMP.W	#$40,D0
	BLS.S	mt_TremoloOk
	MOVE.W	#$40,D0
mt_TremoloOk:
	MOVE.W	D0,8(A5)
	MOVE.B	28(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,29(A6)
	RTS

mt_SampleOffset:
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	BEQ.S	mt_sononew
	MOVE.B	D0,32(A6)
mt_sononew:
	MOVE.B	32(A6),D0
	LSL.W	#7,D0
	CMP.W	8(A6),D0
	BGE.S	mt_sofskip
	SUB.W	D0,8(A6)
	ADD.W	D0,D0
	ADD.L	D0,4(A6)
	RTS
mt_sofskip:
	MOVE.W	#$0001,8(A6)
	RTS

mt_VolumeSlide:
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.S	mt_VolSlideDown
mt_VolSlideUp:
	ADD.B	D0,19(A6)
	CMP.B	#$40,19(A6)
	BMI.S	mt_vsuskip
	MOVE.B	#$40,19(A6)
mt_vsuskip:
	MOVE.B	19(A6),9(A5)
	RTS

mt_VolSlideDown:
	MOVE.B	3(A6),D0
	AND.W	#$0F,D0
mt_VolSlideDown2:
	SUB.B	D0,19(A6)
	BPL.S	mt_vsdskip
	CLR.B	19(A6)
mt_vsdskip:
	MOVE.B	19(A6),9(A5)
	RTS

mt_PositionJump:
	MOVE.B	3(A6),D0
	SUBQ	#1,D0
	MOVE.B	D0,mt_SongPos
mt_pj2:	CLR.B	mt_PBreakPos
	ST 	mt_PosJumpFlag
	RTS

mt_VolumeChange:
	MOVE.B	3(A6),D0
	CMP.B	#$40,D0
	BLS.S	mt_VolumeOk
	MOVEQ	#$40,D0
mt_VolumeOk:
	MOVE.B	D0,19(A6)
	MOVE.B	D0,9(A5)
	RTS

mt_PatternBreak:
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	MOVE.W	D0,D2
	LSR.B	#4,D0
	ADD	D0,D0
	MOVE	D0,D1
	ADD	D0,D0
	ADD	D0,D0
	ADD	D1,D0
	AND.B	#$0F,D2
	ADD.B	D2,D0
	CMP.B	#63,D0
	BHI.S	mt_pj2
	MOVE.B	D0,mt_PBreakPos
	ST	mt_PosJumpFlag
	RTS

mt_SetSpeed:
	MOVE.B	3(A6),D0
	BEQ.W	mt_Return2
	CLR.B	mt_counter
	MOVE.B	D0,mt_speed
	RTS

mt_CheckMoreEfx:
	BSR.W	mt_UpdateFunk
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	SUB.B	#9,D0
	BEQ.W	mt_SampleOffset
	SUBQ	#2,D0
	BEQ.W	mt_PositionJump
	SUBQ	#1,D0
	BEQ	mt_VolumeChange
	SUBQ	#1,D0
	BEQ.S	mt_PatternBreak
	SUBQ	#1,D0
	BEQ.S	mt_E_Commands
	SUBQ	#1,D0
	BEQ.S	mt_SetSpeed
	BRA.W	mt_PerNop

mt_E_Commands:
	MOVE.B	3(A6),D0
	AND.W	#$F0,D0
	LSR.B	#4,D0
	BEQ.S	mt_FilterOnOff
	SUBQ	#1,D0
	BEQ.W	mt_FinePortaUp
	SUBQ	#1,D0
	BEQ.W	mt_FinePortaDown
	SUBQ	#1,D0
	BEQ.S	mt_SetGlissControl
	SUBQ	#1,D0
	BEQ	mt_SetVibratoControl

	SUBQ	#1,D0
	BEQ	mt_SetFineTune
	SUBQ	#1,D0

	BEQ	mt_JumpLoop
	SUBQ	#1,D0
	BEQ.W	mt_SetTremoloControl
	SUBQ	#2,D0
	BEQ.W	mt_RetrigNote
	SUBQ	#1,D0
	BEQ.W	mt_VolumeFineUp
	SUBQ	#1,D0
	BEQ.W	mt_VolumeFineDown
	SUBQ	#1,D0
	BEQ.W	mt_NoteCut
	SUBQ	#1,D0
	BEQ.W	mt_NoteDelay
	SUBQ	#1,D0
	BEQ.W	mt_PatternDelay
	BRA.W	mt_FunkIt

mt_FilterOnOff:
	MOVE.B	3(A6),D0
	AND.B	#1,D0
	ADD.B	D0,D0
	AND.B	#$FD,$BFE001
	OR.B	D0,$BFE001
	RTS	

mt_SetGlissControl:
	MOVE.B	3(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,31(A6)
	OR.B	D0,31(A6)
	RTS

mt_SetVibratoControl:
	MOVE.B	3(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,30(A6)
	OR.B	D0,30(A6)
	RTS

mt_SetFineTune:
	MOVE.B	3(A6),D0
	AND.B	#$0F,D0
	MOVE.B	D0,18(A6)
	RTS

mt_JumpLoop:
	TST.B	mt_counter
	BNE.W	mt_Return2
	MOVE.B	3(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_SetLoop
	TST.B	34(A6)
	BEQ.S	mt_jumpcnt
	SUBQ.B	#1,34(A6)
	BEQ.W	mt_Return2
mt_jmploop: 	MOVE.B	33(A6),mt_PBreakPos
	ST	mt_PBreakFlag
	RTS

mt_jumpcnt:
	MOVE.B	D0,34(A6)
	BRA.S	mt_jmploop

mt_SetLoop:
	MOVE.W	mt_PatternPos(PC),D0
	LSR	#2,D0
	MOVE.B	D0,33(A6)
	RTS

mt_SetTremoloControl:
	MOVE.B	3(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,30(A6)
	OR.B	D0,30(A6)
	RTS

mt_RetrigNote:
	MOVE.L	D1,-(SP)
	MOVE.B	3(A6),D0
	AND.W	#$0F,D0
	BEQ.S	mt_rtnend
	MOVEQ	#0,d1
	MOVE.B	mt_counter(PC),D1
	BNE.S	mt_rtnskp
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	BNE.S	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
mt_rtnskp:
	DIVU	D0,D1
	SWAP	D1
	TST.W	D1
	BNE.S	mt_rtnend
mt_DoRetrig:
	MOVE.W	20(A6),$DFF096	; Channel DMA off
	MOVE.L	4(A6),(A5)	; Set sampledata pointer
	MOVE.W	8(A6),4(A5)	; Set length
	BSR.W	mt_WaitDMA
	MOVE.W	20(A6),D0
	BSET	#15,D0
	MOVE.W	D0,$DFF096
	BSR.W	mt_WaitDMA
	MOVE.L	10(A6),(A5)
	MOVE.L	14(A6),4(A5)
mt_rtnend:
	MOVE.L	(SP)+,D1
	RTS

mt_VolumeFineUp:
	TST.B	mt_counter
	BNE.W	mt_Return2
	MOVE.B	3(A6),D0
	AND.W	#$F,D0
	BRA.W	mt_VolSlideUp

mt_VolumeFineDown:
	TST.B	mt_counter
	BNE.W	mt_Return2
	MOVE.B	3(A6),D0
	AND.W	#$0F,D0
	BRA.W	mt_VolSlideDown2

mt_NoteCut:
	MOVE.B	3(A6),D0
	AND.W	#$0F,D0
	CMP.B	mt_counter(PC),D0
	BNE.W	mt_Return2
	CLR.B	19(A6)
	CLR.W	8(A5)
	RTS

mt_NoteDelay:
	MOVE.B	3(A6),D0
	AND.W	#$0F,D0
	CMP.B	mt_Counter(PC),D0
	BNE.W	mt_Return2
	MOVE.W	(A6),D0
	BEQ.W	mt_Return2
	MOVE.L	D1,-(SP)
	BRA.W	mt_DoRetrig

mt_PatternDelay:
	TST.B	mt_counter
	BNE.W	mt_Return2
	MOVE.B	3(A6),D0
	AND.W	#$0F,D0
	TST.B	mt_PattDelTime2
	BNE.W	mt_Return2
	ADDQ.B	#1,D0
	MOVE.B	D0,mt_PattDelTime
	RTS

mt_FunkIt:
	TST.B	mt_counter
	BNE.W	mt_Return2
	MOVE.B	3(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,31(A6)
	OR.B	D0,31(A6)
	TST.B	D0
	BEQ.W	mt_Return2
mt_UpdateFunk:
	MOVEM.L	D1/A0,-(SP)
	MOVEQ	#0,D0
	MOVE.B	31(A6),D0
	LSR.B	#4,D0
	BEQ.S	mt_funkend
	LEA	mt_FunkTable(PC),A0
	MOVE.B	(A0,D0.W),D0
	ADD.B	D0,35(A6)
	BTST	#7,35(A6)
	BEQ.S	mt_funkend
	CLR.B	35(A6)

	MOVE.L	10(A6),D0
	MOVEQ	#0,D1
	MOVE.W	14(A6),D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	MOVE.L	36(A6),A0
	ADDQ.L	#1,A0
	CMP.L	D0,A0
	BLO.S	mt_funkok
	MOVE.L	10(A6),A0
mt_funkok:
	MOVE.L	A0,36(A6)
	NEG.B	(A0)
	SUBQ.B	#1,(A0)
mt_funkend:
	MOVEM.L	(SP)+,D1/A0
	RTS

mt_WaitDMA:
	MOVEQ	#3,D0
mt_WaitDMA2:
	MOVE.B	$DFF006,D1
mt_WaitDMA3:
	CMP.B	$DFF006,D1
	BEQ.S	mt_WaitDMA3
	DBF	D0,mt_WaitDMA2
	RTS

mt_FunkTable: dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_VibratoTable:
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

mt_PeriodTable:
; Tuning 0, Normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

mt_chan1temp:	blk.l	5
		dc.w	1
		blk.w	21
		dc.w	2
		blk.w	21
		dc.w	4
		blk.w	21
		dc.w	8
		blk.w	11

mt_SampleStarts:	blk.l	31,0

mt_SongDataPtr:	dc.l 0
mt_LWTPtr:	dc.l 0
mt_oldirq:	dc.l 0

mt_speed:	dc.b 6
mt_counter:	dc.b 0
mt_SongPos:	dc.b 0
mt_PBreakPos:	dc.b 0
mt_PosJumpFlag:	dc.b 0
mt_PBreakFlag:	dc.b 0
mt_LowMask:	dc.b 0
mt_PattDelTime:	dc.b 0
mt_PattDelTime2:	dc.b 0,0
mt_PatternPos:	dc.w 0
mt_DMACONtemp:	dc.w 0


;-----------------------------------------------------------------------
;SpaceBalls '9Fingers' trackloader...
;INPUT:	a0	- addr
;	d0	- start track (*2 !)
;	d1	- nr. of tracks to read (*2 !)
; dl_DISK:.w	- drive nr (0,1,2,3)
;OUTPUT:
;	d0	- 0 if all OK, -1 if error (no disk)

************************************************************************

;a0 - destination, d1 - disk id "CYT1", d3 - diskNR: 1,2,...5
;out: d0 - drive nr found ok
dl_check:
		moveq	#0,d2
dl_LOOP:
;		moveq	#40,d4
;		lea	$dff000,a0
;dl_LWAIT:	VBLANK
;		dbf	d4,dl_LWAIT
		movem.l	a0/d1/d2/d3,-(sp)
		move	d2,dl_DISK	;disk Nr
		moveq	#0,d0		;start
		moveq	#2,d1		;nr of tracks
		move	#-1,dl_COUNTER
		bsr	dl_FindDisk
		movem.l	(sp)+,a0/d1/d2/d3
		tst	d0
		bpl.w	dl_DiskID	;if smth read
		movem.l	a0/d1/d2/d3,-(sp)
		moveq	#0,d0		;start
		moveq	#2,d1		;nr of tracks
		bsr	dl_FindDisk
		movem.l	(sp)+,a0/d1/d2/d3
		tst	d0
		bpl.s	dl_DiskID	;if smth read

dl_bad:		addq	#1,d2
		cmpi	#3,d2
		bne.s	dl_LOOP
;... obrazek dysku
		lea	Nload+12,a1
		lea	Nload+[17*14*2],a2
		move	d3,d4
		subq	#1,d4
		add	d4,d4
		lea	(a2,d4.w),a2
		moveq	#[14*2]-1,d0
.cnr:		move	(a2),(a1)		;disk nr
		lea	14(a1),a1
		lea	14(a2),a2
		dbf	d0,.cnr

		lea	Dload+$2670,a1	;disk colors
		lea	DISKcopper,a2
		moveq	#31,d7
.cco:		move	(a1)+,2(a2)
		lea	4(a2),a2
		dbf	d7,.cco

		move.l	a0,-(sp)
		lea	$dff000,a0
		VBLANK
		move.l	#DISKcopper,$80(a0)
		move	#0,$88(a0)
		move.l	(sp)+,a0
		bra.w	dl_check

dl_DiskID:	cmp.l	(a0),d1
		bne.s	dl_bad
		move	d2,d0
		lea	$dff000,a0
		rts

;-----------------------------------------------------------------------
;start from 'dl_START' or 'dl_FINDDISK'...

dl_START:	bsr.s	dl_SetDma
		bsr.w	lbC0001D2	;set drive & wait for disk
lbC000004:	subq	#1,d1
		move	#10,dl_COUNTER+2
		bsr.w	lbC000174
lbC000008:	btst	#0,d0
		bne.b	lbC000018
		bset	#2,$BFD100
		bra.b	lbC000020

lbC000018:	bclr	#2,$BFD100
lbC000020:	bsr.w	lbC00006E
		btst	#0,d0
		beq.b	lbC000032
		move.w	d0,-(sp)
		moveq	#0,d0
		bsr.w	lbC00015A
		move.w	(sp)+,d0
lbC000032:	addq.w	#1,d0
		lea	dl_COUNTER(pc),a3
.dlc:		addq.w	#1,(a3)
		dbra	d1,lbC000008
		andi.w	#$FFFE,(a3)
		bsr.w	lbC000228
		moveq	#0,d0
		rts				;quit here if all OK

dl_SetDma:	moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		moveq	#0,d6
		moveq	#0,d7
		lea	$dff000,a6
		move	#$1002,$9a(a6)	;drive ints clear
		move	#$8010,$96(a6)	;drive DMA on
		rts

dl_FindDisk:	bsr.s	dl_SetDma		;check drive for disk
		bsr.w	lbC0001F6		;if no disk - quit
		tst.w	d5
		bne.b	lbC000052
		bra.w	lbC000004

lbC000052:	move.w	#3,d0
		bsr.w	lbC000142
		moveq	#2,d0
		bsr.w	lbC00015A
		move.w	#3,d0
		bsr.w	lbC000142
		bsr.w	lbC000228
		moveq	#-1,d0
		rts				;here quit if no disk

lbC00006E:	move.w	#$4000,$24(a6)
		move.l	#dl_BUFFER,$20(a6)
		move.w	#$7F00,$9E(a6)
		move.w	#$4489,$7E(a6)
		move.w	#$9500,$9E(a6)
		lea	$BFE001,a5
lbC000094:	btst	#2,(a5)
		beq.b	lbC0000D4
		btst	#5,(a5)
		bne.b	lbC000094
		move.w	#2,$9C(a6)
		move.w	#$9900,$24(a6)
		move.w	#$9900,$24(a6)
lbC0000B2:	btst	#2,(a5)
		beq.b	lbC0000D4
		btst	#1,$1F(a6)
		beq.b	lbC0000B2
		move.w	#$4000,$24(a6)
		bsr.b	lbC0000E0
		lea	dl_COUNTER+2(pc),a3
		tst.w	d2
		beq.b	lbC0000D6
		subq.w	#1,(a3)
		bne.b	lbC00006E
lbC0000D4:	rts

lbC0000D6:	move.w	#10,(a3)
		lea	$1600(a0),a0
		rts

lbC0000E0:	lea	DL_BUFFER,a2
		moveq	#10,d5
		move.l	#$55555555,d7
lbC0000EE:	cmpi.w	#$4489,(a2)+
		bne.b	lbC0000EE
		cmpi.w	#$4489,(a2)
		bne.b	lbC0000FC
		addq.l	#2,a2
lbC0000FC:	move.w	2(a2),d3
		move.w	(6,a2),d4
		and.w	d7,d3
		and.w	d7,d4
		add.w	d3,d3
		or.w	d4,d3
		add.w	d3,d3
		andi.w	#$FF00,d3
		movea.l	a0,a3
		lea	(a3,d3.w),a3
		lea	$38(a2),a2
		moveq	#$7F,d6
lbC00011E:	move.l	$200(a2),d3
		move.l	(a2)+,d4
		and.l	d7,d4
		and.l	d7,d3
		add.l	d4,d4
		or.l	d3,d4
		move.l	d4,(a3)+
		dbra	d6,lbC00011E
		lea	$204(a2),a2
		dbra	d5,lbC0000EE
		moveq	#0,d2
		rts

		moveq	#-1,d2
		rts

lbC000142:	move	d1,-(sp)
lbC000144:	move.b	6(a6),d1
		addi.b	#$32,d1
lbC00014C:	cmp.b	6(a6),d1
		bne.b	lbC00014C
		subq.w	#1,d0
		bne.b	lbC000144
		move	(sp)+,d1
		rts

lbC00015A:	lea	$BFD100,a5
		bclr	#1,(a5)
		or.b	d0,(a5)
		bclr	#0,(a5)
		bset	#0,(a5)
		move.w	#3,d0
		bra.b	lbC000142

lbC000174:	move.w	d0,-(sp)
		move.w	d0,d2
		bclr	#0,d2
		lea	DL_COUNTER(pc),a3
		tst.w	(a3)
		bpl.b	lbC0001A8
		btst	#4,$BFE001
		beq.b	lbC0001A6
lbC00018E:	moveq	#2,d0
		bsr.b	lbC00015A
		btst	#2,$BFE001
		beq.b	lbC0001D0
		btst	#4,$BFE001
		bne.b	lbC00018E
lbC0001A6:	clr.w	(a3)
lbC0001A8:	move.w	DL_COUNTER(pc),d0
		bclr	#0,d0
		sub.w	d0,d2
		tst.w	d2
		beq.b	lbC0001CA
		bpl.b	lbC0001BE
		neg.w	d2
		moveq	#2,d0
		bra.b	lbC0001C0

lbC0001BE:	moveq	#0,d0
lbC0001C0:	lsr.w	#1,d2
		subq.w	#1,d2
lbC0001C4:	bsr.b	lbC00015A
		dbra	d2,lbC0001C4
lbC0001CA:	move.w	(sp)+,d0
		move.w	d0,(a3)
		rts

lbC0001D0:	rts

lbC0001D2:	lea	$BFD100,a5
		move	DL_DISK(pc),d5
		move.b	dl_offsets(pc,d5.w),d5
		neg.b	d5
		or.b	d5,(a5)
		andi.b	#$7F,(a5)
		neg.b	d5
		and.b	d5,(a5)
lbC0001EA:
		btst	#5,$BFE001
		bne.b	lbC0001EA
		rts

lbC0001F6:	lea	$BFD100,a5
		move	DL_DISK(pc),d5
		move.b	dl_offsets(pc,d5.w),d5
		neg.b	d5
		or.b	d5,(a5)
		andi.b	#$7F,(a5)
		neg.b	d5
		and.b	d5,(a5)
		lea	$BFE001,a5
		moveq	#45,d5
lbC000214:
.wp1:		cmp.b	#$ff,6(a6)
		bne.b	.wp1
.wp2:		cmp.b	#$ff,6(a6)
		beq.b	.wp2

		subq	#1,d5			;if no such drive
		bmi.s	lbC000224

		btst	#2,(a5)
		beq.b	lbC000224
		btst	#5,(a5)
		bne.b	lbC000214
		moveq	#0,d5			;ok - disk found
		rts

lbC000224:	moveq	#1,d5			;no disk found
		rts

lbC000228:	lea	$BFD100,a5
		ori.b	#$F8,(a5)
		andi.b	#$87,(a5)
		ori.b	#$F8,(a5)
		rts

dl_Offsets:	dc.b	$f7,$ef,$df,$bf
dl_DISK:	dc.w	0			;drive NR
dl_COUNTER:	dc.w	-1,0			;-1 to init drive
;dl_BUFFER:	blk.b	$3600,0


;-------------------------------------------------------------------
;		... SC HARD SECTOR (!) LOADER AND SAVER ...
;				01.07.1995
;INPUT:
; d0	-	drive
; d1	-	start sector (0 - 1760)
; d2	-	NR of sectors_s
; d3	-	0 - load, 1 - save + $8000 - motor off after load/save
; a0	-	destination/source
; a1	-	buffer ($3200)
;
;OUTPUT:
; d0	-	0 - OK, other - DOS_s error nr.

;---------------------------------------------------------------------
dl_START_s:	movem.l	d1-d7/a0-a5,-(sp)
		link.w	a6,#-$24
		move.w	d0,d4
		andi.w	#3,d4
		move.w	d4,(-$24,a6)
		move.w	d1,(-$22,a6)
		move.w	d2,(-$20,a6)
		move.w	d3,(-$1E,a6)
		move.l	a0,(-$1C,a6)
		move.l	a1,(-$18,a6)
		ror.w	#2,d0
		andi.w	#1,d0
		addq.w	#1,d0
		move.w	d0,(-$14,a6)
		moveq	#0,d0
		move.w	d2,d3
		beq.w	lbC0000C2_s
		moveq	#$1E,d0
		add.w	d1,d3
		cmp.w	#$6E0,d3
		bgt.w	lbC0000F0_s
		andi.l	#$FFFF,d1
		divu.w	#11,d1
		cmpi.w	#1,(-$14,a6)
		beq.b	lbC00005A_s
		add.w	d1,d1
lbC00005A_s:	move.w	d1,(-$12,a6)
		swap	d1
		move.w	d1,(-$10,a6)
		bsr.w	lbC000728_s
		tst.b	(-$1D,a6)
		beq.b	lbC000072_s
		bsr.w	lbC0004DA_s
lbC000072_s:	move.w	(-$10,a6),d0
		moveq	#11,d1
		sub.w	d0,d1
		cmp.w	(-$20,a6),d1
		ble.b	lbC000084_s
		move.w	(-$20,a6),d1
lbC000084_s:	move.w	d1,(-14,a6)
		bsr.w	lbC0000FA_s
		bne.b	lbC0000C2_s
		tst.b	(-$1D,a6)
		beq.b	lbC00009A_s
		bsr.w	lbC0001E8_s
		bne.b	lbC0000C2_s
lbC00009A_s:	move.w	(-$20,a6),d0
		sub.w	(-14,a6),d0
		beq.b	lbC0000C2_s
		move.w	d0,(-$20,a6)
		move.w	(-14,a6),d0
		lsl.l	#8,d0
		add.l	d0,d0
		add.l	d0,(-$1C,a6)
		clr.w	(-$10,a6)
		move.w	(-$14,a6),d0
		add.w	d0,(-$12,a6)
		bra.b	lbC000072_s

lbC0000C2_s:	move.l	d0,-(sp)
		bsr.w	lbC0006FA_s
		bsr.w	lbC0005F6_s
		move.l	(sp)+,d0
		beq.b	lbC0000F0_s
		moveq	#0,d1
		move.w	(-$12,a6),d1
		cmpi.w	#1,(-$14,a6)
		beq.b	lbC0000E0_s
		lsr.w	#1,d1
lbC0000E0_s:	mulu.w	#11,d1
		add.w	(-$10,a6),d1
		add.w	(-6,a6),d1
		move.l	d1,($28,sp)
lbC0000F0_s:	unlk	a6
		tst.l	d0
		movem.l	(sp)+,d1-d7/a0-a5
		rts

lbC0000FA_s:	moveq	#4,d4
lbC0000FC_s:	clr.w	(-4,a6)
		clr.w	(-6,a6)
		clr.w	(-8,a6)
		move.w	(-$12,a6),d2
		bsr.w	lbC000742_s
		bne.w	lbC0001D0_s
		moveq	#$1D,d0
		btst	#2,($BFE001)
		beq.w	lbC0001D0_s
		moveq	#0,d0
		cmpi.b	#2,(-$1D,a6)
		beq.w	lbC0001E2_s
		movea.l	(-$18,a6),a5
		lea	($400,a5),a5
		move.l	#$AAAAAAAA,(a5)
		move.w	#$4489,(4,a5)
		bsr.w	lbC000460_s
		bsr.w	lbC0005F6_s
		bsr.w	lbC0002BC_s
		bne.w	lbC0001D0_s
		move.w	(-12,a6),d0
		beq.b	lbC0001A6_s
		mulu.w	#$440,d0
		lea	(6,a5),a0
		bsr.w	lbC000684_s
		lea	($DFF01e),a4
		bsr.w	lbC000314_s
		bne.b	lbC0001De
		cmpi.b	#1,(-$1D,a6)
		beq.b	lbC000182_s
		move.w	(-6,a6),d0
		sub.w	(-14,a6),d0
		beq.b	lbC0001E2_s
lbC000182_s:	movea.l	(-$18,a6),a5
		lea	($400,a5),a5
		move.w	(-12,a6),d0
		mulu.w	#$440,d0
		adda.l	d0,a5
		move.l	#$AAAAAAAA,(a5)
		move.w	#$4489,(4,a5)
		movea.l	a5,a0
		bsr.w	lbC00063A_s
lbC0001A6_s:	move.w	(-10,a6),d0
		beq.b	lbC0001C4_s
		mulu.w	#$440,d0
		lea	(6,a5),a0
		bsr.w	lbC000684_s
		lea	(-2,a6),a4
		clr.w	(a4)
		bsr.w	lbC000314_s
		bne.b	lbC0001De
lbC0001C4_s:	move.w	(-6,a6),d0
		sub.w	(-14,a6),d0
		beq.b	lbC0001E2_s
		moveq	#$1A,d0
lbC0001D0_s:	move.l	d0,-(sp)
		moveq	#2,d2
		bsr.w	lbC000742_s
		bsr.w	lbC000796_s
		move.l	(sp)+,d0
lbC0001De:	dbra	d4,lbC0000FC_s
lbC0001E2_s:	bsr.w	lbC0006E6_s
		rts

lbC0001E8_s:	moveq	#4,d4
		clr.w	(-6,a6)
		cmpi.b	#2,(-$1D,a6)
		bne.b	lbC000202_s
		move.w	(-$12,a6),d0
		movea.l	(-$18,a6),a0
		bsr.w	lbC000276_s
lbC000202_s:	bsr.w	lbC0007F6_s
		move.l	#$64,d0
		bsr.w	lbC000836_s
		moveq	#$1C,d0
		btst	#3,($BFE001)
		beq.b	lbC00026A_s
		lea	($DFF000),a0
		move.w	#$4000,($24,a0)
		move.l	(-$18,a6),($20,a0)
		move.w	#$6600,($9e,a0)
		move.w	#$9100,($9e,a0)
		cmpi.w	#$50,(-$12,a6)
		bcs.b	lbC000248_s
		move.w	#$A000,($9e,a0)
lbC000248_s:	move.w	#$8010,($96,a0)
		move.w	#2,($9C,a0)
		move.w	#$D961,($24,a0)
		move.w	#$D961,($24,a0)
		bsr.w	lbC0006C2_s
		beq.b	lbC00026A_s
		dbra	d4,lbC000202_s
lbC00026A_s:	move.l	d0,-(sp)
		moveq	#2,d0
		bsr.w	lbC000836_s
		move.l	(sp)+,d0
		rts

lbC000276_s:	move.l	d0,d3
		ori.w	#$FF00,d3
		swap	d3
		move.w	#11,d3
		lea	($400,a0),a0
lbC000286_s:	addq.w	#4,a0
		move.l	#$44894489,(a0)+
		move.l	d3,d0
		bsr.w	lbC00062C_s
		lea	(-8,a0),a0
		bsr.w	lbC00063A_s
		moveq	#$28,d1
		bsr.w	lbC0004C0_s
		bsr.w	lbC00062C_s
		lea	(-8,a0),a0
		bsr.w	lbC00063A_s
		lea	($410,a0),a0
		addi.w	#$100,d3
		subq.b	#1,d3
		bne.b	lbC000286_s
		rts

lbC0002BC_s:	moveq	#10,d2
lbC0002Be:	lea	(6,a5),a0
		move.w	#$40,d0
		bsr.w	lbC000684_s
		bsr.w	lbC0006C2_s
		bne.b	lbC000306_s
		bsr.w	lbC0004AA_s
		beq.b	lbC0002DC_s
		dbra	d2,lbC0002Be
		bra.b	lbC000308_s

lbC0002DC_s:	bsr.w	lbC000472_s
		bne.b	lbC00030C_s
		cmp.w	(-$12,a6),d1
		bne.b	lbC00030C_s
		cmp.b	#11,d2
		bge.b	lbC00030C_s
		cmp.b	#11,d3
		bgt.b	lbC00030C_s
		subq.b	#1,d3
		move.w	d3,(-12,a6)
		move.w	#11,(-10,a6)
		sub.w	d3,(-10,a6)
		moveq	#0,d0
lbC000306_s:	rts

lbC000308_s:	moveq	#$18,d0
		rts

lbC00030C_s:	moveq	#$1B,d0
		rts

lbC000310_s:	moveq	#$19,d0
		rts

lbC000314_s:	movea.l	(-$18,a6),a5
		lea	($400,a5),a5
		move.w	(-8,a6),d0
		mulu.w	#$440,d0
		adda.l	d0,a5
		move.l	#$1770,d0
		bsr.w	lbC000858_s
lbC000330_s:	btst	#1,(1,a4)
		bne.w	lbC000438_s
		bsr.w	lbC00084A_s
		beq.w	lbC00043C_s
		tst.l	($440,a5)
		beq.b	lbC000330_s
		bsr.w	lbC0004AA_s
		bne.b	lbC000308_s
		bsr.w	lbC000472_s
		bne.b	lbC00030C_s
		cmp.w	(-$12,a6),d1
		bne.b	lbC00030C_s
		move.w	d2,d3
		lea	(8,a5),a0
		bsr.w	lbC000494_s
		move.b	#11,d0
		sub.b	(-7,a6),d0
		lea	(8,a5),a0
		bsr.w	lbC00062C_s
		bsr.w	lbC0004BA_s
		lea	($30,a5),a0
		bsr.w	lbC00062C_s
		cmp.w	(-$10,a6),d3
		blt.w	lbC00042A_s
		move.w	(-14,a6),d0
		add.w	(-$10,a6),d0
		cmp.w	d0,d3
		bge.w	lbC00042A_s
		btst	#1,(1,a4)
		bne.w	lbC000438_s
		move.w	(-4,a6),d0
		btst	d3,d0
		bne.w	lbC00042A_s
		cmpi.b	#1,(-$1D,a6)
		bne.b	lbC0003E8_s
		bsr.w	lbC000440_s
		movea.l	(-$1C,a6),a0
		adda.l	d1,a0
		lea	($40,a5),a1
		bsr.w	lbC000542_s
		btst	#1,(1,a4)
		bne.w	lbC000438_s
		lea	($40,a5),a0
		move.w	#$400,d1
		bsr.w	lbC0004C0_s
		lea	($38,a5),a0
		bsr.w	lbC00062C_s
		bsr.w	lbC000450_s
		bra.b	lbC00042A_s

lbC0003E8_s:	lea	($40,a5),a0
		move.w	#$400,d1
		bsr.w	lbC0004C0_s
		move.l	d0,-(sp)
		lea	($38,a5),a0
		bsr.w	lbC000494_s
		cmp.l	(sp)+,d0
		bne.w	lbC000310_s
		btst	#1,(1,a4)
		bne.b	lbC000438_s
		bsr.b	lbC000440_s
		lea	($40,a5),a0
		movea.l	(-$1C,a6),a1
		adda.l	d1,a1
		bsr.w	lbC00050C_s
		bsr.w	lbC000450_s
		move.w	(-6,a6),d0
		cmp.w	(-14,a6),d0
		beq.b	lbC000438_s
lbC00042A_s:		addq.w	#1,(-8,a6)
		cmpi.w	#11,(-8,a6)
		bne.w	lbC000314_s
lbC000438_s:	moveq	#0,d0
		rts

lbC00043C_s:	moveq		#-1,d0
		rts

lbC000440_s:	move.l	d3,d1
		sub.w	(-$10,a6),d1
		move.l	#$200,d0
		mulu.w	d0,d1
		rts

lbC000450_s:	move.w	(-4,a6),d0
		bset	d3,d0
		move.w	d0,(-4,a6)
		addq.w	#1,(-6,a6)
		rts

lbC000460_s:	movea.l	a5,a0
		moveq	#10,d1
		moveq	#0,d0
lbC000466_s:	lea	($440,a0),a0
		move.l	d0,(a0)
		dbra	d1,lbC000466_s
		rts

lbC000472_s:	lea	(8,a5),a0
		bsr.w	lbC000494_s
		move.w	d0,d3
		andi.w	#$FF,d3
		move.w	d0,d2
		lsr.w	#8,d2
		swap	d0
		move.w	d0,d1
		andi.w	#$FF,d1
		lsr.w	#8,d0
		cmp.b	#$FF,d0
		rts

lbC000494_s:	move.l	(a0)+,d0
		move.l	(a0)+,d1
		andi.l	#$55555555,d0
		andi.l	#$55555555,d1
		add.l	d0,d0
		or.l	d1,d0
		rts

lbC0004AA_s:	bsr.w	lbC0004BA_s
		move.l	d0,-(sp)
		lea	($30,a5),a0
		bsr.b	lbC000494_s
		cmp.l	(sp)+,d0
		rts

lbC0004BA_s:	lea	(8,a5),a0
		moveq	#$28,d1
lbC0004C0_s:	move.l	d2,-(sp)
		lsr.w	#2,d1
		subq.w	#1,d1
		moveq	#0,d0
lbC0004C8_s:	move.l	(a0)+,d2
		eor.l	d2,d0
		dbra	d1,lbC0004C8_s
		move.l	(sp)+,d2
		andi.l	#$55555555,d0
		rts

lbC0004DA_s:	movea.l	(-$18,a6),a0
		move.l	#$AAAAAAAA,d0
		move.l	d0,d1
		move.l	d0,d2
		move.l	d0,d3
		move.l	d0,d4
		move.l	d0,d5
		move.l	d0,d6
		move.l	d0,d7
		lea	($400,a0),a1
		cmpi.b	#1,(-$1D,a6)
		beq.b	lbC000502_s
		lea	($32C0,a0),a1
lbC000502_s:	movem.l	d0-d7,-(a1)
		cmpa.l	a1,a0
		bne.b	lbC000502_s
		rts

lbC00050C_s:	move.l	a2,-(sp)
		bsr.w	lbC000602_s
		adda.l	d0,a0
		subq.l	#1,a0
		move.l	a0,($50,a2)
		adda.l	d0,a0
		move.l	a0,($4C,a2)
		adda.l	d0,a1
		subq.l	#1,a1
		move.l	a1,($54,a2)
		move.w	#$1DD8,($40,a2)
		move.w	#2,($42,a2)
		lsl.w	#2,d0
		ori.w	#8,d0
		move.w	d0,($58,a2)
		movea.l	(sp)+,a2
		rts

lbC000542_s:	movem.l	d1-d3/a2,-(sp)
		bsr.w	lbC000602_s
		move.w	d0,d1
		lsl.w	#2,d1
		ori.w	#8,d1
		move.l	a0,($50,a2)
		move.l	a0,($4C,a2)
		move.l	a1,($54,a2)
		move.w	#$1DB1,($40,a2)
		move.w	#0,($42,a2)
		move.w	d1,($58,a2)
		bsr.w	lbC0005F6_s
		move.l	a0,($50,a2)
		move.l	a1,($4C,a2)
		move.l	a1,($54,a2)
		move.w	#$2D8C,($40,a2)
		move.w	d1,($58,a2)
		bsr.w	lbC0005F6_s
		move.l	a0,d2
		add.l	d0,d2
		subq.l	#2,d2
		move.l	a1,d3
		add.l	d0,d3
		add.l	d0,d3
		subq.l	#2,d3
		move.l		d2,($50,a2)
		move.l	d2,($4C,a2)
		move.l	d3,($54,a2)
		move.w	#$DB1,($40,a2)
		move.w	#$1002,($42,a2)
		move.w	d1,($58,a2)
		bsr.w	lbC0005F6_s
		move.l	a1,d3
		add.l	d0,d3
		move.l	a0,($50,a2)
		move.l	d3,($4C,a2)
		move.l	d3,($54,a2)
		move.w	#$1D8C,($40,a2)
		move.w	#0,($42,a2)
		move.w	d1,($58,a2)
		bsr.w	lbC0005F6_s
		move.l	d0,d1
		movea.l	a1,a0
		bsr.w	lbC00063A_s
		adda.l	d1,a0
		bsr.w	lbC00063A_s
		adda.l	d1,a0
		bsr.b	lbC00063A_s
		movem.l	(sp)+,d1-d3/a2
		rts

lbC0005F6_s:	btst	#6,($DFF002)
		bne.b	lbC0005F6_s
		rts

lbC000602_s:	lea	($DFF000),a2
		bsr.b	lbC0005F6_s
		move.w	#$8040,($96,a2)
		move.l	#$FFFFFFFF,($44,a2)
		move.w	#$5555,($70,a2)
		clr.w	($64,a2)
		clr.w	($62,a2)
		clr.w	($66,a2)
		rts

lbC00062C_s:	move.l	d0,-(sp)
		lsr.l	#1,d0
		bsr.w	lbC000658_s
		move.l	(sp)+,d0
		bsr.w	lbC000658_s
lbC00063A_s:	move.b	(a0),d0
		btst	#0,(-1,a0)
		bne.b	lbC000650_s
		btst	#6,d0
		bne.b	lbC000656_s
		bset	#7,d0
		bra.b	lbC000654_s

lbC000650_s:	bclr	#7,d0
lbC000654_s:	move.b	d0,(a0)
lbC000656_s:	rts

lbC000658_s:	andi.l	#$55555555,d0
		move.l	d0,d2
		eori.l	#$55555555,d2
		move.l	d2,d1
		add.l	d2,d2
		lsr.l	#1,d1
		bset	#$1F,d1
		and.l	d2,d1
		or.l	d1,d0
		btst	#0,(-1,a0)
		beq.b	lbC000680_s
		bclr	#$1F,d0
lbC000680_s:	move.l	d0,(a0)+
		rts

lbC000684_s:	lea	($DFF000),a1
		move.w	#$4000,($24,a1)
		move.w	#$8010,($96,a1)
		move.w	#$6600,($9e,a1)
		move.w	#$9500,($9e,a1)
		move.w	#$4489,($7e,a1)
		move.l	a0,($20,a1)
		move.w	#2,($9C,a1)
		lsr.w	#1,d0
		ori.w	#$8000,d0
		move.w	d0,($24,a1)
		move.w	d0,($24,a1)
		rts

lbC0006C2_s:	lea	($DFF000),a1
		move.l	#$1770,d0
		bsr.w	lbC000858_s
lbC0006D2_s:	btst	#1,($1F,a1)
		bne.b	lbC0006E4_s
		bsr.w	lbC00084A_s
		bne.b	lbC0006D2_s
		moveq	#-1,d0
		bra.b	lbC0006E6_s

lbC0006E4_s:	moveq	#0,d0
lbC0006E6_s:	move.w	#2,($DFF09C)
		move.w	#$4000,($DFF024)
		tst.l	d0
		rts

lbC0006FA_s:	move.w	#$400,($DFF09e)
		tst.w	(-$1e,a6)
		bpl.b	lbC000726_s
		moveq	#-1,d1
lbC00070A_s:	move.b	d1,($BFD100)
		move.w	(-$24,a6),d0
		addq.l	#3,d0
		bclr	d0,d1
		move.b	d1,($BFD100)
		bset	d0,d1
		move.b	d1,($BFD100)
lbC000726_s:	rts

lbC000728_s:	moveq	#-1,d1
		move.b	d1,($BFD100)
		bclr	#7,d1
		bsr.b	lbC00070A_s
		move.l	#$C8,d0
		bsr.w	lbC000836_s
		rts

lbC000742_s:	movem.l	d2/d3,-(sp)
		move.l	d2,d3
		bsr.w	lbC0007F6_s
		move.w	(-$24,a6),d0
		add.w	d0,d0
		lea	(dl_DataArea_s,pc),a0
		move.w	(a0,d0.w),d0
		bpl.b	lbC000762_s
		bsr.w	lbC000796_s
		bne.b	lbC000790_s
lbC000762_s:	lsr.w	#1,d0
		lsr.w	#1,d2
		moveq	#1,d1
		sub.w	d0,d2
		beq.b	lbC00077C_s
		bpl.b	lbC000772_s
		moveq	#-1,d1
		neg.w	d2
lbC000772_s:	moveq	#3,d0
		bsr.w	lbC0007CC_s
		subq.w	#1,d2
		bne.b	lbC000772_s
lbC00077C_s:	move.w	(-$24,a6),d0
		add.w	d0,d0
		lea	(dl_DataArea_s,pc),a0
		move.w	d3,(a0,d0.w)
		bsr.w	lbC0007F6_s
		moveq	#0,d0
lbC000790_s:	movem.l	(sp)+,d2/d3
		rts

lbC000796_s:	movem.l	d2,-(sp)
		moveq	#$55,d2
lbC00079C_s:	btst	#4,($BFE001)
		beq.b	lbC0007B6_s
		moveq	#3,d0
		moveq	#-1,d1
		bsr.w	lbC0007CC_s
		dbra	d2,lbC00079C_s
		moveq	#$1e,d0
		bra.b	lbC0007C6_s

lbC0007B6_s:	move.w	(-$24,a6),d0
		add.w	d0,d0
		lea	(dl_DataArea_s,pc),a0
		clr.w	(a0,d0.w)
		moveq	#0,d0
lbC0007C6_s:	movem.l	(sp)+,d2
		rts

lbC0007CC_s:	move.l	d0,-(sp)
		bsr.w	lbC000802_s
		tst.b	d1
		bmi.b	lbC0007DA_s
		bclr	#1,d0
lbC0007DA_s:	bclr	#0,d0
		move.b	d0,($BFD100)
		bset	#0,d0
		move.b	d0,($BFD100)
		move.l	(sp)+,d0
		bsr.w	lbC000836_s
		rts

lbC0007F6_s:	bsr.w	lbC000802_s
		move.b	d0,($BFD100)
		rts

lbC000802_s:	movem.w	d1/d2,-(sp)
		move.w	(-$24,a6),d0
		move.b	($BFD100),d2
		ori.b	#$7F,d2
		addi.b	#3,d0
		bclr	d0,d2
		subi.b	#3,d0
		add.w	d0,d0
		move.w	(dl_DataArea_s,pc,d0.w),d1
		btst	#0,d1
		beq.b	lbC00082e
		bclr	#2,d2
lbC00082e:	move.b	d2,d0
		movem.w	(sp)+,d1/d2
		rts

lbC000836_s:	bsr.w	lbC000858_s
lbC00083A_s:	btst	#0,($BFDE00)
		bne.b	lbC00083A_s
		subq.l	#1,d0
		bne.b	lbC000836_s
		rts

lbC00084A_s:	btst	#0,($BFDE00)
		bne.b	lbC000870_s
		subq.l	#1,d0
		beq.b	lbC000870_s
lbC000858_s:	move.b	#8,($BFDE00)
		move.b	#$CC,($BFD400)
		move.b	#2,($BFD500)
lbC000870_s:	rts

dl_DataArea_s:	dc.w	-1,-1,-1,-1

;-------------------------------------------------------------------
;---------------------------------------------------------------------
iff_helptab:	dc.b	0,3,12,15,48,48+3,48+12,48+15,192
		dc.b	192+3,192+12,192+15,240,240+3,240+12,240+15
;INPUT:
;	A1.l	-	IFF-ANIM structure pointer

iff_REPLAY:	movem.l	d0-a6,-(sp)
		lea	$dff000,a0
		VBLANK
		lea	iff_DoubleTab(pc),a2
		lea	iff_HelpTab(pc),a3
		moveq	#0,d0
iff_DoubLoop:	move	d0,d1
		andi	#15,d1
		move.b	(a3,d1.w),d1
		move	d0,d2
		lsr	#4,d2
		andi	#15,d2
		move.b	(a3,d2.w),d2
		lsl	#8,d2
		ori	d2,d1
		move	d1,(a2)+
		addq	#1,d0
		cmpi	#256,d0
		bne.s	iff_DoubLoop

		lea	$dff000,a0
		lea	4(a1),a1	;skip ANIM
		lea	iff_copper+2,a2
		moveq	#15,d0
iff_CMAP:	move	(a1)+,(a2)
		lea	4(a2),a2
		dbf	d0,iff_CMAP

;----------------------------BODY-----------------------------------
;---------------decompress (ByteRun) and convert

iff_BODY:	move.l	iff_Scron(pc),a2
		lea	40*100*6(a2),a4
		lea	4(a1),a1

iff_convert:	moveq	#0,d0
		move.b	(a1)+,d0
		bmi.s	iff_negval
iff_copy:	moveq	#0,d1
		move.b	(a1)+,d1
		add	d1,d1
		move	iff_DoubleTab(pc,d1.w),(a2)+
		dbf	d0,iff_copy
		cmpa.l	a4,a2		;end of pic?
		bmi.s	iff_convert
		bra.w	iff_ANIM

iff_negval:	neg.b	d0
		moveq	#0,d1
		move.b	(a1)+,d1
		add	d1,d1
		move	iff_DoubleTab(pc,d1.w),d1
iff_negloop:
		move	d1,(a2)+	;if minus value
		dbf	d0,iff_negloop
		cmpa.l	a4,a2		;end of pic?
		bmi.s	iff_convert
		bra.w	iff_ANIM

iff_DoubleTab:	ds.w	256
;-------------------------------------------------------------------
;----------------------------ANIMATE--------------------------------
;-------------------------------------------------------------------
iff_ANIM:
		move.l	iff_scron(pc),a2
		move.l	iff_scron+4(pc),a4
		move	#[100*6*10]-1,d0
iff_SecondPlane:move.l	(a2)+,(a4)+		;copy to buffor2
		dbf	d0,iff_SecondPlane


		VBLANK
		bsr.w	iff_ChangeScreen
		lea	iff_copper,a3
		MOVE.L	a3,$80(A0)		;set copperlist
		move	#0,$88(a0)

	move	#1,DoReplay
	move	#0,ok_go

iff_ANIMLOOP:	tst	ok_go
		beq.s	iff_ANIMLOOP
		move	#0,ok_go
		VBLANK

		bsr.w	iff_ChangeScreen
		move.l	a1,d0
		addq	#1,d0
		andi.l	#-2,d0
		move.l	d0,a1		;even

		cmpi.l	#"DLTA",(a1)+
		bne	iff_END

;----------------------------DLTA-----------------------------------
iff_DLTA:	lea	iff_DoubleTab(pc),a3
		move.l	iff_scron+4(pc),a2	;screen addr
		lea	iff_Ytab,a4

		moveq	#0,d6
		move.b	(a1)+,d6		;get column CNT
	cmpi	#20*6,d6
	bpl.w	iff_END
iff_FracLoop:	move.b	(a1)+,d0
		beq.s	iff_NextRow
		ext	d0
		subq	#2,d0
		lea	(a2),a6
		lea	102*240(a2),a5

iff_Sections:	moveq	#0,d1
		move.b	(a1)+,d1
		beq.s	iff_SameLoop
		bpl.s	iff_ShiftLoop

		andi	#$7f,d1
		subq	#1,d1
	cmpi	#100,d1
	bhi.s	iff_END
iff_CopyLoop:	moveq	#0,d2
		move.b	(a1)+,d2
		add	d2,d2
		move	(a3,d2.w),(a6)
		lea	40*6(a6),a6
		dbf	d1,iff_CopyLoop
		bra.s	iff_RepSections

iff_ShiftLoop:	add	d1,d1
		move	(a4,d1.w),d1
		lea	(a6,d1.l),a6
		bra.s	iff_RepSections

iff_SameLoop:	moveq	#0,d1
		move.b	(a1)+,d1
		subq	#1,d1
	cmpi	#100,d1
	bhi.s	iff_END
		moveq	#0,d2
		move.b	(a1)+,d2
		add	d2,d2
		move	(a3,d2.w),d2		;double
iff_CopySame:	move	d2,(a6)
		lea	40*6(a6),a6
		dbf	d1,iff_CopySame
iff_RepSections:
	cmpa.l	a5,a6
	bpl.s	iff_END

		dbf	d0,iff_Sections
	lea	1(a1),a1

iff_NextRow:	lea	2(a2),a2
		dbf	d6,iff_FracLoop

iff_EndDlta:	bra	iff_ANIMLOOP

;-------------------------------------------------------------------
iff_END:
;		bsr.w	iff_ChangeScreen
		movem.l	(sp)+,d0-a6
;		lea	iff_copper,a1
		rts

;---------------------------SCREEN----------------------------------
iff_ChangeScreen:
		lea	iff_scron(pc),a4
		move.l	(a4),a2
		move.l	4(a4),d1
		move.l	d1,(a4)
		move.l	a2,4(a4)

		moveq	#5,d2
		lea	iff_addr,a4
iff_SetBAddr:	move	d1,6(a4)
		swap	d1
		move	d1,2(a4)
		swap	d1
		addi	#40,d1
		lea	8(a4),a4
		dbf	d2,iff_SetBAddr
		rts

;-------------------------------------------------------------------
iff_Ytab:
VALUE:	SET	0
	REPT	100
	dc.w	VALUE
VALUE:	SET VALUE+240
	ENDR
	blk.l	180,0

;-------------------------------------------------------------------
kreditsy:
;23456789012345678901234567890123456789
TEXT
            ...CYTADELA...
        LISTA PlAC I PODZIeKOWAn
---------------------------------------

         ISBN  83-86603-17-8

---------------------------------------


       ZA WYKONANIE "CYTADELI"
         ODPOWIEDZIALNY JEST
   ZESPol AUTORSKI "VD" W SKlADZIE:
   --------------------------------


PAWEl MATUSZ      - PROGRAMOWANIE
ARTUR BARDOWSKI   - GRAFIKA I ANIMACJE
RADOSlAW CZECZOTKA- GRAFIKA DO POZIOMoW
ARTUR OPALA       - MUZYKA



             ORAZ WYDAWCA:
             -------------

            ARRAKIS SOFTWARE


   


---------------------------------------

         GlOSoW DO INTRODUKCJI
     OPRoCZ AUTORA MUZYKI UzYCZYLI:
     ------------------------------

          MONIKA DRZEWIECKA
           ARTUR BARDOWSKI
             PIOTR OPALA
           DARIUSZ WOlEJSZO





        GlOSoW DO GRY UzYCZYLI:
        -----------------------

             PAWEl MATUSZ
            ZBIGNIEW MATUSZ
  SUSZARKA, MAGNETOFON I WIELE INNYCH





           POZIOMY UKlADALI:
           -----------------

 PODZIEMIA     -   PAWEl MATUSZ
 ELEKTROWNIA   -   ARTUR BARDOWSKI
                   JAKUB BARDOWSKI
                   R. I M.GANCARZ
                   PAWEl MATUSZ
 MAGAZYN       -   ARTUR OPALA
                   JAN RozYCKI
 HANGAR        -   MARCIN STANGEL
                   PAWEl MATUSZ
                   JAN RozYCKI
 LABORATORIUM  -   PAWEl MATUSZ
 KANAlY        -   JAN RozYCKI
 WIeZIENIE     -   JAN RozYCKI
 CENTRUM       -   ARTUR BARDOWSKI


 GRAFIKe DO CENTRUM WYJaTKOWO WYKONAl
           ARTUR BARDOWSKI





          POZIOMY TRENINGOWE:
          -------------------

 PODZIEMIA     -   PAWEl MATUSZ
 MAGAZYNY      -   ARTUR OPALA
 LABORATORIA   -   PAWEl MATUSZ
 KANAlY        -   JAN RozYCKI




        OPRACOWANIE INSTRUKCJI:
        -----------------------

             PAWEl MATUSZ



 

       PROJEKT GRAFICZNY OKlADKI
       -------------------------

           ARTUR BARDOWSKI





  SYSTEM ROZPOZNAWANIA KONFIGURACJI:
  ----------------------------------

            TOMASZ KANTECKI







---------------------------------------

           PONADTO AUTORZY
    SKlADAJa  GORaCE PODZIeKOWANIA
         NASTePUJaCYM OSOBOM:
         --------------------



JANEK RoZYCKI  - ZA NIEOCENIONa POMOC,
                 BEZ KToREJ NIE
                 ZDazYLIBYsMY...
                 (NAJLEPSZE POZIOMY!)

GOSIA SZULC    - ZA WSPARCIE DUCHOWE
                 I CIERPLIWOsc DO MNIE

TOMASZ KANTECKI- ZA POMOC I RADY ORAZ
                 ZA PAMIaTKe

JAKUB BARDOWSKI- ZA MAPY I SEKWENCJE
                 VIDEO

SYLWIA BOCHNACKA- ZA MORAL SUPPORT

lUKASZ BARTNIK - ZA KAMERe VIDEO

PRZEMYSlAW SADlO- ZA SUPERKOMPUTER

MARIUSZ CICHY  - ZA SKANER

AGNIESZKA NARKIEWICZ- ZA WSZYSTKO

AGNIESZKA SUCHOCKA- ZA MORAL SUPPORT






---------------------------------------

   DO SKlADANIA I TESTOWANIA CYTADELI
             WYKORZYSTANO:
       -------------------------



 AMIGA 500  - 1MB, 2.5MB, 3MB, ARIII
 AMIGA 600
 AMIGA 1200 - 2MB, +4MB FAST, +2MB SLOW
              (PCMCIA), GVP
 AMIGA 3000 - 12MB
 AMIGA CD32




---------------------------------------



 W CYTADELe WlOzYLIsMY WIELE MIESIeCY
     CIezKIEJ PRACY. MAMY NADZIEJe,
 zE KOnCOWY EFEKT WAS USATYSFAKCJONUJE.
  zYCZYMY WIELU GODZIN (?) WSPANIAlEJ
   ZABAWY. POWODZENIA zYCZa AUTORZY:


       PAWEl (KANE/SCT) MATUSZ
       ARTUR (ARTB/SCT) BARDOWSKI
       ARTUR (KALOSZ/SCT) OPALA
       RADOSlAW CZECZOTKA








 TERAZ ZOSTAlEs TYLKO TY... I CYTADELA





















ETEXT
dc.b	-1
EVEN
;-------------------------------------------------------------------
Koncowka:
;23456789012345678901234567890123456789
TEXT
            ZNoW TO SAMO...


    PUSTKA... CISZA... SAMOTNOsc...



JUz  OD  PEWNEGO  CZASU  ORBITUJe WOKol
B104-GS12,  OCZEKUJaC NA POMOC Z ZIEMI.
NIE  WIEM  NAWET,  CZY  MOJA  WIADOMOsc
ZOSTAlA ODEBRANA.DlUGO TU NIE WYTRZYMAM
 - NA BOASTERACH NIE UMIESZCZA SIE ZBYT
WIELE sRODKoW DO zYCIA.

NASZA MISJA ZOSTAlA JEDNAK WYKONANA...
NASZA... RESZTA ZAlOGI ZGINela PRZECIEz
W UlAMKU SEKUNDY, NIE  WIEDZaC NAWET CO
SIe DZIEJE. TYLKO MNIE SIe UDAlO. zYCIE
ZE  sWIADOMOsCIa,  zE  JEST SIe JEDYNYM
OCALAlYM  Z  PONAD  1000  OSoB JEST DLA
MNIE  TORTURa. NIE LICZaC TYCH,  KToRZY
ZGINeLI W CYTADELI.

TO,  CO SIe WlAsCIWIE WYDARZYlO W CYTA-
DELI,CO DOPROWADZIlO DO TYCH WSZYSTKICH
WYPACZEn  I  MUTACJI PRAWDOPODOBNIE JUz
NA ZAWSZE  POZOSTANIE  TAJEMNICa. TERAZ
CYTADELA TO STOS GRUZoW I PYlU.






CIaGLE  WRACAM  DO TYCH OSTATNICH CHWIL
W BAZIE. DESPERACKA, PRAKTYCZNIE  SAMO-
BoJCZA ESKAPADA, OSTATECZNIE ZAKOnCZONA
SUKCESEM.

PODlOzENIE  BOMBY  ANIHILACYJNEJ W CEN-
TRUM... DESPERACKI BIEG DO CUDEM OCALA-
lEGO NA LaDOWISKU BOASTERA...  WARIACKI
START NA PElNYM CIaGU... OGROMNY WYBUCH
TUz ZA MNa, UDERZAJaCA  Z SIla HURAGANU
W STATEK FALA POWIETRZA...   DESPERACKA
WALKA ZE STERAMI O  UTRZYMANIE KONTROLI
NAD BOASTEREM...   OSTATECZNIE SUKCES -
WYPROWADZENIE STATKU NA ORBITe...




TERAZ  WCIaz  NADAJe  SYGNAl  O POMOC Z
NIEWIELKIEGO AWARYJNEGO NADAJNIKA.  CZY
KTOs MNIE USlYSZY?     CZY WYsLa POMOC?
KOSMOS JEST OGROMNY -  OD  ZIEMI DZIELa
MNIE DZIESIaTKI LAT sWIETLNYCH.



    JEDNAK MISJA ZOSTAlA WYKONANA.
        CYTADELA NIE ISTNIEJE.
TERAZ ZOSTAlEM TYLKO JA...  I NADZIEJA.

         NADZIEJA NA RATUNEK.













                 KONIEC






ETEXT
dc.b	-1
EVEN
;-------------------------------------------------------------------
NazwyPoziomow:
dc.b	"   PODZIEMIA"		;12 dlugosci
dc.b	" ELEKTROWNIA"
dc.b	"     MAGAZYN"
dc.b	"      HANGAR"
dc.b	"LABORATORIUM"
dc.b	"      KANAlY"
dc.b	"   WIeZIENIE"
dc.b	"     CENTRUM"

NazwyPoziomow2:
dc.b	"PODZIEMIA @   "	;14 dlugosci
dc.b	"ELEKTROWNIA @ "
dc.b	"MAGAZYN @     "
dc.b	"HANGAR @      "
dc.b	"LABORATORIUM @"
dc.b	"KANAlY @      "
dc.b	"WIeZIENIE @   "
dc.b	"CENTRUM @     "
EVEN
;-------------------------------------------------------------------
FlashTab:
dc.w	0,$f0,$e0,$d0,$c0,$b0,$a0,$90,$80,$70,$80,$90,$a0,$b0
dc.w	$c0,$d0,$e0

copper0:dc.l	$1800000,$1000300,-2

MAINcopper:
dc.w	$180,0,$182,0,$184,0,$186,0,$188,0
dc.w	$18A,0,$18C,0,$18E,0,$190,0,$192,0
dc.w	$194,0,$196,0,$198,0,$19A,0,$19C,0
dc.w	$19E,0
dc.w	$1a0,0,$1a2,0,$1a4,0,$1a6,0,$1a8,0
dc.w	$1aA,0,$1aC,0,$1aE,0,$1b0,0,$1b2,0
dc.w	$1b4,0,$1b6,0,$1b8,0,$1bA,0,$1bC,0
dc.w	$1bE,0

dc.w	$108,5*40,$10a,5*40
dc.l	$920038,$9400d0
dc.l	$8e3881,$90ffc3
dc.l	$10200aa,$1040000
dc.w	$1fc,0,$106,0,$10c,0

dc.w	$e0,iff_screen/$10000,$e2,iff_screen&$ffff
dc.w	$e4,[iff_screen+40]/$10000,$e6,[iff_screen+40]&$ffff
dc.w	$e8,[iff_screen+2*40]/$10000,$ea,[iff_screen+2*40]&$ffff
dc.w	$ec,[iff_screen+3*40]/$10000,$ee,[iff_screen+3*40]&$ffff
dc.w	$f0,[iff_screen+4*40]/$10000,$f2,[iff_screen+4*40]&$ffff
dc.w	$f4,[iff_screen+5*40]/$10000,$f6,[iff_screen+5*40]&$ffff

dc.l	$3601ff00,$01006300
dc.l	$fe01ff00,$01000300
dc.l	-2

;-------------------------------------------------------------------
MAPAcopper:
dc.w	$180,0,$182,0,$184,0,$186,0,$188,0
dc.w	$18A,0,$18C,0,$18E,0,$190,0,$192,0
dc.w	$194,0,$196,0,$198,0,$19A,0,$19C,0
dc.w	$19E,0
dc.w	$1a0,0,$1a2,0,$1a4,0,$1a6,0,$1a8,0
dc.w	$1aA,0,$1aC,0,$1aE,0,$1b0,0,$1b2,0
dc.w	$1b4,0,$1b6,0,$1b8,0,$1bA,0,$1bC,0
dc.w	$1bE,0

dc.w	$108,5*40,$10a,5*40
dc.l	$920038,$9400d0
dc.l	$8e3881,$90ffc3
dc.l	$10200aa,$1040000
dc.w	$1fc,0,$106,0,$10c,0

dc.w	$e0,MAPApic/$10000,$e2,MAPApic&$ffff
dc.w	$e4,[MAPApic+40]/$10000,$e6,[MAPApic+40]&$ffff
dc.w	$e8,[MAPApic+2*40]/$10000,$ea,[MAPApic+2*40]&$ffff
dc.w	$ec,[MAPApic+3*40]/$10000,$ee,[MAPApic+3*40]&$ffff
dc.w	$f0,[MAPApic+4*40]/$10000,$f2,[MAPApic+4*40]&$ffff
dc.w	$f4,[MAPApic+5*40]/$10000,$f6,[MAPApic+5*40]&$ffff

dc.l	$3601ff00,$01006300
dc.l	$f601ff00,$01000300;,$1800aaa
dc.w	$108,0,$10a,0
ma_col:
dc.l	$1820fff
dc.w	$e0,MAPAscr/$10000,$e2,MAPAscr&$ffff
dc.l	$f701ff00,$1800000
dc.l	$f801ff00,$01001300
dc.l	$fe01ff00,$01000300;,$1800aaa
dc.l	$ff01ff00,$1800000
dc.l	-2

;-------------------------------------------------------------------

DISKcopper:
dc.w	$180,0,$182,0,$184,0,$186,0,$188,0
dc.w	$18A,0,$18C,0,$18E,0,$190,0,$192,0
dc.w	$194,0,$196,0,$198,0,$19A,0,$19C,0
dc.w	$19E,0
dc.w	$1a0,0,$1a2,0,$1a4,0,$1a6,0,$1a8,0
dc.w	$1aA,0,$1aC,0,$1aE,0,$1b0,0,$1b2,0
dc.w	$1b4,0,$1b6,0,$1b8,0,$1bA,0,$1bC,0
dc.w	$1bE,0

dc.w	$108,4*16,$10a,4*16
dc.l	$920068,$9400a0
dc.l	$8e3881,$90ffc3
dc.l	$1020000,$1040000

dc.w	$e0,Dload/$10000,$e2,Dload&$ffff
dc.w	$e4,[Dload+16]/$10000,$e6,[Dload+16]&$ffff
dc.w	$e8,[Dload+2*16]/$10000,$ea,[Dload+2*16]&$ffff
dc.w	$ec,[Dload+3*16]/$10000,$ee,[Dload+3*16]&$ffff
dc.w	$f0,[Dload+4*16]/$10000,$f2,[Dload+4*16]&$ffff

dc.l	$5001ff00,$01005300
dc.l	$cb01ff00,$01000300

dc.l	$920068,$940098
dc.w	$108,14,$10a,14
dc.w	$e0,Nload/$10000,$e2,Nload&$ffff
dc.w	$e4,[Nload+14]/$10000,$e6,[Nload+14]&$ffff
dc.w	$180,0,$182,$555,$184,$999,$186,$dde
dc.l	$1020088
dc.l	$d801ff00,$01002300
dc.l	$e901ff00,$01000300
dc.l	-2


;-------------------------------------------------------------------
CREDITcopper:
dc.w	$180,0,$182,0,$184,0,$186,0,$188,0
dc.w	$18A,0,$18C,0,$18E,0,$190,0,$192,0
dc.w	$194,0,$196,0,$198,0,$19A,0,$19C,0
dc.w	$19E,0
dc.w	$1a0,0,$1a2,0,$1a4,0,$1a6,0,$1a8,0
dc.w	$1aA,0,$1aC,0,$1aE,0,$1b0,0,$1b2,0
dc.w	$1b4,0,$1b6,0,$1b8,0,$1bA,0,$1bC,0
dc.w	$1bE,0

dc.w	$108,0,$10a,0
dc.l	$920038,$9400d0
dc.l	$8e3881,$90ffc3
dc.l	$1020022,$1040000

dc.w	$e0,CREDscr/$10000,$e2,CREDscr&$ffff
dc.w	$e4,[CREDscr+8000]/$10000,$e6,[CREDscr+8000]&$ffff
dc.w	$e8,[CREDscr+2*8000]/$10000,$ea,[CREDscr+2*8000]&$ffff
dc.w	$ec,[CREDscr+3*8000]/$10000,$ee,[CREDscr+3*8000]&$ffff
CREDchg:
dc.w	$f0,[SCROLL1scr]/$10000,$f2,[SCROLL1scr]&$ffff

dc.l	$3601ff00,$01005300
dc.l	$fe01ff00,$01000300
dc.l	-2


;-------------------------------------------------------------------
ENDLEVcopper:
dc.w	$180,0,$182,0,$184,0,$186,0,$188,0
dc.w	$18A,0,$18C,0,$18E,0,$190,0,$192,0
dc.w	$194,0,$196,0,$198,0,$19A,0,$19C,0
dc.w	$19E,0
dc.w	$1a0,0,$1a2,0,$1a4,0,$1a6,0,$1a8,0
dc.w	$1aA,0,$1aC,0,$1aE,0,$1b0,0,$1b2,0
dc.w	$1b4,0,$1b6,0,$1b8,0,$1bA,0,$1bC,0
dc.w	$1bE,0

dc.w	$108,0,$10a,0
dc.l	$920038,$9400d0
dc.l	$8e3881,$90ffc3
dc.l	$1020022,$1040000

dc.w	$e0,ENDLEVrys/$10000,$e2,ENDLEVrys&$ffff
dc.w	$e4,[ENDLEVrys+8000]/$10000,$e6,[ENDLEVrys+8000]&$ffff
dc.w	$e8,[ENDLEVrys+2*8000]/$10000,$ea,[ENDLEVrys+2*8000]&$ffff
dc.w	$ec,[ENDLEVrys+3*8000]/$10000,$ee,[ENDLEVrys+3*8000]&$ffff
dc.w	$f0,[ENDLEVscr]/$10000,$f2,[ENDLEVscr]&$ffff

dc.l	$3601ff00,$01005300
dc.l	$fe01ff00,$01000300
dc.l	-2


;-------------------------------------------------------------------
KONC2copper:
dc.w	$180,0,$182,$111

dc.w	$108,0,$10a,0
dc.l	$920038,$9400d0
dc.l	$8e3881,$90ffc3
dc.l	$1020022,$1040000
KONchg:
dc.w	$e0,KONC1scr/$10000,$e2,KONC1scr&$ffff

dc.l	$3601ff00,$01001300
dc.l	$3a01ff00,$1820222
dc.l	$3c01ff00,$1820333
dc.l	$3e01ff00,$1820444
dc.l	$4001ff00,$1820555
dc.l	$4201ff00,$1820666
dc.l	$4401ff00,$1820777
dc.l	$4601ff00,$1820888
dc.l	$4801ff00,$1820999
dc.l	$4a01ff00,$1820aaa
dc.l	$4c01ff00,$1820bbb
dc.l	$4e01ff00,$1820ccc
dc.l	$5001ff00,$1820ddd
dc.l	$5201ff00,$1820eee
dc.l	$5401ff00,$1820fff

dc.l	$e201ff00,$1820eee
dc.l	$e401ff00,$1820ddd
dc.l	$e601ff00,$1820ccc
dc.l	$e801ff00,$1820bbb
dc.l	$ea01ff00,$1820aaa
dc.l	$ec01ff00,$1820999
dc.l	$ee01ff00,$1820888
dc.l	$f001ff00,$1820777
dc.l	$f201ff00,$1820666
dc.l	$f401ff00,$1820555
dc.l	$f601ff00,$1820444
dc.l	$f801ff00,$1820333
dc.l	$fa01ff00,$1820222
dc.l	$fc01ff00,$1820111
dc.l	$fe01ff00,$01000300
dc.l	-2


;-------------------------------------------------------------------
iff_copper:
	dc.w	$180,0,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
	dc.w	$190,0,$192,0,$194,0,$196,0,$198,0,$19a,0,$19c,0,$19e,0

iff_addr:
	dc.w	$e0,0/$10000,$e2,0&$ffff
	dc.w	$e4,[0+40]/$10000,$e6,[0+40]&$ffff
	dc.w	$e8,[0+80]/$10000,$ea,[0+80]&$ffff
	dc.w	$ec,[0+120]/$10000,$ee,[0+120]&$ffff
	dc.w	$f0,[0+160]/$10000,$f2,[0+160]&$ffff
	dc.w	$f4,[0+200]/$10000,$f6,[0+200]&$ffff

	dc.w	$108,200,$10a,200
	dc.l	$920038,$9400d0

;	dc.l	$8e3883,$90ffc1
	dc.l	$8e3a83,$90ffd1
	dc.l	$1020000,$1040000
;	dc.w	$1fc,0,$106,0,$10c,0

	dc.l	$3701ff00
	dc.l	$01006b00
	dc.w	$108,-40,$10a,-40
	dc.l	$3801ff00
	dc.w	$108,200,$10a,200


suwak:
VALUE:	SET	$3901ff00
	REPT	198/2
	dc.l	VALUE
	dc.w	$108,-40,$10a,-40
	dc.l	$1020000
	dc.l	VALUE+$01000000
	dc.w	$108,200,$10a,200
	dc.l	$1020000
VALUE:	SET	VALUE+$02000000
	ENDR


	dc.l	$ff01ff00
	dc.l	$01000300
	dc.l	-2

;-------------------------------------------------------------------
;credit part
CREDscr:	equ	BASE+$50200
SCROLL1scr:	equ	BASE+$4bd00
SCRscr:		dc.l	SCROLL1scr,SCROLL1scr+8720

;miedzy etapy part
ENDLEVrys:	equ	BASE+$2ba00		;in place of map
ENDLEVmus:	equ	BASE+$59900		;in place of zero tab
ENDLEVscr:	equ	BASE+$61c00		;in place of ? ($1f40)

;death:
DeathMem:	equ	$52000

;main server part
iff_screen:	equ	BASE+$20000+$4200	;$bc00	- hangar (& save buffer)
SERscr:		equ	BASE+$2bc00+$4200	;$2640
SERbuf:		equ	BASE+$2e240+$4200	;$2640
SERlepr:	equ	BASE+$30880+$4200	;$264*2 = $4c8

SERoff:		equ	iff_screen+[53*40*6]+12 ;offset on server screen

;mapa part
MAPAmus:	equ	BASE+$2c000		;$6b7e
MAPAbuf:	equ	BASE+$32c00		;$800
MAPApic:	equ	BASE+$5a000		;$b480
MAPAscr:	equ	BASE+$65500		;$140

;end part
KONC1scr:	equ	BASE+$4c000
KONscr:		dc.l	KONC1scr,KONC1scr+8720

;end anim
Anim1:		equ	$10000
Anim2:		equ	$10000+135858
Anim3:		equ	$10000+276782


iff_timer:	dc.w	4,0		;frame timing
iff_speed:	dc.l	0
ok_go:		dc.w	0
iff_scron:	dc.l	KONC1scr,KONC1scr+[110*40*6]

AnimsAdr:	dc.l	anims
;ramkowanie,   speed, ile ramek, speed, ...,-1
anims:
	dc.l	anim1,$21,60,1,7,16,80,300,-1
	dc.l	anim2,$28,80,1,6,300,-1
	dc.l	anim3,$2c,15,1,5,24,50,300,-1
	dc.l	-1

;-------------------------------------------------------------------
dl_buffer:	equ	BASE+$20e00	;$3200

PoczHaslo:	dc.w	0,0,0
HasloFlag:	dc.w	0
OldLev2:	dc.l	0
OldLev3:	dc.l	0

;-------------------------------------------------------------------
>extern		"DATA:STORE/savegame.dat",STRUCTURE,-1

mt_data:	equ	BASE+$58404
;>extern		"DAT1:MODS/mod.aconcagua.pro",mt_data,-1 ;$27368
mt_data2:	equ	BASE+$38000
>extern		"DAT1:MODS/mod.dirranbandi.pro",mt_data2,-1 ;$13254
;>extern		"DAT1:GFX/hangar.rawb",iff_screen,-1

;>extern		"DAT1:GFX/mapka.rawb",MAPApic,-1
;>extern		"DAT1:MODS/mod.brief1.pro",MAPAmus,-1

;>extern		"DAT1:ANIM2/END.anim",BASEF+Anim1,-1


IFEQ	exe
MT_pic:		equ	BASE+$d600
ELSE
MT_pic:
ENDC
>extern		"DAT1:GFX/mt.raw.pp",mt_pic+LOADB,-1		;$3338
KaneFont:	equ MT_PIC+$3338
>extern		"DAT1:STORE/Kane.fnt",KaneFont+LOADB,-1	;$c00
MT_endlev:	equ KaneFont+$c00
>extern		"DAT1:MODS/mod.MiedzyEtapy.pro.pp",mt_endlev+LOADB,-1 ;$5384
DLoad:		equ MT_endlev+$5384
>extern		"DAT1:GFX/DYSK.RAWB",DLoad+LOADB,-1	;$26b0
Nload:		equ DLoad+$26b0
>extern		"DAT1:GFX/DYSK_napisy_POL.rawb",Nload+LOADB,-1 ;$364
HangTab:	equ NLoad+$364
>extern		"DATA:STORE/HangarTab.dat",HangTab+LOADB,-1 ;$660
ZabTab:		equ HangTab+$660
>extern		"DAT1:STORE/zab1_KEY.txt",ZabTab+LOADB,-1 ;$148
FileLoader:	equ ZabTab+$148
>extern		"CODE:BIN/FileLOADER.DAT",FileLoader+LOADB,-1 ;$852
ProtCode:	equ FileLoader+$852
>extern		"CODE:BIN/protection.pp",ProtCode+LOADB,-1 	;$1820
Strzalka:	equ ProtCode+$1820
>extern		"DAT1:GFX/strzalka.rawb",Strzalka+LOADB,-1 ;$84
Font8:		equ Strzalka+$84
>extern		"DATA:GFX_VIR/FONTS01.FNT",Font8+LOADB,-1 ;$300
Engine:		equ Font8+$300
>extern		"CODE:BIN/CYT.dat.pp",Engine+LOADB,-1 	;$4ca4

end:	equ	Engine+$4cb0

st:		equ	S+LOADB
en:		equ	END+LOADB


