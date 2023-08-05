clear; close all;

s = zpk('s');

%% la funzione di trasferimento G(s)
G = (36*(s+1))/((s+3)*(s+6)^2);
G

%% il controllore C(s)
%{
%essendo che l'errore di velocita' e_v=3/K il quale deve
%essere minore del 15% e, quindi, di 0.15, allora 3/K <= 0.15.
%Pertanto, K >= 20. Quindi, scelgo un valore di K pari a 20.1.
%Il controllore C(s)=K/s (l'effetto integrale poiche' non e' 
%presente nella G(s) in questione) sara' pari a:
%}
C = 20.1/s;
C

delta = smorz_Mr(3);
delta

%% la funzione di anello L(s)
%{
%la funzione di anello L(s) iniziale sara' pari all'interconnessione
%in serie tra il controllore C(s) precedentemente calcolato e la 
%funzione di trasferimento G(s) data:
%}
Lold = series(C,G);
Lold

%rappresento il diagramma dei moduli e il diagramma delle fasi della
%funzione di anello L(s) appena ottenuta:
figure(1);
margin(Lold);
grid;
legend;

%% la pulsazione di attraversamento wc
%{
%essendo che la pulsazione di banda passante w_bw e' un maggiorante della
%pulsazione di attraversamento wc, posso scegliere un valore arbitrario
%di wc che sia minore del valore "critico" minimo della pulsazione della
%banda passante, cioe' minore di 7 rad/sec ( essendo che la pulsazione di banda
%passante w_bw deve essere compresa nell'intervallo indicato dalla specifica
%cioe':  7 <= w_bw <= 10 rad/sec ). Quindi, scelgo:
%}
wc = 4.5;

%% il modulo e la fase in corrispondenza della pulsazione di attraversamento wc
%{
%la seguente funzione permette di calcolare il valore del modulo e
%dell'argomento ad una specifica pulsazione (in questo caso la pulsazione
%di attraversamento wc scelta precedentemente scelta):
%}
[modulo_iniziale,argomento_iniziale] = bode(Lold,wc);
modulo_iniziale
180 - abs(argomento_iniziale)
%{
% calcolare il modulo e la fase in corrispodenza della pulsazione di
%attraversamento wc mi permette di capire che tipo di rete correttrice
%utilizzare. In questo caso dato che il modulo e' pari a 2.4366, quindi,
%maggiore dell'unita' (poiche' deve risultare che |L(jw)|=1), dovro' 
%attenuare sul modulo. Per quanto riguarda, invece, la fase, essa 
%risultera' pari a 37.4215°, cioe' minore del margine di fase obiettivo
%che era pari a 39°. Pertanto, dovro' utilizzare una rete correttrice di
%tipo sella per attenuare sui moduli e anticipare sulle fasi
%contemporaneamente
%}

%%
%l'amplificazione m che la rete correttrice deve fornire
m = 1/modulo_iniziale;
m

margine_fase = 50;
%il guadagno in fase che serve per raggiungere il margine di fase obiettivo
theta = margine_fase-(180-abs(argomento_iniziale));
theta

%%
%scelgo un k>1
k = 20;

%% i parametri della rete a sella
[alpha,T1,T2] = sella(wc,m,theta,k);
alpha
T1
T2

%% la struttura della rete a sella
Cll = ((1+s*alpha*T1)/(1+s*T1))*((1+s*T2)/(1+s*alpha*T2));
Cll

%rappresento il diagramma dei moduli e delle fasi
figure(2);
bode(Cll);
grid;
legend;
%noto che il margine di fase in corrispondenza della pulsazione di
%attraversamento obiettivo (wc=4.5) e' pari al margine di fase obiettivo 
%phi_m_obiettivo=50°)

%% la funzione di anello finale
%{
%essa e' ottenuta dall'interconnessione in serie tra la funzione di
%trasferimento dell'impianto G(s) e l'interconnessione in serie tra il
%controllore C(s) e la rete correttrice di tipo sella Cll
%}
L = series(series(C,Cll),G);
L

%{
%calcolando di nuovo il modulo e 180-abs(argomento) (in questo caso 
%denominati con termini diversi cosi' da differenziarli da quelli 
%iniziali), noto che ho raggiunto il modulo unitario e il margine di fase
%obiettivo prefissato inizialmente.
%}
[modulo_finale,argomento_finale] = bode(L,wc);
modulo_finale
180-abs(argomento_finale)

%rappresento il diagramma dei moduli e delle fasi della L finale
figure(3);
margin(L);
grid;
legend;

%rappresento in un solo grafico il diagramma dei moduli e delle fasi della 
%funzione di anello iniziale Lold, della rete correttrice di tipo sella Cll
%e della funzione di anello finale L
figure(4);
margin(Lold);
hold on;
bode(Cll);
margin(L);
legend;
grid;

%% la funzione di trasferimento del sistema retroazionato effettiva
T = feedback(L,1);
T

%rappresento graficamente il diagramma dei moduli della f.d.t. appena 
%ottenuta
figure(5);
bodemag(T);
grid;
legend;

%% il picco di risonanza della funzione di trasferimento del sistema retroazionato effettiva 
PICCO_RISONANZA = mag2db(getPeakGain(T));
PICCO_RISONANZA 

%% la pulsazione di banda passante della funzione di trasferimento del sistema retroazionato effettiva
PULSAZIONE_BANDA_PASSANTE = bandwidth(T);
PULSAZIONE_BANDA_PASSANTE 


%% la funzione di trasferimento del sistema retroazionato ideale
Tridotta = 0.8607/(s^2 + 1.711*s + 0.8607);
Tridotta

%% il picco di risonanza della funzione di trasferimento del sistema retroazionato ideale 
PICCO_RISONANZA = mag2db(getPeakGain(Tridotta));
PICCO_RISONANZA 

%% la pulsazione di banda passante della funzione di trasferimento del sistema retroazionato ideale
PULSAZIONE_BANDA_PASSANTE = bandwidth(Tridotta);
PULSAZIONE_BANDA_PASSANTE 


%%
%rappresento in unico grafico il diagramma dei moduli della funzione di
%trasferimento del sistema retroazionato effettiva T e della f.d.t. ideale
%Tridotta
figure(6);
bodemag(T);
hold on;
bodemag(Tridotta);
grid;
legend;

%rappresento in unico grafico la risposta al gradino della funzione di
%trasferimento del sistema retroazionato effettiva T e della f.d.t. ideale
%Tridotta
figure(7);
step(T);
hold on;
step(Tridotta);
grid;
legend;




