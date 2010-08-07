function eit_norm_response,date_obs,inwave,fits_header,verbose=verbose,$
           no_index=no_index
;+
;NAME
;   eit_norm_response
;PURPOSE 
;  compute a normalized response for each eit band  
;INPUTS
;   date_obs  = date of observation
;   inwave    = wavelength of observation
;   fits_header = header to obtain pointing/size information
;OUTPUTS
;   returns normalization factor to be applied to measured DN level
;   on given date such that all EIT data is normalized to 2-Feb-1996.
;KEYWORDS
;   no_index = set if do not want to use recommended Index correlation
;              for response scaling
;   verbose = set for testing 
;WARNINGS
;   this routine may not always have the most recent normalizations
;   especially just following a bakeout.
;PROCEDURE
;   Uses EUV flat field determined by scaling from Calibration lamps
;CREATION
;   17-May-2001. J. Newmark and F. Auchere
;   
;MODIFICATIONS
;   10-Dec-2001. J. Newmark inclusion of trend corrections
;   28-Feb-2002. J. Newmark inclusion of wavelength dependence
;                of flat field
;   11-Jul-2003. J. Newmark : Windows compatibility
;-
common eit_norm_blk, wavelength, date, sflat, calorig 

delim = get_delim()
if not keyword_set(verbose) then verbose = 0
if n_elements(wavelength) eq 0 then wavelength = 0
if n_elements(date) eq 0 then date = 0
mjd_1996_0 = 50083.0d0*8.64d4
date_obs = anytim2utc(date_obs,/vms)
temp_date = anytim2utc(date_obs)
date_ut = (8.64d4*temp_date.mjd + 1.e-3*temp_date.time) - mjd_1996_0
temp_obs = temp_date.mjd

ddir = getenv('SSW_EIT_RESPONSE')
filein = concat_dir(ddir,'fit_resp.dat')

; correction for CCE effect
if temp_obs ne date then begin
   date = temp_obs
   if verbose then message, /info, 'Reading in flat...'
   if n_elements(calorig) eq 0 then calorig = readfits(getenv('SSWDB')+delim+$
     'soho'+delim+'eit'+delim+'calibrate'+delim+'cal19951209.fts', /silent)
   visible = eit_getcal(date_obs)/calorig
   visible = visible/median(visible[922:1021, 1002:1021])
   degrad = total(visible)/total(visible ne 0)
   sflat = eit_vis2euv(visible,degrad=degrad)
endif else if verbose then message, /info, 'Using pre-read normalization'
if inwave eq 284 or inwave eq 304 then begin
   res = [0.0077716820, 0.97235556, -0.25301483, -0.24468922, -0.087938358]
   wsflat = 10^(res[0] + res[1]*alog10(sflat) + res[2]*alog10(sflat)^2.0 + $
             res[3]*alog10(sflat)^3.0 + res[4]*alog10(sflat)^4.0)
endif else wsflat = sflat

; correction for trend analysis
readcol,filein,wave,start_time,end_time,coeff_0,coeff_1,coeff_2,coeff_3,$
         format='I,D,D,D,D,D,D',/silent

bakes = eit_bakeouts()
tb = anytim2utc(bakes[*,1])
date_b = (8.64d4*tb.mjd + 1.e-3*tb.time) - mjd_1996_0
ok = where(date_b lt end_time[n_elements(end_time)-1])
bake_s = anytim2utc([bakes[ok,0],!stime])
bake_e = anytim2utc(['1996-Feb-01',bakes[ok,1]])

case 1 of 
  inwave eq 171: begin
                  top = 0
                  top2 = 0.25*n_elements(end_time)
                 end
  inwave eq 195: begin
                  top = n_elements(end_time)*0.25
                  top2 = 0.5*n_elements(end_time)
                 end
  inwave eq 284: begin
                  top = n_elements(end_time)*0.5
                  top2 = 0.75*n_elements(end_time)
                 end
  inwave eq 304: begin
                  top = n_elements(end_time)*0.75
                  top2 = 1*n_elements(end_time)
                 end
  else:
endcase

date_ut = date_ut < round(end_time(top2-1))
index=(where(wave eq inwave and round(date_ut) ge round(start_time) and $
            round(date_ut) le round(end_time)))(0)

if index(0) ne -1 then begin
   grid = temp_date.mjd - bake_e(index-top).mjd
   nfactor = coeff_1(index)*exp(coeff_0(index)*grid)
endif else nfactor = 1.
if keyword_set(no_index) then nfactor = 1.
;

; proper binning and subfields
x_bin = 1 & y_bin = 1
if n_elements(fits_header) ne 0 then begin
   n_x = eit_fxpar(fits_header,'NAXIS1')
   n_y = eit_fxpar(fits_header,'NAXIS2')
endif else begin
   n_x = 1024
   n_y = 1024
endelse
corner_offset = [-1, -1, -20, -20]
if ((n_x + n_y) lt 2048) then begin
   corner = intarr(4)
   corner(0) = EIT_FXPAR(fits_header, 'P1_X')
   corner(1) = EIT_FXPAR(fits_header, 'P2_X')
   corner(2) = EIT_FXPAR(fits_header, 'P1_Y')
   corner(3) = EIT_FXPAR(fits_header, 'P2_Y')
   IF datatype(EIT_FXPAR(fits_header, 'OBJECT')) NE 'STR' THEN BEGIN
        ; Must be NRL header
        corner(0) = FXPAR(fits_header, 'P1ROW')
        corner(1) = FXPAR(fits_header, 'P2ROW')
        corner(2) = FXPAR(fits_header, 'P1COL')
        corner(3) = FXPAR(fits_header, 'P2COL')
   ENDIF
   if (corner(0) mod 2) and (corner(1) mod 2) then corner_offset = [-1,-2,-20,-20]
   corner = corner + corner_offset
endif else corner = [0, 1023, 0, 1023]

nx_grid = corner(1) - corner(0) + 1
if nx_grid gt n_x then x_bin = nx_grid/n_x

flat = wsflat(corner(0):corner(1), corner(2):corner(3))
if (x_bin ne 1) then flat = rebin(temporary(flat), n_x, n_y)

return, flat * nfactor
end
