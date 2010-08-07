;+
; Project     : SOHO - LASCO/EIT
;
; Name        :	MAKE_INDEX
;
; Purpose     :
;
; Use         : IDL>
;
; Inputs      :
;
; Optional Inputs:
;
; Outputs     :
;
; Keywords    :
;
; Comments    :
;
; Side effects:
;
; Category    :
;
; Written     :
;
; Version     :
;
; @(#)make_index.pro	1.1 02/07/02 :LASCO IDL LIBRARY
;
;-

;-----------------------------------------------------------------------

;
;  EX.	make_index, findfile('/net/corona/ql/ECS/ELASCL_0110*L')
;
; Make a file with start and end times of packet files listed in input
;
; Input:
; list		STRARR	Filenames of packet files
;
;



PRO make_index, list


	openw,1,'index.txt'

	n = n_elements(list)
	for i=0,n-1 do begin
		sc=read_tm_packet(list(i))
		sz = size(sc)
		numpckts = sz(2)
		;tais = obt2tai(sc(6:11,*))
		taist = obt2tai(sc(6:11,0))

		; Assume 5 packets per second
		taien_est = taist + 0.2*numpckts
		IF numpckts GT 1 THEN BEGIN
			REPEAT BEGIN
				taien = obt2tai(sc(6:11,numpckts-1))
				numpckts=numpckts-1
			ENDREP UNTIL taien GT taist and taien LT taien_est+(60*60*4d)
			; Do this to account for bad packets at end of QKL/REL file

			printf,1,string(taist,format='(F22.11)')+'  '+string(taien,format='(F22.11)')+'  '+list(i)
		ENDIF
	endfor
	close,1
end
