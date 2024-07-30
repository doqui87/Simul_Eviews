'=======================================
' Introducción a la econometría
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' 	OVERFITTING | Train-Test | REGULARIZACION
'=======================================


'==================
'	SETTING
'==================

'		y = μ + e ~ N(μ , σ)
'		μ =  4x + 2 sin(6x)
'		x ~ U[0, 1] 
'	
'		Se entrenan modelos polinomiales en 
'				Totalidad de los datos
'				Train_test_split de !TTS %

' 		Se entrena un modelo de regresión regularizada por ElasticNet


'==================
'	The story goes
'==================
 
'	> Nosotros no observamos μ sino (x y). 
'		Ver Fig1: scatter datos
'		Quizás no hay forma de "adivinar" que el verdadero modelo no es lineal

'	> Una forma de resolverlo puede ser entrenar un modelo polinomial para captar no-linealidades en los datos

' 	> Tener en cuenta: Aumentar los regresores siempre aumenta el R2
'		Rsqared_k: Vector con los R2 a medida que aumenta K (poly degree)
' 		Ver Fig2: Matriz de grafos con scatter datos | modelo real | modelo estimado

'	> El riesgo que existe es sobreajustar a los datos y no aprenderse el modelo subyacente.
'		¿Cómo evitar el sobreajuste? Train_test_split
'			Ver Fig3:RMSE en conjuntos de entrenamiento y testeo
'			Ver Fig4:Graficas de los modelos
'		Una opción: elegir el K que minimice el ECM en Testeo


'	Otra opción: agregar una penalidad por tener coeficientes grandes 
'			ver actividad 1 para eq_poly_9
'			Eso da lugar a técnicas de regularizacion


'==================
'	OBJETOS
'==================

' FIG1:	Scatterplot de datos "observados"

' FIG2: 	Overfitting:Modelos polinomicos (distintos k)
'			Scatter matrix FIG1 + modelo real + modelos estimados

' FIG3: 	Train | Test Split
'			RMSE en conjuntos de Entrenamiento y testeo \

' FIG4: 	Regularizacion
'			ElasticNet vs Poly(9): scatter | true | fitted

		

'==================
'	ACTIVIDADES
'==================
'		Ver los coefficientes de las regresiones

'		Como me crashea Eviews cuando hago coefevol de ElasticNet, 
'			hacer el grafico de CoefEvolution (escalas de ejes logaritmicas) 
'			y el diagnostico de train/test metrics

'		Chequear que VarSelect no hace regularizacion

'		Chequear que otra alternativa es PCA
		
'==================
'	PARAMETROS
'==================
rndseed 1

!n = 15
!tts = .8

!k_max = 9

!sigma = 1


' Params endog
!split = @ceil(!tts*!n) 'Obs del train_test
!nobs = !n+200 '200+n para tener smooth plots 




' ++++++++
' Crear Workfile y borrar contenido
'+++++++++

wfclose(noerr)
wfcreate(wf=Overfitting_regul, page=simulations) u 1 !nobs
delete *

'+++Crear series

' x ~ U(0;1) pero hago (-.1 ; 1.1) 
'	para mostrar problemas de EXTRAPOLACION
series x = -.2 + 1.2* @trend/!nobs 

smpl 1 !n 
series x = @trend/!n 'Dentro de la muestra de simuacion U(0,1)
series true = 4*x + 2* @sin(6*x) 
series y = true + !sigma * nrnd

smpl @all
true = 4*x + 2* @sin(6*x) ' repito para smooth plots

'Series extra
series rmse_train
series rmse_test

sample train 1 !split
sample test !split+1 !n

rmse_train.displayname train
rmse_test.displayname test



'==================
'	LOOPEAR Poly(k)
'==================

for !k=1 to !k_max

	smpl @all

	' FEATURE ENGINEERING
	series deg{!k} = x^!k

	'POLINOMIAL(K) FIT
	%regs = @wlookup("deg*", "series")
	equation eq_poly{!k}.ls y c {%regs}
	
	'+Predict
	eq_poly{!k}.fit fit_{!k}
	fit_{!k}.displayname fit
	
	'FIG2
	graph _fig2_{!k}.scat x y true fit_{!k}
	_fig2_{!k}.addtext(t, just(c)) Grado: {!k}
	_fig2_{!k}.options -legend
	_fig2_{!k}.sort(x)
	_fig2_{!k}.setelem(2) lpat(solid) symbol(none)
	_fig2_{!k}.setelem(3) lpat(solid) symbol(none)
	_fig2_{!k}.axis(l) range(-1,6)


	'==================
	'	TRAIN | TEST Split
	'==================

	'Entrenar 
	smpl train
	equation eq_poly{!k}_tts.ls y c {%regs}

	' makreresids
	smpl @all
	eq_poly{!k}_tts.fit y_fit 
	series resids_tts = y-y_fit

	' Calcular RMSE
	smpl train
	rmse_train(!k) = @sqrt(@sumsq(resids_tts)/!split)

	smpl test
	!rmse = @sqrt(@sumsq(resids_tts)/(!n-!split-1))
	rmse_test(!k) = !rmse
	
	
 next


'==================
'		Regularizacion
'==================

'	ELASTIC NET
smpl 1 !n

'%powers = "-5 -4 -3 -2 -1"
'%nums = "1 0.8 0.6 0.4 0.2"
'
'%lambas = "1"
'for %power {%powers}
'	for %num {%nums}
'		%lambda = @str({%num}*10^({%power}))
'		%lambdas = %lambdas+" "+%lambda
'	next
'next
'
'
'string lambas = %lambdas
'string regs = %regs
'
'
'equation eqenet.enet(penalty=ridge, lambda={%lambdas}) y c {%regs}

' ELASTIC NET FUNCIONARIA MEJOR con parámetros por default
equation eqenet.enet() y c {%regs}

'	STEPWISE
equation eq_varselect.varsel(method=uni) y c deg1 @  {%regs}




'==================
'			PLOT
'==================

smpl @all
graph fig1.scat x y

%fig2s = @wlookup("_fig2*")
graph fig2.merge {%fig2s}
fig2.addtext(t, c, font(garamond, 30, b)) Overfitting modelo polínómico


smpl 1 !k_max
graph fig3.line rmse_train rmse_test
fig3.axis(l) log
fig3.addtext(t, c, font(garamond, 24, b)) Root Mean Squared error
smpl @all

eqenet.fit(e, g) enet_f
eq_varselect.fit(e, g) varselect_f
graph fig4a.scat x y true enet_f varselect_f
fig4a.addtext(t, just(c)) ElasticNet (y VARSELECT)
fig4a.options 
fig4a.sort(x)
fig4a.legend position(bl) columns(4)
fig4a.setelem(2) lpat(solid) symbol(none)
fig4a.setelem(3) lpat(solid) symbol(none)
fig4a.setelem(4) lpat(solid) symbol(none)
fig4a.axis(l) range(-1,6)
graph fig4.merge fig4a _fig2_9
fig4.addtext(t, just(c), font(garamond, 26, b)) Regularizacion
fig4.align(2, .5,1)


