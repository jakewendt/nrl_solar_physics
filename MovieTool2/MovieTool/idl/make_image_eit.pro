;+
FUNCTION MAKE_IMAGE_EIT, img, hdr, $
	FIXGAPS=fixgaps, $
	NOLABEL=nolabel, $
	NOBYTESCL=nobytescl, $
	FILENAME=filename, $
	USEEITPREP=useeitprep


; Returns scaled EIT image with time label and sets color table for viewing
; image.
;
; INPUTS:
;  img		512x512 or 1024x1024 EIT image array
;  hdr		LASCO header structure
;
; OUTPUTS:
;  1024x1024 BYTARR
;
; KEYWORDS:
;  FIXGAPS	If set, replace gaps with previous image (in common block)
;  NOLABEL	If set, do not put on time label
;  NOBYTESCL	If set, floating point array with no time label
;  FILENAME	Set to full filename if image to be read here
;  USEEITPREP	Set if wanting to use EIT_PREP, must also use FILENAME
;
; SIDE EFFECTS:
;  changes color table
;
; MODS:
;
; 1999/05/21	N B Rich	Add FIXGAPS keyword, common block
; 1999/05/26	N B Rich	Move case statement; make all images 1024x1024
; 1999/11/15 	N B Rich	Adapt for Mercury transit images (horiz. strips)
; 1999/12	N B Rich	Check for allowable nz
; 2000/01	N B Rich	Add NOLABEL keyword
; 2000/09/08	N B Rich	Add EIT_NORM_RESPONSE and change bmin/bmax settings
; 2000/09/22	n b rich	Divide by exptime and sumcol^2
; 2001/01/29    n.b.rich	Change bmin/bmax after updating SSW library
; 2001/02/09	n.b.rich	Move reduce_std_size and remove box_refn
; 2001/02/12	n.b.rich	Add NOBYTESCL option
; 2001.03.01	n.b.rich	Reset bmin,bmax and colortables for new flat field;
;				fixed hsize
; 2001.03.02	n.b.rich	Fix ind00 again and fix call to EIT_DEGRID
; 2001.03.06	n.b.rich	Do ind00 before reduce_std_size
; 2001.04.11  	n.b.rich	Add default box_avg values
;
; 20010516	the-jake	Added autoscaling of images based on median to help
;				correct for binned image problems.  Corrected indentations
;				on all code.
; 2001.06.07	n.b.rich	Omit /ORIG from EIT_DEGRID call for SSW
; 20010724	thejake	began incorporation of EIT_PREP
; 2002.04.08	n.b.rich	Change location of .dat files
; 2002.08.05	n.b.rich	Change lasco_hdr2struct to lasco_fitshdr2struct
;
;  08/05/02 @(#)make_image_eit.pro	1.4 - IDL NRL LASCO Library
;
;-

COMMON RTMVI_COMMON_IMG, prev2,prev3,prev195,prev171,prev284,prev304




	if KEYWORD_SET(USEEITPREP) then begin	;#	thejake 010724
		if KEYWORD_SET(FILENAME) then $
			eit_prep, filename, eitprephdr, img, /resp, /nrl, /float, /filter, fill=fltarr(32,32) $
		else begin
			PRINT, "Filename must be set with the USEEITPREP keyword"
			STOP
		endelse
		IF datatype(hdr) EQ 'UND' THEN hdr = lasco_fitshdr2struct(eitprephdr)
	endif		;#	end thejake 010724

	datdir = concat_dir(GETENV('LASCO_DATA'),'color')
	sz = SIZE(img)
	hsize = sz(1)
	vsize = sz(2)
	scale = 1024/hsize
	bx1 = 11		;412
	bx2 = 210		;bx1+199
	by1 = 821		;0
	by2 = 1010	;29
	fillcol=1.	; default
	box=[bx1,bx2,by1,by2]/scale
	box_ref=30.
	help, box_ref
	thdr=hdr	;"	DO NOT use the eitprephdr




	if NOT KEYWORD_SET(USEEITPREP) then begin		;#	thejake 010724
		bias = OFFSET_BIAS(hdr, /SUM)
		image = FLOAT(img) - bias			;subtract detector bias from image
		fitshdr=STRUCT2FITSHDR(hdr)
		wavelength = FIX(STRMID(hdr.sector,0,3))
		image = EIT_DEGRID(image, fitshdr)
		image = EIT_FLAT(image, fitshdr)
		imn = EIT_NORM_RESPONSE(hdr.date_obs,wavelength,fitshdr,/verbose)
		image = image/imn
	endif else $
		image = img		;#	end thejake 010724






	ind00 = WHERE(image LE 0,n)
	nz = where(image GT 0)
	print,hdr.exptime,hdr.sumcol
	image = image/(hdr.exptime)	;*(hdr.sumcol>1)^2)  : done in reduce_std_size
	box_img = DOUBLE(image(box(0):box(1),box(2):box(3)))
	IF hdr.r1col NE 20 THEN box_img=image
	CASE (hdr.sector) OF
		'304A': box_avg=0.97
		'284A': box_avg=0.28
		'195A': box_avg=2.59
		'171A': box_avg=3.41
	ENDCASE
	good = WHERE(box_img GT 0,ngood)
	IF (ngood GT 200000/scale) THEN box_avg=TOTAL(box_img(good))/N_ELEMENTS(good)
	help,box_avg
	image = TEMPORARY(image) * (box_ref/box_avg)        ;** normalize to counts in box
	maxmin,image
	mvi = GETENV('MVIS')
	IF nz(0) NE -1 THEN fillcol=median(image(nz))

	CASE (hdr.sector) OF
		'304A' : BEGIN
			RESTORE,concat_dir(datdir,'304_mpg_col.dat')
			TVLCT,r,g,b
;"			bmin = 0	;0.5
;"			bmax = 4.4 ;4	;3.3	; changed from 3.5
			IF KEYWORD_SET(FIXGAPS) THEN BEGIN
				IF (ind00(0) NE -1) THEN BEGIN			;** gaps in this image
					IF (fixgaps EQ 1) or DATATYPE(prev304) EQ 'UND' or hsize/vsize NE 1 $
						THEN image(ind00) = fillcol $
					ELSE BEGIN
						sz=size(prev304)
						IF sz(1) NE hsize THEN prev304 = rebin(temporary(prev304),hsize,hsize)
						image(ind00) = prev304(ind00)	;** fill gaps in this img with prev image
					ENDELSE
				ENDIF
			ENDIF
			IF hsize/vsize EQ 1 THEN prev304=image
		END

		'284A' : BEGIN
			RESTORE,concat_dir(datdir,'284_mpg_col.dat')
			TVLCT,r,g,b
;"			bmin = 0	;0.5	; changed from 1.0
;"			bmax = 4.2 ;4 ;2.8	; changed from 3.8
			IF KEYWORD_SET(FIXGAPS) THEN BEGIN
				IF (ind00(0) NE -1) THEN BEGIN			;** gaps in this image
					IF (fixgaps EQ 1) or DATATYPE(prev284) EQ 'UND' or hsize/vsize NE 1 $
						THEN image(ind00) = fillcol $
					ELSE BEGIN
						sz=size(prev284)
						IF sz(1) NE hsize THEN prev284 = rebin(temporary(prev284),hsize,hsize)
						image(ind00) = prev284(ind00)	;** fill gaps in this img with prev image
					ENDELSE
				ENDIF
			ENDIF
			IF hsize/vsize EQ 1 THEN prev284=image
		END

		'171A' : BEGIN
			RESTORE,concat_dir(datdir,'171_mpg_col.dat')
			TVLCT,r,g,b
;"			bmin = 0	;-0.2	; nbr, 1/29/01 - after updating SSW
;"			bmax = 4.4 ;4 ;3.3	; nbr, 3/1/01
			IF KEYWORD_SET(FIXGAPS) THEN BEGIN
				help,fixgaps,prev171,ind00
				IF (ind00(0) NE -1) THEN BEGIN			;** gaps in this image
					IF (fixgaps EQ 1) or DATATYPE(prev171) EQ 'UND' or hsize/vsize NE 1 $
						THEN image(ind00) = fillcol $
					ELSE BEGIN
						sz=size(prev171)
						print,'sz[1]',sz[1]
						help,hsize
						IF sz(1) NE hsize THEN prev171 = rebin(temporary(prev171),hsize,hsize)
						image(ind00) = prev171(ind00)	;** fill gaps in this img with prev image
					ENDELSE
				ENDIF
			ENDIF
			IF hsize/vsize EQ 1 THEN prev171=image
		END

		ELSE  : BEGIN
			RESTORE,concat_dir(datdir,'195_mpg_col.dat')
			TVLCT,r,g,b			;** 5/25/00, NBR
;"			bmin = 0.0		; changed from 0.5 - NBR 9/8/00
;"			bmax = 4.4  ;4  ;3.6
			IF KEYWORD_SET(FIXGAPS) THEN BEGIN
				IF (ind00(0) NE -1) THEN BEGIN			;** gaps in this image
					IF (fixgaps EQ 1) or DATATYPE(prev195) EQ 'UND' or hsize/vsize NE 1 $
						THEN image(ind00) = fillcol $
					ELSE BEGIN
						sz=size(prev195)
						IF sz(1) NE hsize THEN prev195 = rebin(temporary(prev195),hsize,hsize)
						image(ind00) = prev195(ind00)	;** fill gaps in this img with prev image
					ENDELSE
				ENDIF
			ENDIF
			IF hsize/vsize EQ 1 THEN prev195=image
		END
	ENDCASE

	time_str=STRMID(hdr.date_obs + ' ' + hdr.time_obs, 0, 16)
	b=where(image le 0,dummy)
	IF dummy ne 0 THEN image(b)=1

	image=ALOG10(image)



	IF nz(0) NE -1 THEN BEGIN		;#	thejake	010516	Auto Scaling of image based on median
		bmin=median(image(nz))-2.2
		bmax=median(image(nz))+1.8
	ENDIF
	help, bmin, bmax




	IF hsize/vsize GT 2 THEN BEGIN
		IF hdr.sector EQ '284A' THEN bmax=bmin+0.25*(bmax-bmin) ELSE bmax=bmin+0.5*(bmax-bmin)
		help,bmax
	ENDIF
	maxmin,image
	wait,2

	IF hsize EQ vsize THEN WINDOW, XSIZE=1024, YSIZE=1024, /FREE, /PIXMAP $
		ELSE window, xsize=hsize, ysize=vsize,/free,/pixmap

	image = REDUCE_STD_SIZE(image,thdr,/full)

	IF NOT keyword_set(NOBYTESCL) THEN BEGIN
		image = BYTSCL(image, bmin, bmax)
		IF hsize EQ vsize THEN BEGIN
		TV, image
		IF (hsize LT 1024) THEN small=1 ELSE small=0
		IF not(keyword_set(NOLABEL)) THEN RTMVIXY, time_str
		ENDIF ELSE BEGIN
			tv,image
			IF not(keyword_set(NOLABEL)) THEN RTMVIXY,XY=[10,75],time_str+'  '+hdr.sector,/SMALL
		ENDELSE
        	image = TVRD()
	ENDIF

	WDELETE
	RETURN, image
END
