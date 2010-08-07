pro lz_start_date3,volno
;
;+
; NAME:
;	LZ_START_DATE3
;
; PURPOSE:
;   	Lists the level-0 cdrom start dates
;
; CATEGORY:
;	UTIL
;
; CALLING SEQUENCE:
;	LZ_START_DATE3,Volno
;
; INPUTS:
;	Volno:	The CD_ROM volume number
;
; OPTIONAL INPUTS:
;	None
;
; KEYWORD PARAMETERS:
;	None
;
; OUTPUTS:
;	None
;
; OPTIONAL OUTPUTS:
;	None
;
; COMMON BLOCKS:
;	None
;
; SIDE EFFECTS:
;	Writes a file of the start dates
;
; RESTRICTIONS:
;	None
;
; PROCEDURE:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; 	Written by:	RA Howard, 15 Mar 1996
;	N. Rich, 10/21/96, prompts for multiple disks for each release;
;			   prints info for each volume of 1 release on the
;			   same page
;	000803 Jake		Added /SH to spawn commands
;	000808 the Jake		Changed lzcds to .lzcds
;	020318	Jake		Changed to grep for CD-NUMBER now that making disks here
;				modified strtrim line
;
;
; @(#)lz_start_date3.pro	1.4 07/09/03 : LASCO IDL LIBRARY
;-

CD,'/cdrom/cdrom0',current=curr
;SPAWN,'grep SEQUENCE voldesc.sfd',voldesc, /SH
SPAWN,'grep CD-NUMBER voldesc.sfd',voldesc, /SH		;	Jake 020318
;;
;;  strip out disk number from voldesc
;;
;
;nxt=''
voldesc=voldesc(0)
;volno = strtrim ( strmid(voldesc,strpos(voldesc,':')+2,5) ,2)
colonplace = strpos(voldesc,':')
volno = strtrim ( strmid(voldesc,colonplace+1,STRLEN(voldesc)-colonplace) ,2)
print,'volno = ',volno
;
;READ,'How many CDs in this release? ',num
;
;
;FOR sequ = 1,num DO BEGIN
;
  ff=findfile('/cdrom/cdrom0/data/so/g03*/lz/*.sfd')
  ;
  ;   for each sfd find the start date
  ;
  OPENU,lu,'~/.lzcds/lz_last_start_dates.lst',/GET_LUN,/APPEND
  printf,lu
  PRINTF,lu,'  CD VOLUME    FILENAME          START DATE & TIME      STOP DATE & TIME'
  PRINTF,lu
  FOR i=0,N_ELEMENTS(ff)-1 DO BEGIN
     SPAWN,'grep START_DATE '+ff(i),dte,/SH
     dte_start = strmid(dte,11,10)+' '+strmid(dte,22,8)
     SPAWN,'grep STOP_DATE '+ff(i),dte,/SH
     dte_stop = strmid(dte,10,10)+' '+strmid(dte,21,8)
     ;SPAWN,'grep REFERENCE= '+ff(i),fn
     parts = str_sep(ff(i),'/')
     parts = reverse(parts)
     fn = parts(2)+' '+strmid(parts(0),0,8)+'.D01'
     PRINTF,lu,volno,fn,dte_start,dte_stop,format='(a7,5x,a17,4x,a19,4x,a19)'
  ENDFOR
  CLOSE,lu
  FREE_LUN,lu
  cd,curr
;  spawn,'eject cdrom'
;  IF sequ NE num THEN read,'Please insert CD number '+string(sequ+1)+' and ;<RETURN>',nxt
;  wait,10
;ENDFOR

END
