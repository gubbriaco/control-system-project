function [alpha,T1,T2]=sella(wc,m,phi,k)
%
% Calcola i parametri della rete
% a sella
% I parametri della funzione sono:
% wc  : pulsazione di attraversamento desiderata
% m   : reciproco del modulo della funzione di anello non-compensata |L(j wc)|
% phi : incremento richiesto sulla fase in gradi
% k   : T1/T2
% La funzione restituisce
% T1  : costante di tempo della parte attenuatrice
% T2  : costante di tempo della parte anticipatrice
% alpha : distanza logaritmica tra poli e zeri delle parti
%         attenuatrici e anticipatrici della rete
%

mod=m;

m=(mod*(cos(phi*pi/180)-mod))/(1-mod*cos(phi*pi/180));

if (k<=1/m) disp('Non puoi progettare la rete con i parametri proposti!');
          alpha=[];
          T1=[];
          T2=[];
           return;
else
    alpha = (k*m-1)/(k-m);
    radici = roots([alpha^2*k^2 ((1+alpha^2*k^2-mod^2*(alpha^2+k^2))/(1-mod^2)) 1]);
    xp=max(radici);
    T2=(1/wc)*sqrt(xp);
    T1=k*T2;
end;