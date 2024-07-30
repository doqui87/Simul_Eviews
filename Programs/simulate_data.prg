'=======================================
' Econometría de Series de Tiempo
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' 	Data Simulation
'=======================================
'
' En este programa simulamos los datos con los que vamos a trabajar las próximas clases
' un modelo autorregresivo de rezagos distribuidos de primer orden con un quiebre estructural, 
'
' Empezamos con un modelo relativamente complejo para poder hacer el diagnóstico del modelo y refinar sucesivamente el análisis a medida que avanzamos con los temas del curso.
'
'
'==================
'	SETTING
'==================
'
' 	Workfilde con 500 observaciones
'		0   - 100: coldstart 
'		101 - 300: training sample
'		301 - 500: test sample
'
'
' 	Modelo ARDL(1,1):
'		y ~ c0 + c1 Dummy 			' quiebre en el intercepto
'			+ b0 x + b2 Dummy*x 	' quiebre en la pendiente
'			+ b1 x(-1) + a1 y(-1) 	' algo de inercia
'			+ e			' shock aleatorio
'
'	con:
'		x ~ U(-10, 10)
'		e ~ N(0,1)
'
'		Dummy = 1 para 200<t
'
'	Parámetros:
'		c0 = c1 = 1
'		b0 = b2 = 1 
'		b1 = a1 = 1/2
'
'
'
'
'==================
'	Parámetros
'==================

'Fijar random seed
rndseed 42

!n = 500

' Static DGP
!c0 = 1
!c1 = 1
!b0 = 1
!b2 = 1

' Dynamic
!b1 = 1/2
!a1 = 1/2



'==================
'	SIMULACIONES
'==================

' Crear workfile

wfclose(noerr)
wfcreate(wf=sim_data, page=simulations) u 1 !n


' Crear series
series x	' exógena
series dummy
series e	' perturbación
series y	' endógena

group xy x y

'Inicializar variables dinámicas
smpl @first @first
x = 0
y = 0


' Simular data
'---------------

 smpl @first+1 @last

e = nrnd 			' perturbación
dummy = @recode(@obsnum<=200, 0,1)	' dummy=1 para t>200
x = 20*(rnd-1/2)		'	x~U(-10, 10)


' Simular y
y =  !c0 + !c1*Dummy + !b0*x + !b2*Dummy*x + !b1*x(-1) + !a1*y(-1)+ e








 'Code inspirado en las simulaciones del libro
'   Ghysels, E & Marcellino, M. (2018) Applied Economic Forecasting using Time Series Methods


