function offset_bias,telescope,readport,date,sum=sum
;
;+
; NAME:			OFFSET_BIAS
;
; PURPOSE:		Provides the electronic offset introduced for
;			each readout port
;
; CATEGORY:		LASCO Calibration
;
; CALLING SEQUENCE:	Offset = OFFSET_BIAS(Telescope,Readport)
;
; INPUTS:		Telescope = String indicating telescope
;				Values are 'C1','C2','C3','EIT'
;			Readport = String indicating read out port
;				Values are 'A','B','C','D'
;
; OPTIONAL INPUTS:	Date= string giving the date as YYMMDD
;
; KEYWORD PARAMETERS:	SUM:	If present, computes the proper bias for LEB Summing
;
; OUTPUTS:		Integer giving the offset bias in DN
;
; OPTIONAL OUTPUT PARAMETERS:
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:		Obtained from flight calibration
;
; MODIFICATION HISTORY:
;			RA Howard Writen 6 Feb 1996
;      V1    RAH   02/06/96     Initial Release
;      V2    RAH   06/02/97     Added function of date to C3
;      V3    RAH   06/10/97     Added function of date to C1 & C2
;      V4    RAH   08/21/97     Added correction for leb summing
;      V5    RAH   06/08/98     Updates to C2 and C3 coefficients for port C
;      V6    RAH   06/10/98     Updates to C2 and C3 coefficients for port C, QL through 5/98
;      V7    RAH   09/18/98     Updates to C2 and C3 coefficients for port C, LZ through 6/21/98
;      V8    NBR   10/21/98	Use lasco_ftshdr2struct, not ftshdr2struct
;      V9    RAH   08/20/99     Updates to C2 and C3 coefficients for port C
;      V10   RAH   12/21/99     Updates to C2 and C3 coefficients for port C
;      V11   RAH   01/21/00     Syntax change from ENDIF to END for IDL 5.3
;      V12   RAH   07/03/00     Updates to C2 and C3 coefficients for port C
;	NBR, 08/04/00 - Use SCCS version number; Add HISTORY to header if FITS header
;      V13   RAH   01/06/01     Updates to C2 and C3 coefficients for port C, split c2 before/after mispoint
;      V14   RAH   12/13/01     Updates to C2 and C3 coefficients for port C
;      V15   RAH   07/09/02     Updates to C2 and C3 coefficients for port C
;
;-
;
ver= '@(#)offset_bias.pro	1.26 07/09/02' ;LASCO IDL LIBRARY
version = STRMID(ver,4,strlen(ver))


np =  N_PARAMS()
CASE np OF
   1: BEGIN
        hdr = telescope
        IF (DATATYPE(hdr) NE 'STC') THEN  hdr = LASCO_FITSHDR2STRUCT(hdr)
	   
	
        port = STRUPCASE(STRTRIM(hdr.readport,2))
        tel = STRUPCASE(STRTRIM(hdr.detector,2))
        mjd = hdr.mid_date  
        time = hdr.mid_time*1000.
        IF (mjd EQ 0)  THEN BEGIN
           dte = STR2UTC(hdr.date_obs)
           mjd = dte.mjd
           IF (mjd EQ 0)  THEN BEGIN
              dte = STR2UTC(hdr.date)
              mjd = dte.mjd
              IF (mjd EQ 0) THEN mjd=50083
           ENDIF
        ENDIF
      END
   3: BEGIN
        dte = YYMMDD2UTC(date)
        mjd = dte.mjd
        port = STRUPCASE(STRTRIM(readport,2))
        tel = STRUPCASE(STRTRIM(telescope,2))
        time = 0
      END
else: BEGIN
        port = STRUPCASE(STRTRIM(readport,2))
        tel = STRUPCASE(STRTRIM(telescope,2))
        IF (tel EQ 'C1') OR (tel EQ 'C3')  THEN BEGIN
           PRINT,'%WARNING:  OFFSET BIAS: Called with older parameters. Date used is base date'
        ENDIF
        mjd = 50083		; base date = 1/1/96
        time=0
      END
ENDCASE
CASE tel OF
   'C1':    CASE port OF
            'A':  b=364
            'B':  b=331
;            'C':  b=320
            'C':  BEGIN
                    del = (mjd-50395L)
                    bias = 351.958+30.739*(1-exp(-del/468.308)) 
;                    del = (mjd-50395L);*24.
;                    dt0 = '1996/11/08 09:08:08.569'
;                    t0  = anytim2utc(dt0)
;                    hours = (mjd - t0.mjd) + time/3.6e6
;                    bias = 351.86 + 0.0564*hours
;                    IF mjd GT t0.mjd THEN   $
;                      bias = 351.86 + 0.06879*hours - 5.94e-05*hours^2
                    b = ROUND(bias)
                  END
            'D':  b=522
            else: b=0
            ENDCASE
   'C2':    CASE port OF
            'A':  b=364
            'B':  b=540
;            'C':  b=470
            'C':  BEGIN
                     firstday = 50079L
                     IF (mjd LE 51057L)  THEN BEGIN
                        coeff = [470.97732,0.12792513,-3.6621933e-05];  before the mispoint
                     ENDIF
                     IF ((mjd GT 51057L) AND (mjd LT 51819L))  THEN BEGIN
                          coeff = [551.67277,0.091365902,-0.00012637790,7.4049597e-08]  ; since 1 Sep 98
                          firstday = 51099L
                     ENDIF
                     IF (mjd GE 51819L) AND (mjd LT 51915L) THEN BEGIN
                          coeff = [574.5788,0.019772032]  ; since 1 Oct 00
                          firstday = 51558L
                     ENDIF
                     IF (mjd GE 51915L)  THEN BEGIN
                          coeff = [582.0574,0.016625946]  ; since 1 Oct 00
                          firstday = 51915L
                     ENDIF
                     nc = N_ELEMENTS(coeff)
                     dd = mjd-firstday
                     b = POLY(dd,coeff)
                  END
            'D':  b=526
            else: b=0
            ENDCASE
   'C3':    CASE port OF
            'A':  b=314
            'B':  b=346
;            'C':  b=319
            'C':  IF (mjd LT 50072)  THEN b=319 ELSE BEGIN
                     IF (mjd LE 51057L)  THEN BEGIN
                          coeff = [322.21639,0.011775379,4.4256968E-05,-3.167423e-08];  before the misspoint
                          firstday = 50072L
                     ENDIF
                     IF ((mjd GT 51057L) AND (mjd LE 51696L)) THEN BEGIN
                          coeff = [354.50857,0.062196067,-8.8114799e-05,5.0505447e-08]   ;  since 1 Sep 98
                          firstday = 51099L
                     ENDIF
                     IF (mjd GT 51696L) AND (mjd LT 51915L) THEN BEGIN
                          coeff = [369.02719,0.014994955,-4.0873204e-06]   ;  since 1 Jun 00
                          firstday = 51558L
                     ENDIF
                     IF (mjd GE 51915L) THEN BEGIN
                          coeff = [373.94898,0.011018500]   ;  since 1 Jun 01
                          firstday = 51915L
                     ENDIF
                     nc = N_ELEMENTS(coeff)
                     dd = mjd-firstday
                     b = POLY(dd,coeff)
                  ENDELSE
            'D':  b=283
            else: b=0
            ENDCASE
   'EIT':   CASE port OF
            'A':  b=1017
            'B':  b=840
            'C':  b=1041
            'D':  b=844
            else: b=0
            ENDCASE
   else:    b=0
ENDCASE
IF (KEYWORD_SET(sum) AND (np EQ 1)) THEN BEGIN
   lebsum = (hdr.lebxsum>1) * (hdr.lebysum>1)
   b = b*lebsum
ENDIF

IF np EQ 1 THEN IF datatype(telescope) NE 'STC' THEN FXADDPAR,telescope,'HISTORY',version+', '+TRIM(STRING(b))
RETURN,b
END
