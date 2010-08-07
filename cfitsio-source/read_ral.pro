
pro read_ral,file,fn=fn,img=img,hdr=hdr,exact=exact

if not keyword_set(exact) then f =  '~/calroc_2002/'+strmid(file,0,4)+$
   '-'+strmid(file,4,2)+'-'+strmid(file,6,2)+'/'+ file else $
   f = file
readcol,f+'.txt',bstart,bend,fname,dates,times,format='(a,a,a,a,a)'
bstart=long(bstart)
b_end=long(bend)

if n_elements(fn) eq 0 then begin
   diff = b_end - bstart
   ok = where(diff eq 2150.*2150.*2 + 7,cnt)
   bstart = bstart(ok)
   num = cnt
endif else begin
   num = 1
   bstart = bstart(fn)
endelse

if float(!version.release) ge 5.3 then begin
  swap_endian = 1 - is_lendian()
  openr,lun,f+'.dat',/get_lun,swap_endian=swap_endian
endif else openr,lun,f+'.dat',/get_lun
img = fltarr(2150,2150,num)
single = intarr(2150,2150)
hdr = bytarr(8,num)
hs = bytarr(8)
for i =0,num-1 do begin
   point_lun,lun,bstart(i)
   readu,lun,hs
   hdr(0,i) = hs
   readu,lun,single
   fsingle = float(single)
   low = where(single lt 0,cnt)
   if cnt ne 0 then fsingle(low) = 65535. + fsingle(low)
   img(0,0,i) = fsingle
endfor
free_lun,lun
end


