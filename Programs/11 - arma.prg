'=======================================
' Econometría de Series de Tiempo
' 	Un enfoque basado en simulación
'	Guido Ianni
'
'		ARMA
'=======================================
' 
' Modelos Autorresivos (AR)con medias móviles(MA)
'
' La clase de hoy tiene muy poco código y va a ser mayormente una discusión sobre:
'	
'	- Especificación
'	- Estimación
'	- Diagnóstico
'	- Pronóstico
'
' Y nos vamos a apoyar mucho en AUTO-ARIMA.
'
'	Si queda tiempo, estimar modelos
'			 ARMA(1,0)
'			 ARMA(0,1)
'			 ARMA(1,1)
'			 ARMA(2,0)
' 			
'		Y correr compare_models


'======================
' 		Setting
'======================
'
'	El "paraguas" que va a encompasar todos los modelos que simulamos es un ARMA(2,2) 
'
'			------------------------------------------------------------------------------------------------------------
'					y = !delta + !rho1 y(-1) + !rho2 y(-2) + e + !theta1 e(-1) + !theta2 e(-2)
'			------------------------------------------------------------------------------------------------------------
'	Fijamos ahora los parámetros de nuestra simulación
'
!n = 1000
!cold_start = 100
!train_test_split = .8

!y0 = 0

!sigma_e = 1

!delta 	= 0
!rho1 	= 0.85
!rho2 	= 0
!theta1	= 0 
!theta2	= 0

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
!n_total = !cold_start + !n
wfclose(noerr)
wfcreate(wf=sim_data, page=simulations) u 1 !n_total

' Simular errores
series e = !sigma_e * nrnd

' Inicializar endógena
smpl @first @first+2

series y=0

' Simular GDP
smpl @first+2 @last
 y = !delta + !rho1 * y(-1) + !rho2 * y(-2) + e + !theta1 * e(-1) + !theta2 * e(-2)


'----------------------------------------
' train_test_split
'-----------------------------------------

!split = !cold_start + @ceil(!train_test_split * !n)

sample cold_start @first !cold_start
sample train !cold_start+1 !split
sample test !split+1 @last

sample fanchart_plot !split-10 !split+20

smpl train


'----------------------------------------------------------------
'		Doctring Automatic ARIMA forecating
'====================================
' Se sugiere fuertemente ver los detalles en 
'		- User Guide I - pág. 538
'	 y en 
'		- Object reference - pág. 659
'
' Doctring para 
'		series.autoarma(options) forecast_name [exogenous_regressors]
'====================================================

'
' Resumen:
'	1. Transforma la variable
'	2. Diferencia hasta "d" veces basado en KPSS
'	3. Hace GridSearch de un ARIMAX(p,d,q) [exogenous_regressors]
'		model selection basado en algún selection_criteria 
'		(AIC|BIC|HQ|MSFE(h))
'		con "d" predeterminado en el paso 2
'
' Outputs disponibles:
'	1. Forecast comparison graph (fgraph)
'	2. Selection criteria table (atable)
'	3. Selection criteria graph (agraph)
'	4. Objeto ecuación en workfile con la especificación escogida(eqname)
'
'
'
' Options
'---------
'
' tform=arg																|
'		Transformación de la endógena previa al modelado		|
'		auto = Eviews decide entre log vs no-log					|
'		none  = no transformation										|
'		log = logaritmo													|
'		bc = Box-Cox													|	Transformaciones
'		default = auto													|	variable
' bc = int																	|	endogena
'		Potencia de box-cox (requiere tform=bc)					|
' diff = int																	|
'		Máximo orden de integración 								|
'		basado en KPSS sucesivo 									|
'		Underdifferentiate strategy									|
'		default = 2														|


' maxar = int												|
'		Máximo orden del AR a testear				|
'		default = 4										|
' maxma = int											|
'		mutatis mutandis 								|
' maxsar = int											|
'		mutatis mutandis								|		SARMA especification
'		default = 2										|
' maxsma = int											|
'		mutatis mutandis 								|
'		default = 2										|
' periods = int											|
'		periodicidad del SAR							|
'		default = interanual (e.g. 12 para monthly)	| 


' forclen = int																			|
'		número de períodos para forecastear									| 
'		estima en current sample, 												|
'		forecastea desde "@last" de estimation sample	           			|
' avg = key																			| Optimal Forecasting options
'		usar forcast averaging, en lugar de model selection					|
'		aic = SAIC weights															|
'		sic = BMA weights															|
'		uni = uniform weights														|

' select = key	
'		métrica para selección de modelos								| 
'		ignorada si avg is not NULL										|
'		AIC +> modelos mas complejos									|
'		BIC +> modelos más parsimoniosos							|
'		HQ +> usualmente intermedio entre AIC y BIC				|
'		MSE +> Si el interés es forecasting performance			|
' mselen = key																|
' 		train_test_split para elegir por select = MSE					|
'		ignored if select is not MSE										|    Model selection
'		5 , 10 , 15, 20 son los únicos admitidos						|
' msetype =  key															|
'		tipo de forecasting para elegir por MSE							|
'		ignored if select is not MSE										|
'		dyn = dynamic forecast (default)									|
'		[h for h in range(1,13)]												|
'		si "h" -> fe(h) - h steps ahead forecasts.						|

' fgraph														|
'		Agregar forecast comparison graph				|
' atable														| 
'		Agregar selection criteria table					|
' agraph														|   Output customization
'		Agregar selection criteria graph 					|
' eqname =  name											|
'		Dejar en el workfile la espeficiación escogida	|

'seed = num
'		Semilla para el random number generator	







'---------------------------------------
'		(auto)Estimación
'======================


freeze(_autoarima_summary) y.autoarma( _
tform=none, _
diff = 0, _
maxar = 4, _
maxma = 4, _
forclen = 20, _
select = BIC, _
fgraph, atable, agraph, _
eqname =  _best_model) _
Y_autoforecast _
c


'---------------------------------------
'		Forecasting 
'======================

smpl test
_best_model.forecast yf yf_se
smpl fanchart_plot

call fanchart(y, yf, yf_se, "_Fanchart")




'---------------------------------------
' Estimar Pool de ARMAs y comparar
'======================

smpl train

equation eq_ar1.ls y c ar(1)	
equation eq_ar2.ls y c ar(1 to 2)

equation eq_ma1.ls y c ma(1)
equation eq_ma2.ls y c ma(1 to 2)

equation eq_arma11.ls y c ar(1) ma(1)


eq_ar1.displayname  ar(1)	
eq_ar2.displayname ar(2)
eq_ma1.displayname ma(1)
eq_ma2.displayname ma(2)
eq_arma11.displayname Arma(1,1)



' Comparar modelos
'Agrupar
%table_name = "Model_comp"
%models_list = @wlookup("eq_*", "equation")


call model_comparison(%models_list, "test", %table_name)


spool forecast_eval
call compare_forecasters(y, %models_list, "forecast_eval")
