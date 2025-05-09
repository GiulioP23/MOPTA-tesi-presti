# Analisi Dati - Load
Analisi dati della MOPTA competition 2024, "Electricity Load"

// #### Elenco attività

## Considerazioni preliminari
Per analizzare il dataset proposto si può procedere in modo incrementale, partendo dai modelli più semplici e considerando solo alcune delle features, fino ai modelli più complessi. Inizialmente procederò considerando solamente i consumi in funzione del tempo, approccio potenzialmente problematico in quanto diverse location potrebbero avere consumi molto diversi, per via di un diverso modello di consumi (fdp) o per una diversa intensità dei consumi (avendo stessa fdp), o avere una forte dipendenza dal periodo Q.

Successivamente analizzerò i dati per periodo e location

#### Variabilità dei dati rispetto a *Quarter*
Uno dei fattori che più influenzano i consumi è il periodo dell'anno. I consumi del periodo estivo sono infatti nettamente diversi da quelli del periodo invernale.

![all_residenzial_load_period](/immagini/all_residenzial_load_period.png)

Per ricavare un modello che effettui previsioni accurate in qualunque momento dell'anno è quindi importante avere a disposizione la data in cui sono stati raccolti i dati, e rispettivamente in cui si vogliono prevedere i dati.

Il dataset della competizione, tuttavia, indica solo il trimestre (Q1, Q2, Q3, Q4) in cui sono stati raccolti i dati.

> This demand data can be considered indicative of a typical demand pattern for the region during that quarter.
> (AIMMS-MOPTA 2024 - "Data")

Si può in un primo momento identificare la variabile Q con dei valori numerici (e.g. 1, 2, 3, 4 misurando il tempo in trimestri) immaginando che i dati siano stati raccolti a intervalli sufficientemente regolari. Per quanto siano disponibili pochi campioni (solo quattro punti per location), è possibile ricavare un modello che tenga conto anche del periodo dell'anno, e permetta di effettuare previsioni per qualunque altro giorno dell'anno.

![all_loc_residential_load_vs_day_and_inst](/immagini/all_loc_residential_load_vs_day_and_inst.png)
*Load vs instance and quarter, all locations.*

Tuttavia, l'ipotesi che i dati siano stati raccolti a intervalli regolari potrebbe non essere giustificata.
Confrontando l'andamento dei carichi (load) per ciascuna location al variare del trimestre è possibile vedere notevoli differenze. E.g. per *3_r* gli andamenti nei diversi trimestri sono distribuiti uniformemente. Al contrario per *4_r* Q1 e Q4 sono sovrapponibili, così come Q2 e Q3. Questa somiglianza nell'andamento dei dati suggerisce che siano stati raccolti a breve distanza gli uni dagli altri. 

![3_r_load_by_period](/immagini/3_r_load_by_period.png) ![4_r_load_by_period](/immagini/4_r_load_by_period.png)

Di conseguenza il trimestre potrebbe non essere una stima accurata del giorno ($d=\frac{4q}{360}$), e la varianza su tale dato andrebbe calcolata sulla base delle informazioni fornite: varianza di una distribuzione uniforme su 91 giorni.


#### Varianza dei dati rispetto a *Instance*
Può essere interessante osservare preliminarmente l'andamento della varianza per le singole instance, considerando tutti i dati, fermo restando la problematica osservata precedente, ovvero che non è assicurato a priori che location diverse abbiano consumi comparabili.

![all_industrial_load_variance](/immagini/all_industrial_load_variance.png)
*(residential load)*

#### Trasformata di Fourier delle serie temporali

## Modelli single-feature (Instance)
Come primo approccio alla modellazione dei dati proposti si può procedere considerando unicamente Load vs Instance (l'ora del giorno), ed ignorando le altre informazioni fornite: periodo e location. I dati vengono tuttavia suddivisi tra "zone industriali" e "zone residenziali" dal momento che mostrano proprietà molto diverse.
Naturalmente non sarebbe permesso a priori effettuare tale operazione, dal momento che non vi è garanzia che i dati vengano generati secondo una stessa distribuzione in diversi periodi, e soprattutto in diverse location (a meno di normalizzazione).

### Modelli polinomiali
In questa sezione provo a trovare il miglior modello del tipo $y=b_0+b_1 x+b_2 x^2+...$ per il carico (Load) rispetto al tempo (Instance). I valori per`Instance` sono stati rinormalizzati a formato orario, che è più leggibile e riduce i problemi di overflow per modelli di ordine alto.

Per la scelta del modello sono stati utilizzati diversi criteri: *Test F*, *FPE*, *AIC*, *MDL*, *Crossvalidazione k-fold* (con k=2 e 4).

#### Dati industriali
Per quanto riguarda I dati di aree industriali tutti i criteri indicano polinomi di quarto grado, ovvero con 5 parametri, come la scelta migliore, con $MSE=18.2\text{MWh}^2$ e $R^2=0.84$.

$$y_{ind}(t)=10.95-4.12x+1.20x^2-0.07x^3+0.001x^4$$ 

![all_industrial_f_best_fit](/immagini/all_industrial_f_best_fit.png)

#### Dati residenziali
I dati relativi alle aree residenziali mostrano al contrario notevoli criticità. I diversi criteri suggeriscono modelli di ordine diverso, e tutti modelli di ordine molto elevato: 9 parametri per tutti i criteri eccetto MDL, che indica come migliore un modello a 6 parametri.
Questo non è tuttavia inatteso, dal momento che MDL privilegia modelli più parsimoniosi. E per modelli di ordine alto, con SSR stabile all'aumentare di q, il termine dominante diventa quello di penalizzazione si q, che cresce come $\sim qln(N)/N$.

Vi sono inoltre problemi di identificabilità (rango matrice di sensitività). Di conseguenza è possibile concludere che modelli di tipo polinomiale non siano la miglior classe di modelli per analizzare questi dati.
Valore $MSE=28.7\text{MWh}^2$ nel caso di polinomi con 9 parametri, $R^2=0.48$.

![all_residential_f_best_fit](/immagini/all_residential_f_best_fit.png)

Tale risultato non è sorprendente se si considerano le differenze tra le serie di dati disponibili considerando il periodo: i dati relativi a periodi diversi occupano aree chiaramente diverse, contraddicendo l'ipotesi iniziale che i dati vengano generati secondo la stessa distribuzione indipendentemente dal periodo (questo non è invece vero per i dati delle aree industriali).

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

Nel caso dei dati residenziali tutti i criteri sono concordi nel preferire un modello a 5 parametri, con $MSE=28.9\text{MWh}^2$ e $R^2=0.47$. I risultati sono abbastanza simili a quelli ottenuti con il modello polinomiale,
ma a fronte di un numero molto minore di parametri, e senza incorrere in problemi di identificabilità.

![all_residential_FvsPoli](/immagini/all_residential_FvsPoli.png)

Può essere interessante considerare le singole armoniche che contribuiscono alla previsione per verificare se è possibile dire qualcosa circa l'*interpretabilità* del modello. 
La figura seguente rappresenta le armoniche sommate a $b_0$ (il parametro costante) e amplificate di un fattore 4 (per migliorarne la visibilità). Viene mantenuta l'ampiezza relativa delle armoniche.

![all_residential_f_components](/immagini/all_residential_f_components.png)

> Nel codice matlab sono state utilizzate nell'ordine $cos$ e $sin$ per ogni armonica, quindi la componente 1 nell'immagine è il $cos(f_0x)$ (con segno meno).

Effettivamente la fondamentale (1) rende conto dell'andamento globale della giornata, con consumi alti durante il giorno, e consumi bassi durante la notte, mentre la componente sinusoidale (2) dell'asimmetria tra attività nella prima metà giornata e nella seconda.

Le componenti successive (3 e 4) contribuiscono a ricostruire i due picchi giornalieri intorno alle 8am e 8pm, probabilmente dovute all'attività domestica dei residenti. 
Può essere interessante notare che le due componenti ricostruiscono una sinusoide sfasata rispetto all'inizio della giornata, e che traslando i dati relativi ai tempi è probabilmente possibile ridurre ulteriormente il numero di parametri necessari.
Sarà poi analogamente interessante verificare se le fondamentale abbia andamento simile anche nelle aree industriali per verificare se esso possa essere considerato di uguale origine, permettendo quindi di interpretare i due casi come: *attività industriale*, per le aree industriali e *attività industriale+attività domestica* per le aree residenziali.

#### Dati industriali
Per quanto riguarda i dati industriali vengono indicati modelli di ordine più alto, 7-13 parametri, con $MSE=14.9\text{MWh}^2$ e $R^2=0.87$ (valori per un modello a 9 parametri selezionato con FPE).
Per quanto riguarda l'interpretabilità non sono presenti elementi di interesse eccetto la predominanza della fondamentale (cos) rispetto a tutte le altre componenti ($b_1=-12.14$, $|b_i|<6.1$ per $k>1$).

### Risultati
Con questo primo approccio non ci si attendevano risultati eccellenti, ed effettivamente sono emerse diverse criticità: problemi di identificabilità (rango matrice di verosimiglianza), bontà del fit limitata (in molti casi $R^2\sim 0.5$), bias nelle previsioni per *Quarter* (valori sovrastimati per il periodo invernale, e sottostimati per il periodo estivo).
Inoltre i modelli polinomiali si sono mostrati più adatti (ordine basso) alla modellazione del problema per i dati industriali, mentre la serie di Fourier è risultata migliore per la modellazione del problema per i dati residenziali. 
Questi risultati possono essere schematizzati nella figura seguente:

| 			| Residential Data | Industrial Data |
|-----------|-----------|-----------|
|  Fourier |![all_residential_fourier_plotregression](/immagini/all_residential_fourier_plotregression.png)| ![all_industrial_fourier_plotregression](/immagini/all_industrial_fourier_plotregression.png)| 
| Polinomials | ![all_residential_poli_plotregression](/immagini/all_residential_poli_plotregression.png)| ![all_industrial_poli_plotregression](/immagini/all_industrial_poli_plotregression.png)| 


-- #### Trasformata di Fourier

## Fit serie temporali al variare del periodo (Load vs Instance and Quarter)
I risultati non ottimali emersi con l'approccio fin qui adottato suggeriscono di provare ad utilizzare modelli più ricchi e flessibili sfruttando le features disponibili fin qui ignorate (Quarter e Location).

### Modello additivo: c(d)+f(h)
Osservando il grafico che mostra Load vs Instance con colori diversi per Quarter è possibile vedere che i valori (per diversi trimestri) appaiono sovrapponibili 
a meno di una costante. Un primo approccio può quindi essere quello di provare ad identificare modelli ottenuti come una funzione $f_i(h)$ che descrive l'andamento giornaliero del carico (Load) a cui viene sommata una costante il cui valore dipende dal giorno dell'anno $c(d)$.

$$y=f_i(h)+c(d)$$

Essendo disponibili pochi punti in Quarter non ha senso utilizzare modelli troppo complessi per descrivere c(t), mentre ci attendiamo che $f_i(h)$ abbia un andamento simile a quello identificato in precedenza. Ci attendiamo naturalmente anche di ottenere risultati complessivamente migliori rispetto a prima.

Per identificare i modelli sono stati utlizzati i seguenti approci di feature selection: lasso, backward stepwise selection, forward stepwise selection, utilizzando diversi criteri (adjusted R2, BIC, AIC).
Per $c(d)$ si sono provate serie di Fourier ($T=365\text{d}$) e polinomi di ordine basso (1°, 2°).

#### Dati residenziali
Utilizzando una serie di Fourier al primo ordine per modellizare $c(d)$ ed una serie di Fourier fino al 10° ordine per $f_i(h)$ si sono ottenuti modelli a 12-20 parametri, fino al 8-9° ordine in Instance, con $MSE=10.2\text{MWh}^2$ e $R^2=0.81$.

![all_residential_load_lasso_const_f](/immagini/all_residential_load_lasso_const_f.png)
![all_residential_load_lasso_const_f_plotregression](/immagini/all_residential_load_lasso_const_f_plotregression.png)

Come si può vedere i risultati mostrati nel grafico "plotregression" non sono ottimali, specialmente nella zona di produzione bassa (sx). Effettivamente per questi valori i carichi (Load) per diversi periodi e location si sovrappongono (grafico iniziale), contrariamente alle ipotesi di modello additivo in $d$ e $h$.

Utilizzando invece un polinomio per modellizzare $c(d)$ si sono ottenuti risultati simili con $MSE=10.05\text{MWh}^2$ e $R^2=0.82$.

![all_residential_load_lasso_const_p](/immagini/all_residential_load_lasso_const_p.png)

Volendo rappresentare separatamente $c(d)$ si ottengono le seguenti funzioni, dove è forse preferibile il primo approccio (fourier) per una migliore interpretabilità ed estensibilità del modello.

![all_residential_load_lasso_const_both](/immagini/all_residential_load_lasso_const_both.png)

#### Dati industriali
Per i dati industriali si ottengono risultati leggermente migliori e più parsimoniosi (10-11 parametri), con $MSE=11.42\text{MWh}^2$ e $R^2=0.89$.

![all_industrial_load_back_const_f](/immagini/all_industrial_load_back_const_f.png)
![all_industrial_load_back_const_f_plotregression](/immagini/all_industrial_load_back_const_f_plotregression.png)

Risultati ancora migliori (leggermente) per modelli con c polinomiale, con $MSE=11.04\text{MWh}^2$ e $R^2=0.90$.

Il confronto tra i due risultati per c(d) è il seguente:
![all_industrial_load_lasso_const_both](/immagini/all_industrial_load_lasso_const_both.png)

Può essere interessante verificare se i due modelli per $c(d)$ siano comparabili:

$$c_{ind}(d)=k_i+2.7\cdot \cos\left(\frac{2\pi}{T}d\right)-0.3\cdot\sin\left(\frac{2\pi}{T}d\right)$$

$$c_{res}(d)=k_r+4.7\cdot \cos\left(\frac{2\pi}{T}d\right)-3.4\cdot\sin\left(\frac{2\pi}{T}d\right)$$

che non permette di trarre conclusioni di particolare rilevanti.

### Modello biperiodico
Per ovviare alle problematiche evidenziate nel paragrafo precedente è opportuno aumentare la complessità del modello. Invece di considerare un semplice modello somma di una parte in $d$ (Quarter) ed una in $h$ (Instance) si può utilizzare una serie di Fourier bidimensionale, che quindi prende in considerazione anche tutti i termini di interazione del tipo $\sin(k_Q d)\cdot\cos(k_I h)$.

Per la serie di Fourier si sono utilizzati periodi doppi rispetto a quelli attesi, ovvero 48h per Instance e 730d per Quarter, per tenere conto delle non-periodicità eventualmente presenti (legate ad esempio ad un trend pluriannuale).
Per quanto riguarda la complessità massima considerata si è utilizzato un modello fino al 4° ordine in Instance, e fino al 2° in Quarter e analogamente per i termini di interazione (fino al 2° ordine per quelli misti).
Per scegliere i predittori più opportuni si sono utilizzati i metodi indicati in precedenza: lasso shrinkage, stepwise selection.

#### Dati residenziali
Per i dati residenziali si sono ottenuti modelli a 18 parametri con $MSE=8.72\text{MWh}^2$ e $R^2=0.84$ (lasso selected).
Inoltre in questo caso le previsioni sono distribuite più uniformemente rispetto al target (grafico previsione vs target).

![all_residential_load_forw_plotregression](/immagini/all_residential_load_forw_plotregression.png)

#### Dati industriali
Per i dati industriali invece si sono ottenuti modelli di ordine più elevato (11-35 parametri) con $MSE=9.91\text{MWh}^2$ e $R^2=0.91$ (forward stepwise, 11 params).
Inoltre in questo caso le previsioni sono distribuite più uniformemente rispetto al target (grafico previsione vs target).

![all_industrial_load_forw_plotregression](/immagini/all_industrial_load_forw_plotregression.png)

## Fit serie temporali al variare della location (Load vs Instance and Quarter by Location)
Dividendo infine il dataset per Location si riduce ulteriormente l'errore sulle previsioni. Diventa tuttavia più difficoltosa la validazione.
- Per i dati _industriali_ si sono ottenuti modelli di flessibilità molto variabile a seconda dei criteri utilizzati (18-40 parametri), con $MSE=1.5\text{MWh}^2$ e $R^2=0.98$.

![period_industrial_load_forw_f](/immagini/period_industrial_load_forw_f.png)
![period_industrial_load_forw_plotregression](/immagini/period_industrial_load_forw_plotregression.png)

- Per i dati _residenziali_ si sono ottenuti modelli a 27-30 parametri, con $MSE=3.0\text{MWh}^2$ e $R^2=0.92$ (17 params, forward stepwise, 1_r).

## Fit serie temporali al variare di periodo e location (Load vs Instance by Location and Quarter)
In questa sezione effettuo la ricerca dei modelli migliori per descrivere le singole serie temporali di ciascuna location.

### Serie di Fourier
Per le serie **residenziali** anche in questo caso i criteri utilizzati indicano concordemente come miglior modelli quelli a 5 parametri con $R^2\sim 0.9$.
![3_r_q3_MDL_fourier](/immagini/3_r_q3_MDL_fourier.png)


Per le serie **industriali** i criteri utilizzati suggeriscono modelli di ordine molto elevato (9-13 parametri), cosa che potrebbe portare a concludere che la serie di Fourier non sia adatta a descrivere tali dati.
La crossvalidazione (4-fold) in questo caso restituisce valori molto diversi anche per la stessa serie e non è molto utile a determinare la complessità del modello.
![1_i_q1_FPE_fourier](/immagini/1_i_q1_FPE_fourier.png)

### Modelli polinomiali
Utilizzando i modelli polinomiali si ottengono risultati opposti ai precedenti: per le serie relative alle aree industriali tutti i criteri indicano modelli a 5 parametri come ottimali con $MSE=5.47\text{MWh}^2$ e $R^2=0.95$.

![2_i_q2_MDL_poli](/immagini/2_i_q2_MDL_poli.png)

Analogamente, per le aree residenziali diversi criteri indicano diversi modelli, spesso o molto complessi (9-param) o molto semplici (3 param), cosa che conferma l'ipotesi formulata inizialmente che i modelli polinomiali non siano adatti a descrivere le serie delle aree residenziali. Per AIC (Q2, 2r) si ottiene $MSE=1.8\text{MWh}^2$ e $R^2=0.9$.

*Ordine del modello polinomiale ottimale secondo il Final Prediction Error (FPE) per 2_r.*

| Quarter | Ordine | 
|:-----: |:------: |
|    Q1 |     2 | 
|    Q2 |     9 | 
|    Q3 |     2 | 
|    Q4 |     7 | 

![2_r_q1_FPE_poli](/immagini/2_r_q1_FPE_poli.png)

![2_r_q2_FPE_poli](/immagini/2_r_q2_FPE_poli.png)


### Risultati
Analizzando le singole serie individualmente per *Quarter* e *Location* si riescono ad ottenere buoni risultati (laddove l'ordine del modello non venga chiaramente sottostimato), con $R^2\sim 0.9$.

| Location | Period | Model | N-params (FPE)| $R^2$ |
|:-----:|:-----:|:-----:|:-----:|:-----:|
|    1_i |    Q1 |     Fourier |      13 |     0.9907 |
|    2_i |     Q2 |     Poli |      5 |     0.9464 |
|    1_r |     Q3 |     Fourier |      5 |     0.8752 |
|    2_r |     Q2 |     Poli |      10 |     0.9035 |

![2_r_q2_poli_plotregression](/immagini/2_r_q2_poli_plotregression.png)

^1 Verificare la correttezza del termine
