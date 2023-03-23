import("stdfaust.lib");


pdly = hslider("preDelay", 0, 0, 44100, 1); //si può impostare SR

bw = hslider("bandWidth", 0.7, 0, 1, 0.01);

idif1 = hslider("imput diffusion 1", 0.75, 0, 1, 0.001);
idif2 = hslider("imput diffusion 2", 0.625, 0, 1, 0.001);
damp = 1-hslider("damping", 0.7, 0, 1, 0.01);
decay = hslider("decay", 0.7, 0, 1, 0.01);
ddiff1 = hslider("decay diffusion 1", 0.7, 0, 1, 0.01);
ddiff2 = hslider("decay diffusion 2", 0.5, 0.25, 0.5, 0.01);

lp1p(a) = _*(a) : +~*(1-a);


apf(idif, t) = (ma.sub : (*(idif) <: de.delay(2700, t), _))~*(idif) : +;  //ma.sub inverte l'ordine degli operatori
//process = ba.pulsen(1, ma.SR) : apf;


apfm(idif, t, ex) = (+ : (*(idif) <: de.sdelay(2700, 512, t+(os.osc(1)*ex)), _))~*(idif) : -; //esternare oscillatore






yL =  apfm(ddiff1, 672, 16) : de.delay(ma.SR, 4453) : lp1p(damp) : *(decay) : apf(ddiff1, 1800) : de.delay(ma.SR, 3720) : *(decay);
yR =  apfm(ddiff1, 908, 16) : de.delay(ma.SR, 4217) : lp1p(damp) : *(decay) : apf(ddiff2, 2656) : de.delay(ma.SR, 3163) : *(decay);
tank = (ro.cross(2),_,_ : _,ro.cross(2),_ : +,+ : yL, yR)~si.bus(2);
//si.bus(s) dice che ci sono due canali e quindi raddoppia
//ro.cross reindirizza i flussi cambiando la numerazione degli ingressi (più o meno una cosa del genere)


dattorro = _ : de.delay(ma.SR, pdly) : lp1p(bw) : apf(idif1, 142) : apf(idif1, 107) : apf(idif2, 379) : apf(idif2, 277) <: tank;   //modifica decay dopo l'uscita

//process = fi.allpassnt(1, 1);    //filtro allpass con topologia lattice

process = _ <: _*(0.5),dattorro :>/(2);