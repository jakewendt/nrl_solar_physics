;+
; Project     : SOHO - LASCO/EIT
;                   
; Name        : GETBKGIMG
;               
; Purpose     : Get background image for given telescope
;               
; Explanation : This routine returns a model image (stray light and/or
;		f-corona) for a given telescope, date, image size.
;               
; Use         : bkgimg = GETBKGIMG(hdr, model_hdr)
;    
; Inputs      : None.
;               
; Opt. Inputs : ops	Start time of display in TAI.
;               
; Outputs     : None.
;               
; Opt. Outputs: None.
;               
; Keywords    : use /FFV to return full field of view model (1024x1024 image)
;		use /ALL to return yearly minimum otherwise closest monthly minimum images
;		are interpolated for given date
;		use /ANY_YEAR to return monthly minimum over multiple years.
;	ROLLED	Look in $MONTHLY_IMAGES/rolled
;
; Calls       : 
;
; Common      : SOHO_DATA	Contains start and end times of SOHO roll periods.
;               
; Restrictions: None.
;               
; Side effects: None.
;               
; Category    : Data analysis
;               
; Prev. Hist. : None.
;
; Written     : Scott Paswaters, NRL
;               
; Modified    : 06 Oct 1997 SEP - Added year independent option /ANY_YEAR
;		28 Jul 1998 NBR - added time to tai computation; comment out
;				STRPUT lines in interpolation section
;		23 Sep 1998 NBR - finish repair to year difference problem in interpolation
;		29 Sep 1998 NBR - for /FFV, rebin result to size of input image
;		 5 Oct 1998 NBR - add call for level_1 images
;		13 Nov 1998 NBR - Fix year difference repair
;		25 Mar 1999 NBR - Do not interpolate if DATE_OBSs are equal
;		 6 Apr 1999 NBR - Use congrid to resize if necessary
;		 9 Apr 1999 NBR - Set year2 = year1 for ANY_YEAR
;		   Dec 1999 NBR - Fix Y2K glitch for finding ind
;		   Jan 2000 NBR - Tinker with resize of imgm; ReFix y2k bug for finding ind
;		   Feb 2000 NBR - Rebin both imgm and imgm2 before interpolating
;	Jun 2000 NBR - Add ROLL keyword for rolled images
;	3/23/01, NBR - Check if bkgimg should be rolled in this procedure, making ROLL keyword 
;			unnecessary
;	3/30/01, NBR - Redo year problem for any-year
;	11/20/01, NBR - Use ROLL_TIMES.pro and change ROLL to ROLLED to be consistent with other pros
;	12/17/01, NBR - Fix ANY_YEAR end-of-year problem
;	 3/ 8/02, NBR - Fix computation of factor for interpolation
;	 7/10/02, NBR - Implement new method of finding images (not offset by 14 days) (except for 
;			ANY_YEAR)
;
;
; 	01/27/03, @(#)getbkgimg.pro	1.18 - NRL LASCO IDL Library
;            
; (SCCS variables for IDL use)
;-
; 
FUNCTION GETBKGIMG, hhdr, hdrm, CURRENT=current, FFV=ffv, ALL=all, ANY_YEAR=any_year, $
	ROLLED=rolled

COMMON soho_data, statai, entai


   rebin_flag = 0
   dir = GETENV('MONTHLY_IMAGES')
   IF (dir EQ '')  THEN dir=GETENV('IMAGES')
   IF (DATATYPE(hhdr) NE 'STC')  THEN hdr = LASCO_FITSHDR2STRUCT(hhdr) ELSE hdr=hhdr
   levelchar = ''

   level = FIX(strmid(hdr.filename,1,1))
   cam = STRMID(STRLOWCASE(STRTRIM(hdr.detector,2)),1,1)
   IF ( (cam NE '2') AND (cam NE '3') ) THEN BEGIN
      PRINT, '%%GETBKGIMG: Currently only works for c2 or c3'
      RETURN, -1
   ENDIF
   IF level GT 3 THEN BEGIN
	 dir = dir+'/level_1'
	levelchar = '1'
   ENDIF
;dir = dir+'/testdir'
   curdate = hdr.date_obs
   utc = STR2UTC(curdate+' '+hdr.time_obs)
   tain = UTC2TAI(utc)

;  Check for dates where spacecraft roll >> 1 degree.
;
IF NOT(keyword_set(ROLLED)) THEN BEGIN
   IF datatype(statai) EQ 'UND' THEN roll_times, statai, entai
   ntees = n_elements(entai)
   FOR i=0,ntees-1 DO IF tain GE statai[i] AND tain LT entai[i] THEN ROLLED=1
ENDIF

   IF keyword_set(ROLLED) THEN BEGIN
	dir = GETENV('MONTHLY_IMAGES')+'/rolled'
	levelchar = 'r'
	any_year = 0
   ENDIF

   interp = 0

   x1 = hdr.r1col - 20
   x2 = hdr.r2col - 20
   y1 = hdr.r1row - 1
   y2 = hdr.r2row - 1
help,dir
   filpol = ABBRV_FILPOL(hdr.filter)+ABBRV_FILPOL(hdr.polar)
   IF KEYWORD_SET(CURRENT) THEN $
      name = cam+'m'+levelchar+'_'+filpol+'_currnt.fts' $
   ELSE IF KEYWORD_SET(ALL) THEN $
      name = cam+'m'+levelchar+'_'+filpol+'_all.fts' $
   ELSE BEGIN	;** return closest monthly minimum
      IF KEYWORD_SET(ANY_YEAR) THEN $
       	 srchstrng = FILEPATH(cam+'m'+levelchar+'_'+filpol+'_xx*.fts', ROOT_DIR=dir) $
      ELSE  srchstrng = FILEPATH(cam+'m'+levelchar+'_'+filpol+'*.fts', ROOT_DIR=dir)
      names =  FINDFILE(srchstrng)
      IF (names(0) EQ '') THEN BEGIN
         PRINT, '%%GETBKGIMG: No models found for: ',  srchstrng
	 ;stop
         RETURN, -1
      ENDIF
      BREAK_FILE, names, a, jnk, name, ext
      namelen = strlen(name(0))
      num = STRMID(name,namelen-5,1)
      good = WHERE( (num EQ 'x') OR (num EQ '0') OR (num EQ '1') $
		 OR (num EQ '2') OR (num EQ '3') OR (num EQ '4') $
                 OR (num EQ '5') OR (num EQ '6') OR (num EQ '7') $
		 OR (num EQ '8') OR (num EQ '9') ,ngood)
      names = name(good)+'.fts'
      length = strlen(names(0))

	;** ANY_YEAR ONLY! **
      IF keyword_set(ANY_YEAR) THEN utc.mjd = utc.mjd + 14	;** add in 2 weeks  -  model's date is not mid date
	;				;** model's date is last date of 28 day period, 
	;				;   of which day 14-15 is the mid-point of the model
	;**
      num = UTC2YYMMDD(utc)
      numdt = utc2str(utc,/ecs,/date_only)
     ; daynum = FIX(num,2,4)

      IF KEYWORD_SET(ANY_YEAR) THEN BEGIN	;** only look at mmdd
	 ord = SORT(names)
	 names = names[ord]
	 num = FIX(STRMID(num,2,4))
	 namenums = FIX(STRMID(names,length-8,4))
         ind = FIND_CLOSEST(num, namenums, /less)
	;IF num LT namenums[ind] or num GT namenums[ngood-1] THEN BEGIN
	IF ind GE ngood-1 THEN BEGIN
	   name = names[ngood-1]
	   name2= names[0]
	ENDIF ELSE BEGIN
	   name = names(ind)
	   name2= names[ind+1]
	ENDELSE
	interp = 1
      ENDIF ELSE BEGIN
         wnames = WHERE(STRMID(names,length-10,2) NE 'xx',nwnames)
         IF (nwnames EQ 0)  THEN BEGIN
            PRINT, '%%GETBKGIMG: No models found for: ',  dir+'/'+cam+'m_'+filpol+'*.fts'
            RETURN, -1
         ENDIF
         names = names(wnames)
	 utcs = yymmdd2utc(STRMID(names,length-10,6))
	 ord = SORT(utcs.mjd)
	 utcs = utcs[ord]
	 names = names[ord]
         ind = FIND_CLOSEST(utc.mjd, utcs.mjd,/less)
      	 name = names(ind)
      	 IF ( (ind NE 0) AND (ind NE nwnames-1) ) and NOT(keyword_set(ROLL)) THEN BEGIN
	   interp = 1
           name2 = names(ind+1) 
	 ENDIF
      ENDELSE

   ENDELSE

   ;ok = FILE_EXIST(dir+'/'+name)
   ok = FILE_EXIST( FILEPATH(name,ROOT_DIR=dir) )
print, 'reading ', name
   IF (ok EQ 1) THEN BEGIN
      ;imgm = LASCO_READFITS(dir+'/'+name, hdrm) $
      imgm = LASCO_READFITS( FILEPATH(name,ROOT_DIR=dir) , hdrm) 
      IF x1 EQ 0 AND y1 EQ 0 AND x2 EQ 1023 AND y2 EQ 1023 THEN BEGIN
	imgm = rebin(temporary(imgm),hdr.naxis1,hdr.naxis1) 
	rebin_flag = 1
	ENDIF
;	imgm = CONGRID(temporary(imgm),hdr.naxis1,hdr.naxis1); ** nbr, 4/6/99
;     	imgm = REBIN(temporary(imgm),1024,1024)	; **NBR, 11/16/99 ; does not work with pan=0.5

   ENDIF ELSE BEGIN
      PRINT, '%%GETBKGIMG: Model not found.'
      RETURN, -1
   ENDELSE

   IF (interp EQ 1) THEN BEGIN	;** interpolate between two monthly images
   ;IF (0) THEN BEGIN	;** interpolate between two monthly images
      ;ok = FILE_EXIST(dir+'/'+name2)
      ok = FILE_EXIST( FILEPATH(name2,ROOT_DIR=dir) )
      IF (ok EQ 1) THEN BEGIN
         ;imgm2 = LASCO_READFITS(dir+'/'+name2, hdrm2)
         imgm2 = LASCO_READFITS( FILEPATH(name2,ROOT_DIR=dir) , hdrm2)
      	 IF x1 EQ 0 AND y1 EQ 0 AND x2 EQ 1023 AND y2 EQ 1023 THEN $
	   imgm2 = rebin(temporary(imgm2),hdr.naxis1,hdr.naxis1) 
;		imgm = CONGRID(temporary(imgm),hdr.naxis1,hdr.naxis1); ** nbr, 4/6/99
;     		imgm = REBIN(temporary(imgm),1024,1024)	; **NBR, 11/16/99 ; does not work with pan=0.5

         tm1 = hdrm.date_obs
         tm2 = hdrm2.date_obs
	 IF tm1 EQ tm2 THEN GOTO, no_interp $
	 ELSE BEGIN
	     print, 'Using ', name2,' to interpolate.'
	     ;STRPUT,tm1, STRMID(hdr.date_obs,0,4), 0
		  ;;** nbr, 7/28/98
	     year = FIX(STRMID(numdt,0,4))
	     year1= year
	     year2= year
	     IF KEYWORD_SET(ANY_YEAR) THEN BEGIN
		IF tm1 GT tm2 THEN year1=year1-1
		STRPUT, tm1, TRIM(STRING(year1))
	     ENDIF

	     taim1 = UTC2TAI(STR2UTC(tm1))
	     taim2 = UTC2TAI(STR2UTC(tm2))
	     ;STRPUT,tm2, STRMID(hdr.date_obs,0,4), 0
	     ;REPEAT BEGIN		; ** nbr, 9/23/98: fix year difference problem
		;			;         3/30/01: Redo year diff problem for any-year
		;IF year LT year1 THEN year= year+1 
		;IF year GT year2 THEN year= year-1
		;STRPUT,numdt, TRIM(STRING(year))
		;tai = UTC2TAI(STR2UTC(numdt+' '+hdr.time_obs))
	    ; ENDREP UNTIL year LE year2 and year GE year1
	     print,'Dummy date is ',numdt
	     factor = (tain - taim1) / (taim2 - taim1)
		help,factor

	     IF factor gt 1 THEN factor=1
	     imgm = imgm * (1.0 - factor)
	     imgm2 = imgm2 * factor
	     imgm = imgm + imgm2
	 ENDELSE
      ENDIF
   ENDIF
   no_interp:

   IF KEYWORD_SET(FFV) THEN RETURN, imgm

   ; if the model is the summed properly then return (useful for color models)

   IF(hdr.naxis1 eq hdrm.naxis1 and hdr.naxis2 eq hdrm.naxis2 and $
    hdr.sumrow eq hdrm.sumrow and hdr.lebxsum eq hdrm.lebxsum) then return,imgm


   ; get proper sub region
   tot_sum = (hdr.sumrow > 1) * (hdr.lebxsum > 1)
   if(tot_sum gt 1) then begin
    x1 = x1/tot_sum
    x2 = x2/tot_sum
    y1 = y1/tot_sum
    y2 = y2/tot_sum
   endif
   imgm = imgm(x1:x2,y1:y2)

   ; reduce model to match size of image
   IF tot_sum gt 1 and rebin_flag eq 0 THEN BEGIN
   sz = SIZE(imgm)
   xs = hdr.sumrow
   IF (xs NE 0) THEN imgm = REBIN(imgm, sz(1)/xs, sz(2)/xs)
   sz = SIZE(imgm)
   xs = hdr.lebxsum
   IF (xs NE 1) THEN imgm = REBIN(imgm, sz(1)/xs, sz(2)/xs)
   ENDIF

   RETURN, imgm

END
