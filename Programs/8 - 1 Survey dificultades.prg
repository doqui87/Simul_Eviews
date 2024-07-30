'=======================================
' Econometría de Series de Tiempo
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' 	Survey dificultades con linear regression
'=======================================
'
'
'
' La clase pasada consideramos el modelo de regresión lineal estático
'	Lo estimamos por MCO | OLS
'	Evaluamos su bondad de ajuste (y otras medidas de información)
'	Hicimos algunos contrastes de hipótesis sencillas
'
' En esta clase vamos a ver concentrarnos en contrastar errores de especificación y otros problemas relacionados.

'---------------------------------------
'		 Actividades
'======================

'	> Estimar modelo estático 

'	> Normalidad: 
'		Contraste Jarque-bera
'		
'	> Heteroscedasticidad
'		White

'		Breusch-Pagan-Godfrey

'	> Autocorrelación
'		Durbin-Watson

'		Breusch-Godfrey LM

'	> Inestabilidad paramétrica
'		Mínimos cuadrados recursivos (animar rolling_group)

'		Chow: 
'			Varios break_dates
'			Exógeno y endógenos

'		Dummy variables
'			Testear beta_hat = true_beta

'	> Forecasting
'		Forecastear la ecuación con dummies
		'Comparar MSFE y MAFE de ambos modelos



'---------------------------------------
'		 Figuras y tablas
'======================

'	> Figuras
'	  -----------

'	Fig1:
'		Histograma y estadísticas descriptivas- Modelo estatico

'	Fig2:
'		Mínimos cuadrados Recursivos
'			FIg2A: Lineplot
'			Fig2B: XYline
		

'	> Tablas
'	  -----------
'	Tabla1:
'		Heteroscedasticidad - White

'	Tabla1:
'		Heteroscedasticidad Breush-Pagan

'	Tabla3:
'		Autocorrelación: Breusch-Godfrey LM Test 

' 	Static_chow_test
'		Test de Chow para selected break dates

'	Forecast_eval
'		MSPE y MAFE de Modelo1 (estático) y Modelo2 (w/dummy)
		

'======================
' 		Preliminares
'======================

'Fijar el directorio de trabajo 
%runpath = @runpath
cd %runpath


'======================
' Simular los datos
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




'======================
' 		Actividades
'======================


'	> Estimar modelo estático
'-----------------------------------------
equation eq_static.ls y c x

 
'	> Normalidad: 
'-----------------------------------------
'		Contraste Jarque-bera
freeze(fig1_hist_resids) resid.hist
fig1_hist_resids.addtext(t) Histograma y estadísticas descriptivas\nModelo estatico


'		
'	> Heteroscedasticidad
'-----------------------------------------

'		White
freeze(tabla1_white) eq_static.hettest(type=white, c)

'		Breusch-Pagan-Godfrey
freeze(tabla2_breush_pagan) eq_static.hettest(type=BPG) @regs


'	> Autocorrelación (Test LM)
'-----------------------------------------

'		Breusch-Godfrey Autocorrelation
freeze(tabla3_breush_godfrey) eq_static.auto(2)


'------------------------------------------
'	> Inestabilidad paramétrica
'=======================


' Mínimos Cuadrados Recursivos
'--------------------------------------------

'Estimar y freezar la vista de rolling coeficients
' Guarda rolling coefficients como R_c1 y R_c2
freeze(Fig2a_RLS) eq_static.rls(c,s,q)
delete r_c1se r_c2se

' Armar grupo con los rolling coeficients
group rolling_group R_c1 R_c2
graph fig2b_rollingline.xyline rolling_group
fig2b_rollingline.addtext(t) Trayectoria de Rolling Least Squares


'		Chow
'-------------------
spool static_chow_tests

%test_breaks = "150 200 250"
for %date {%test_breaks}
	freeze(_temp) eq_static.chow {%date}
	static_chow_tests.append(name=break_in_{%date}) _temp
	delete _temp
next


' Bai-Perron 
'--------------
' Estimar también endógenamente el # breaks con (BIC info criteria)
equation endo_breaks.breakls(method=globinfo) y c x

freeze(Tabla4_Bai_Perron) endo_breaks



'-------------------------------
'		Dummy variable
'=================

' Crear modelo de regresion
equation eq_dummy.ls y c x dummy dummy*x


' Testear beta_hat = true_beta
freeze(Tabla4_estimates_eq_true) eq_dummy.wald c(1)=1, c(2)=1, c(3)=1, c(4)=1



'-------------------------------
'		Forecasting
'=================

'Fijar muestra out-of-sample
smpl test

'Forecastear
eq_static.forecast(ga) y1f y1f_sd
eq_dummy.forecast(ga)  y2f y2f_sd

' Calcular métricas
!MSFE1 = @rmse(y, y1f)
!MAFE1 = @mae(y, y1f)

!MSFE2 = @rmse(y, y2f)
!MAFE2 = @mae(y, y2f)

'Construir tabla
table(4,3) Forecast_eval

Forecast_eval(1,2) = "Forecast evaluation"


Forecast_eval(2,2) = "Static"
Forecast_eval(2,3) = "w/Dummy"


Forecast_eval(3,1) = "MSFE"
Forecast_eval(3,2) = !MSFE1
Forecast_eval(3,3) = !MSFE2

Forecast_eval(4,1) = "MAFE"
Forecast_eval(4,2) = !MAFE1
Forecast_eval(4,3) = !MAFE2

'------------------------------------------
'	> Inestabilidad paramétrica
'=======================

smpl fanchart_plot

include ./tools.prg

call fanchart(y, y1f, y1f_sd, "fig3a")
fig3a.addtext(t) Fanchart Modelo Estatico


call fanchart(y, y2f, y2f_sd, "fig3b")
fig3b.addtext(t) Fanchart Modelo con dummies

graph fig3.merge fig3a fig3b
