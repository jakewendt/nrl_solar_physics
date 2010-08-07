function eit_dark, date, bin=bin
;+
; EIT_DARK
;
; Purpose - returns a fourier series fit to the measured offset values
;
; Inputs: date
; Output: the offset value
;
; Created: Mar 2001. F. Auchere
; Modified: 14 Dec 2001. F. Auchere - New fit with Fourier series
; Updated: Fri Dec 14 EIT planner
; Updated: Mon Dec 17 EIT planner
; Modified: 12 Jan 2002. F. Auchere - Handles different offset in binned images
;-

if n_elements(date) eq 0 then return, 852.0
if not keyword_set(bin) then bin = 1

eit_dark_fitparam, ampli, phase, ext, ndays

time = ((anytim2utc(date)).mjd - (anytim2utc('01-jan-1996')).mjd + ext)/(ndays + 2.0*ext)
if n_elements(time) eq 1 then dark = ampli[0] else dark = replicate(ampli[0], n_elements(time))

for i = 1, n_elements(ampli)-1 do dark = dark + ampli[i]*2.0*cos(i*2.0*!pi*time + phase[i-1])

if bin ge 2 then dark = dark + 5.0

return, dark

end
