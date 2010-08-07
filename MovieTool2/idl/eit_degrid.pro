function eit_degrid, image, fits_header, final=final, image_no = image_no, $
   verbose = verbose, no_copy = no_copy
;+
; Name:
;    eit_degrid
;
; Purpose:
;    Degrid an EIT image, either full FOV or POV and/or binned.  
;
; Input Parameters:
;    image  = image w/ missing blocks raised to the detector offset, and 
;             detector offset subtracted.
;    header = FITS header or EIT index structure for image
;
;    Note that image can be full-res or a binned image.
;
; Output:
;    clean_image = degridded image
;
; Keywords:
;     final    = set if using LZ data
;     image_no = set if image is from a 3-D LZ FITS file
;     verbose  = set if messages discriminating new read or pre-read wanted
;
; Calling Sequence:
;    clean_image = eit_degrid(image, fits_header)
;    clean_image = eit_degrid(image, index)
;    clean_image = eit_degrid(image, fits_header, image_no=image_no)
; 
; Restrictions:
;    Can't handle a vector of images {yet}.
;    If you pipe an LZ file to this, you'd better have the fits header.
;    If you're doing this with single-image files, it will work just
;    fine if have a FITS header structure.
;
; History:
;    23-Mar-96 - (DMF) - Written
;     8-Apr-96 - (JSN) - Fix for incorrect entry of pixel size.
;    22-Jul-96 - (JSN) - Added capability of export SSW 
;    20-Aug-96 - (JSN) - Added image_no keyword for 3D LZ data.
;    28-Aug-96 - (JSN) - changed to always XDR format
;    29-Aug-96 - (DMF) - XDR too slow! Backed off to block I/O files in
;                        OVMS interal representation
;     9-Oct-96 - (BNH) - Now accepts FITS headers or index structures.
;                        Cleaned a few things up and dispatched FIND_KEYWORD
;                        for good.  Pulled all the history of this routine 
;                        into the "History" section.  Still need to sort
;                        out how to make index structures to cope
;                        with the new-improved "LZ" file structure.  
;    16-Oct-96 - (BNH) - Add a common block for the currently-used grid.
;    1997/04/11 - JBG  - Added VERBOSE keyword.
;    1997/11/10 - JSN  - Use newly calculated grid (after July 1997)
;    1998/02/04 - JSN  - New AL +1 grids
;    3-Jun-1998 - Zarro (SAC/GSFC)
;                      - Added calls to temporary for improved
;                        memory management. 
;    1999/07/14 - JSN  - Streamline code
;   28-Sep-1999 - N.Rich - Adapt for LASCO fits header: object, wave, DATE-OBS
;   18-May-2000 - JSN  - online LASCO compatibility
;   17-May-2001 - JSN  - only original grids
;-

common EIT_DEGRID_BLK, filename, degrid_array
;
if not keyword_set(verbose) then verbose = 0
;
if n_elements(filename) eq 0 then filename = 'NO FILE'

if (n_elements(fits_header) eq 0) then $
  message, 'No index structure or fits header supplied.  Exiting..'
;
; Let's make this easy if it's a dark or a calibration lamp image: if it is,
; we obviously don't want to degrid the image.
;
nrlhdr=0
object = EIT_FXPAR(fits_header, 'OBJECT')
IF datatype(object) NE 'STR' THEN BEGIN
        print,'Using NRL generated EIT header'
        object=EIT_FXPAR(fits_header,'LP_NUM')
        nrlhdr=1
ENDIF
cftemp = EIT_FXPAR(fits_header, 'CFTEMP', image_no = image_no)

if (object eq 'Calibration lamp') or $
   (strmid(object, 0, 4) eq 'Dark') or $
   (cftemp gt 0) then $
      return, image
;
; definitions of GSFC vms cluster
;
  gsfcvms = is_gsfcvms()
;
  if keyword_set(no_copy) then a = temporary(image) else a = image
;
n_x = eit_fxpar(fits_header,'NAXIS1')
n_y = eit_fxpar(fits_header,'NAXIS2')

if not keyword_set(final) then final = 0

corner_offset = [-1, -1, -20, -20]

utc_date_19960307 = anytim2utc('1996/03/07')
utc_date_19960321 = anytim2utc('1996/03/21')
utc_date_19960323 = anytim2utc('1996/03/23')
utc_date_19960327 = anytim2utc('1996/03/27')
utc_date_19970727 = anytim2utc('1997/07/27')


if ((n_x + n_y) lt 2048) then begin

   corner = intarr(4)
;
   corner(0) = eit_fxpar(fits_header, 'P1_X')
   corner(1) = eit_fxpar(fits_header, 'P2_X')
   corner(2) = eit_fxpar(fits_header, 'P1_Y')
   corner(3) = eit_fxpar(fits_header, 'P2_Y')
   IF nrlhdr THEN BEGIN
        corner(0) = eit_fxpar(fits_header, 'P1ROW')
        corner(1) = eit_fxpar(fits_header, 'P2ROW')
        corner(2) = eit_fxpar(fits_header, 'P1COL')
        corner(3) = eit_fxpar(fits_header, 'P2COL')
   ENDIF
;
; P1_X, etc. describe the field of view. If set to zero then early
; QKL data so handle specially.
;
; An entirely klugey case for the 1996 March 7 south polar plume study.
; and the 1996 March 21 glitch. Otherwise do not degrid. 
;
   if corner(0) eq 0 then begin
      date_obs = eit_fxpar(fits_header,'DATE_OBS',image_no = image_no)
      if nrlhdr then date_obs = eit_fxpar(fits_header,'DATE-OBS',image_no=image_no)
      utc_date_obs = anytim2utc(date_obs)
      case utc_date_obs.mjd of 
         utc_date_19960307.mjd: corner = [256, 767, 481, 800]
         utc_date_19960321.mjd: corner = [256, 767, 800, 1023]
         else: begin
               message,/info,'Early partial FOV images can not be degridded'
               return,a
              end
      endcase        
   endif else begin

;
; fix for incorrect entry of pixel size.  8-apr-96 JSN
;
      if (corner(0) mod 2) and (corner(1) mod 2) then $
           corner_offset = [-1,-2,-20,-20]

         corner = corner + corner_offset
;         message, /info, 'Subfield corners = '+string(corner)
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


   degrid = 1

   if gsfcvms then begin
      degrid_file = 'eit_disk:[eit.reform.degrid]degrid_'
   endif else begin
      degrid_file = concat_dir(getenv('SSW_EIT_RESPONSE'),'degrid_')
   end

   wave = eit_fxpar(fits_header,'WAVELNTH',image_no=image_no)
   if nrlhdr then wave = STRMID(eit_fxpar(fits_header,'SECTOR'),0,3)
   filter_string = eit_fxpar(fits_header,'FILTER',image_no=image_no) 
   wave = strtrim(wave(0),2)
   filter_string = strlowcase(strtrim(filter_string(0),2))

   date_obs = eit_fxpar(fits_header,'DATE_OBS',image_no=image_no)
   if nrlhdr then date_obs = eit_fxpar(fits_header,'DATE-OBS',image_no=image_no)
   utc_date_obs = anytim2utc(date_obs)

   if (not final) and (utc_date_obs.mjd lt utc_date_19960327.mjd) $
      and (utc_date_obs.mjd ne utc_date_19960323.mjd) then begin
      if strlowcase(filter_string) eq 'clear' then begin
         degrid_file = degrid_file + wave + '_' + 'al1.dat'
      endif else if strlowcase(filter_string) eq 'al +2' then begin
         degrid_file = degrid_file + wave + '_' + 'clear.dat'
      endif else degrid = 0
   endif else begin
      if filter_string ne 'clear' then filter_string = 'al1'
      degrid_file = degrid_file + wave + '_' + filter_string + '.dat'  
   end

   if degrid then begin

;
;  Check to see if we already have this loaded in the common block
;  BNH 16-Oct-96
;
      if (degrid_file ne filename) then begin
         if verbose then message, /info, 'Reading in grid.'
	 filename = degrid_file
         if gsfcvms then begin
            release = !version.release
            version_release = 100*strmid(release, 0, 1) + $
               10*strmid(release, 2, 1) + strmid(release, 4, 1)
            if version_release le 503 then begin
               openr, degrid_unit, degrid_file, /get_lun, /block
            endif else begin
               openr, degrid_unit, degrid_file, /get_lun, /block, /vax_float
            end
         endif else begin
             openr, degrid_unit, degrid_file, /get_lun, /xdr
         end

         degrid_array = fltarr(1024, 1024)
         readu, degrid_unit, degrid_array
         close, degrid_unit & free_lun, degrid_unit
      endif else $
 	if verbose then message, /info, 'Using pre-read grid.'


      dg_mult = degrid_array(corner(0):corner(1), corner(2):corner(3))
      if (x_bin eq 1) and (y_bin eq 1) then begin
         a = temporary(a)*temporary(dg_mult)
      endif else begin
         a = temporary(a)*rebin(temporary(dg_mult), n_x, n_y)
      end

   endif else a = float(temporary(a))

return, a
end
