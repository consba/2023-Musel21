import("stdfaust.lib");
import("21ME.lib");

p = hslider("mid polar pattern",0.5,0,1,0.01) : si.smoo;
a = 0-hslider("azimuth",0,-180,180,0.1) *ma.PI/180;

process = os.osc(100) : mel.mspan(p,a);