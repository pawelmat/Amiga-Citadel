����   5   5   5   5   5   5   5   5   5   5
;CITADEL Hard Disk loader - by KANE/SCT, 18.09.1995

wait:	macro
.w\@:	cmp.b	#$ff,6(a0)
	bne.s	*-6
	cmp.b	#$ff,6(a0)
	beq.s	*-6
	dbf	d0,.w\@
	endm


l_buf:		equ	$100000

s:
	move	#$20,$dff09a
	moveq	#1,d0
	moveq	#57,d1
	lea	l_buf,a1
	jsr	HD_seek

	moveq	#1,d0
	moveq	#1,d1
	lea	l_buf+2,a1
	jsr	HD_seek

	moveq	#1,d0
	moveq	#7,d1
	lea	l_buf+4,a1
	jsr	HD_seek

	move	#$8020,$dff09a
	rts



	org	$f8000
	load	*
ss:
;-----------------------------------------------
;INPUT:	a0 - [name], a1 - buffer, d0 - disk nr (1,2,3,4,5), d1 - start TR
;OUTPUT: d0 - NULL (ok), d1 - length

HD_seek:	movem.l	a0-a6/d2-d7,-(sp)
		cmpi	#5,d0
		bne.s	HD_not5
		lea	4(a0),a0		;skip df0:
		bsr	HD_load
		bra.s	HD_end
HD_not5:	subq	#1,d0
		add	d0,d0
		add	d0,d0
		lea	DiskAdr(pc),a0
		move.l	(a0,d0.w),a0		;disk structure
		lea	-4(a0),a0
HD_find:	lea	6(a0),a0
		move	-2(a0),d0
		cmpi	d0,d1
		bne.s	HD_find
		bsr	HD_load
HD_end:		lea	$dff000,a0
		move.l	d1,d0
		lsr.l	d0
		divu	#60000,d0
		addq.w	#1,d0
		mulu	#15,d0
		wait
		movem.l	(sp)+,a0-a6/d2-d7
		moveq	#0,d0
		rts

;-----------------------------------------------
oldopenlib:	equ	-$198
closelibrary:	equ	-$19e

open:		equ	-$01e
close:		equ	-$024
lock:		equ	-$054
unlock:		equ	-$05a
examine:	equ	-$066
read:		equ	-$02a
mode_oldfile:		equ	1005
;-----------------------------------------------
HD_load:	move	l_offset(pc),d0
		bne.s	HD_CfgOK
		movem.l	a0/a1,-(sp)
		lea	PrefName(pc),a2		;load config (path)
		lea	l_name(pc),a1
		pea	(a1)
		bsr.s	HD_DoLoad
		move.l	(sp)+,a1
		lea	RestName(pc),a0
		move	d1,d0
		subq	#2,d0
HD_CopRest:	move.b	(a0)+,d1
		addq	#1,d0
		move.b	d1,(a1,d0.w)
		bne.s	HD_CopRest
		move	d0,l_offset
		movem.l	(sp)+,a0/a1
HD_CfgOK:	lea	l_name(pc),a2
HD_CopLoop:	move.b	(a0)+,d1
		addq	#1,d0
		move.b	d1,-1(a2,d0.w)
		bne.s	HD_CopLoop

HD_DoLoad:		lea	-20(sp),sp
			move.l	a2,load_loadname(sp)
			move.l	a1,load_buffer(sp)
			move.l	$4.w,a6
			lea	dosname(pc),a1
			jsr	oldopenlib(a6)
			move.l	d0,dosbase(sp)
			move.l	d0,a6
			move.l	load_loadname(sp),d1
			move.l	#mode_oldfile,d2
			jsr	open(a6)
			tst.l	d0
			beq	load_filerror
			move.l	d0,load_filehandle(sp)

			move.l	load_loadname(sp),d1
			move.l	#mode_oldfile,d2
			jsr	lock(a6)
			move.l	d0,load_filelock(sp)

			move.l	d0,d1
			move.l	a0,-(sp)
			lea	load_fileinfoblock(pc),a0
			move.l	a0,d2
			move.l	(sp)+,a0
			jsr	examine(a6)

			move.l	load_filelock(sp),d1
			jsr	unlock(a6)

			lea	load_fileinfoblock(pc),a0
			move.l	load_filehandle(sp),d1
			move.l	load_buffer(sp),d2
			move.l	#$fffff,d3
			jsr	read(a6)
			move.l	d0,-(sp)		;length

load_seekerror:		move.l	load_filehandle+4(sp),d1
			jsr	close(a6)

load_filerror:		move.l	$4.w,a6
			move.l	dosbase+4(sp),a1
			jsr	closelibrary(a6)
			move.l	(sp)+,d1
			lea	20(sp),sp
			rts

dosbase:		equ	0
load_filehandle:	equ	4
load_filelock:		equ	8
load_buffer:		equ	12
load_loadname:		equ	16

dosname:	dc.b	"dos.library",0
load_fileinfoblock:	blk.b	270,0
prefname:	dc.b	"S:CITADEL.CFG",0
RestName:	dc.b	"/CITADEL/DATA/",0
even
l_offset:	dc.w	0
l_name:		blk.b	128,0
;-----------------------------------------------

diskAdr:	dc.l	disk1,disk2,disk3,disk4,disk5
disk1:
dc.b	0,1,"C01",0
dc.b	0,7,"C02",0
dc.b	0,53,"C03",0
dc.b	0,57,"C04",0
disk2:
dc.b	0,0,"C05",0
dc.b	0,10,"C06",0
dc.b	0,30,"C07",0
dc.b	0,54,"C08",0
disk3:
dc.b	0,0,"C09",0
dc.b	0,1,"C10",0
dc.b	0,22,"C11",0
dc.b	0,42,"C12",0
dc.b	0,62,"C13",0
dc.b	0,72,"C14",0
dc.b	0,76,"C15",0
disk4:
dc.b	0,1,"C16",0
dc.b	0,12,"C17",0
dc.b	0,18,"C18",0
dc.b	0,21,"C19",0
dc.b	0,24,"C20",0
dc.b	0,34,"C21",0
dc.b	0,43,"C22",0
dc.b	0,60,"C23",0
disk5:


end:
