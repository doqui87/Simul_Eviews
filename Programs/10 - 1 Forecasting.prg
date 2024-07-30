'=======================================
' Econometría de Series de Tiempo
' 	Un enfoque basado en simulación
'	Guido Ianni
'
'		Evaluación y combinación de pronósticos
'=======================================
' 
' En esta clase nos vamos a centrar en 3 preguntas:
'
'	1.	¿Qué tan "bueno" es un forecast? => Qué propiedades que tiene
'	2. 	¿Es un forecast mejor que otro? => estadísticos (MSFE)
'	3. 	¿Es posible mejorar un forecast combinando varios? 
'
'	Recordar:
'		----------------------------------------------------------------------------------------------------
'		Especialmente en modelos de series de tiempo
'			un buen ajuste in-sample no implica buena performance out-of-sample
'		-----------------------------------------------------------------------------------------------------
'
' 	 Vamos a seguir trabajando con los simulados con los que venimos trabajando las últimas clases.
'	Y con las variantes interesantes de los modelos ARDL que analizamos la clase pasada
'
'		M1: modelo estático y ~ x
'		M2: modelo estático con dummies y ~ d + x + dx
'		M3: leading indicator model
'		M4: ARDL (3,3) ---> DROPPED
'		M5: ARDL trimming GridSearch (AIC)
'		M6: ARDL trimming LASSO - --> DROPPED
'		M7: ARDL(1,1) con quiebre estructural
'
'======================
' 		Actividades
'======================
'	1. Comparar los pronósticos de los modelos M1-M7, en parejas
'	2. Comparar los pronósticos de los modelos M1-M7, one vs all
'	3. Testear insesgamiento y eficiencia: fe(+h) ~ a + (b-1) yf(+h)
'
'
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
equation eq_M1.ls y c x				' Modelo estático - M1
equation eq_m2.ls y c dummy x dummy*x		' c/ quiebre estructural - M2
equation eq_M3.ls y c x(-1)			' Leading indicator - M3
equation eq_M5.ardl(deplags=3, reglags=3) y x	' c/automatic lag selection- M5
equation eq_M7.ls y c x x(-1) y(-1) dummy dummy*x(-1) 'ARDL(1,1) c/ str. break - M7


eq_m1.displayname Estatico
eq_m2.displayname c/dummies
eq_m3.displayname Leading indic.
eq_m5.displayname ARDL auto_lag
eq_m7.displayname ARDL c/dummies


'---------------------------------------
'		Forecasting
'======================

%table_name = "Model_comp"
%models_list = @wlookup("eq*", "equation")

call model_comparison(%models_list, "test", %table_name)


smpl test
eq_m5.forecast yf5 yf5_se
smpl fanchart_plot

call fanchart(y, yf5, yf5_se, "Fanchart")




'---------------------------------------
'		Forecasting comparison and evaluation
'======================



' One vs all

'Short-Run evaluation
freeze(forecast_eval_ShortRun) y.fcasteval(trim=5) {%models_list}

'Long-Run evaluation
smpl test
freeze(forecast_eval_LongRun) y.fcasteval(trim=5) {%models_list}


' 1 vs 1 model comparison

'Crear Spol para guardar resultados
spool forecast_eval

call compare_forecasters(y, %models_list, "forecast_eval")










