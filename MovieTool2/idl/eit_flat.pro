function eit_flat, image, fits_header, image_no = image_no, $
   verbose = verbose, no_copy = no_copy
;+
; NAME:
;   eit_flat
;
; PURPOSE:
;   
;
; CALLING SEQUENCE:
;    flat_fielded_img = eit_flat(img, fits_header, image_no=image_no)
;
; INPUTS:
;    img         = Raw image, detector offset subtracted and missing pixels raised
;                  to baseline level
;    fits_header = index structure/fits header for img
;
; OPTIONAL INPUTS:
;    None
;
; KEYWORDS
;    image_no    = image number in LZ file 
;    verbose     = set if messages discriminating new read or pre-read wanted
;    no_copy     = don't make dual copies of input image
;                  (only use if output image replaces input image)
;
; EXAMPLE:
;    flat_img = eit_flat(img, fits_header)             ; 2-D version
;    flat_img = eit_flat(img, fits_header, image_no)   ; 3-D version
;
; MODIFICATION HISTORY
;    The epoch - (JSN) - Written
;    17-Oct-96 - (BNH) - Now sports a document header
;                      - Also sports a common block
;    1997/04/11 - D.M. - Added VERBOSE keyword.
;    1998/04/13 - D.M. - Added /VAX_FLOAT keyword in OpenVMS OPENR statement
;			 for IDL 5.1 compatibility.
;    3-Jun-1998 - Zarro (SAC/GSFC)
;                      - Added calls to temporary for improved
;                        memory management. 
;   28-Sep-1999 - N.Rich - adapt for LASCO fits header: object, wave, DATE-OBS
;   18-May-2000 - J.S.Newmark - online LASCO compatibility   
  
;
; COMMON BLOCKS:
;    eit_flat_blk = filename and flat field for last image flat-fielded (to
;                   speed up operation)
;-
;
; Do this so we read the flatfield only once during an IDL session
;
common eit_flat_blk, wavelength, flat_array
;
if not keyword_set(verbose) then verbose = 0
;
if n_elements(wavelength) eq 0 then wavelength = 'UNDEFINED'
;
nrlhdr=0
object = eit_fxpar(fits_header, 'OBJECT')
IF datatype(object) NE 'STR' THEN BEGIN
        print,'Using NRL generated EIT header'
        object=EIT_FXPAR(fits_header,'LP_NUM')
        nrlhdr=1
ENDIF
if (object eq 'Cal lamp') or $
   (strmid(object, 0, 4) eq 'Dark') then return, image
;
if keyword_set(no_copy) then a = temporary(image) else a=image & sz_a = size(a)
;
corner_offset = [-1, -1, -20, -20]
;
utc_date_19960307 = anytim2utc('1996/03/07')
utc_date_19960321 = anytim2utc('1996/03/21')
;
n_x = sz_a(1) & n_y = sz_a(2)
;
if ((n_x + n_y) lt 2048) then begin
;
   corner = intarr(4)
   corner(0) = EIT_FXPAR(fits_header, 'P1_X')
   corner(1) = EIT_FXPAR(fits_header, 'P2_X')
   corner(2) = EIT_FXPAR(fits_header, 'P1_Y')
   corner(3) = EIT_FXPAR(fits_header, 'P2_Y')
   IF nrlhdr THEN BEGIN
      corner(0) = EIT_FXPAR(fits_header, 'P1ROW')
      corner(1) = EIT_FXPAR(fits_header, 'P2ROW')
      corner(2) = EIT_FXPAR(fits_header, 'P1COL')
      corner(3) = EIT_FXPAR(fits_header, 'P2COL')
   ENDIF

;
   if corner(0) eq 0 then begin
      date_obs = EIT_FXPAR(fits_header, 'DATE_OBS', image_no = image_no)
      IF nrlhdr THEN date_obs = eit_fxpar(fits_header,'DATE-OBS',$
                                     image_no=image_no)
      utc_date_obs = anytim2utc(date_obs)
      case utc_date_obs.mjd of
         utc_date_19960307.mjd: corner = [256, 767, 481, 800]
         utc_date_19960321.mjd: corner = [256, 767, 800, 1023]
         else: begin
               message,/info,'Early partial FOV images can not be flat fielded'
               return,a
              end
      endcase
   endif else begin
      if (corner(0) mod 2) and (corner(1) mod 2) then $
           corner_offset = [-1,-2,-20,-20]
      corner = corner + corner_offset
      if verbose then print, '%EIT_FLAT-I-CORNERS, subfield corners = ', corner
   end
;
; First case: full FOV, pixel summing
;
endif else corner = [0, 1023, 0, 1023]
;
x_bin = 1 & y_bin = 1
nx_grid = corner(1) - corner(0) + 1
ny_grid = corner(3) - corner(2) + 1
if nx_grid gt n_x then x_bin = nx_grid/n_x
if ny_grid gt n_y then y_bin = ny_grid/n_y
; print, '%EIT_FLAT-D-BIN, x_bin, y_bin = ' + $
;  strtrim(x_bin, 2) + ', ' + strtrim(y_bin, 2) + '.'

   wave = strtrim(eit_fxpar(fits_header,'WAVELNTH',image_no=image_no),2) 
   if nrlhdr then wave = STRMID(eit_fxpar(fits_header,'SECTOR'),0,3)

;  use only short wavelegnth (195) and long (284) wavelength flats
;  as there is only ~1% difference between these and 171, 304 respectively
   if wave eq '171' then wave='195'
   if wave eq '304' then wave='284'

if (wave ne wavelength) then begin
    if verbose then message, /info, 'Reading in flat...'
    wavelength = wave
;
; definitions of GSFC vms cluster
;
    if is_gsfcvms() then begin
      flat_file = 'eit_disk:[eit.reform.flat]flat_'+wave+'.dat' 
      release = !version.release
      version_release = 100*strmid(release, 0, 1) + $
         10*strmid(release, 2, 1) + strmid(release, 4, 1)
      if version_release le 503 then begin
         openr, flat_unit, flat_file, /get_lun, /block
      endif else begin
         openr, flat_unit, flat_file, /get_lun, /block, /vax_float
      end
    endif else begin
      flat_file = concat_dir(getenv('SSW_EIT_RESPONSE'),'flat_'+wave+'.dat')
      openr,flat_unit,flat_file,/get_lun,/xdr
    endelse
;
    flat_array = fltarr(1024, 1024)
    readu, flat_unit, flat_array
    close, flat_unit & free_lun, flat_unit
endif else begin
    if verbose then message, /info, 'Using pre-read flat'
end

fl_mult = flat_array(corner(0):corner(1), corner(2):corner(3))

if (x_bin eq 1) and (y_bin eq 1) then begin
    a = temporary(a)*temporary(fl_mult)
endif else begin
    a = temporary(a)*rebin(temporary(fl_mult), n_x, n_y)
end

return, a
end
