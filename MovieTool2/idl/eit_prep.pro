pro eit_prep,filename,outheader,outimage,	$
                ;
                ;----------------------Calibration, processing options
                no_calibrate = no_calibrate, cosmic=cosmic,$
                surround=surround,fill_block=fill_block,$
                no_index=no_index,$
                ;
                ;----------------------Output controls
                outfits=outfits,nodata=nodata,outdir=outdir,$
                ;
                ;----------------------Misc.
                verbose=verbose,save_zero=save_zero, $                
                nrl=nrl,n_block=n_block,data=data, $
                image_no=image_no, noprompt = noprompt, _extra=extra

;+
; NAME:
;	EIT_PREP
;
; PURPOSE:
;	Process an EIT image.
;
;	Processing routine for preparing Level-1 EIT data. 
;       Presently this version reads in the named FITS
;       image and produces a background subtracted, degridded,
;	flat-fielded, and degradation corrected output array or FITS file. 
;       In the future this routine will also vignette correct. 
;       The input may also be the output index structure and data cube as 
;       produced by read_eit.
;
; CATEGORY:
;	FITS processing
;
; CALLING SEQUENCE:
;       EIT_PREP,filename,[outheader,outimage] [data=data] [,/outfits] 
;                [,/verbose] [,/cosmic] [,/no_calibrate] [,/no_index]
;                [,/save_zero] [,/nrl] [n_block = n_block]
;                [,/surround] [,/nodata] [,outdir = outdir] 
;                [,image_no = image_no]  
;
; INPUTS:
;	filename - FITS file name or the output of eit_catrd 
;                  may also be index structure (e.g. output of read_eit)
;
; 
; OPTIONAL INPUT KEYWORD PARAMETERS: 
;       outfits  - set if want to produce an output FITS file
;                  (or set string filename)
;       outdir   - Destination directory for prepped FITS files
;                  (if outdir is set, /outfits is assumed)
;       nrl      - set if input file was processed at NRL
;	surround - set to replace missing block data with the average of
;			surrounding blocks. 
;	image_no - Image number(s) (or 'ALL') to process in multiple image LZ file.
;	fill_block - intarr(32,32) which is used to replace missing data blocks
;	save_zero- set to retain images that have only 0 counts.
;	verbose  - set for a few more messages
;       data     - data array(cube) corresponding to index structure
;       nodata   - set if don't want output array (auto set if lt 3 params)
;       cosmic   - set if want to remove cosmic rays - may remove small
;                   real features
;       no_calibrate - set if want "raw" returned images, i.e. only background subtracted
;       no_index - set if don't want to use recommended Index correlation
;                   for final response scaling
;
; OPTIONAL OUTPUTS:
;	outheader- FITS header or output index structure
;	outimage - Processed EIT image.  Default data type is Float
;
; OPTIONAL OUTPUT KEYWORD PARAMETERS:
;	n_block  - Number of blocks repaired
;
; COMMON BLOCKS: none.
;
; SIDE EFFECTS: 
;	If /outfits is set, then a FITS file is written. 
;
; RESTRICTIONS:
;     1)  Processes only one 3-Dim file at a time, either a single image
;         vector, or the entire file.
;
;     2)  Does not process a mixture of 2D and 3D files
;
;     3)  If filename is a vector, there is no checks to make sure
;         that all the images are the same size. User must be careful
;         to check this.
;
; PROCEDURE:
;         The FITS file is read in. Any missing blocks are replaced
;         with the present dark noise value. The dark noise is
;         subtracted off the entire image. The image is degridded.
;         The image is flat fielded and corrected for degradation. 
;         The image is optionally returned.
;         A new FITS file with an updated header is written out
;         with the format eit_l1_yyyymmdd_hhmmss.fits
;
;         Note: the De-gridding and Flat-fielding are multiplicative 
;               operations with an AVERAGE value over the full field
;               of 1.0
;
; MODIFICATION HISTORY:
; 	Written by:  J. Newmark 	Date.  July 1996
;       1996 Sep 24 - J. Newmark - add flat fielding 
;       1996 Oct 8 - J. Newmark  - allow NRL format files
;	1996 Oct 16, J. R. Lemen, Changed calling arguments.
;       1996 Dec 09 - J. Newmark - add usage of image_no throughout.
;       1997 Feb 10 - J. Newmark - allow input if index structure and data
;                                  cube
;       1997 Mar 09 - J. Newmark - write out FITS files from indx/data
;                                   structures
;       1997 Mar 10 - J. Newmark - fix output FITS file names.
;       1997 Apr 09 - J. Newmark - account for new exptime
;       1997 Apr 12 - J. Newmark - account for correction of Al+1 to ClEAR
;       1997 Aug 14 - J. Newmark - implemented Handy requests of outdir, use
;                                   of nodata
;       1997 Aug 18 - J. Newmark - updated conversion of struct->fitshead
;                                  fix up code for /surround
;                                  clean up code for output file name
;       1997 Oct 06 - J. Newmark - added preliminary response normalization
;       1997 Oct 30 - J. Newmark - update header for LZ Partial Fov images 
;       1997 Nov 10 - J. Newmark - add new grids after July 1997
;
; Version 2.0 
;       1998 Mar 27 - J. Newmark - support ALL or vector images in single 3D 
;                                  file, speed up 3D processing,  
;                                  clean up history, pathway checks,
;                                  update documentation, fix n_block bug 
;                                  added adjust keyword
;       1998 Jun 3  - D. Zarro (SAC/GSFC) 
;                                -  sprinkled liberally with calls to temporary
;       1998 Jul 22 - J. Newmark - add phot_norm keyword
;       1998 Jul 23 - J. Newmark - add cosmic keyword
;       1998 Dec 08 - J. Newmark - change adjust keyword
;       2000 Jan 05 - J. Newmark - new response normalization, deleted
;                                  phot_norm keyword
;       2000 Aug 04 - J. Newmark - NOPROMPT keyword for batch processing
;                                  large data sets, cleaned up memory managment
;       2001 Mar 15 - F. Auchere - added time varying dark current
;
;Version 3.0
;       2001 May 18 - J. Newmark/F. Auchere - new response normalization 
;	2001 Jun 21 - N. Rich - Add NRL check at (near) line 332
;	2001 Aug 15 - Zarro (EITI/GSFC) - add optional FITS out file name in
;                                         OUTFITS
;
;Version 4.0
;       2001 Dec 10 - J. Newmark - changed default options, 
;                        new calibration, new default options lead 
;                        to default output type as float
;       2002 Jan 12 - F. Auchere - modified call to eit_dark to handle
;                        different offset in binned images
;       2003 Apr 17 - D. Biesecker - modified call to is_fits to correctly
;                        handle collapsed directory path names
;-

utc_date_19960327 = anytim2utc('1996/03/27')
utc_date_19960323 = anytim2utc('1996/03/23')
utc_obe_good = anytim2utc('1996/07/18')
t_obe = utc_obe_good.mjd + 1.d-3*utc_obe_good.time/86400.
flag_3d = 0
use_fits = 1
filter_factor = [0.49, 0.49, 0.33, 0.29]
wavelength = [171, 195, 284, 304]

if is_string(outfits) then outfile=outfits

if n_elements(outdir) then outfits = 1 else outdir = ''
yes_data = not keyword_set(nodata) or n_params() eq 3

t0 = systime(1)				; Keep track of running time
if datatype(filename) eq 'STC' then begin
   if keyword_set(data) then begin
         use_fits = 0 
         image_no = 0
   endif else begin
      message, /info, 'No Data supplied, reading FITS files...'
      filename = filename.filename
   endelse
 endif 
nfiles = n_elements(filename)
vv = fltarr(nfiles)
n_block = intarr(nfiles)

if use_fits then begin
    stat = is_fits(filename(0))
    if stat eq 0 then begin
      files = eit_file2path(filename) 
      stat = is_fits(files(0))
      if stat eq 0 then begin
          files = eit_file2path(filename,/collapse)
          stat= is_fits(files(0))
          if stat eq 0 then begin
              message,'The files do not appear to be FITS file.',/info
             return
          endif
      endif
    endif else files = filename

    if yes_data then begin
       noprompt = keyword_set(noprompt) or (get_logenv('ssw_batch') ne '')
       prompt = 1 - noprompt
       tsize = total(file_stat(files,/size))/1.e6
       if tsize ge 100 and prompt then begin 
          print,'You have requested '+string(tsize)+' MB of data'
          print,'You can select the output to be only FITS files if this '+$
                'is too large for your machine"s memory.'
          ans=''
          read,ans,prompt='Enter C (continue) or F (FITS only): '
          if strupcase(ans) eq 'F' then begin
             yes_data = 0
             outfits = 1
          endif
       endif
    endif

    if keyword_set(image_no) and nfiles gt 1 then begin
       message,'This program only works on 1 3-Dim file at a time.',/info
       return
    endif

endif

i = 0
repeat begin				; MAIN LOOP: begins

  if ((i+1) mod 10) eq 0 then message,/info,	$
        string('Working on',i+1,'/',strtrim(nfiles,2),	$
	'   ETC=',(nfiles-i+1)*(systime(1)-t0)/60./float(i+1),	$
	' mins.',form='(a,i4,3a,f5.1,a)')

  if use_fits then begin
    thisfile = files(i)
    if n_elements(image_no) eq 0 then begin
        image = readfits(thisfile,header,silent=1-keyword_set(verbose)) 
        image_no = 0
    endif else begin
         if flag_3d then image_no = images3d(i)
         header = headfits(thisfile)
         if n_elements(image_no) gt 1 then begin
            nfiles = n_elements(image_no)
            files = replicate(files,nfiles)
            images3d = image_no
            image_no = images3d(0)
            flag_3d = 1
            vv = fltarr(nfiles)
            n_block = intarr(nfiles)
         endif else if strupcase(image_no) eq 'ALL' then begin
            nfiles = eit_fxpar(header,'naxis3')
            files = replicate(files,nfiles)
            images3d = indgen(nfiles)
            image_no = 0
            flag_3d = 1
            vv = fltarr(nfiles)
            n_block = intarr(nfiles)
         endif
         if image_no eq 0 then begin
             image = readfits(thisfile,silent=1-keyword_set(verbose))
         endif else begin
             image = readfits(thisfile,silent=1-keyword_set(verbose),$
                          nslice = image_no)
         endelse
    endelse

    if keyword_set(nrl) then header = nrl2eit(header)
  endif else begin
    header = filename(i)
    thisfile = eit_file2path(header.filename)
    image = data(*,*,i)
  endelse

; set final keyword for degrid routine
  if strpos(strlowcase(thisfile), 'efz') ge 0 or strtrim(eit_fxpar(header,$
    'DATASRC'),2) eq 'LZ file' then final = 1 else final = 0

  date_obs = eit_fxpar(header,'date_obs',image_no=image_no)  ;== Added 15 March 2001 F. Auchere
  utc_date_obs = anytim2utc(date_obs)                 
  hist = eit_fxpar(header,'history')
  IF keyword_set(NRL) THEN version = 3.0 ELSE version = float(strmid(hist(0),8,3))
	;==Add NRL check, 21Jun01, nbr

; Fix missing blocks, dark subtract:

  if keyword_set(fill_block) and keyword_set(surround) then $
    message,'Cannot set both fill_bock and surround'

  if keyword_set(cosmic) then begin
      image = cosmicr(image)
      tagval = 'Replaced Cosmic Rays with Median Filtering'
      if use_fits then fxaddpar, header,'HISTORY', tagval else $
         header = rep_tag_value(header,[header.history,tagval],'HISTORY')
  endif

  bin = round(eit_fxpar(header, 'CDELT1')/eit_pixsize())

  case 1 of 
    keyword_set(surround): begin
     if not keyword_set(no_degrid) then $
        image = raise_missing_blocks(image, repl=eit_dark(date_obs,bin=bin),n_block=nblock,/no_copy) $
     else image = raise_missing_blocks(image, /surround,n_block=nblock,/no_copy)   ;== Modified 15 March 2001 F. Auchere
     tagval = 'Replaced missing blocks with SURROUND'
     end

    keyword_set(fill_block) : begin
      image =raise_missing_blocks(image,fill_block=fill_block,n_block=nblock,/no_copy)
      tagval = 'Replaced missing blocks with FILL_BLOCK'
      end

    else: begin
      image = raise_missing_blocks(image, repl=eit_dark(date_obs, bin=bin),n_block=nblock,/no_copy)  ;== Modified 15 March 2001 12 jan 2002 F. Auchere
      tagval = 'Replaced missing blocks with EIT_DARK'
      end
  endcase
  n_block(i) = nblock

  if use_fits then fxaddpar, header,'HISTORY', tagval else $
         header = rep_tag_value(header,[header.history,tagval],'HISTORY')
  image = temporary(image) - eit_dark(date_obs, bin=bin)  ;== Modified 15 March 2001, 12-jan 2002 F. Auchere
  tagval = 'Subtracted dark current, EIT_DARK'
  if use_fits then fxaddpar, header,'HISTORY', tagval else $
         header = rep_tag_value(header,[header.history,tagval],'HISTORY')

; calibrate - degrid, flat field, normalize by exposure time, time varying
;              response correction
  if not keyword_set(no_calibrate) then begin 
     image = eit_degrid(image, header, final = final, image_no = image_no,$
                      /no_copy)
     if keyword_set(surround) then $
         image = raise_missing_blocks(image, /surround,n_block=nblock,/no_copy)
     tagval = 'Degridded image with EIT_DEGRID'
     if use_fits then fxaddpar, header,'HISTORY', tagval else $
         header = rep_tag_value(header,[header.history,tagval],'HISTORY')
     
     image = eit_flat(image, header, image_no = image_no,/no_copy)
     tagval = 'Flat fielded image with EIT_FLAT'
     if use_fits then fxaddpar, header,'HISTORY', tagval else $
         header = rep_tag_value(header,[header.history,tagval],'HISTORY')
     

     if version(0) ge 2.0 then shut_time = 0 else begin
         t_obs =  utc_date_obs.mjd + 1.d-3*utc_date_obs.time/86400        
         shut_time = eit_fxpar(header,'SHUTTER CLOSE TIME',image_no=image_no)
         if shut_time le 0 or t_obs lt t_obe then shut_time = 2.1
     endelse
     exptime=eit_fxpar(header,'exptime',image_no=image_no)+shut_time
     image = temporary(image) / exptime
     tagval = 'Exposure normalized (per sec)'     
     if use_fits then fxaddpar, header,'HISTORY', tagval else $
         header = rep_tag_value(header,[header.history,tagval],'HISTORY')

     filter = strupcase(strtrim(eit_fxpar(header,'filter',image_no=image_no),2))
     wave = eit_fxpar(header,'wavelnth',image_no=image_no)
     i_wave = where(wavelength eq wave)
     if (not final) and (utc_date_obs.mjd lt utc_date_19960327.mjd) and $
         (utc_date_obs.mjd ne utc_date_19960323.mjd) then begin
            if filter eq 'CLEAR' then image = temporary(image) / filter_factor(i_wave(0))
     endif else if filter eq 'AL +1' then image = temporary(image)/filter_factor(i_wave(0))
     if n_elements(leak_284) ne 0 and filter eq 'CLEAR' and wave eq 284 then $
                  image = temporary(image)/leak_284
     tagval = 'Flux normalized to CLEAR Filter'     
     if use_fits then fxaddpar, header,'HISTORY', tagval else $
         header = rep_tag_value(header,[header.history,tagval],'HISTORY')

     wave = eit_fxpar(header,'wavelnth',image_no=image_no)
     image = temporary(image) / eit_norm_response(utc_date_obs,wave,header,$
              no_index=no_index)
     tagval = 'Flux normalized for time response changes'     
     if use_fits then fxaddpar, header,'HISTORY', tagval else $
         header = rep_tag_value(header,[header.history,tagval],'HISTORY')
  endif else image = fix(round(temporary(image)))
;
; FITS header updates, needed for LZ partial field of view.
  if use_fits and final and eit_fxpar(header,'naxis3') gt 0 then begin
     fxaddpar, header, 'WAVELNTH', eit_fxpar(header,'wavelnth',image_no=image_no)
     fxaddpar, header, 'CFTEMP', eit_fxpar(header,'cftemp',image_no=image_no)
     fxaddpar, header, 'DATE_OBS', eit_fxpar(header,'date_obs',image_no=image_no)
     fxaddpar, header, 'FILTER', eit_fxpar(header,'filter',image_no=image_no)
     fxaddpar, header, 'EXPTIME', eit_fxpar(header,'exptime',image_no=image_no)
     up_corr = where(strpos(header,'COMMENT   CORREC') ne -1)
     if up_corr(0) ne -1 then header(up_corr) = 'COMMENT   '+$
           'CORRECTED DATE_OBS = '+ anytim2utc(eit_fxpar(header,$
           'corrected date_obs',image_no=image_no),/ccsds)
  endif

; Pointing adjustment - 3/30/98 JSN
  if version lt 2.6 and use_fits then begin
      fxaddpar, header, 'CDELT1', eit_pixsize()
      fxaddpar, header, 'CDELT2', eit_pixsize()
      xy = eit_point(utc_date_obs)
      fxaddpar, header, 'CRPIX1', xy(0)
      fxaddpar, header, 'CRPIX2', xy(1)
  endif

; Set up the output file name:

  dat_ob=anytim2cal(eit_fxpar(header,'date_obs',image_no=image_no),form=8)
  if is_string(outfile) then outname=outfile else $
   outname = 'eit_l1_'+strmid(dat_ob,0,8)+'_'+strmid(dat_ob,8,6)+'.fits' 
  outname = concat_dir(outdir,outname)

  ; Write the FITS file
  if keyword_set(outfits) then begin
     if use_fits then writefits, outname, image, header else begin
          hdr = struct2fitshead(header)
          writefits,outname,image,hdr
          delvarx,hdr
     endelse
  endif 


; Concatenate the headers and images
   if i eq 0 then outheader = header else begin
           if use_fits then begin
                szo = size(outheader)
                szh = size(header)
                case 1 of 
                   szh(1) lt szo(1): header = [header,' ']
                   szh(1) gt szo(1): header = header(0:szo(1)-1)
                   else: 
                endcase  
                outheader = [[outheader],[header]] 
           endif else begin
             out_str = outheader(0)
             outheader = [str_copy_tags(out_str,outheader), str_copy_tags(out_str,header)]
           endelse
   endelse
   if i eq 0 and yes_data then begin
      ss = size(image)
      if keyword_set(no_calibrate) then outimage = intarr(ss(1),ss(2),nfiles) else $
			       outimage = fltarr(ss(1),ss(2),nfiles)
   endif
   vv(i) = max(image)
   if yes_data then outimage(0,0,i) = temporary(image)

i = i + 1
endrep until i eq nfiles                        ; MAIN LOOP ends

if not keyword_set(save_zero) then begin	; Reject blank images
  jj = where(vv ne 0,ncount)

  if ncount eq 0 then begin
       message,/info,'All images are zero'
       outimage = 0
       outheader = ''
  endif else begin
     if yes_data and ncount ne nfiles then outimage = outimage(*,*,jj)
     if use_fits then outheader = outheader(*,jj) else $
         outheader = outheader(jj)
     n_block = n_block(jj)
     if n_elements(jj) eq 1 then n_block = n_block(0) 
  endelse
endif

message,/info,string('took',systime(1)-t0,' seconds',format='(a,f5.1,a)')
end

