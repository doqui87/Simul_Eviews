'=======================================
' Econometría de Series de Tiempo
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' 	Modelo Lineal Estático
'=======================================
'
' En este programa trabajamos con los datos simulados que nos van acompañar durante las próximas clases. 
'
' Son datos de un un modelo autorregresivo de rezagos distribuidos de primer orden con un quiebre estructural ARDL (1,1). Pero nosotros vamos a estimar un modelo de regresión lineal estático.
'
'Es decir:
'	los datos vienen de un modelo dinámico relativamente complejo 
'	pero nosotros vamos a estimar uno estático
'
'Esto nos va a poder permitir hacer el diagnóstico del modelo y refinar sucesivamente el análisis a medida que avanzamos con los temas del curso.


'======================
' Actividades
'======================

' 1. Hacer los lineplots de X e Y (var exógena y endógena, resp.)

' 2. Hacer el scatterplot

' 3. Estimar la regresión estática
'		y ~ c x

' 4. Hacer el scatterplot con el linefit

' 5. Hacer el forecast y evaluar:
'	MSFE | Mean Squared forecast error
'	MAFE | Mean absolute forecast error

'6. Plot Fanchart
'	y vs yf  con Intervalos de Confianza 

'======================
' Preliminares
'======================

'Fijar el directorio de trabajo 

%runpath = @runpath
cd %runpath



'======================
' Simular los datos
'======================

exec ./simulate_data.prg

' Uncomment below para ver cómo se simulan los datos
'open ./simulate_data.prg 



'--------------------
' train_test_split
' con coldstart=100
'-------------------

sample train 101 300
sample test 301 @last

smpl train


'======================
' Realizar actividades
'======================

' 1. Lineplot X e Y
'---------------------

freeze(fig1) xy.line
fig1.setelem(2) axis(r)
fig1.addtext(t) Lineplot X e Y

' 2. Scatterplot X-Y con Linefit()
'-----------------------------------
freeze(fig2) xy.scat linefit()
fig2.addtext(t) Scatterplot X e Y


' 3. Regresión lineal estática
'----------------------------------
equation eq_static.ls y c x


' 5. Forecast: MSFE y MAFE
'----------------------------------

'Fijar muestra out-of-sample
smpl test

'Forecastear
eq_static.forecast(ga) yf yf_sd

' Calcular métricas
scalar MSFE = @rmse(y, yf)
scalar MAFE = @mae(y, yf)

'Construir tabla
table(3,2) Forecast_eval

Forecast_eval(1,1) = "Forecasting"
Forecast_eval(1,2) = "Performance"


Forecast_eval(2,1) = "MSFE"
Forecast_eval(2,2) = MSFE

Forecast_eval(3,1) = "MAFE"
Forecast_eval(3,2) = MAFE



' 6. Forecast graph: y vs yf con IC
'-----------------------------------------------
sample fanchart 290 320
smpl fanchart

include ./tools.prg
'open ./tools.prg

call fanchart(y, yf, yf_sd, "fig3")


