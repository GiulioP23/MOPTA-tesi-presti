# Analisi Dati - Load
Analisi dati della MOPTA competition 2024, "Electricity Load"

// #### Elenco attività

## Considerazioni preliminari
Per analizzare il dataset proposto si può procedere in modo incrementale, partendo dai modelli più semplici e considerando solo alcune delle features, fino ai modelli più complessi. Inizialmente procederò considerando solamente i consumi in funzione del tempo, approccio potenzialmente problematico in quanto diverse location potrebbero avere consumi molto diversi, per via di un diverso modello di consumi (fdp) o per una diversa intensità dei consumi (avendo stessa fdp), o avere una forte dipendenza dal periodo Q.

Successivamente analizzerò i dati per periodo e location

#### Variabilità dei dati rispetto a *Quarter*
Uno dei fattori che più influenzano i consumi è il periodo dell'anno. I consumi in del periodo estivo sono infatti nettamente diversi da quelli del periodo invernale.

![all_residenzial_load_period](/immagini/all_residenzial_load_period.png)

Per ricavare un modello che effettui previsioni accurate in qualunque momento dell'anno è quindi importante avere a disposizione la data in cui sono stati raccolti i dati, e rispettivamente in cui si vogliono prevedere i dati.

Il dataset della competizione tuttavia indica solo il trimestre (Q1, Q2, Q3, Q4) in cui sono stati raccolti i dati.

> This demand data can be considered indicative of a typical demand pattern for the region during that quarter.
> (AIMMS-MOPTA 2024 - "Data")

Si può in un primo momento identificare la variabile Q con dei valori numerici (e.g. 1, 2, 3, 4 misurando il tempo in trimestri) immaginando che i dati siano stati raccolti a intervalli sufficientemente regolari. Per quanto siano disponibili pochi campioni (solo quattro punti per location), è possibile ricavare un modello che tenga conto anche del periodo dell'anno, e permetta di effettuare previsioni per qualunque altro giorno dell'anno.

![all_loc_residential_load_vs_day_and_inst](/immagini/all_loc_residential_load_vs_day_and_inst.png)
*Load vs instance and quarter, all locations.*

Tuttavia l'ipotesi che i dati siano stati raccolti a intervalli regolari potrebbe non essere giustificata.
Confrontando l'andamento dei carichi (load) per ciascuna location al variare del trimestre è possibile vedere notevoli differenze. E.g. per *3_r* gli andamenti nei diversi trimestri sono distribuiti uniformemente. Al contrario per *4_r* Q1 e Q4 sono sovrapponibili, così come Q2 e Q3. Questa somiglianza nell'andamento dei dati suggerisce che siano stati raccolti a breve distanza gli uni dagli altri. 

![3_r_load_by_period](/immagini/3_r_load_by_period.png) ![4_r_load_by_period](/immagini/4_r_load_by_period.png)

Di conseguenza il trimestre potrebbe non essere una stima accurata del giorno ($d=\fraq{4q}{360}$), e la varianza su tale dato andrebbe calcolata sulla base delle informazioni fornite: varianza di una distribuzione uniforme su 91 giorni.


#### Varianza dei dati rispetto a *Instance*
Può essere interessante osservare preliminarmente l'andamento della varianza per le singole isntances, considerando tutti i dati, fermo restando la problematica osservata precedente, ovvero che non è assicurato a priori che location diverse abbiano consumi comparabili.

![all_industrial_load_variance](/immagini/all_industrial_load_variance.png)
*(residential load)*

#### Trasformata di Fourier delle serie temporali


## Fit univariato^1
Come primo approccio alla modellazione dei dati proposti si può procedere considerando unicamente Load vs Instance (l'ora del giorno), ed ignorando le altre informazioni fornite: periodo e location. I dati vengono tuttavia suddivisi tra "zone industriali" e "zone residenziali" dal momento che mostrano proprietà molto diverse.
Naturalmente non sarebbe permesso a priori effettuare tale operazione, dal momento che non vi è garanzia che i dati vengano generati secondo una stessa distribuzione in diversi periodi, e sopratutto in diverse location (a meno di normalizzazione).

// ### k-neighborhood

### Modelli polinomiali
In questa sezione provo a trovare il miglior modello del tipo $y=b_0+b_1 x+b_2 x^2+...$ per il carico (Load) rispetto al tempo (Instance). I valori per`Instance` sono stati rinormalizzati a formato orario, che è più leggibile e riduce i problemi di overflow per modelli di ordine alto.

Per la scelta del modello sono stati utilizzati diversi criteri: *Test F*, *FPE*, *AIC*, *MDL*, *Crossvalidazione k-fold* (con k=2 e 4).

#### Dati industriali
Per quanto riguarda I dati di aree industriali tutti i criteri indicano polinomi di quarto grado, ovvero con 5 parametri, come la scelta migliore, con $MSE=18.2\text{MWh}^2$.
$$y_{ind}(t)=10.95-4.12x+1.20x^2-0.07x^3+0.001x^4$$ 

![all_industrial_f_best_fit](/immagini/all_industrial_f_best_fit.png)

#### Dati residenziali
I dati relativi alle aree residenziali mostrano al contrario notevoli criticità. I diversi criteri suggeriscono modelli di ordine diverso, e tutti modelli di ordine molto elevato: 9 parametri per tutti i criteri eccetto MDL, che indica come migliore un modello a 6 parametri.
Questo non è tuttavia inatteso, dal momento che MDL privilegia modelli più parsimoniosi. E per modelli di ordine alto, con SSR stabile all'aumentare di q, il termine dominante diventa quello di penalizzazione si q, che cresce come $\sim qln(N)/N$.

Vi sono inoltre problemi di identificabilità (rango matrice di sensitività). Di conseguanza è possibile concludere che modelli di tipo polinomiale non siano la miglior classe di modelli per analizzare questi dati.
Valore $MSE=28.7\text{MWh}^2$ nel caso di polinomi con 9 parametri.

![all_residential_f_best_fit](/immagini/all_residential_f_best_fit.png)

Tale risultato non è sorprendente se si considerano le differenze tra le serie di dati disponibili considerando il periodo: i dati relativi a periodi diversi occupano aree chiaramente diverse, contraddicendo l'ipotesi iniziale che i dati vengano generati secondo la stessa distribuzione indipendentemente dal periodo. OSS. questo non è invece vero per i dati delle aree industriali.

![all_residenzial_load_period](/immagini/all_residenzial_load_period.png)

### Serie di Fourier
In questa sezione provo a trovare il miglior modello del tipo 
$$y=b_0+
	b_1sin\left(\dfrac{2\pi}{T}x\right)+b_2cos\left(\dfrac{2\pi}{T}x\right)+
	b_3sin\left(2\dfrac{2\pi}{T}x\right)+b_4cos\left(2\dfrac{2\pi}{T}x\right)+...+
	b_{2k-1}sin\left(k\dfrac{2\pi}{T}x\right)+b_{2k}cos\left(k\dfrac{2\pi}{T}x\right)$$
per il carico (Load) rispetto al tempo (Instance).

Considerata la natura periodica di generazione dei dati (ciclo giornaliero) e la rinormalizzazione dei tempi in ore, qui $T=24$, e non sembrerebbe necessario utilizzare periodi più lunghi di T=24h.


Per la scelta del modello sono stati utilizzati gli stessi criteri considerati in precedenza: *Test F*, *FPE*, *AIC*, *MDL*, *Crossvalidazione k-fold* (con k=2 e 4).


#### Dati residenziali

Nel caso dei dati resideniali tutti i criteri sono concordi nel preferire un modello a 5 parametri, con $MSE=28.9\text{MWh}^2$. I risultati sono abbastanza simili a quelli ottenuti con il modello polinomiale,
ma a fronte di un numero molto minore di parametri, e senza incorrere in problemi di identificabilità.

![all_residential_FvsPoli](/immagini/all_residential_FvsPoli.png)

Può essere interessante considerare le singole armoniche che contribuiscono alla previsione per verificare se è possibile dire qualcosa circa l'*interpretabilità* del modello. 
La figura seguente rappresenta le armoniche sommate a $b_0$ (il parametro costante) e amplificate di un fattore 4 (per migliorarne la visibilità). Viene mantenuta l'ampiezza relativa delle armoniche.

![all_residential_f_components](/immagini/all_residential_f_components.png)

> Nel codice matlab sono state utilizzate nell'ordine $cos$ e $sin$ per ogni armonica, quindi la componente 1 nell'immagine è il $cos(f_0x)$ (con segno meno).

Effettivamente la fondamentale (1) rende conto dell'andamento globale della giornata, con consumi alti durante il giorno, e consumi bassi durante la notte, mentre la componente sinusoidale (2) dell'asimmetria tra attività nella prima metà giornata e nella seconda.

Le componenti successive (3 e 4) constribuiscono a ricostruire i due picchi giornalieri intorno alle 8am e 8pm, probabilmente dovute all'attività domestica dei residenti. 
Può essere interessante notare che le due componenti ricostruiscono una sinusoide sfasata rispetto all'inizio della giornata, e che traslando i dati relativi ai tempi è probabilmente possibile ridurre ulteriormente il numero di parametri necessari.
Sarà poi analogamente interessante verificare se le fondamentale abbia andamento simile anche nelle aree industriali per verificare se esso possa essere considerato di uguale origine, permettendo quindi di interpretare i due casi come: *attività industriale*, per le aree industriali e *attività industriale+attività domestica* per le aree residenziali.

#### Dati industriali
Per quanto riguarda i dati industriali non vi sono particolari miglioramenti rispetto ai modelli polinomiali: viene indicato il modello a 5 parametri con $MSE=18.15\text{MWh}^2$.
Per quanto riguarda l'interpretabilità non sono presenti elementi di interesse eccetto la predominanza della fondamentale (cos) rispetto a tutte le altre componenti ($b_1=-12.14$, $|b_i|<6.1$ per $k>1$).

### Splines

## Fit serie temporali al variare della location (Load vs Instance by Location and Period)
In questa sezione provo a modellare le singole serie temporali disponibili per ogni location.

### Modelli polinomiali

### Serie di Fourier
#### Trasformata di Fourier

### Splines

## Fit serie temporali al variare del periodo (Load vs Instance by Period)

## Fit serie temporali al variare di periodo e location (Load vs Instance and Period by Location)
In questa sezione effettuo la ricerca dei modelli migliori per descrivere le singole serie temporali di ciascuna location.

### Serie di Fourier
Per le serie **residenziali** anche in questo caso i criteri utilizzati indicano concordemente come miglior modelli quelli a 5 parametri.
![3_r_q3_MDL](/immagini/3_r_q3_MDL.png)


Per le serie **industriali** i criteri utilizati suggeriscono modelli di ordine molto elevato (9-13 parametri, 13 massimo numero di parametri considerato), cosa che potrebbe portare a concludere che la serie di Fourier non sia adatta a descrivere tali serie.
La crossvalidazione (4-fold) in questo caso restituisce valori molto diversi anche per la stessa serie e non è molto utile a determinare la complessità del modello.
![1_i_q1_FPE](/immagini/1_i_q1_FPE.png)


^1 Verificare la correttezza del termine