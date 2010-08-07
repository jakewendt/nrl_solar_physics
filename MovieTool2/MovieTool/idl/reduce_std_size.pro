function reduce_std_size,img0,hdr, FULL=FULL , NO_REBIN=NO_REBIN, BIAS=bias, $
	SAVEHDR=savehdr
;+
; NAME:
;
;	REDUCE_STD_SIZE
;
; PURPOSE:
;
;	Create a "full image" 512x512 of the input image.  Accounts for sub 
;	images and pixel summing.
;
; CATEGORY:
;
;	LASCO DATA REDUCTION
;
; CALLING SEQUENCE:
;
;	Result = REDUCE_STD_SIZE(Img,Hdr)
;
; INPUTS:
;
;	Img:	Input Image array
;	Hdr:	FITS header or LASCO header structure
;
; OPTIONAL INPUTS:
;	None
;	
; KEYWORD PARAMETERS:
;
;	FULL:	   Returns an image of size 1024x1024 pixels if set. The default is a 
;		   512x512 image.
;
;	NO_REBIN:  Set this to return an array which has not been rescaled 
;		   into 512 or 1024.  The default is to perform a rebin to 
;                  resize the image.
;
;	BIAS:	Subtracts bias and corrects values for binning before returning image. 
;		Will return bias value.
;
;	SAVEHDR:	Do not put new values in header
;
; OUTPUTS:
;
;	The function result is a full image, with the input image inserted into
;	the correct place in the full image. Also, hdr is modified.
;
; OPTIONAL OUTPUTS:
;	bias
;
; COMMON BLOCKS:
;	None
;
; SIDE EFFECTS:
;	None
;
; PROCEDURE:
;
;	The input image is inserted into its proper place in a full image.  
;	On-chip and off-chip pixel summing are properly considered. The output 
;	image is resized to a 512 x 512 image.  Optionally, it can be resized 
;	to 1024 x 1024 or any size, or not resized at all.  
;
;	If the image is not resized, then each dimension would be determined
;	by the amount of summing along each axis according to 1024 / SUM,
;	where SUM is the number of pixels summed along the axis.  i.e., if 2x2 
;	summing is used, then the image size would be 512 x 512.  If 4x2 
;	summing were used, then the image size would be 256 x 512.
;
;	IF BIAS keyword is set, output image values are corrected for summing 
;	and offset bias. LEBSUM and SUM header values are changed to reflect output. 
;
; EXAMPLE:
;
;	To obtain the default 512 x 512 image:
;
;		Output = REDUCE_STD_SIZE(Img,Hdr)
;
;	To obtain a 1024 x 1024 image:
;
;		Output = REDUCE_STD_SIZE(Img,Hdr,/full)
;
;	To obtain an image sized by the summing:
;
;		Output = REDUCE_STD_SIZE(Img,Hdr,/no_rebin)
;
; MODIFICATION HISTORY:		Written, RA Howard, NRL
;    VERSION 1   rah    29 Aug 1996
;    VERSION 1.1 sep    29 Sep 1996	added /FULL keyword, and ability to
;					handle header structures
;    VERSION 1.2 rah    22 Oct 1996	Added /no_rebin keyword
;    VERSION 1.3 rah    17 Jul 1997	Corrected handling of image sizes >1024
;    VERSION 1.4 nbr	11 Dec 1998	Corrected handling of summed images with sizes > 512
;    VERSION 1.5 nbr    11 Feb 1999	Modify R[1,2][row,col] in header (returned)
;   		 nbr	12 Feb 1999	Divide by lebxsum*lebysum if binned image
;		 nbr	17 Feb 1999	See notes below
;		 nbr	18 Feb 1999	Do not divide by lebxsum*lebysum if %P or PB image
;		 nbr	23 Mar 1999	Modify NAXIS[1,2] in header
;		 nbr 	23 Apr 1999	Added telescope check
;		nbr	 7 Dec 1999	Replace stc_flag with LASCO_FITSHDR2STRUCT; fix
;					problem with unsummed, rebinned images
;		nbr,  1 Aug 2000 - Modify for MK4 images
;	nbr, 30 Jan 01 - Add BIAS keyword and streamline program
;	nbr, 15 Jun 01 - Remove conditional on REBIN
;	nbr, 19 Nov 01 - Handle zero-size images
;	nbr, 14 Mar 03 - Correct binning correction again; add /SAVEHDR
;
; 
; 03/20/03 @(#)reduce_std_size.pro	1.14 :NRL Solar Physics
;
;-
;

PRINT, "%%Running REDUCE_STD_SIZE"
IF (DATATYPE(hdr) NE 'STC') THEN hdr = LASCO_FITSHDR2STRUCT(hdr)

   sumrow = hdr.SUMROW > 1
   sumcol = hdr.SUMCOL > 1
   lebxsum = hdr.LEBXSUM > 1
   lebysum = hdr.LEBYSUM > 1
   naxis1 = hdr.NAXIS1
   naxis2 = hdr.NAXIS2
   polar = hdr.polar
   tel = hdr.TELESCOP

IF naxis1 LE 0 or naxis2 LE 0 THEN BEGIN
	help,naxis1,naxis2,img0
	message,hdr.filename+' -- Invalid Image -- Returning',/CONT
	return,img0
ENDIF
;IF STRPOS(polar,'P') NE -1 THEN sumfac = 1 ELSE sumfac = float(lebxsum*lebysum)

      r1col = hdr.R1COL
      r1row = hdr.R1ROW
      if (r1col lt 1) then r1col = hdr.P1COL
      if (r1row lt 1) then r1row = hdr.P1ROW

IF keyword_set(BIAS) THEN BEGIN
   bias = offset_bias(hdr)
   
   ; value of lebsummed = 4(v + b)
   ; correctedval = (val/4) - b
   ; value of chipsummed = 4v + b
   ; correctedval = (val - b)/4 = val/4 - b/4
   
   IF sumcol GT 1 THEN BEGIN
   	img = (img0 - bias)/(sumcol*sumrow)
   	message,'Correcting for Chip summing'
   ENDIF ELSE BEGIN
   	IF lebxsum GT 1 THEN message,'Correcting for LEB summing', /INFORM
	img = img0/(lebxsum*lebysum) - bias
   ENDELSE
   message,'Offset bias subtracted.',/INFORM
ENDIF ELSE img = img0

nxfac = sumcol*lebxsum		; If image is binned, nxsum = 2
nyfac = sumrow*lebysum		; If image is summed, assume size is halved.

IF tel EQ 'SOHO' THEN IF (hdr.p2col-hdr.p1col EQ 1023 $
	and hdr.p2row-hdr.p1row EQ 1023 $
	and naxis1 EQ 512) THEN BEGIN
	nxfac=2		; This indicates size, not summing.
	nyfac=2
ENDIF	;** Monthly model images are half-size but not summed
;stop
nx = nxfac*naxis1	; These values correspond to the r1,r2 values
ny = nyfac*naxis2

; ** First take care of subframes.
IF ((nx lt 1024) or (ny lt 1024)) and tel EQ 'SOHO' THEN BEGIN	; NBR, 12/11/98: was NE
   sz=size(img)
   FULL_img = MAKE_ARRAY(1024/nxfac,1024/nyfac,TYPE=sz(sz(0)+1))
   nx=sz(1)<1024	; These values redefined to correspond to image size
   ny=sz(2)<1024
   IF nxfac LT 2 THEN naxis1 = 1024 ELSE naxis1 = 512
   IF nyfac LT 2 THEN naxis2 = 1024 ELSE naxis2 = 512
   IF (r1row GT 1024) THEN offrow=1 ELSE offrow=r1row
   IF (r1col LT 20) THEN BEGIN
      startrow=(offrow-1)/nyfac
      startrow=startrow<(1024-ny)
	print,r1col-1,nxfac,offrow-1,nyfac,nx,ny
      full_img((r1col-1)/nxfac,startrow) = img(0:nx-1,0:ny-1)
   ENDIF ELSE BEGIN
      IF ((r1col-20)/nxfac+(nx-1) GT 1024/nxfac)  THEN startcol=0 ELSE startcol=(r1col-20)/nxfac
      IF ((offrow-1)/nyfac+(ny-1) GT 1024/nyfac)  THEN startrow=0 ELSE startrow=(offrow-1)/nyfac
      full_img(startcol,startrow)=img(0:nx-1,0:ny-1)
   ENDELSE
; ** If not subframe, then do nothing here.
ENDIF ELSE full_img = img	

IF tel EQ 'SOHO' and NOT(keyword_set(SAVEHDR)) THEN BEGIN
	hdr.R1COL = 20
	hdr.R1ROW = 1
	hdr.R2COL = 1043
	hdr.R2ROW = 1024
	hdr.NAXIS1 = naxis1
	hdr.NAXIS2 = naxis2
ENDIF ELSE IF NOT(keyword_set(SAVEHDR)) THEN $
	print, '!!!! REDUCE_STD_SIZE: Header RCOL and RROW values unchanged!!!!!'

IF KEYWORD_SET(NO_REBIN)    THEN RETURN,full_img
;
; if image size is not equal to 512 x 512 then scale
;
sz=size(img)
naxis1=sz(1)						; ** NBR, 2/17/99
IF KEYWORD_SET(FULL) THEN scale_to = 1024 ELSE scale_to = 512

IF tel EQ 'SOHO' THEN BEGIN
	hdr.NAXIS1 = scale_to
	hdr.NAXIS2 = scale_to
ENDIF
;if (naxis1 ne scale_to) and tel EQ 'SOHO' then full_img=REBIN(full_img,scale_to,scale_to)
full_img=REBIN(full_img,scale_to,scale_to)
return,full_img

end
