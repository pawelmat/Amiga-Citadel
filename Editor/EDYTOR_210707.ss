;	*****************************************************
;	*	      CITADEL - MAP EDITOR (module)	    *
;	*	Coded by Kane on 20.04.1994-xx.05.1995	    *
;	*****************************************************

;SAVE:
;	wb
;	<nazwa, np LEVEL01.MAP>
;	BEG> a0
;	END> a1

A500:	equ	1
EXE:	equ	1

IFEQ	A500
BASEC:		equ	$100000			;free 0.5 meg chip(A1200)
;BASE:		equ	$180000			;free 0.5 meg fast
BASE:		equ	$c00000			;free 0.5 meg fast
ELSE
BASEC:		equ	$000000			;free 0.5 meg chip(A1200)
BASE:		equ	$c00000			;free 0.5 meg fast
ENDC

TTL		VIRTUAL_DESIGN_PRODUCTION
JUMPPTR		S
IFNE		EXE
;AUTO		rb\sv_map\41000\e\js\wb\a0\a1\
AUTO		e\js\wb\a0\a1\
ENDC
ALL:		REG	d0-a6
WAITBLT:	MACRO
		btst.b	#14,2(a0)
		bne.s	*-6
		ENDM
VBLANK:		MACRO
		cmpi.b	#$ff,6(a0)
		bne.s	*-6
		cmpi.b	#$ff,6(a0)
		beq.s	*-6
		ENDM


		ORG	BASEC+$20000
		LOAD	*

s:
		lea	$dff000,a0

		moveq	#80,d0
.wnop:		VBLANK
		dbf	d0,.wnop

		lea	sc_COLORS,a1		;copy colors
		lea	WallCols,a2
		moveq	#31,d0
.sc_Copycol:	move	(a1)+,2(a2)
		lea	4(a2),a2
		dbf	d0,.sc_Copycol


		lea	sv_LevelEnemy,a1
		lea	EnemyNRG0,a2
		lea	EnemyNRG,a3
		moveq	#16,d0
		moveq	#1,d1
.sc_SetNMY_NRG:	move	(a1,d0.w),d2
		cmp	d1,d2
		bne.s	.sc_se2
		moveq	#0,d2
		move	2(a1,d0.w),d2		;NRG
		move	d2,(a3)+
		divu	#100,d2
		move.b	d2,(a2)+
		move	#0,d2
		swap	d2
		divu	#10,d2
		move.b	d2,(a2)+
		swap	d2
		move.b	d2,(a2)+
		moveq	#0,d2
		move	10(a1,d0.w),d2		;SPD
		move	d2,(a3)+
		divu	#100,d2
		move.b	d2,(a2)+
		move	#0,d2
		swap	d2
		divu	#10,d2
		move.b	d2,(a2)+
		swap	d2
		move.b	d2,(a2)+
		moveq	#16,d0
		addq	#1,d1
		cmpi	#3,d1
		beq.s	.sc_se3
.sc_se2:	addi	#16,d0
		cmpi	#256*16,d0
		bne.s	.sc_SetNMY_NRG
.sc_se3:

		lea	sv_LevelData,a1
		move	16(a1),sv_PosX
		move	18(a1),sv_PosY

		bsr	InitGrid
		bsr	DrawMap
		bsr	DrawWalls
		bsr	PrintChoice
		bsr	Print_NMY_CNT
		bsr	ClrGscreen
		move	#$a9,d4
		move	#$15,d5
		bsr	PanelInvert

;bra.s	www
		lea	SwitchTab,a1		;clear Switch Tab
		moveq	#0,d0
		move	#$800-1,d1
.clst:		move.l	d0,(a1)+
		dbf	d1,.clst

		lea	sv_LevelSwitch,a1
		lea	SwitchTab,a2		;copy Switch Tab
		lea	(a2),a4
		moveq	#0,d2			;CNT
		moveq	#-1,d7
.SetST:		move	(a1)+,d0
		cmpi	#-1,d0
		bne.s	.Set1
		cmpi	#-1,(a1)
		beq.s	.SetE
		addq	#1,d7
		move	d7,d6
		lsl	#6,d6
		move	d2,(a4)
		lea	2(a2,d6.w),a3
		lea	-2(a3),a4
		moveq	#0,d2			;CNT
		bra.s	.SetST
.Set1:		move	d0,(a3)+
		addq	#2,d2
		bra.s	.SetST
.SetE:		move	d2,(a4)
		bsr	PrintSwitch

www:

		VBLANK
		move	#$7fff,$96(a0)
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		move	#$00ff,$9e(a0)		;ADKONR
		move.l	VBR_base(pc),a1
		lea	OldLev3(pc),a2
		move.l	$6c(a1),(a2)		;set lev3 interrupt
		lea	NewLev3(pc),a2
		move.l	a2,$6c(a1)

		lea	OldLev2(pc),a2
		move.l	$68(a1),(a2)		;set lev2 key interrupt
		lea	NewLev2(pc),a2
		move.l	a2,$68(a1)

		VBLANK
		move.l	#RealCopper,d0
		move.l	d0,$80(a0)
		move	#0,$88(a0)

		move	#$83e0,$96(a0)
		move	#$c028,$9a(a0)

;----------------------------
MAIN_LOOP:	VBLANK
		tst	DoQuit
		bne.w	sv_quit

		move	#0,Right
		tst	DoRedraw
		beq.s	L3_1
		bsr	DrawWalls
		bsr	PrintChoice
		move	#0,DoRedraw
L3_1:		tst	DoRedrMap
		beq.s	L3_3
		bsr	cc_MapFix
		move	#0,DoRedrMap
L3_3:
		move	mouse_y,d1
		cmpi	#160,d1
		bpl.s	L3_2
		tst	IdentWall
		beq.s	L3_2
		bsr	PrintIdent
		VBLANK
L3_2:
		btst.b	#6,$bfe001
		bne.s	L4
		bsr	Pressed
		bra.w	MAIN_LOOP
L4:		btst.b	#2,$dff016
		bne.w	MAIN_LOOP
		bsr	Pressed2
		bra.w	MAIN_LOOP


sv_quit:	lea	$dff000,a0
		VBLANK
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		move.l	#copper0,d0
		move.l	d0,$80(a0)
		move	#0,$88(a0)
		VBLANK
		move.l	VBR_base(pc),a1
		move.l	OldLev2(pc),$68(a1)
		move.l	OldLev3(pc),$6c(a1)
		move	#$83f0,$96(a0)
		move	#$e02c,$9a(a0)


		lea	SwitchTab,a1		;copy SwitchTab to map
		lea	sv_LevelSwitch,a2
		lea	2(a1),a3
		moveq	#126,d7
		move	#-1,(a2)+
.SetST:		move	(a3)+,d0
		beq.s	.Set1
		move	d0,(a2)+
		bra.s	.SetST
.Set1:		lea	64(a1),a1
		lea	2(a1),a3
		tst	(a3)
		beq.s	.Set2
		move	#-1,(a2)+
.Set2:		dbf	d7,.SetST
		move.l	#-1,(a2)+

		lea	(a2),a1

		lea	sv_Map,a0
;		lea	sv_LevelSwitch,a1
;.sv_EndMap:	cmpi	#-1,(a1)+
;		bne.s	.sv_EndMap
;		cmpi	#-1,(a1)+
;		bne.s	.sv_EndMap

		rts

;-------------------------------------------------------------------
NewLev3:	movem.l ALL,-(sp)
		bsr	mouse
		lea	SColTab(pc),a1			;flash cursor
		addi	#2,(a1)
		move	(a1),d0
		andi	#62,d0
		move	2(a1,d0.w),SprCols+6
		move	2(a1,d0.w),SprCols2+2

		cmpi	#160,mouse_y
		bpl.s	nl1
		bsr	cursor2
		bsr	PrintPos
		bra.s	nlq
nl1:		lea	sprite+4,a1
		lea	sprcop,a2
		REPT	8
		move.l	(a2)+,(a1)+
		ENDR
		bsr	cursor
nlq:


		movem.l	(sp)+,ALL
		move	#$20,$dff09c
		rte

;-------------------------------------------------------------------
;interrupt level 2 - test keys

NewLev2:	movem.l	ALL,-(sp)
		moveq	#0,d0
		tst.b	$bfed01
		move.b	$bfec01,d0
		move	#$0008,$dff09c		;zero interrupt

		tst	d0
		beq.w	cc_NoKey

cc_esc:		cmpi.b	#$75,d0			;ESC
		beq.s	cc_esc2
		cmpi.b	#$ff,d0			;tylda
		bne.s	cc_f1
cc_esc2:	move	#1,DoQuit
		bra	cc_NoKey
cc_f1:		tst	DoRedraw
		bne.s	cc_a1
		cmpi.b	#$5f,d0			;F1
		bne.s	cc_f2
		move.l	#Walls1,WallScr
		move	#1,DoRedraw
		bra	cc_NoKey
cc_f2:		cmpi.b	#$5d,d0			;F2
		bne.s	cc_f3
		move.l	#Walls2,WallScr
		move	#1,DoRedraw
		bra	cc_NoKey
cc_f3:		cmpi.b	#$5b,d0			;F3
		bne.s	cc_a1
		move.l	#Walls3,WallScr
		move	#1,DoRedraw
		bra	cc_NoKey
cc_a1:		cmpi.b	#$61,d0			;arrows
		bne.s	cc_a2
		subi	#1,MapX
		bsr	cc_MapFixS
		bra	cc_NoKey
cc_a2:		cmpi.b	#$63,d0			;arrows
		bne.s	cc_a3
		addi	#1,MapX
		bsr	cc_MapFixS
		bra	cc_NoKey
cc_a3:		cmpi.b	#$65,d0			;arrows
		bne.s	cc_a4
		subi	#1,MapY
		bsr	cc_MapFixS
		bra	cc_NoKey
cc_a4:		cmpi.b	#$67,d0			;arrows
		bne.s	cc_a5
		addi	#1,MapY
		bsr	cc_MapFixS
		bra	cc_NoKey
cc_a5:

		cmpi.b	#$a5,d0			;arrows
		bne.s	cc_a21
		subi	#5,MapX
		bsr	cc_MapFixS
		bra	cc_NoKey
cc_a21:		cmpi.b	#$a1,d0			;arrows
		bne.s	cc_a31
		addi	#5,MapX
		bsr	cc_MapFixS
		bra	cc_NoKey
cc_a31:		cmpi.b	#$c3,d0			;arrows
		bne.s	cc_a41
		subi	#5,MapY
		bsr	cc_MapFixS
		bra	cc_NoKey
cc_a41:		cmpi.b	#$83,d0			;arrows
		bne.s	cc_a51
		addi	#5,MapY
		bsr	cc_MapFixS
		bra	cc_NoKey
cc_a51:

		bra	cc_NoKey


cc_MapFixS:	move	#1,DoRedrMap
		rts

cc_MapFix:	move	MapX,d1
		bpl.s	mf2
		move	#0,MapX
mf2:		move	MapY,d1
		bpl.s	mf3
		move	#0,MapY
mf3:		move	MapX,d1
		cmpi	#25,d1
		bmi.s	mf4
		move	#24,MapX
mf4:		move	MapY,d1
		cmpi	#45,d1
		bmi.s	mf5
		move	#44,MapY
mf5:		bsr	InitGrid
		bsr	DrawMap
		rts

cc_NoKey:
		move.b	#$41,$bfee01
		nop
		nop
		nop
		move.b	#0,$bfec01
		move.b	#0,$bfee01
		movem.l	(sp)+,ALL
		rte

VBR_base:	dc.l	0
OldLev2:	dc.l	0
OldLev3:	dc.l	0
;-------------------------------------------------------------------
Pressed2:	move	#1,Right		;Rmb pressed
Pressed:	movem.l	ALL,-(sp)
		move	mouse_x,d0
		move	mouse_y,d1
		subi	#194,d1
		bpl.s	p_Choose
		move	mouse_y,d1
		cmpi	#160,d1
		bmi	SetOnMap
		bra	SetPanel
p_Choose:	lsr	#5,d0
		lsr	#5,d1
		mulu	#10,d1
		add	d1,d0
		move	d0,d3			;square
		move.l	WallScr,a1

		moveq	#0,d1
		move.b	(a1,d0.w),d1		;wall nr.
		cmpi.b	#-1,d1
		beq.w	P_Quit

		cmpi	#6,choiceID
		bne.s	.pc_00
		move	#$0a9,d4
		move	#$06,d5
		bsr.w	PanelInvert
		bra.s	.pc_01
.pc_00:		cmpi	#7,choiceID
		bne.s	.pc_01
		move	#$09d,d4
		move	#$06,d5
		bsr.w	PanelInvert
.pc_01:		move	mouse_x,d0
		move	mouse_y,d2
		subi	#194,d2
		andi	#%11111,d0
		andi	#%11111,d2
		lsr	#4,d0
		lsr	#4,d2
		add	d2,d2
		add	d2,d0			;in-square
		add	d3,d3
		add	d3,d3
		add	d3,d0
		moveq	#0,d2
		move.b	20(a1,d0.w),d2		;szczegolowy nr.
		move	d2,Choice
		move	d1,Choice+2
		move	Right,d3

		cmpi	#15,d1
		beq.w	p_DoorO
		cmpi	#18,d1
		beq.w	p_DoorO
		cmpi	#26,d1
		beq.w	p_DoorO
		cmpi	#21,d1
		beq.w	p_Guzik
		cmpi	#22,d1
		beq.w	p_Guzik
		cmpi	#27,d1
		bmi.w	p_Wall
		cmpi	#28,d1
		beq.w	p_Teleport
		cmpi	#31,d1
		bmi.w	p_Column
		cmpi	#33,d1
		bmi.w	p_ColumnUp
		cmpi	#35,d1
		bmi.w	p_ColumnDn
		cmpi	#38,d1
		bmi.w	p_Blood
		cmpi	#38,d1
		beq.w	p_Tables
		cmpi	#40,d1
		beq.w	p_Enemy
		cmpi	#53,d1
		beq.w	p_Enemy
		bra.w	p_Item

P_End:		bsr	PrintChoice

P_Quit:		btst.b	#6,$bfe001
		beq.s	P_Quit
		btst.b	#2,$dff016
		beq.s	P_Quit
		movem.l	(sp)+,ALL
		rts

p_DoorO:	move	#8,BrickID
		move	#0,ChoiceID
		or	d3,Choice
		bra.s	P_End
p_Guzik:	move	#4,BrickID
		move	#0,ChoiceID
		or	d3,Choice
		bra.s	P_End
p_Wall:		move	#0,BrickID
		move	#0,ChoiceID
		or	d3,Choice
		bra.w	P_End
p_Teleport:	cmpi	#4,d2
		bne.s	p_Column
		move	#13,BrickID
		move	#1,ChoiceID
		bra.w	P_End
p_Column:	move	#12,BrickID
		move	#1,ChoiceID
		bra.w	P_End
p_ColumnUp:	move	#14,BrickID
		move	#1,ChoiceID
		bra.w	P_End
p_ColumnDn:	move	#15,BrickID
		move	#1,ChoiceID
		bra.w	P_End
p_Blood:	move	#0,BrickID
		move	#4,ChoiceID
		bra.w	P_End
p_Tables:	move	#0,BrickID
		move	#5,ChoiceID
		bra.w	P_End
p_Enemy:	move	#17,BrickID
		move	#3,ChoiceID
		bra.w	P_End
p_Item:		move	#16,BrickID
		move	#2,ChoiceID
		lsl	#5,d3
		or	d3,Choice
		bra.w	P_End


;-------------------------------------------------------------------
PrintChoice:	lea	screen2+6400+32,a2	;clear
		move	#[32*5]-1,d0
.dw_clr2:	move.l	#0,(a2)
		lea	40(a2),a2
		dbf	d0,.dw_clr2

		lea	BASEC+co_walls,a4

		move	ChoiceID,d0
		cmpi	#1,d0
		bne.s	pc_10
		lea	sv_CollumnOffsets,a3		;if collumn
		move	Choice,d1
		cmpi	#9,d1
		bpl.s	pc_1
		lea	screen2+6400+32,a2
		subq	#1,d1
		add	d1,d1
		add	d1,d1
		move.l	(a3,d1.w),d1
		lea	(a4,d1.l),a4
		bsr	PrintCol
		rts
pc_1:		lea	screen2+6400+32+200,a2
		subq	#1,d1
		add	d1,d1
		add	d1,d1
		move.l	(a3,d1.w),d1
		lea	(a4,d1.l),a4
		bsr	PrintUD
		rts

pc_10:		cmpi	#2,d0
		bne.s	pc_20
		lea	sv_ItemOffsets,a3		;if item
		move	Choice,d1
		andi	#31,d1
		lea	screen2+6400+32,a2
		subq	#1,d1
		add	d1,d1
		add	d1,d1
		move.l	(a3,d1.w),d1
		lea	(a4,d1.l),a4
		bsr	PrintUD
		rts

pc_20:		cmpi	#3,d0
		bne.s	pc_30
		lea	sv_EnemyOffsets,a3		;if enemy
		move	Choice,d1
		lsr	#1,d1
		lea	screen2+6400+32,a2
		add	d1,d1
		add	d1,d1
		move.l	(a3,d1.w),d1
		lea	(a4,d1.l),a4
		bsr	PrintCol
		rts

pc_30:		cmpi	#5,d0
		bne.s	pc_40
		lea	sv_PlaqueOffsets,a3		;if table
		move	Choice,d1
		lea	screen2+6400+32+1600,a2
		subq	#1,d1
		add	d1,d1
		add	d1,d1
		move.l	(a3,d1.w),d1
		lea	(a4,d1.l),a4
		bsr	PrintUD
		rts

pc_40:		cmpi	#6,d0				;block
		bne.s	pc_50
		rts

pc_50:		cmpi	#7,d0				;player
		bne.s	pc_60
		rts

pc_60:		move	Choice+2,d1
		mulu	#65*64,d1
		lea	screen2+6400+32,a2
		lea	(a4,d1.l),a4
		bsr	PrintWall2
		rts

;-------------------------------------------------------------------
;show what wall on.

PrintIdent:	lea	BASEC+co_walls,a4	;start of gfx
		lea	sv_Map,a1
		lea	CursorPos,a2
		move	(a2),d0
		lsl	#3,d0
		move	2(a2),d1
		lsl	#7,d1
		lsl	#2,d1
		add	d1,d0
		lea	(a1,d0.w),a1		;map pos

		move	ChoiceID,d0		;if WALL
		bne.w	pi2
		move	#0,LastCol
		move	#0,LastItem
		move	#0,LastEnem
		move	#0,LastPlaque
		move	#0,LastBlood
		move	4(a2),d1		;dir
		move.b	(a1,d1.w),d2
		andi	#63,d2
		cmp	LastWall,d2
		beq.w	piEnd
		tst	d2
		beq.s	pi1
		move	d2,LastWall
		bsr	PI_CLR				;clear
		move	d2,d0
		lsr	#1,d0
		subq	#1,d0
		mulu	#64*65,d0
		lea	screen2+6400+36,a2
		lea	(a4,d0.l),a4
		bsr	PrintWall3
		rts
pi1:		move	#0,LastWall
		move	#0,LastCol
		move	#0,LastItem
		move	#0,LastEnem
		move	#0,LastBlood
		move	#0,LastPlaque
		bsr	PI_CLR
		rts

pi2:		cmpi	#1,d0			;collumn
		bne.s	.pi3
		move	#0,LastWall
		move	#0,LastItem
		move	#0,LastEnem
		move	#0,LastPlaque
		lea	sv_CollumnOffsets,a3
		moveq	#0,d1
		move.b	5(a1),d1
		cmp	LastCol,d1
		beq.w	piEnd
		tst	d1
		beq.s	pi1
		move	d1,LastCol
		bsr	PI_CLR				;clear
		cmpi	#9,d1
		bpl.w	.pi2_1
		lea	screen2+6400+36,a2
		subq	#1,d1
		add	d1,d1
		add	d1,d1
		move.l	(a3,d1.w),d1
		lea	(a4,d1.l),a4
		bsr	PrintCol
		rts
.pi2_1:		lea	screen2+6400+36+200,a2
		subq	#1,d1
		add	d1,d1
		add	d1,d1
		move.l	(a3,d1.w),d1
		lea	(a4,d1.l),a4
		bsr	PrintUD
		rts

.pi3:		cmpi	#2,d0
		bne.s	.pi3_1
		lea	sv_ItemOffsets,a3		;if item
		move	#0,LastWall
		move	#0,LastCol
		move	#0,LastEnem
		move	#0,LastPlaque
		moveq	#0,d1
		move.b	6(a1),d1
		move	d1,d2
		andi	#31,d1
		cmp	LastItem,d1
		beq.w	piEnd
		tst	d1
		beq.w	pi1
		move	d1,LastItem
		bsr	PI_CLR				;clear
		lea	screen2+6400+36,a2
		subq	#1,d1
		add	d1,d1
		add	d1,d1
		move.l	(a3,d1.w),d1
		lea	(a4,d1.l),a4
		bsr	PrintUD2
		rts

.pi3_1:		cmpi	#4,d0
		bne.s	.pi3_2
		lea	sv_BloodOffsets,a3		;if blood
		move	#0,LastWall
		move	#0,LastCol
		move	#0,LastEnem
		move	#0,LastPlaque
		move	4(a2),d1		;dir
		move.b	(a1,d1.w),d1
		andi	#%11000000,d1
		lsr.w	#6,d1
		cmp	LastBlood,d1
		beq.w	piEnd
		tst	d1
		beq.w	pi1
		move	d1,LastBlood
		bsr	PI_CLR				;clear

		lea	screen2+6400+36,a2
		subq	#1,d1
		add	d1,d1
		add	d1,d1
		move.l	(a3,d1.w),d1
		lea	(a4,d1.l),a4
		bsr	PrintWall3
		rts

.pi3_2:		cmpi	#5,d0
		bne.s	.pi4
		lea	sv_PlaqueOffsets,a3		;if plaque (table)
		move	#0,LastWall
		move	#0,LastCol
		move	#0,LastEnem
		move	#0,LastBlood
		move	4(a2),d1		;dir
		andi	#3,d1
		add	d1,d1
		move.b	4(a1),d0
		rol.b	#2,d0
		rol.b	d1,d0
		andi	#3,d0
		
		cmp	LastPlaque,d0
		beq.w	piEnd
;		tst	d0
;		beq.w	pi1
		move	d0,LastPlaque
		bsr	PI_CLR				;clear

		lea	screen2+6400+36,a2
		subq	#1,d0
		add	d0,d0
		add	d0,d0
		move.l	(a3,d0.w),d0
		lea	(a4,d0.l),a4
		bsr	PrintUD2
		rts

.pi4:		cmpi	#3,d0			; enemy
		bne.s	piEnd
		move	#0,LastWall
		move	#0,LastCol
		move	#0,LastItem

		moveq	#0,d1
		move.b	7(a1),d1
		lea	sv_LevelEnemy,a3
		lsl	#4,d1
		move	(a3,d1.w),d1
		cmp	LastEnem,d1
		beq.s	piEnd
		tst	d1
		beq	pi1
		move	d1,LastEnem
		bsr	PI_CLR
		subq	#1,d1
		lea	sv_EnemyOffsets,a3		;if enemy
		lea	screen2+6400+36,a2
		add	d1,d1
		add	d1,d1
		move.l	(a3,d1.w),d1
		lea	(a4,d1.l),a4
		bsr	PrintCol
piEnd:		rts


PI_CLR:		movem.l	a2/d0,-(sp)
		lea	screen2+6400+36,a2	;clear
		move	#[32*5]-1,d0
.dw_clr2:	move.l	#0,(a2)
		lea	40(a2),a2
		dbf	d0,.dw_clr2
		movem.l	(sp)+,a2/d0
		rts

LastWall:	dc.w	0
LastCol:	dc.w	0
LastItem:	dc.w	0
LastEnem:	dc.w	0
LastBlood:	dc.w	0
LastPlaque:	dc.w	0
;-------------------------------------------------------------------
;if clicked on upper half... set choice on map.

SetOnMap:	lea	sv_Map,a1
		lea	CursorPos,a2
		move	(a2),d0
		lsl	#3,d0
		move	2(a2),d1
		lsl	#7,d1
		lsl	#2,d1
		add	d1,d0
		lea	(a1,d0.w),a1

		tst	EditSwitch
		bne	FixSwitch

		move	ChoiceID,d1
		move	Choice,d2
		tst	Right
		beq.s	.so_0
		moveq	#0,d2			;if clr
.so_0:
		cmpi	#1,d1
		bne.s	.so_2
		andi.b	#%11100000,5(a1)	;column
		or.b	d2,5(a1)
		bra	p_Quit2
.so_2:		cmpi	#2,d1
		bne.s	.so_3
		andi.b	#%11000000,6(a1)	;item
		or.b	d2,6(a1)
		bra	p_Quit2
.so_3:		cmpi	#3,d1			;enemy
		bne.w	.so_4
		tst	EditAgr			;if editing aggression
		bne.w	p_Quit2
		tst	d2
		beq.s	.so_30
		lea	sv_LevelEnemy,a3
		moveq	#0,d3
		move.b	7(a1),d3
		lsl	#4,d3
		move	#0,(a3,d3.w)		;clr old enemy here
		moveq	#0,d3
.so_3f:		addi	#16,d3
		cmpi	#256*16,d3
		beq	p_Quit2
		tst	(a3,d3.w)
		bne.s	.so_3f
		move	d2,(a3,d3.w)	;en in EnemyTab
		subq	#1,d2
		add	d2,d2
		add	d2,d2
		lea	EnemyNrg,a4
		move	(a4,d2.w),2(a3,d3.w)	;energy
		move	2(a4,d2.w),10(a3,d3.w)	;speed
		bsr	GetRandom
		andi	#510,d0
		move	d0,8(a3,d3.w)		;angle
		move	CursorPos,d0
		mulu	#1024,d0
		addi	#512,d0
		move	d0,4(a3,d3.w)		;PosX
		move	CursorPos+2,d0
		mulu	#1024,d0
		addi	#512,d0
		move	d0,6(a3,d3.w)		;PosY
		move	d3,d2
		lsr	#4,d2		;nr of enemy
		bra.s	.so_31
.so_30:		moveq	#0,d3
		move.b	7(a1),d3
		lsl	#4,d3
		lea	sv_LevelEnemy,a3
		move	#0,(a3,d3.w)
.so_31:		move.b	d2,7(a1)
		bra	p_Quit2

.so_4:		cmpi	#4,d1
		bne.s	.so_5
		move	4(a2),d3
		andi.b	#%00111111,(a1,d3.w)	;blood
		or.b	d2,(a1,d3.w)
		bra	p_Quit2
.so_5:		cmpi	#5,d1
		bne.s	.so_6
		move	4(a2),d3
		andi	#3,d3
		add	d3,d3
		ror.b	#2,d2
		ror.b	d3,d2
		move.b	#%00111111,d4
		ror.b	d3,d4
		and.b	d4,4(a1)		;tables
		or.b	d2,4(a1)
		bra	p_Quit2
.so_6:		cmpi	#6,d1
		bne.s	.so_7
		andi.b	#%10111111,6(a1)	;block
		or.b	d2,6(a1)
		bra	p_Quit2
.so_7:		cmpi	#7,d1			;player
		bne.s	.so_8
		tst	PlayEnd			;or end?
		bne.s	.so_7_1
		move	CursorPos,sv_PosX
		move	CursorPos+2,sv_PosY
		lea	sv_LevelData,a3
		lea	EnemyNrg,a4
		move	(a4),d0
		andi	#255,d0
		add	d0,d0
		move	d0,20(a3)	;angle
		move	sv_PosX,16(a3)
		move	sv_PosY,18(a3)
		bra	p_Quit2

.so_7_1:	lea	sv_LevelData,a3		;end
		move	CursorPos,22(a3)
		move	CursorPos+2,24(a3)
		bra	p_Quit2

.so_8:
		move	4(a2),d3		;wall
		move.b	d2,(a1,d3.w)
p_Quit2:	bsr	InitGrid
		bsr	DrawMap
		bra	p_Quit

;-------------------------------------------------------------------
;if klicked on upper half and editing switch...
;a1 - map pos
;a2 - cursor pos
;d0 - map location (offset)

FixSwitch:	move	SwitchNr,d1
		lsl	#6,d1
		lea	SwitchTab,a3
		lea	(a3,d1.w),a3
		move	(a3),d1			;end of cell data
		bne.w	fs_9

		move.b	5(a1),d2
		andi	#31,d2
		cmpi	#4,d2
		bne.s	fs_1
		addi	#4,d0			;teleport
		addi	#2,(a3)
		move	d0,2(a3,d1.w)
		bra	fs_Quit
fs_1:
		move.b	4(a1),d2		;any card around?
		REPT	4
		move	d2,d3
		andi	#3,d3
		cmpi	#1,d3
		beq.s	fs_2
		lsr	#2,d2
		ENDR

		move	4(a2),d2
		andi	#3,d2
		or	d2,d0
		move.b	(a1,d2.w),d3
		andi	#63,d3
		cmpi	#44,d3			;44-46 - Switch
		bmi.s	fs_Quit			;nothing
		cmpi	#47,d3
		bpl.s	fs_Quit
		addi	#2,(a3)
		move	d0,2(a3,d1.w)

fs_Quit:	bsr	ClrGscreen
		bsr	PrintSwitch
		bra	p_Quit

fs_2:		addi	#4,(a3)			;karta
		addi	#5,d0
		move	d0,2(a3,d1.w)
		move	4(a2),d2
		andi	#3,d2
		addq	#1,d2
		cmpi	#4,d2
		bne.s	.fs3
		moveq	#3,d2
.fs3:		move	d2,4(a3,d1.w)
		bra	fs_Quit

fs_9:		move	4(a2),d2
		andi	#3,d2
		or	d2,d0
		addi	#2,(a3)
		move	d0,2(a3,d1.w)
		bra	fs_Quit

;-------------------------------------------------------------------
;poses:		dc.w	0
;		blk.l	100,0

SetPanel:
		move	mouse_x,d0
		move	mouse_y,d1
		subi	#160,d1
;	lea	poses(pc),a1		;remember gadget poses
;	move	(a1),d2
;	move	d0,2(a1,d2.w)
;	move	d1,4(a1,d2.w)
;	addq	#4,d2
;	move	d2,(a1)
	
		lea	PanelTab,a1
		moveq	#-1,d7
sp_Find:	move	(a1)+,d2
		bmi.w	sp_quit
		addq	#1,d7		;find nr. of gadget
		move	d2,d3
		addi	#8,d3
		move	(a1)+,d4
		move	d4,d5
		addi	#8,d5
		cmp	d2,d0
		bmi.s	sp_Find
		cmp	d0,d3
		bmi.s	sp_Find
		cmp	d4,d1
		bmi.s	sp_Find
		cmp	d1,d5
		bmi.s	sp_Find

		cmpi	#4,d7
		bpl.s	sp_G2
		cmpi	#0,d7			;arrows
		bne.s	sp_a21
		subi	#5,MapX
		bra.s	sp_a42
sp_a21:		cmpi	#1,d7
		bne.s	sp_a31
		addi	#5,MapX
		bra.s	sp_a42
sp_a31:		cmpi	#2,d7
		bne.s	sp_a41
		subi	#5,MapY
		bra.s	sp_a42
sp_a41:		addi	#5,MapY
sp_a42:		bsr	cc_MapFix
		bra	sp_Quit

sp_G2:		cmpi	#7,d7
		bpl.s	sp_G3
		cmpi	#4,d7			;Wall Sets
		bne.s	sp_f2
		move.l	#Walls1,WallScr
		bra.s	sp_f0
sp_f2:		cmpi	#5,d7
		bne.s	sp_f3
		move.l	#Walls2,WallScr
		bra.s	sp_f0
sp_f3:		move.l	#Walls3,WallScr
sp_f0:		move	#1,DoRedraw
		bra	sp_Quit

sp_G3:		cmpi	#7,d7
		bne.s	sp_G4
		cmpi	#6,choiceID
		beq.w	sp_Quit
		cmpi	#7,choiceID
		beq.w	sp_Quit
		move	#6,choiceID
		move	#%01000000,choice
		move	#50,brickID
		bsr	PrintChoice
		move	#$0a9,d4
		move	#$06,d5
		bsr.w	PanelInvert
		bra	sp_Quit

sp_G4:		cmpi	#8,d7			;player
		bne.s	sp_G5
		cmpi	#6,choiceID
		beq.w	sp_Quit
		cmpi	#7,choiceID
		beq.w	sp_Quit
		move	#7,choiceID
		move	#18,brickID
		bsr	PrintChoice
		move	#$09d,d4
		move	#$06,d5
		bsr.w	PanelInvert
		move	Right,PlayEnd		;player or level end?
		bra	sp_Quit

sp_G5:		cmpi	#21,d7			;CNT's
		bpl.s	sp_G6
		subi	#9,d7
		lea	EnemyNRG0,a1
		tst	Right
		bne.s	.sp_G50
		addi.b	#1,(a1,d7.w)
		cmpi.b	#10,(a1,d7.w)
		bne.s	.sp_G51
		move.b	#0,(a1,d7.w)
		bra.s	.sp_G51
.sp_G50:	subi.b	#1,(a1,d7.w)
		bpl.s	.sp_G51
		move.b	#9,(a1,d7.w)
.sp_G51:	bsr	Print_NMY_CNT
		bra	sp_Quit

sp_G6:		cmpi	#21,d7			;ident
		bne.s	sp_G7
		bsr	PI_CLR
		eori	#1,IdentWall
		move	#$a9,d4
		move	#$15,d5
		bsr.w	PanelInvert
		bra	sp_Quit

sp_G7:		cmpi	#22,d7			;Guzik
		bne.s	sp_G8
		eori	#1,EditSwitch
		move	#$9d,d4
		move	#$15,d5
		bsr.w	PanelInvert
		bra	sp_Quit

sp_G8:		cmpi	#23,d7			;Switch up
		bne.s	sp_G9
		subi	#1,SwitchNr
		bpl	sp_G9_1
		move	#0,SwitchNr
		bra	sp_G9_1

sp_G9:		cmpi	#24,d7			;Switch down
		bne.s	sp_G10
		addi	#1,SwitchNr
		cmpi	#128,SwitchNr
		bmi	sp_G9_1
		move	#0,SwitchNr
sp_G9_1:	bsr	ClrGscreen
		bsr	PrintSwitch
		bra	sp_Quit

sp_G10:		cmpi	#25,d7			;-2
		bne.s	sp_G11
		move	SwitchNr,d0
		lsl	#6,d0
		lea	SwitchTab,a1
		lea	(a1,d0.w),a1
		move	(a1),d0			;end of cell data
		beq.w	sp_Quit
		addi	#2,(a1)
		move	#-2,2(a1,d0)
		bsr	ClrGscreen
		bsr	PrintSwitch
		bra	sp_Quit

sp_G11:		cmpi	#26,d7			;CLR
		bne.s	sp_G12
		bsr	ClrLine
		bsr	ClrGscreen
		bsr	PrintSwitch
		bra	sp_Quit

sp_G12:		cmpi	#34,d7			;COMMANDS
		bpl.s	sp_G13
		subi	#27,d7
		move	Choice,d1
		tst	Right
		beq.s	sp_G12_1
		moveq	#0,d1
sp_G12_1:	cmpi	#4,d7			;if no special NR
		bpl.s	sp_G12_2
		moveq	#1,d1
sp_G12_2:	lsl	#8,d1
		or	d7,d1
		move	SwitchNr,d0
		lsl	#6,d0
		lea	SwitchTab,a1
		lea	(a1,d0.w),a1
		move	(a1),d0			;end of cell data
		beq.w	sp_Quit
		addi	#2,(a1)
		move	d1,2(a1,d0)
		bsr	ClrGscreen
		bsr	PrintSwitch
		bra	sp_Quit

sp_G13:		cmpi	#34,d7			;Agression
		bne	sp_G14
		move	#$f9,d4
		move	#$04,d5
		bsr.w	PanelInvert
		eori	#1,EditAgr
		beq.w	sp_G13_1

		lea	EnemyNRG0,a1
		lea	AgrSave,a2
		moveq	#9,d0
.s1:		move	(a1),(a2)+
		move	#0,(a1)+
		dbf	d0,.s1
		lea	sv_LevelData,a1
		lea	EnemyNRG0,a2		; what's printed on screen
		lea	EnemyNRG,a3		; actual enemy value
		move.b	4(a1),d0
		move	d0,d1
		lsr	#2,d0
		andi	#3,d0
		move.b	d0,(a2)			;trafienia
		andi	#3,d1
		move.b	d1,1(a2)		;trafienia
		move.b	5(a1),2(a2)		;bron
		moveq	#0,d2
		move	8(a1),d2		;agresja
		divu	#50,d2			;/50 np 500=>10
		move	d2,2(a3)
		andi.l	#$ffff,d2
		divu	#100,d2
		move.b	d2,3(a2)
		move	#0,d2
		swap	d2
		divu	#10,d2
		move.b	d2,4(a2)
		swap	d2
		move.b	d2,5(a2)

		move.b	10(a1),d0
		move	d0,d1
		lsr	#2,d0
		andi	#3,d0
		move.b	d0,6(a2)		;trafienia
		andi	#3,d1
		move.b	d1,7(a2)		;trafienia
		move.b	11(a1),8(a2)		;bron
		moveq	#0,d2
		move	14(a1),d2		;agresja
		divu	#50,d2			;/50 np 500=>10
		move	d2,6(a3)
		andi.l	#$ffff,d2
		divu	#100,d2
		move.b	d2,9(a2)
		move	#0,d2
		swap	d2
		divu	#10,d2
		move.b	d2,10(a2)
		swap	d2
		move.b	d2,11(a2)
		bsr	Print_NMY_CNT
		bra	sp_Quit
sp_G13_1:
		lea	sv_LevelData,a1
		lea	EnemyNRG0,a2
		lea	EnemyNRG,a3
		move.b	(a2),d0		;enemy 1
		andi	#3,d0
		lsl	#2,d0
		move.b	1(a2),d1
		andi	#3,d1
		or	d1,d0
		move.b	d0,4(a1)
		move.b	2(a2),d0
		andi	#7,d0
		move.b	d0,5(a1)
		move	2(a3),d0
		mulu	#50,d0
		move	d0,8(a1)
		move.b	6(a2),d0	;enemy 2
		andi	#3,d0
		lsl	#2,d0
		move.b	7(a2),d1
		andi	#3,d1
		or	d1,d0
		move.b	d0,10(a1)
		move.b	8(a2),d0
		andi	#7,d0
		move.b	d0,11(a1)
		move	6(a3),d0
		mulu	#50,d0
		move	d0,14(a1)

		lea	EnemyNRG0,a1
		lea	AgrSave,a2
		moveq	#9,d0
.s1:		move	(a2)+,(a1)+
		dbf	d0,.s1
		bsr	Print_NMY_CNT
		bra	sp_Quit

sp_G14:
		nop
sp_quit:	bra	p_Quit


PanelTab:
	dc.w	$11f,$0d,$131,$0d,$128,$16,$128,$04
	dc.w	$0fc,$15,$106,$15,$110,$15,$0a9,$06
	dc.w	$09d,$06
NrgPos:	dc.w	$b8,$09,$c2,$09,$cc,$09,$b8,$15,$c2,$15,$cc,$15
	dc.w	$d8,$09,$e2,$09,$ec,$09,$d8,$15,$e2,$15,$ec,$15
	dc.w	$a9,$15
	dc.w	$9d,$15
	dc.w	$89,$08,$89,$14,$57,$12,$36,$12
	dc.w	$36,$04,$41,$04,$4c,$04,$57,$04,$62,$04,$6d,$04,$78,$04
	dc.w	$f9,$04
	dc.w	-1

;-------------------------------------------------------------------
;d4,d5 - x,y of brick
PanelInvert:
		movem.l	ALL,-(sp)
		lea	panel,a1
		subq	#1,d5
		mulu	#40,d5
		move	d4,d0
		lsr	#4,d4
		add	d4,d4
		add	d4,d5			;offset
		lea	(a1,d5.w),a1
		andi	#15,d0
		move.l	#$ff000000,d1
		lsr.l	d0,d1
		eor.l	d1,(a1)
		eor.l	d1,40(a1)
		eor.l	d1,2*40(a1)
		eor.l	d1,3*40(a1)
		eor.l	d1,4*40(a1)
		eor.l	d1,5*40(a1)
		eor.l	d1,6*40(a1)
		eor.l	d1,7*40(a1)
		movem.l	(sp)+,ALL
		rts

;-------------------------------------------------------------------
Print_NMY_CNT:
		lea	EnemyNRG0,a1
		lea	EnemyNRG,a2
		cmpi.b	#3,3(a1)		;speed to 300
		bmi.s	.pn00
		move.b	#2,3(a1)
.pn00:		cmpi.b	#3,9(a1)
		bmi.s	.pn01
		move.b	#2,9(a1)
.pn01:
		moveq	#3,d7
.pn_1:		moveq	#0,d0			;dec -> hex
		move.b	(a1)+,d0
		mulu	#100,d0
		moveq	#0,d1
		move.b	(a1)+,d1
		mulu	#10,d1
		add	d1,d0
		moveq	#0,d1
		move.b	(a1)+,d1
		add	d1,d0
		move	d0,(a2)+
		dbf	d7,.pn_1

		lea	Numbers,a2
		lea	NrgPos,a4
		lea	EnemyNRG0,a5
		moveq	#11,d7
.pn_2:		move	(a4)+,d0		;x,y
		move	(a4)+,d1
		mulu	#40,d1
		move	d0,d2
		lsr	#4,d0
		add	d0,d0
		add	d0,d1			;offset
		lea	Panel,a1
		lea	(a1,d1.w),a1
		andi	#15,d2			;bits right
		addi	#8,d2

		moveq	#0,d0
		move.b	(a5)+,d0
		bne.s	.pn3
		moveq	#10,d0
.pn3:		subi	#1,d0
		lea	(a2,d0.w),a3		;nr. offset

		moveq	#7,d6
.pn4:		move.l	#$ffffff00,d0
		ror.l	d2,d0
		and.l	d0,(a1)
		moveq	#0,d0			;print nr.
		move.b	(a3),d0
		ror.l	d2,d0
		or.l	d0,(a1)
		lea	10(a3),a3
		lea	40(a1),a1
		dbf	d6,.pn4

		dbf	d7,.pn_2
		rts

;-------------------------------------------------------------------
PrintPos:	lea	numbers,a2
		lea	panel+40*9+3,a1
		moveq	#0,d0
		move	CursorPos,d0		;X
		divu	#10,d0
		bsr	PPnum
		swap	d0
		bsr	PPnum


		lea	panel+40*19+3,a1
		moveq	#0,d0
		move	CursorPos+2,d0
		divu	#10,d0
		bsr	PPnum
		swap	d0

PPnum:		moveq	#9,d1
		tst	d0
		beq.s	ppn2
		move	d0,d1
		subq	#1,d1
ppn2:		lea	(a2,d1.w),a3
		move.b	(a3),(a1)
		move.b	10(a3),40(a1)
		move.b	2*10(a3),2*40(a1)
		move.b	3*10(a3),3*40(a1)
		move.b	4*10(a3),4*40(a1)
		move.b	5*10(a3),5*40(a1)
		move.b	6*10(a3),6*40(a1)
		move.b	7*10(a3),7*40(a1)
		lea	1(a1),a1
		rts

;-------------------------------------------------------------------
DrawMap:
		movem.l	ALL,-(sp)
		lea	sv_MAP,a1
		lea	screen+[19*8*40*4],a2
		move	MapX,d0
		lsl	#3,d0
		move	MapY,d1
		lsl	#8,d1
		lsl	#1,d1
		add	d1,d0
		lea	(a1,d0.w),a1		;map start offset
		move.l	a1,MapOffset

		moveq	#19,d7			;Y CNT
D_LoopY:	moveq	#39,d6			;X CNT
D_LoopX:
		lea	bricks,a3
		moveq	#0,d5
D_Dir:		move	d5,d1
		move.b	(a1,d5.w),d0
		andi	#$3e,d0
		beq.w	D_d1
		cmpi.b	#44,d0
		beq.s	d_guzik
		cmpi.b	#46,d0
		beq.s	d_guzik
		cmpi.b	#54,d0
		beq.s	d_drzwiZep
		cmpi.b	#32,d0
		beq.s	d_drzwiOtw
		cmpi.b	#38,d0
		beq.s	d_drzwiOtw
		cmpi.b	#30,d0
		beq.s	d_drzwiZamk
		cmpi.b	#36,d0
		beq.s	d_drzwiZamk
		move.b	4(a1),d2
		move.b	#%11000000,d3
		ror.b	d5,d3
		ror.b	d5,d3
		and.b	d3,d2
		beq.s	.d_n1
		move	#7,d2			;table on wall
		addi	#19,d1
		bsr.w	DrawIcon
		bra.s	D_d1
.d_n1:		move	#7,d2			;norm. wall
		bsr.w	DrawIcon
		bra.s	D_d1
d_guzik:	move	#7,d2			;guzik
		addq	#4,d1
		bsr.w	DrawIcon
		bra.s	D_d1
d_drzwiZep:	move	#7,d2			;zepsute drzwi
		addi	#8,d1
		bsr.w	DrawIcon
		bra.s	D_d1
d_drzwiOtw:	move	#8,d2			;drzwi otw
		move.b	6(a1),d0
		andi	#64,d0
		beq.s	d_do1
		move	#11,d2			;if blokada drzwi
d_do1:		addi	#8,d1
		bsr.w	DrawIcon
		bra.s	D_d1
d_drzwiZamk:	move	#8,d2			;zamkniete drzwi
		move.b	6(a1),d0
		andi	#64,d0
		beq.s	d_dz1
		move	#11,d2			;if blokada drzwi
d_dz1:		bsr.w	DrawIcon
D_d1:		addq	#1,d5
		cmpi	#4,d5
		bne.w	D_Dir


		move.b	5(a1),d0		;kolumny
		andi	#31,d0
		beq.s	D_d2
		cmpi.b	#1,d0
		beq.s	d_col1
		cmpi.b	#2,d0
		beq.s	d_col1
		cmpi.b	#3,d0
		beq.s	d_col2
		cmpi.b	#5,d0
		beq.s	d_col2
		cmpi.b	#4,d0
		beq.s	d_tel
		cmpi.b	#9,d0
		bmi.s	D_d2
		cmpi.b	#17,d0
		bmi.s	d_Up
		bra.s	d_Dn

		bra.s	D_d2
d_col1:		moveq	#12,d1			;nieprzechodnia
		moveq	#7,d2
		bsr.w	DrawIcon
		bra.s	D_d2
d_col2:		moveq	#12,d1			;przechodnia
		moveq	#4,d2
		bsr.w	DrawIcon
		bra.s	D_d2
d_tel:		moveq	#13,d1			;teleport
		moveq	#8,d2
		bsr.w	DrawIcon
		bra.s	D_d2
d_Up:		moveq	#14,d1			;col. up
		moveq	#9,d2
		bsr.w	DrawIcon
		bra.s	D_d2
d_Dn:		moveq	#15,d1			;col. down
		moveq	#10,d2
		bsr.w	DrawIcon
D_d2:

		move.b	6(a1),d0
		andi	#63,d0
		beq.s	D_d3
		andi	#32,d0
		bne.s	d_Pup
		moveq	#16,d1			;przedmiot down
		moveq	#12,d2
		bsr.w	DrawIcon
		bra.s	D_d3
d_Pup:		moveq	#16,d1			;przedmiot up
		moveq	#15,d2
		bsr.s	DrawIcon

D_d3:		move.b	7(a1),d0
		beq.s	D_d4
		moveq	#17,d1			;przeciwnik
		moveq	#14,d2
		bsr.s	DrawIcon

D_d4:		move	sv_PosX,d0
		lsl	#3,d0
		move	sv_PosY,d1
		lsl	#8,d1
		lsl	#1,d1
		add	d1,d0
		lea	sv_MAP,a4
		lea	(a4,d0.w),a4		;map start offset
		cmpa.l	a4,a1
		bne.s	D_d5
		moveq	#18,d1			;player
		moveq	#14,d2
		bsr.s	DrawIcon

D_d5:		move	sv_LevelData+22,d0
		lsl	#3,d0
		move	sv_LevelData+24,d1
		lsl	#8,d1
		lsl	#1,d1
		add	d1,d0
		lea	sv_MAP,a4
		lea	(a4,d0.w),a4		;map start offset
		cmpa.l	a4,a1
		bne.s	D_d6
		moveq	#18,d1			;End of Level
		moveq	#11,d2
		bsr.s	DrawIcon
D_d6:


		lea	8(a1),a1
		lea	1(a2),a2
		dbf	d6,D_LoopX
		lea	24*8(a1),a1
		lea	-33*40(a2),a2
		dbf	d7,D_LoopY
		movem.l	(sp)+,ALL
		rts

;-------------------------------------------------------------------
;a3 - bricks, d1 - brick offset (0,1,...), d2 - color (1-15)
;a2 - screen pos

DrawIcon:
		movem.l	d0/d1/a2/a3,-(sp)
		lsl	#4,d1
		lea	(a3,d1.w),a3
		moveq	#0,d0
DI_ColLoop:	btst	d0,d2
		beq.s	di_zero
		move.b	(a3),d1
		or.b	d1,(a2)
		move.b	2(a3),d1
		or.b	d1,160(a2)
		move.b	4(a3),d1
		or.b	d1,2*160(a2)
		move.b	6(a3),d1
		or.b	d1,3*160(a2)
		move.b	8(a3),d1
		or.b	d1,4*160(a2)
		move.b	10(a3),d1
		or.b	d1,5*160(a2)
		move.b	12(a3),d1
		or.b	d1,6*160(a2)
		move.b	14(a3),d1
		or.b	d1,7*160(a2)
		bra.s	di_cont1
di_zero:	move.b	(a3),d1
		not	d1
		and.b	d1,(a2)
		move.b	2(a3),d1
		not	d1
		and.b	d1,160(a2)
		move.b	4(a3),d1
		not	d1
		and.b	d1,2*160(a2)
		move.b	6(a3),d1
		not	d1
		and.b	d1,3*160(a2)
		move.b	8(a3),d1
		not	d1
		and.b	d1,4*160(a2)
		move.b	10(a3),d1
		not	d1
		and.b	d1,5*160(a2)
		move.b	12(a3),d1
		not	d1
		and.b	d1,6*160(a2)
		move.b	14(a3),d1
		not	d1
		and.b	d1,7*160(a2)
di_cont1:	lea	40(a2),a2
		addq	#1,d0
		cmpi	#4,d0
		bne.w	DI_ColLoop
		movem.l	(sp)+,d0/d1/a2/a3
		rts

;-------------------------------------------------------------------
InitGrid:
		movem.l	ALL,-(sp)

		lea	screen,a1
		moveq	#0,d0
		move	#[40*20*8]-1,d7
i_clr:		move.l	d0,(a1)+
		dbf	d7,i_clr

		lea	screen,a1		;kratka
		moveq	#19,d3
		moveq	#-1,d0
		move.l	#$80808080,d1
i_l0:		REPT	10
		move.l	d0,(a1)+
		ENDR
		lea	3*40(a1),a1
		moveq	#6,d2
i_l1:		REPT	10
		move.l	d1,(a1)+
		ENDR
		lea	3*40(a1),a1
		dbf	d2,i_l1
		dbf	d3,i_l0

		movem.l	(sp)+,ALL
		rts

;-------------------------------------------------------------------
DrawWalls:
		movem.l	ALL,-(sp)
		lea	screen2,a2		;clear
		move	#[10*64*5]-1,d0
		moveq	#0,d1
dw_clr:		move.l	d1,(a2)+
		dbf	d0,dw_clr

		lea	BASEC+co_Walls,a1	;draw
		lea	screen2,a2
		move.l	WallScr,a3
		moveq	#17,d7
dw_loop1:	moveq	#0,d0
		move.b	(a3)+,d0
		bmi.s	dw_1
		mulu	#64*65,d0
		lea	(a1,d0.l),a4
		bsr.s	PrintWall
dw_1:		lea	4(a2),a2
		cmpi.l	#screen2+40,a2
		bne.s	dw_2
		lea	screen2+[40*32*5],a2
dw_2:		dbf	d7,dw_loop1

		movem.l	(sp)+,ALL
		rts

;-------------------------------------------------------------------
;Decode VIR format to RAW
;a2 - screen addr, a4 - wall addr
PrintWall:
		movem.l	ALL,-(sp)
		move.l	#$80000000,d0		;for or
		move	#31,d1			;X CNT
		move	#31,d5			;Y CNT
		bra.w	pw_DoIt

PrintWall2:	movem.l	ALL,-(sp)
		move.l	#$80000000,d0		;for or
		move	#31,d1			;X CNT
		move	#31,d5			;Y CNT
		move	Choice,d4
		andi	#1,d4
		beq.s	pw_DoIt
		bra.w	pw_Invert

PrintWall3:	movem.l	ALL,-(sp)
		move.l	#$80000000,d0		;for or
		move	#31,d1			;X CNT
		move	#31,d5			;Y CNT
		andi	#1,d2
		beq	pw_DoIt
		bra	pw_Invert

PrintCol:	movem.l	ALL,-(sp)
		move.l	#$00800000,d0		;for or
		move	#15,d1			;X CNT
		move	#31,d5			;Y CNT
		bra.s	pw_DoIt

PrintUD:	movem.l	ALL,-(sp)
		move.l	#$00800000,d0		;for or
		move	#15,d1			;X CNT
		move	#15,d5			;Y CNT
		move	Choice,d4
		andi	#%100000,d4
		bne.s	pw_DoIt
		lea	8*40*5(a2),a2		;lower
		bra.s	pw_DoIt

PrintUD2:	movem.l	ALL,-(sp)
		move.l	#$00800000,d0		;for or
		move	#15,d1			;X CNT
		move	#15,d5			;Y CNT
		andi	#%100000,d2
		bne.s	pw_DoIt
		lea	8*40*5(a2),a2		;lower

pw_DoIt:	lea	(a4),a1			;wall
ci_DecodeI1:	lea	(a2),a3			;add item to background
		move.l	d0,d4
		not.l	d4			;for and
		move	d5,d2			;Y CNT
ci_DecodeI2:	move.b	(a1)+,d3
		beq.s	ci_DecodeI3
		add.b	d3,d3
		bcs.s	.ci_di00
		and.l	d4,(a3)
		bra.s	.ci_di01
.ci_di00:	or.l	d0,(a3)
.ci_di01:	add.b	d3,d3
		bcs.s	.ci_di10
		and.l	d4,40(a3)
		bra.s	.ci_di11
.ci_di10:	or.l	d0,40(a3)
.ci_di11:	add.b	d3,d3
		bcs.s	.ci_di20
		and.l	d4,80(a3)
		bra.s	.ci_di21
.ci_di20:	or.l	d0,80(a3)
.ci_di21:	add.b	d3,d3
		bcs.s	.ci_di30
		and.l	d4,120(a3)
		bra.s	.ci_di31
.ci_di30:	or.l	d0,120(a3)
.ci_di31:	add.b	d3,d3
		bcs.s	.ci_di40
		and.l	d4,160(a3)
		bra.s	ci_DecodeI3
.ci_di40:	or.l	d0,160(a3)
ci_DecodeI3:	lea	40*5(a3),a3
		lea	1(a1),a1
		dbf	d2,ci_DecodeI2

		lea	1+65(a1),a1		;vir to 65 - next row
		cmpi	#31,d5
		beq.s	.ci_d5
		lea	32(a1),a1
.ci_d5:		ror.l	d0
		bpl.s	ci_d4
		lea	4(a2),a2
ci_d4:		dbf	d1,ci_DecodeI1
		movem.l	(sp)+,ALL
		rts


pw_Invert:	lea	(a4),a1			;wall - invert
		move.l	#1,d0			;for or
cj_DecodeI1:	lea	(a2),a3
		move.l	d0,d4
		not.l	d4			;for and
		move	d5,d2			;Y CNT
cj_DecodeI2:	move.b	(a1)+,d3
		beq.s	cj_DecodeI3
		add.b	d3,d3
		bcs.s	.cj_di00
		and.l	d4,(a3)
		bra.s	.cj_di01
.cj_di00:	or.l	d0,(a3)
.cj_di01:	add.b	d3,d3
		bcs.s	.cj_di10
		and.l	d4,40(a3)
		bra.s	.cj_di11
.cj_di10:	or.l	d0,40(a3)
.cj_di11:	add.b	d3,d3
		bcs.s	.cj_di20
		and.l	d4,80(a3)
		bra.s	.cj_di21
.cj_di20:	or.l	d0,80(a3)
.cj_di21:	add.b	d3,d3
		bcs.s	.cj_di30
		and.l	d4,120(a3)
		bra.s	.cj_di31
.cj_di30:	or.l	d0,120(a3)
.cj_di31:	add.b	d3,d3
		bcs.s	.cj_di40
		and.l	d4,160(a3)
		bra.s	cj_DecodeI3
.cj_di40:	or.l	d0,160(a3)
cj_DecodeI3:	lea	40*5(a3),a3
		lea	1(a1),a1
		dbf	d2,cj_DecodeI2

		lea	1+65(a1),a1		;vir to 65 - next row
		rol.l	d0
		dbf	d1,cj_DecodeI1
		movem.l	(sp)+,ALL
		rts

;---------------------------------------------------------------------
ClrGscreen:	movem.l	d0/d1/a1,-(sp)
		lea	Gscreen,a1
		moveq	#0,d0
		move	#[20*8]-1,d1
.cg:		move.l	d0,(a1)+
		dbf	d1,.cg
		movem.l	(sp)+,d0/d1/a1
		rts

ClrLine:	movem.l	d0/a1,-(sp)
		move	SwitchNr,d0
		lsl	#6,d0
		lea	SwitchTab,a1
		lea	(a1,d0.w),a1
		move	#[64/4]-1,d0
.cl:		move.l	#0,(a1)+
		dbf	d0,.cl
		movem.l	(sp)+,d0/a1
		rts

;---------------------------------------------------------------------
PrintSwitch:	movem.l	ALL,-(sp)
		move	SwitchNr,d0
		lsl	#6,d0
		lea	SwitchTab,a1
		lea	(a1,d0.w),a1		;switch cell
		lea	Gscreen+80+1,a2		;screen addr
		moveq	#0,d0
		move	SwitchNr,d0		;print nr
		divu	#10,d0
		addi	#16,d0
		bsr	Litera
		swap	d0
		addi	#16,d0
		bsr	Litera
		move	#"."-32,d0
		bsr	Litera
;ps_Loop:
		move	(a1)+,d7		;CNT
		beq.w	psEnd
		move	(a1)+,d1
		move	d1,d0
		andi	#7,d0
		cmpi	#5,d0
		beq.s	ps_karta
		cmpi	#4,d0
		beq.s	ps_tel
		move	#"G"-32,d0		;guzik
		bra.s	ps_cont1
ps_karta:	move	#"K"-32,d0		;karta
		bsr	Litera
		move	(a1)+,d0		;kolor
		move.b	ps_KartKOL(pc,d0.w),d0
		subi	#32,d0
		bra.s	ps_cont1
ps_kartKOL:	dc.b	"-RGB"
ps_tel:		move	#"T"-32,d0		;teleport
		bsr	Litera
		move	d1,d0
		bsr	Lokacja
		move	(a1)+,d0
		beq	psEnd
		bsr	Lokacja
		bra	psEnd

ps_cont1:	bsr	Litera
		move	d1,d0
		bsr	Lokacja

ps_Loop:	move	(a1)+,d0
		beq.s	psEnd
		cmpi	#-2,d0			;command = -2 ?
		bne.s	ps_1
		move	#"#"-32,d0
		lea	1(a2),a2
		bsr	Litera
		bra.s	ps_Loop
ps_COMM:	dc.b	"ODCDSBRB W I C"
ps_1:		lea	1(a2),a2
		andi	#$ff,d0
		add	d0,d0
		move	ps_COMM(pc,d0.w),d1
		move	d1,d0
		lsr	#8,d0
		cmpi	#" ",d0
		beq.s	ps_2
		subi	#32,d0
		bsr	Litera			;command
ps_2:		move	d1,d0
		andi	#$ff,d0
		subi	#32,d0
		bsr	Litera			;command

		move	(a1)+,d0
		beq.s	psEnd
		bsr	Lokacja
		bra.s	ps_Loop

psEnd:		movem.l	(sp)+,ALL
		rts

Litera:
;		subi	#32,d0
		lsl	#3,d0
		lea	Fonts,a3
		lea	(a3,d0.w),a3
		move.b	(a3)+,(a2)
		move.b	(a3)+,80(a2)
		move.b	(a3)+,2*80(a2)
		move.b	(a3)+,3*80(a2)
		move.b	(a3)+,4*80(a2)
		move.b	(a3)+,5*80(a2)
		move.b	(a3)+,6*80(a2)
;		move.b	(a3)+,7*80(a2)
		lea	1(a2),a2
		rts

Lokacja:	movem.l	d0/d1,-(sp)
		lea	1(a2),a2		;spacja
		move	d0,d1
		lsr	#3,d0
		andi.l	#63,d0			;X
		lsr	#7,d1
		lsr	#2,d1
		andi.l	#63,d1			;Y
		divu	#10,d0
		addi	#16,d0
		bsr	Litera
		swap	d0
		addi	#16,d0
		bsr	Litera
		ori.b	#1,[6*80]-1(a2)
		move.l	d1,d0
		divu	#10,d0
		addi	#16,d0
		bsr	Litera
		swap	d0
		addi	#16,d0
		bsr	Litera
		movem.l	(sp)+,d0/d1
		rts

;---------------------------------------------------------------------
;non-system read mouse routine by KANE of SUSPECT

oldmouse:	dc.w	0		;rejestr pomocniczy
mouse_x:	dc.w	0		;pozycja x,y myszy (w pixlach)
mouse_y:	dc.w	0

mouse:		lea	oldmouse(pc),a1
		move	10(a0),d0
		move	d0,d1
		andi	#$ff,d0
		lsr	#8,d1
		move.b	(a1),d2
		move.b	1(a1),d3
		move.b	d0,(a1)
		move.b	d1,1(a1)
		subi.b	d2,d0
		subi.b	d3,d1
		ext	d0
		ext	d1

		addi	d0,2(a1)		;ogranicz do ekranu
		bpl.s	left_ok
		clr	2(a1)
left_ok:	cmpi	#[row*8]-1,2(a1)
		bmi.s	right_ok
		move	#[row*8]-1,2(a1)
right_ok:	addi	d1,4(a1)
		bpl.s	up_ok
		clr	4(a1)
up_ok:		cmpi	#258-1,4(a1)
		bmi.s	down_ok
		move	#258-1,4(a1)
down_ok:	rts

;---------------------------------------------------------------------
;draw cursor routine (sprite, at x,y) by KANE of SUSPECT

cursor:		lea	sprite(pc),a1
		move	mouse_y(pc),d0
		addi	#37-8,d0		;y to border
		move	d0,d1
		addi	#8,d1
		ror	#8,d1
		lsl.b	#1,d1		;vstop
		rol	#8,d0
		tst.b	d0
		beq.s	cur_2
		ori	#4,d1
		clr.b	d0
cur_2:		move	mouse_x(pc),d2
		addi	#119,d2		;x to border
		lsr	#1,d2
		bcc.s	cur_3
		ori	#1,d1
cur_3:		or.b	d2,d0
		move	d0,(a1)
		move	d1,2(a1)
		rts

;-------------------------------------------------------------------
cursor2:
		lea	CursorPos,a3
		move	mouse_x(pc),d0
		move	d0,d2
		lsr	#3,d2
		addi	MapX,d2
		move	d2,(a3)			;X of cursor on map
		andi	#7,d0
		move	mouse_y(pc),d1
		move	d1,d2
		lsr	#3,d2
		move	#19,d3
		sub	d2,d3
		addi	MapY,d3
		move	d3,2(a3)		;Y of cursor on map
		andi	#7,d1
		move	brickID,d2
		cmpi	#50,d2
		bpl.w	cur_23			;if norm
		cmpi	#12,d2
		bpl.s	cur_21

		move	#0,4(a3)		;dir
		cmpi	#2,d1			;N
		bmi.w	cur_22
		cmpi	#6,d1			;S
		bmi.s	c_40
		addi	#2,d2
		move	#2,4(a3)
		bra.w	cur_22
c_40:		cmpi	#4,d0			;E
		bmi.s	c_41
		addi	#1,d2
		move	#1,4(a3)
		bra.w	cur_22
c_41:		addi	#3,d2			;W
		move	#3,4(a3)
		bra.w	cur_22

cur_21:		lea	sprite+4,a1
		lea	bricks,a2
		lsl	#4,d2
		lea	(a2,d2.w),a2
		REPT	8
		move.b	#0,(a1)+
		move.b	(a2)+,(a1)+
		lea	1(a2),a2
		move	#0,(a1)+
		ENDR
		bra.w	cur_23

cur_22:		lea	sprite+4,a1
		lea	bricks,a2
		lsl	#4,d2
		lea	(a2,d2.w),a2
		REPT	8
		move.b	#0,(a1)+
		move.b	(a2)+,(a1)+
		lea	1(a2),a2
		move	#0,(a1)+
		ENDR
		ori	#%00011000,sprite+5*4
		ori	#%00011000,sprite+6*4

cur_23:

		lea	sprite(pc),a1
		move	mouse_y(pc),d0
		andi	#$1f8,d0
		move	mouse_x(pc),d2
		andi	#$1f8,d2

		addi	#40-8,d0		;y to border
		move	d0,d1
		addi	#8,d1
		ror	#8,d1
		lsl.b	#1,d1		;vstop
		rol	#8,d0
		tst.b	d0
		beq.s	cur_20
		ori	#4,d1
		clr.b	d0
cur_20:		addi	#123,d2		;x to border
		lsr	#1,d2
		bcc.s	cur_30
		ori	#1,d1
cur_30:		or.b	d2,d0
		move	d0,(a1)
		move	d1,2(a1)
		rts

;-------------------------------------------------------------------
GetRandom:	movem.l	a4/d4,-(sp)
		move.l	sv_RomAddr,a4
		move	(a4)+,d0
		move.l	a4,d4
		andi.l	#$ffff,d4
		or.l	#$f90000,d4		;f90000-fa0000
		move.l	d4,sv_RomAddr
		movem.l	(sp)+,a4/d4
		rts

sv_RomAddr:	dc.l	$f90000
;-------------------------------------------------------------------
row:		equ	40

sprite:	dc.w	$6d6d,$7400
	dc.w	%00001000,0
	dc.w	%00001000,0
	dc.w	%00001000,0
	dc.w	%01110111,0
	dc.w	%00001000,0
	dc.w	%00001000,0
	dc.w	%00001000,0
	dc.w	%00000000,0
sproff:	dc.l	0

sprcop:	dc.w	%00001000,0
	dc.w	%00001000,0
	dc.w	%00001000,0
	dc.w	%01110111,0
	dc.w	%00001000,0
	dc.w	%00001000,0
	dc.w	%00001000,0
	dc.w	%00000000,0

ScolTab:
	dc.w	0
	dc.w	$fff,$eee,$ddd,$ccc,$bbb,$aaa,$999,$888,$777,$666
	dc.w	$555,$444,$333,$222,$111,000
	dc.w	$111,$222,$333,$444,$555,$666,$777,$888,$999,$aaa
	dc.w	$bbb,$ccc,$ddd,$eee,$fff
	
;-------------------------------------------------------------------
RealCopper:
dc.w	$0180,$000,$0182,$222,$0184,$444,$0186,$666
dc.w	$0188,$888,$018a,$aaa,$018c,$ccc,$018e,$eee
dc.w	$0190,$080,$0192,$0ee,$0194,$088,$0196,$0f0
SprCols:
dc.w	$0198,$880,$019a,$fff,$019c,$f00,$019e,$dd0
SprCols2:
dc.w	$01ba,$fff

dc.w	$120,sproff/$10000,$122,sproff&$ffff
dc.w	$124,sproff/$10000,$126,sproff&$ffff
dc.w	$128,sproff/$10000,$12a,sproff&$ffff
dc.w	$12c,sproff/$10000,$12e,sproff&$ffff
dc.w	$130,sproff/$10000,$132,sproff&$ffff
dc.w	$134,sproff/$10000,$136,sproff&$ffff
dc.w	$138,sproff/$10000,$13a,sproff&$ffff
dc.w	$13c,sprite/$10000,$13e,sprite&$ffff


;dc.l	$1fc0000,$1060000,$10c0000		;AGA OFF!!!


dc.l	$920038,$9400d0,$8e0171,$9037d1
dc.l	$1020033,$1040024
dc.w	$108,3*row,$10a,3*row

cop_screen:
dc.w	$e0,screen/$10000,$e2,screen&$ffff
dc.w	$e4,[screen+row]/$10000,$e6,[screen+row]&$ffff
dc.w	$e8,[screen+[2*row]]/$10000,$ea,[screen+[2*row]]&$ffff
dc.w	$ec,[screen+[3*row]]/$10000,$ee,[screen+[3*row]]&$ffff
dc.l	$2001ff00,$01004300
;dc.l	$c7e1fffe,$01000300
dc.l	$c001ff00,$01000300

dc.w	$e0,panel/$10000,$e2,panel&$ffff
dc.w	$108,0,$10a,0
dc.l	$1820afa
dc.l	$c101ff00,$01001300

dc.l	$e101ff00,$01000300
dc.w	$108,4*row,$10a,4*row
WallCols:
dc.w	$0180,0,$0182,0,$0184,0,$0186,0
dc.w	$0188,0,$018a,0,$018c,0,$018e,0
dc.w	$0190,0,$0192,0,$0194,0,$0196,0
dc.w	$0198,0,$019a,0,$019c,0,$019e,0
dc.w	$01a0,0,$01a2,0,$01a4,0,$01a6,0
dc.w	$01a8,0,$01aa,0,$01ac,0,$01ae,0
dc.w	$01b0,0,$01b2,0,$01b4,0,$01b6,0
dc.w	$01b8,0,$01ba,0,$01bc,0,$01be,0
dc.w	$e0,[screen2]/$10000,$e2,[screen2]&$ffff
dc.w	$e4,[screen2+row]/$10000,$e6,[screen2+row]&$ffff
dc.w	$e8,[screen2+[2*row]]/$10000,$ea,[screen2+[2*row]]&$ffff
dc.w	$ec,[screen2+[3*row]]/$10000,$ee,[screen2+[3*row]]&$ffff
dc.w	$f0,[screen2+[4*row]]/$10000,$f2,[screen2+[4*row]]&$ffff
cop_cont2:
dc.l	$e201ff00,$01005300
dc.l	$ffdffffe
dc.l	$2201ff00,$01000300,$1800ff0

dc.w	$e0,Gscreen/$10000,$e2,Gscreen&$ffff
dc.l	$10200ff
dc.w	$108,0,$10a,0
dc.l	$1820fff
dc.l	$2301ff00,$01009300,$1800030
dc.l	$2b01ff00,$01000300,$1800ff0
dc.l	$2c01ff00,$1800000
dc.l	-2

copper0:
dc.l	$01000300,$1800000,-2


;-------------------------------------------------------------------
st_Offsets:

sv_WallOffsets:		;start offsets of walls in table
dc.l	0,65*64,2*65*64,3*65*64,4*65*64
dc.l	5*65*64,6*65*64,7*65*64,8*65*64,9*65*64
dc.l	10*65*64,11*65*64,12*65*64,13*65*64,14*65*64
dc.l	15*65*64,16*65*64,17*65*64,18*65*64,19*65*64

dc.l	20*65*64,21*65*64,22*65*64,23*65*64,24*65*64
dc.l	25*65*64,26*65*64,39*65*64				;+buffer

sv_CollumnOffsets:
dc.l	27*65*64,27*65*64+[65*32],28*65*64,28*65*64+[65*32]	;collumns
dc.l	29*65*64,29*65*64+[65*32],30*65*64,30*65*64+[65*32]
dc.l	31*65*64,31*65*64+32,31*65*64+[65*32],31*65*64+[65*32]+32 ;up
dc.l	32*65*64,32*65*64+32,32*65*64+[65*32],32*65*64+[65*32]+32
dc.l	33*65*64,33*65*64+32,33*65*64+[65*32],33*65*64+[65*32]+32 ;down
dc.l	34*65*64,34*65*64+32,34*65*64+[65*32],34*65*64+[65*32]+32

sv_ItemOffsets:
; items, 29-48
dc.l	65*65*64,65*65*64+32,65*65*64+[65*32],65*65*64+[65*32]+32
dc.l	66*65*64,66*65*64+32,66*65*64+[65*32],66*65*64+[65*32]+32
dc.l	67*65*64,67*65*64+32,67*65*64+[65*32],67*65*64+[65*32]+32
dc.l	68*65*64,68*65*64+32,68*65*64+[65*32],68*65*64+[65*32]+32
dc.l	69*65*64,69*65*64+32,69*65*64+[65*32],69*65*64+[65*32]+32

sv_BloodOffsets:
dc.l	35*65*64,36*65*64,37*65*64,39*65*64

sv_PlaqueOffsets:
dc.l	38*65*64,38*65*64+32,38*65*64+[65*32],38*65*64+[65*32]+32

sv_EnemyOffsets:
dc.l	40*65*64
dc.l	52*65*64+[65*32]

;-------------------------------------------------------------------
;ulozenia scian
WallScr:	dc.l	Walls1

Walls1:
dc.b	00,01,02,03,04,05,06,07,08,09
dc.b	10,11,20,21,22,23,25,26,-1,-1
dc.b	2,2,2,2,4,4,4,4,6,6,6,6,8,8,8,8,10,10,10,10
dc.b	12,12,12,12,14,14,14,14,16,16,16,16,18,18,18,18,20,20,20,20
dc.b	22,22,22,22,24,24,24,24,42,42,42,42,44,44,44,44,46,46,46,46
dc.b	48,48,48,48,52,52,52,52,54,54,54,54

Walls2:
dc.b	14,15,17,18,27,28,29,31,32,33
dc.b	34,38,35,36,37,-1,-1,-1,-1,-1
dc.b	30,30,30,30,32,32,32,32,36,36,36,36,38,38,38,38
dc.b	1,2,1,2,3,4,3,4,5,5,5,5,9,11,10,12
dc.b	13,13,13,13,17,19,18,20,21,21,21,21
dc.b	1,3,2,3
dc.b	$40,$40,$40,$40,$80,$80,$80,$80,$c0,$c0,$c0,$c0

Walls3:
dc.b	-1,-1,-1,-1,-1,-1,40,53,-1,-1
dc.b	65,66,67,68,69,-1,-1,-1,-1,-1
dc.l	0,0,0,0,0,0
dc.b	1,1,1,1,2,2,2,2
dc.l	0,0
dc.b	1,3,2,4,5,7,6,8,9,11,10,12,13,15,14,16,17,19,18,20


;-------------------------------------------------------------------
SwitchTab:	equ	BASE+$66000		;$2000 (128*64)
sv_MAP:		equ	BASE+$68000		;$8000
sv_LEVELDATA:	equ	BASE+$70000
sv_LevelEnemy:	equ	BASE+$70000+40
sv_LevelSwitch:	equ	BASE+$70000+4136

;---------------Editor memory
screen:		equ	BASEC+$26000		;$7d00
screen2:	equ	BASEC+$2e000		;$3200
panel:		equ	BASEC+$32000		;$500

bricks:		equ	BASEC+$32600
numbers:	equ	BASEC+$33000
sc_colors:	equ	BASEC+$33800		;$40 (64)
Fonts:		equ	BASEC+$34000		;$300
Gscreen:	equ	BASEC+$34600		;$280

;---------------OFFSETS:
co_Walls:	equ	$35000			;[320*4*65]*4=$14500 * 4
; $14500 + $14500 + $19640 + $71c0 = $49200
; wallsA   wallsB   enemy    items

;-------------------------------------------------------------------
Oryginal_Data:

;---------------FREE 0.5 MB:
memory:		dc.l	BASE

;---------------EditorPrefs
MapX:		dc.w	0
MapY:		dc.w	0
MapOffset:	dc.l	0

;---------------OTHER:
DoQuit:		dc.w	0
DoRedraw:	dc.w	0
BrickID:	dc.w	0		;0,4,8, 12,13,...18 (dla sprite)
					;50 - normal
ChoiceID:	dc.w	0		;0..5 (wall/collumn/enemy...)
Choice:		dc.w	2,0		;nr of wall, col itp.
Right:		dc.w	0
IdentWall:	dc.w	1		;1- identify wall on
PlayEnd:	dc.w	0		;0-set player, 1-level end
DoRedrMap:	dc.w	0		;1 - redraw map

EditSwitch:	dc.w	0		;1 - edit switch option on
SwitchNr:	dc.w	0		;actual switch (0-127)
EditAgr:	dc.w	0		;1 - editing enemy agression

CursorPos:	dc.w	0,0,0		;x,y on map + dir(0,1,2,3)

AgrSave:	dc.w	0,0,0,0,0,0,0,0,0,0

EnemyNRG0:	dc.b	0,0,0,0,0,0, 0,0,0,0,0,0
EnemyNRG:	dc.w	0,0,0,0		;nrg, spd
;---------------POSITION:
sv_PosX:	dc.w	0
sv_PosY:	dc.w	0
sv_angle:	dc.w	90
;sv_WalkSpeed:	dc.w	0,220,0,0		;(up to 300),val,buf,CNT
;sv_RotSpeed:	dc.w	12


;-------------------------------------------------------------------
;-------------------------------------------------------------------
CommandTable:
;switch: -1, present_loc, command_nr1., command_loc1, command_nr2, ...
;-2, command_nr, command_loc, ... (for switch out - optional)
dc.w	-1,4*512+4*8+0, 17<<8+5,3*512+2*8
dc.w	3<<8+6,0*512+5*8, 2,2*512+0*8, 2,3*512+0*8
dc.w	-2, 6,0*512+5*8, 3,2*512+0*8, 3,3*512+0*8

dc.w	-1,0*512+0*8+2, 0,3*512+5*8+2, 3,2*512+0*8, 3,3*512+0*8
dc.w	-2, 1,3*512+5*8+2

dc.w	-1,10*512+3*8+0, 4,7*512+3*8+1, 4,7*512+4*8+3, 1<<8+6,13*512+7*8
dc.w	-2,8<<8+4,7*512+3*8+1, 8<<8+4,7*512+4*8+3, 6,13*512+7*8

dc.w	-1,16*512+6*8+0, 0,16*512+5*8+0
dc.w	-2, 1,16*512+5*8+0

dc.w	-1,9*512+14*8+2, 3,9*512+14*8, 3,9*512+13*8

dc.w	-1,22*512+27*8+1, 2,17*512+16*8
dc.w	-2, 4<<8+6,24*512+29*8

dc.w	-1,22*512+29*8+2, 4,24*512+30*8+3, 4,25*512+29*8+2
dc.w	-2,  6,24*512+29*8, 3,17*512+16*8

;card: -1, present_loc, card_col (1,2,3), command_nr1, ...
dc.w	-1,4*512+1*8,2, 0,4*512+3*8+0
dc.w	-1,0*512+13*8,1, 4,1*512+13*8+0
dc.w	-1,14*512+15*8,3, 0,16*512+16*8+0

;teleport: -1, present_loc+4, X jump, Y jump
dc.w	-1,13*512+17*8+4, 0, 23
dc.w	-1,23*512+2*8+4,  4, 23
dc.w	-1,24*512+29*8+4, 31, 7
dc.w	-1,-1

;-------------------------------------------------------------------
>extern	"EDITOR:GFX/WALLS1A.VIR",BASEC+co_Walls,-1
>extern	"EDITOR:GFX/WALLS1B.VIR",BASEC+co_Walls+83200,-1
>extern	"EDITOR:DATA/ITEMS01.VIR",BASEC+co_Walls+270400
>extern	"EDITOR:DATA/FONTS01.FNT",Fonts,-1
>extern	"EDITOR:GFX/ENEMY1A.VIR",BASEC+co_Walls+83200+83200,-1
>extern	"EDITOR:GFX/ENEMY1B.VIR",BASEC+co_Walls+83200+83200+52000,-1
>extern	"EDITOR:GFX/COLS01.DAT",sc_colors,-1

>extern	"EDITOR:DATA/BRICKS.RAW",bricks,-1
>extern	"EDITOR:DATA/EDITOR.NUM",numbers,-1
>extern	"EDITOR:DATA/EDITOR_PANEL.RAW",panel,-1

>extern "EDITOR:MAPS/LEVEL01.MAP",sv_MAP,-1

;>extern "df0:GFX/LEVEL01.MAP",sv_MAP,-1
;>extern "df1:LEVEL01.MAP",sv_MAP,-1

;>extern	"DATA:GFX_VIR/WALLS1A.VIR",BASEC+co_Walls,-1
;>extern	"DATA:GFX_VIR/WALLS1B.VIR",BASEC+co_Walls+83200,-1
;>extern	"DATA:GFX_VIR/ITEMS01.VIR",BASEC+co_Walls+270400
;>extern	"DATA:MAPS/LEVEL02.MAP",sv_MAP,-1
;>extern	"DATA:GFX_VIR/FONTS01.FNT",Fonts,-1
;>extern	"DATA:GFX_VIR/ENEMY1A.VIR",BASEC+co_Walls+83200+83200,-1
;>extern	"DATA:GFX_VIR/ENEMY1B.VIR",BASEC+co_Walls+83200+83200+52000,-1
;>extern	"DATA:STORE/COLS01.DAT",sc_colors,-1
;
;>extern	"DAT1:GFX/BRICKS.RAW",bricks,-1
;>extern	"DAT1:GFX/EDITOR.NUM",numbers,-1
;>extern	"DAT1:GFX/EDITOR_PANEL.RAW",panel,-1
;-------------------------------------------------------------------

end:
