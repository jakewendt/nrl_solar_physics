</TR>
</TABLE>
<P>

<FORM NAME="form">
 <FONT COLOR="Black">
 <INPUT TYPE=button VALUE="Start" onClick="start_play();">
 <INPUT TYPE=button VALUE="Pause" onClick="stop_play();">
 <INPUT TYPE=button VALUE="Faster" onClick="speed*=inc; show_speed();">
 <INPUT TYPE=button VALUE="Slower" onClick="speed/=inc; show_speed();">
 <INPUT TYPE=button VALUE="Step" onClick="step();">
 <INPUT TYPE=button NAME="direction" VALUE="Reverse" onClick="reverse();">
 <INPUT TYPE=button VALUE="Swing Mode:" onClick="swing_mode();">
 <INPUT TYPE=text VALUE="OFF" NAME="swing" SIZE=3>

 </FONT>
 <BR>
 Frame: <INPUT TYPE=text VALUE="" NAME="frame" SIZE=22> 
 &nbsp; Speed:<INPUT TYPE=text VALUE="" NAME="rate" SIZE=4> (frames/sec)
</FORM>
 
</FORM>
</CENTER>

<B>Document</B>: <I><SCRIPT>document.write(document.title);</SCRIPT></I><BR>
<B>URL</B>: <I><SCRIPT>document.write(document.URL);</SCRIPT></I><BR>


<SCRIPT LANGUAGE="JavaScript">
<!--

function get_window_width(fac,def) {  // Return window width

 
var width;
if (!fac) {fac=.75;}
if (!def) {def=512;}
if (window.screen) {
 width=parseInt(fac*parseFloat(window.screen.width));
} else {
 width=def;
}

return width;

}

/////////////////////////////////////////////////////////////////////////////

function get_window_height(fac,def) {   // Return window height

 
var height;
if (!fac) {fac=.75;}
if (!def) {def=512;}

if (window.screen) {
 height=parseInt(fac*parseFloat(window.screen.height));
} else {
 height=def;
}

return height;

}

/////////////////////////////////////////////////////////////////////////////
// Javascript Pop-up image Window
// Written: Zarro (SAC/GSFC), October 1998, (dzarro@solar.stanford.edu)

var win;

function pop_img(url,title,width,height) {

if (!url) {
 alert('Image URL not entered');
 return false;
}

// default to fit within 75% of browser window, or 512x512

if (!width) {width=get_window_width(.75,512);}
if (!height) {height=get_window_height(.75,512);}

if (!win || win.closed) {
 win = open("","img","width="+width.toString()+",height="+height.toString()+",scrollbars=yes,resizable=yes"); 
}

// dynamically create HTML, adding a CLOSE button

if (win) {
 d=win.document;
 d.write('<html><head><title>Image Window</title></head><body bgcolor="white"><center>');
 if (title) {
  d.write('<h1>'+title+'</h1>');
 }
 d.write('<img src='+url+'>');
 d.write('<br><br><br>');
 d.write('<form><b><input type="button" value="CLOSE" onClick="self.close();"></b></form></center>'); 
 d.write('</html></body>');
 d.close();
 win.focus();
}

return true;     
}

///////////////////////////////////////////////////////////////////////////

function load_img() {        // asynchronously load all images into cache
 for (i=0; i < imax ; i++) {
  id[i]=setTimeout("load_src()",0);
 }
 return;
}
/////////////////////////////////////////////////////////////////////////////

function load_src() {      // load individual images into cache

 if (index < imax) {
  if (iwidth && iheight) {
   images[index] = new Image(iwidth,iheight);
  } else {
   images[index] = new Image();
  }
  images[index].onload=count_images;
  images[index].src = urls[index];
  index++;
 }
 return;
}

/////////////////////////////////////////////////////////////////////////////

function clear_ids() {         // clear asynchronous id's
 for (i=0; i < imax ; i++) {clearTimeout(id[i]);}
 return;
}


/////////////////////////////////////////////////////////////////////////////

function count_images() // count images as they are loaded into cache
{ 
 if (++num_loaded_images == imax) {
  show_speed();
  clear_ids();
  animate();
 } else {
  document.animation.src=images[num_loaded_images-1].src;
  document.form.frame.value="Loading "+num_loaded_images+" of "+imax; 
 }
}

///////////////////////////////////////////////////////////////////////////

function image_abort() //  abort loading images
{ 
 imax=num_loaded_images;
 if (!images[num_loaded_images].complete) imax=imax-1;
 alert("Aborting");
 if (imax > -1) animate(); 
}

///////////////////////////////////////////////////////////////////////////

function image_error(message) //  abort loading images
{ 
 alert(message);
}

///////////////////////////////////////////////////////////////////////////

function start_play()  // start movie
{
 if (playing == 0) {
  if (timeout_id == null && num_loaded_images==imax) animate();
 }
} 

///////////////////////////////////////////////////////////////////////////

function stop_play() // stop movie
{ 
 if (timeout_id) clearTimeout(timeout_id); 
  timeout_id=null;
  playing = 0;
} 

///////////////////////////////////////////////////////////////////////////

function swing_mode()    // set swing mode
{
 if (swingon) {
  swingon=0;
  document.form.swing.value="OFF";
 }
  else {
  swingon=1;
  document.form.swing.value="ON";
 }
}

///////////////////////////////////////////////////////////////////////////
  
function animate()  // control movie loop
{
 var j;
 frame=(frame+dir+imax)%imax;
 j=frame+1;
 if (j == imax) 
  { nloop = nloop + 1;
    if (nloop > reload_loop) 
     { nloop = 0;
       document.form.frame.value="Reloading... ";
       //window.location.replace(document.URL);
       window.location.reload();
     }
  }
 if (images[frame].complete) {
  document.animation.src=images[frame].src;
  document.form.frame.value="Displaying "+j+" of "+imax
  if (swingon && (j == imax || frame == 0)) reverse();
  timeout_id=setTimeout("animate()",delay);
  playing=1;
 }
}

///////////////////////////////////////////////////////////////////////////

function step() // step frames
{
 var j;
 if (timeout_id) clearTimeout(timeout_id); timeout_id=null;
 frame=(frame+dir+imax)%imax;
 j=frame+1;
 if (images[frame].complete) {
  document.animation.src=images[frame].src;
  document.form.frame.value="Displaying "+j+" of "+imax;
  playing=0;
 }
}

///////////////////////////////////////////////////////////////////////////

function reverse()  // reverse direction
{
 dir=-dir;
 if (dir > 0) document.form.direction.value="Reverse"; bname="Reverse";
 if (dir < 0) document.form.direction.value="Forward"; bname="Forward";
}

///////////////////////////////////////////////////////////////////////////

function show_speed()      // show speed
{
  document.form.rate.value=Math.round(speed);
  delay = 1000.0/speed; 
  reload_loop = 1200*speed/imax ;
}

///////////////////////////////////////////////////////////////////////////
// actual image loading is done here

show_speed();
images = new Array(imax);
urls= new Array(imax);
id= new Array(imax);

