'=======================================
' Econometría de Series de Tiempo
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' 	Modelo de regresión dinámico
'=======================================
'
' La clase pasada discutimos cómo lidiar con algunas dificultades 
' que nos puede presentar la estimación de un modelo de regrresión lineal:
'	- No normalidad de residuos
'	- Matriz de varianzas y covarianzas no escalar (Heteroscedasticidad y Autocorrelación de residuos)
'	- Errores de especificación (e.g. quiebres estructurales)
'
' En esta clase vamos a ver cómo incluir la dinámica en el modelo.
' 
' En concreto, vamos a trabajar con los modelos autorregresivos de de rezagos distribuidos ARDL. 
' Para el caso del modelo ARDL (1,1) tenemos:
'
'		----------------------------------------------------------------------
'					y ~ b0 + b1 x + b2 x(-1) + a1 y(-1)
'		----------------------------------------------------------------------
'
'	Tiene como casos particulares:
'		1.  Modelo estático: b2 = a1 = 0
'		2.  Modelo Ar(1): b1 = b2 = 0
'		3.  Random Walk:  b1 = b2 = 0 | a1=1
'		4.  1st Diff Model: b1 = -b2  | a1=1
'		5.  Leading Indicator: a1 = b1 = 0
'		6.  DL: a1 = 0
'		7.  GDL (geometric distributed lags) bi =b (w^i L^i) [i>1]
'		8.  Partial Adjustment: b2=0 (ajusta y al equilibrio)
'		9.  ECM: b1+b2+a1=1
'		10. OLS con autocorrelación: a1b1+b2 = 0
'
' Vamos a seguir trabajando con el modelo con datos simulados con los que venimos trabajando las últimas clases.
' 
' 
'
'---------------------------------------
'		 Actividades
'======================
'
'
'
'	> Estimar 
'		M1: modelo estático y ~ x
'		M2: modelo estático con dummies y ~ d + x + dx
'		M3: leading indicator model  y ~ x(-1)
'		M4: ARDL (3,3)
'		M5: ARDL trimming GridSearch (AIC | SBC| HQ)
'		M6: ARDL trimming LASSO - ver gráfico
'		M7: ARDL(1,1) con quiebre estructural


'	> Hacer el diagnóstico de la especificación ARDL escogida (M5)
'		Multicolinealidad (VIF - Conf_elipses)
'		Normalidad (JB - Q-Q)
'		Autocorrelación (BG, DW)
'		Heteroscedasticidad (BPG)
'		Errores de especificación de forma funcional (RESET)

'	> Forecasting y evaluación de performance out-of-sample
'		De todos los modelos estimados

'---------------------------------------
'		 Figuras y tablas
'======================

'	> Figuras
'	  -----------

'		_scatter:
'			Scatterplot X e Y con linefit() modelo estático

'		M5_3_GridSearch
'			Gráfico de Model Selection Criteria (AIC) Modelos ARDL (M5)

'		M5_4_cellipse
'			Elipses de confianza estimadores modelo M5

'		M5_6_hist
'			Histograma y estadísticas descriptivas- Modelo ARDL

'		fanchart
'			Modelo ARDL "óptimo"


'	> Tablas
'	  -----------
'		M5_1_Output
'			Estimation output modelo M5

'		M5_2_GridSearch
'			Barplot estadísticos AIC de la selección del lag modelo ARDL (M5)

'		M5_5_VIF
'			Factores Infladores de varianza 

'		M5_7_auto
'			Breusch-Godfrey (BG) Serial Correlation LM Test

'		M5_8a_het_white
'			Salida contraste de heteroscedasticidad de White

'		M5_8b_het_bpg
'			Salida contraste de heteroscedasticidad de Breusch-Pagan-Godfrey LR test

'		MODEL_COMP
'			Custom table con comparación de performance modelo in-sample y put-of-sample


'======================
' 		Preliminares
'======================

'Fijar el directorio de trabajo 
%runpath = @runpath
cd %runpath

include ./tools.prg
'======================
' 		Simular los datos
'======================

exec ./simulate_data.prg
'open ./simulate_data.prg 


'----------------------------------------
' train_test_split (coldstart=100)
'-----------------------------------------

sample train 101 300
sample test 301 @last
sample fanchart_plot 290 320

smpl train

'---------------------------------------
'		Estimar modelos 
'======================
equation eq_M1.ls y c x								' Modelo estático - M1
equation eq_M2.ls y c dummy x dummy*x			' c/ quiebre estructural - M2
equation eq_M3.ls y c x(-1)							' Leading indicator - M3
equation eq_M4.ls y c x x(-1 to -3) y(-1 to -3)		 ' ARDL(3,3) - M4
equation eq_M5.ardl(deplags=3, reglags=3) y x	' c/automatic lag selection- M5
equation eq_M6.enet y c x x(-1 to -3) y(-1 to -3)	' LASSO shrinkage - M6
equation eq_M7.ls y c x x(-1) y(-1) _
dummy dummy*x(-1) 									'ARDL(1,1) c/ str. break - M7


eq_m1.displayname Estatico
eq_m2.displayname c/dummies
eq_m3.displayname Leading indic.
eq_m4.displayname ARDL(3,3)
eq_m5.displayname ARDL auto_lag
eq_m6.displayname LASSO
eq_m7.displayname ARDL c/dummies


'---------------------------------------
' 		Diagnóstico ARDL(1,1)
'======================


freeze(_scatter) xy.scat linefit()
_scatter.setelem(2) axis(r)
_scatter.addtext(t) Scatterplot X e Y



freeze(M5_1_output) eq_M5' Model Output
freeze(M5_2_GridSearch)eq_m5.ictable	'Model Selection Criteria
freeze(M5_3_GridSearch) eq_m5.icgraph 'Plot de métricas AIC


'	 Multicolinealidad
'--------------------------
freeze(M5_4_cellipse) eq_m5.cellipse
M5_4_cellipse.addtext(t) Elispses de confianza

freeze(M5_5_VIF) eq_m5.varinf


'Histograma residuos
'-------------------

freeze(M5_6_hist) eq_m5.hist
M5_6_hist.addtext(t) Histograma de residuos - ARDL(1,1)


' Autocorrelación
' -------------------
freeze(m5_7_auto) eq_m5.auto(2)

' Agregar DW statistic
m5_7_auto(7,1) = " DW statistic -------->"
m5_7_auto(7,2) = eq_M5.@DW


' Heteroscedasticidad
' -------------------
freeze(m5_8a_het_white) eq_m5.white
freeze(m5_8b_het_BPG) eq_m5.hettest @regs




'---------------------------------------
'		Forecasting
'======================

%table_name = "Model_comp"
%models_list = @wlookup("eq*", "equation")

call model_comparison(%models_list, "test", %table_name)


smpl test
eq_m5.forecast yf yf_se
smpl fanchart_plot
call fanchart(y, yf, yf_se, "Fanchart_M5")

smpl test
eq_m3.forecast yf3 yf3_se
smpl fanchart_plot
call fanchart(y, yf3, yf3_se, "Fanchart_M3")

graph comp_fancharts.merge fanchart_m5 fanchart_m3
comp_fancharts.align(2,1,1)
comp_fancharts.addtext(t) Comparacion de Fancharts


'freeze(lasso_sel) eq_m6.coefevol 'CRASHES: hacer manualmente
'lasso_sel.axis(b) log range(0,1.2)


