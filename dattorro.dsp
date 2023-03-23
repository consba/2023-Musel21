declare name "Dattorro Reverb";

import("stdfaust.lib");

dattorroSr = 29761;

//dattorroval : dattorrosr = x : sr

// funzione per l'adattamento dei valori
adapt(val) = val; //* ma.SR / 29761 : int;

// slider

//guisr = vslider("Sample Rate[style:radio{'44100':0;'48000':1;'96000':2}]",0, 0, 2, 1);
//mymax = select3(guisr, 44100, 48000, 96000);
mymax = 96000;

pdly = vslider("[0]preDelay", 0, 0, mymax, 1); //si può impostare SR
decay = vslider("[1]decay", 0.5, 0, 1, 0.01) : si.smoo;
dDgroup(x) = hgroup("[2]Decay diffusion", x);
ddiff1 = dDgroup(vslider("1", 0.7, 0, 1, 0.01));
ddiff2 = dDgroup(vslider("2", 0.5, 0.25, 0.5, 0.01));
iDgroup(x) = hgroup("[3]Input diffusion", x);
idif1 = iDgroup(vslider("1", 0.75, 0, 1, 0.001));
idif2 = iDgroup(vslider("2", 0.625, 0, 1, 0.001));
bw = vslider("[4]bandWidth", 0.7, 0, 0.9999999, 0.01);
damp = 1-vslider("[5]damping", 0.0005, 0, 1, 0.0001);
exgroup(x) = hgroup("[6]Excursion", x);
oscRadio = exgroup(vslider("Osc[style:radio{'Sine':0;'Tri':1;'Sqare':2}]",0, 0, 2, 1));
oscS = select3(oscRadio,os.osc(1),os.triangle(1),os.square(1));
exui = exgroup(vslider("Amp", 16, 0, 100, 0.001));

dattorroGroup = hgroup("Dattorro Reverb", dattorro);

lp1p(a) = _*(a) : +~*(1-a);

apf(idif, t) = (ma.sub : (*(idif) <: de.delay(mymax, t), _))~*(idif) : +;  
                //ma.sub inverte l'ordine degli operatori
//process = ba.pulsen(1, ma.SR) : apf;

apfm(idif, t, ex) = (+ : (*(idif) <: de.sdelay(mymax, 512, t+(oscS*ex)), _))~*(idif) : -; //esternare oscillatore


//yL =  apfm(ddiff1, adapt(672), exui) : de.delay(mymax, adapt(4453)) : lp1p(damp) : *(decay) : apf(ddiff1, adapt(1800)) : de.delay(ma.SR, adapt(3720));
//yR =  apfm(ddiff1, adapt(908), exui) : de.delay(mymax, adapt(4217)) : lp1p(damp) : *(decay) : apf(ddiff2, adapt(2656)) : de.delay(ma.SR, adapt(3163)) : *(decay);

yL =  apf(ddiff1, adapt(672)) : de.delay(mymax, adapt(4453)) : lp1p(damp) : *(decay) : apf(ddiff1, adapt(1800)) : de.delay(ma.SR, adapt(3720));
yR =  apf(ddiff1, adapt(908)) : de.delay(mymax, adapt(4217)) : lp1p(damp) : *(decay) : apf(ddiff2, adapt(2656)) : de.delay(ma.SR, adapt(3163)) : *(decay);

tank = (ro.cross(2),_,_ : _,ro.cross(2),_ : +,+ : yL, yR)~(*(decay),*(decay));
//si.bus(s) dice che ci sono due canali e quindi raddoppia
//ro.cross reindirizza i flussi cambiando la numerazione degli ingressi (più o meno una cosa del genere)

dattorro = _ : de.delay(mymax, pdly) : lp1p(bw) : apf(idif1, adapt(142)) : apf(idif1, adapt(107)) : apf(idif2, adapt(379)) : apf(idif2, adapt(277)) <: tank;   //modifica decay dopo l'uscita

//process = fi.allpassnt(1, 1);    //filtro allpass con topologia lattice
//process = _ <: _*(0.5),dattorro :>/(2);

dw = 0.9;

process = _ <: (_*(1-dw) <: _,_),dattorroGroup : _,_,*(dw),*(dw) :> _,_;
