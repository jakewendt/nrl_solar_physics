pro lz_disk_init3,dummy, NOCOPY=nocopy
;+
; NAME:
;	LZ_DISK_INIT3
;
; PURPOSE:
;	This procedure does some level-0 disk initial tasks:
;    	copy definitive attitude files from cd to $NRL_LIB/lasco/data/attitude
;    	copy definitive orbit files from cd to $NRL_LIB/lasco/data/orbit
;    	read data files and get start dates
;
; CATEGORY:
;	UTIL
;
; CALLING SEQUENCE:
;	LZ_DISK_INIT3
;
; INPUTS:
;	None
;
; OUTPUTS:
;	None
;
; SIDE EFFECTS:
;	Creates various disk files
;
; RESTRICTIONS:
;	None
;
; MODIFICATION HISTORY:
; 	Written by:	RAHoward, NRL, May 1996
;	961216 by N. Rich	commented out miss_pckts, start_dates lines
;	970423 by N. Rich	prompt for multiple disks for each release
;       970618 by N. Rich	avoid long list of chmod: WARNING messages by
;				changing cp and chmod commands for or and at
;	970627 by N. Rich	Include print statements for copied files
;	990416 by N. Rich	Print multiple volume numbers
;	991216 by N. Rich	Change hkdir to solardata
;	000803 by Jake		Added /SH to spawn commands
;	000808 the Jake		Changed lzcds to .lzcds
;	001011 the Jake		Copying d01 files to $TMFILES Directory now.
;	011030 the Jake		Changed name to lz_disk_init3 for clarification
;	020314	Jake            attitude and orbit files not available in download
;				ISTP is no longer supplying CDs
;				lines copying this data have been REM'd
;	021009 Jake		trying to fix carriage return kept at the end of volno
;	030729	Jake	added NOCOPY keyword to not copy data files
;
;
;@(#)lz_disk_init3.pro	1.7 07/30/03 : LASCO IDL LIBRARY
;-
	CD,'/cdrom/cdrom0',current=curr

	nxt=''
	update=''
	gdirs = ['g001','g002','g003','g004','g005','g006','g015','g016','g017']
	hkdir = '/net/corona/corona01/lz/hk/'
	tmfiles = GETENV ('TMFILES')

	READ,'How many CDs in this release? ',num
	print
	print,'HK directory is ',hkdir
	READ,' Perform attitude and orbit and hk update?[y/n] ',update

	nrl_lib = getenv_slash('NRL_LIB')+'lasco'+!delimiter+'data'+!delimiter

	FOR sequ = 1,num DO BEGIN
		;
		;  strip out disk number from voldesc
		;
		SPAWN,'grep SEQUENCE /cdrom/cdrom0/voldesc.sfd',voldesc,/SH
		voldesc=voldesc(0)
		volno = strtrim ( strmid(voldesc,strpos(voldesc,':')+1,5) ,2); change +2 to +1 (jake)
		print,'Sequence number = ',volno
		IF sequ EQ 1 THEN firstvol=volno
		IF update EQ 'y' THEN BEGIN
			cd,!delimiter+'cdrom'+!delimiter+'cdrom0'+!delimiter+'data'+!delimiter+'so'
;
;	NO LONGER AVAILABLE WHEN DOWNLOADING (020315, Jake)
;
;			atfiles=findfile('def/at/*.cdf')
;			found = n_elements(atfiles)
;			FOR k = 0,found-1 DO BEGIN
;				print,'cp '+atfiles(k)+' '+nrl_lib+'attitude'+!delimiter+'definitive'
;				spawn,'cp '+atfiles(k)+' '+nrl_lib+'attitude'+!delimiter+'definitive',/SH
;				parts = str_sep(atfiles(k),'/')
;				atfile = parts(2)
;				spawn,'chmod a-x '+nrl_lib+'attitude'+!delimiter+'definitive'+!delimiter+atfile,/SH
;			ENDFOR
;			orbfiles=findfile('def/or/*.cdf')
;			found = n_elements(orbfiles)
;			IF found GT 1 THEN BEGIN
;				FOR k = 0,found-1 DO BEGIN
;					print,'cp '+orbfiles(k)+' '+nrl_lib+'orbit'+!delimiter+'definitive'
;					spawn,'cp '+orbfiles(k)+' '+nrl_lib+'orbit'+!delimiter+'definitive',/SH
;					parts = str_sep(orbfiles(k),'/')
;					orbfile = parts(2)
;					spawn,'chmod a-x '+nrl_lib+'orbit'+!delimiter+'definitive'+!delimiter+orbfile,/SH
;				ENDFOR
;			ENDIF ELSE print,'!!!!!!!!!!! No orbit files found in def/or.'

			FOR g = 0,8 DO BEGIN
				spawn,'ls '+gdirs(g)+'/lz/*sfd',/SH
				spawn,'cp '+gdirs(g)+'/lz/* '+hkdir+gdirs(g),/SH
			ENDFOR
		ENDIF

		; JAKE
		IF NOT KEYWORD_SET(NOCOPY) THEN BEGIN
			print, 'Copying data files to '+tmfiles
			spawn, 'cp /cdrom/cdrom0/data/so/g031/lz/*.d01 '+tmfiles, /SH
		ENDIF
		;

		cd,'~/.lzcds'
		lz_start_date3,'last'
		cd,curr
		spawn,'eject cdrom',/SH
		print
		IF sequ NE num THEN $
			read,'Please insert CD number '+string(sequ+1)+' and <RETURN>',nxt
		wait,10
	ENDFOR
	cd,'~/.lzcds'
	IF volno EQ firstvol THEN fname = 'lz_'+volno+'_start_dates.lst' ELSE $
		fname = 'lz_'+firstvol+'_'+volno+'_start_dates.lst'
	spawn,'mv lz_last_start_dates.lst '+fname,/SH
;	spawn,'pr '+fname+' |lp',/SH
	RETURN
END
