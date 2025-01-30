# Analisi Dati - Solar
Analisi dati della MOPTA competition 2024, "Solar"

## Considerazioni preliminari
Il dataset è composto da 384 rilevamenti effettuati in 4 giornate distribuite nei 4 trimestri dell'anno. Per ciascun rilevamento sono disponibili:
- *Generation* l'energia (MWh) prodotta dai pannelli solari in momento della giornata.
- *Instance* l'orario in cui è stata prodotta l'energia (96 instance di 15 minuti in ogni giornata).
- *Quarter* il trimestre a cui appartiene la giornata in cui sono stati raccolti i dati.

Informazioni aggiuntive:
- Solar electricity generation depends on meteorological conditions, thus the 'production' of electricity at these nodes is a function of solar irradiance for solar PVs.
- The electricity supply from solar PV is dependent on meteorological conditions.
- Electricity generation data is provided for a quarterly 'average' day in the region for a single solar PV unit.

### Variabilità dei dati rispetto a *Quarter*
Uno dei fattori che più influenzano la produzione di energia elettrica è il periodo dell'anno. La produzione di energia nel periodo estivo circa doppia rispetto a quella del periodo invernale.

![al_by_period](/immagini/solar/all_by_period.png)

Per ricavare un modello che effettui previsioni accurate in qualunque momento dell'anno è quindi importante avere a disposizione il giorno in cui sono stati raccolti i dati e, rispettivamente, in cui si vogliono fare previsioni.

Il dataset della competizione, tuttavia, indica solo il trimestre (Q1, Q2, Q3, Q4) in cui sono stati raccolti i dati.

> Electricity generation data is provided for a quarterly 'average' day in the region for a single solar PV unit.
> (AIMMS-MOPTA 2024 - "Data")

Si può in un primo momento identificare la variabile Q con dei valori numerici (e.g. 1, 2, 3, 4 misurando il tempo in trimestri) immaginando che i dati siano stati raccolti a intervalli sufficientemente regolari. Per quanto siano disponibili pochi campioni (solo quattro punti per location), è possibile ricavare un modello che tenga conto anche del periodo dell'anno, e permetta di effettuare previsioni per qualunque altro giorno dell'anno.

![all_3d](/immagini/solar/all_3d.png)
*Generation vs instance and quarter, all locations.*

Naturalmente non vi è garanzia che le serie giornaliere siano state raccolte a intervalli regolari, ovvero a tre mesi di distanza le une dalle altre. è tuttavia disponibile un'informazione aggiuntiva nel caso dei dati solari: la produzione di energia è dipendente dall'irraggiamento che, in linea di principio (salvo disturbi meteo) dipende dall'ora della giornata e dal periodo dell'anno. In particolare la lunghezza delle giornate (periodo di irraggiamento positivo) varia secondo una nota legge.

è facile verificare che le lunghezze delle giornate selezionate sono in prima approssimazione:
- Quarter: Q1: 8.75h
- Quarter: Q2: 12.75h
- Quarter: Q3: 14.75h
- Quarter: Q4: 12.75h

Il fatto che le durate delle giornate per i giorni in Q2 e Q4 siano uguali suggerisce che siano effettivamente stati selezionati due giorni a 6 mesi di distanza.
Inoltre l'andamento della durate delle giornate permette di concludere che il luogo in cui sono state effettuate le misure si trova nell'emisfero boreale.

### Andamento Instance vs Quarter
Per quanto riguarda la possibilità di individuare un modello apprioriato anche per $G(d)$ (*generation* vs *day*), e successivamente $G(i, d)$ si incontrano diversi problemi.
- I dati disponibili per ciascun *Instance* sono solo quattro. Risulta pertanto difficile immaginare di identificare modelli particolarmente complessi.
- Diverse *Isntance* hanno andamento diverso:
  - per offset
  - per intercetta con l'asse delle ascisse

![isnt_gen_by_quarter](/immagini/solar/isnt_gen_by_quarter.png)

Nonostante non ci si potesse attendere che l'andamento rispetto a *Quarter* fosse il medesimo per diverse *Instance* le caratteristiche individuate sopra potrebbero rendere l'individuazione di un modello con due variabili non semplice.

### Trasformata di Fourier
La trasformata di Fourier effettuata con i tutti i dati, per ogni serie temporale, non evidenzia particolari di interesse. Risulta soltanto un picco per frequenza nulla, conseguenza del fatto che l'integrale del segnale è diverso da zero (essendo esso strettamente positivo).

![all_fft_by_period](/immagini/solar/all_fft_by_period.png)


## Identificazione modelli sulle serie giornaliere
Inizialmente procedo provando ad identificare un modello polinomiale utilizzando tutti i dati disponibili nelle serie giornaliere.

### Modello polinomiale
I diversi criteri utilizzati (test F, AIC, FPE, MDL, Crossvalidazione 4-fold) indicano, con sostanziale accordo, modelli di ordine elevato per tutti i trimestri: 8 per *Q2*, 6 per *Q3*, 7-8 per *Q4*.

![q2_FPE_poli](/immagini/solar/q2_FPE_poli.png)

Interessante è il caso di Q1, dove tutti i criteri suggeriscono un modello di ordine 0 (constante), a eccezione della crossvalidazione che invece indica un modello a 10 parametri.

Modello migliore (test F) per *Q2*:
| Ordine | MSE |
|:----------: |:----------: |
| 8 | 3.60e-07 |

| $\theta$ | $\sigma$ | 
|:----------: |:----------: |
| -2.64e-04 | 6.09e-04 | 
| 5.14e-04 | 8.79e-04 | 
| -1.72e-04 | 4.10e-04 | 
| -1.10e-05 | 8.60e-05 | 
| 8.87e-06 | 9.31e-06 | 
| -9.22e-07 | 5.40e-07 | 
| 3.61e-08 | 1.59e-08 | 
| -4.91e-10 | 1.87e-10 | 

### Serie di Fourier
I  citeri utilizzati indicano modelli di ordine elevato per tutti i trimestri: 7-11 param per *Q1*, 7-13 per *Q2*, 3-7 per *Q3*, 5-9 per *Q4*. 

![q1_MDL_fourier](/immagini/solar/q1_MDL_fourier.png)

E del resto si può vedere che molte delle componenti sono necessarie a ricostruire il segnale dove il segnale è nullo. <!-- rivedi -->

![q1_components_fourier](/immagini/solar/q1_components_fourier.png)

Modello migliore (test F) per *Q1*:
| Parametri | MSE |
|:----------: |:----------: |
| 11 | 7.40e-08 |

| $\theta$ | $\sigma$ | 
|:----------: |:----------: |
| 9.58e-04 | 2.95e-05 | 
| -1.54e-03 | 4.17e-05 | 
| -6.70e-04 | 4.17e-05 | 
| 7.73e-04 | 4.17e-05 | 
| 8.00e-04 | 4.17e-05 | 
| -2.09e-04 | 4.17e-05 | 
| -4.38e-04 | 4.17e-05 | 
| 7.14e-05 | 4.17e-05 | 
| 5.67e-05 | 4.17e-05 | 
| -1.05e-04 | 4.17e-05 | 
| 4.88e-05 | 4.17e-05 | 

// ### Not null
// Eliminazione dei dati nulli, per identificare il modello solamente sui valori positivi di generazione. 

//In questo caso costruisco la matrice di sensitività applicando la funzione *parte positiva* ai termini della funzione di regressione. L'obiettivo è quello di ridurre la complessità del modello, sfruttando il fatto che l'informazione presente laddove non vi è generazione di energia (dovuta al fatto che il sole non è ancora sorto) può essere in realtà rappresentata più semplicemente dalla funzione menzionata. In effetti per tutte le instances prima del sorgere del sole è naturale attendersi che l'energia prodotta sia nulla.  <!-- vedi anche come P(Generazione | Sole) con P(Generazione|not Sole)=0-->

// Tale approccio richiede però un algoritmo di ottimizzazione vincolata.

// è anche possibile utilizzare delle splines con 3 nodi, ottenendo modelli notevolmente più semplici: 4 parametri, nel caso della serie di Fourier, 2 due nel caso polinomiale. <!-- definizione corretta di spline, formalmente qui il terzo segmento non è ottenuto come spline -->

// ![q1_3k_spline_fourier_FPE](/immagini/solar/q1_3k_spline_fourier_FPE.png)
// *Serie di Fourier vincolata*

// ![q1_3k_spline_poli_FPE](/immagini/solar/q1_3k_spline_poli_FPE.png) <!-- da discutere--> 
// *Serie regressione lineare con vincolo nell'origine f(0)=0*

## Identificazione modello 3D
Come visto nelle serie giornaliere identificare un modello che approssimi soddisfacientemente tutti i dati forniti obbliga a ricorrere a modelli di ordine elevato. Nel caso bidimensionale il problema diventa ancora più significativo, dal momento che bisogna tenere conto dei termini di interazione.
Effettivamente diversi tentativi in tal senso non hanno prodotto risultati apprezzabili, nonostante si siano utilizzati dei modelli molto flessibili (primo ordine, secondo ordine con termini di interazione, ordini successivi fino al 6° per *Quarter*, 11° per *Instance* senza interazione).

In questi tentativi si è utilizzato come periodo quello noto, ovvero $T_y=365$ (periodo per *Quarter*) e $T_d=24$ (periodo per *Instance*), ottenendo un modello a 9 parametri (dopo aver effettuato una regolarizzazione) con $MSE=1.9\cdot10^{-6}MWh^2$.

Risultati leggermente migliori sono stati ottenuti utilizzando un periodo doppio (per entrambe le grandezze) ottenendo un modello a 14 parametri con $MSE=8.7\cdot10^{-7}MWh^2$, e incrementando la complessità massima del modello (serie completa fino al 4° ordine, circa 50 params).
Tuttavia si notano considerevoli criticità in questi casi per la predizione nei *Quarter* per cui non si dispone di dati. In questi casi i modelli per *Generation* tendono a prevedere ampiezze crescenti, mentre dovrebbero restituire un valore nullo.




Sembrerebbero esserci problemi legati in particolar modo alla gestione delle aree in cui la funzione è nulla.


In tal caso procedo con l'identificazione sui soli valori di generazione positivi, applicando poi la funzione parte positiva per le previsioni sull'intera giornata.
### Modello polinomiale G(h, p)
Per selezionare il polinomio più adatto è stato utilizzato Lasso con $\lambda=4.69\cdot10^{-5}$ (scelto come index1SE).


### Modello polinomiale

### Serie di Fourier
