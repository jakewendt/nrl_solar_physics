function abbrv_filpol,filter
;+
; NAME:
;	ABBRV_FILPOL
;
; PURPOSE:
;	This function returns an abbreviated code for the filter
;	and polarizer/sector wheels.
;
; CATEGORY:
;	UTIL
;
; CALLING SEQUENCE:
;	Result = ABBRV_FILPOL(Filter)
;
; INPUTS:
;	Filter = String giving the filter or polarizer/sector value
;
; OPTIONAL INPUTS:
;	None
;
; OUTPUTS:
;	The function result is a string containing the code for the filter
;	wheel or the polarizer wheel.  Each wheel posisiton is a two
;	character string.
;
; PROCEDURE:
;	The wheel position is decoded and converted to a 2 character string.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;	Written, RA Howard, NRL, 7 October 1996
;	15 Oct 96	RAH	Added removing whitespace from filter
;				Corrected filter/polarizer/sector cases
;
;       @(#)abbrv_filpol.pro	1.3 10/15/96     LASCO IDL LIBRARY
;
;-
;
CASE STRCOMPRESS(STRUPCASE(filter),/remove_all) OF
   'CLEAR':  filt='cl'
   'FEXIV':  filt='fv'
   'FEX':    filt='fx
   'CAXV':   filt='ca'
   'NAI':    filt='na'
   'LENS':   filt='le'
   'ORANGE': filt='or'
   'BLUE':   filt='bl
   'DEEPRD': filt='rd'
   'HALPHA': filt='ha'
   'IR':     filt='ir'
   '0DEG':   filt='p0'
   '+60DEG': filt='pp'
   '-60DEG': filt='pm'
   'DENSITY':filt='nd'
   'AL+1':   filt='a1'
   'AL+2':   filt='a2'
   'BLOCKE': filt='be'
   'BLOCKW': filt='bw'
   '304A':   filt='30'
   '195A':   filt='19'
   '284A':   filt='28'
   '171A':   filt='17'
   else:     filt=STRMID(filter,0,2)
ENDCASE
RETURN,filt
END
