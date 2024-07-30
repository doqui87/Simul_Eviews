'=======================================
' Econometría de Series de Tiempo
' 	Un enfoque basado en simulación
'	Guido Ianni
'		Dickey - Fuller
'=======================================


'Esta simulación ilustra que la distribución Dickey-Fuller 
'		para el contraste de raíces unitarias


'  Fig"n" 
'		tiene las distribuciones empíricas (aprox DF) 
'		de los test de signif. indiv de las especificaciones UnitRootTest

' La Tabla "crit_values" tiene sus valores empricos

' Falta embellecer


'======================
' Calibración PARAMETROS
'======================

%ns = "20 50 200" 	'tamaño muestral estimaciones
!R = 10000				' Repeticiones replicaciones Monte Carlo

!n_max = 200


'======================
' 		Preliminares
'======================

'Fijar el directorio de trabajo 
%runpath = @runpath
cd %runpath


'++ Creo WorkFile
wfclose(noerr) 
wfcreate(wf=Sim_data, page=simulations) u 1 !n_max
delete *



'==================
'		SIMULAR
'==================


'Crear matriz para guardar resultados de las simulaciones

matrix(!R, 3*@wcount(%ns)) simres
alpha(@wcount(%ns)) specs

'Run Monte Carlo experiment
!counter = 1
for %n {%ns}
	' Ffijar muestra "util"
	'Estimar R veces un modelo AR(1)
	for !rep=1 to !R

		'simular series
  		series u = nrnd
  		series y = @cumsum(u)
		
		'Estimar 3 variantes de ADF_Unit_root_test
		equation no_cons.ls d(y) y(-1)
		equation cons.ls d(y) y(-1) c
		equation cons_trend.ls d(y) y(-1) c @trend
		
		'guardar t_stat de la UR test en simres
		simres(!rep,!counter) = no_cons.@tstats(1)
		simres(!rep,!counter+1) = cons.@tstats(1)
		simres(!rep,!counter+2) = cons_trend.@tstats(1)

  next

' Guardar especificación en alpha series
specs(!counter)  = "no_cons" + %n
specs(!counter+1)  = "cons" + %n 
specs(!counter+2)  = "cons_trend" + %n  

!counter = !counter+3

next


'==================
'   NEW PAGE
'==================
'Crear pagina con resultados de simulaciones
pagecreate(page=simresults) u 1 !R

' Traerse resultados de simulaciones
copy simulations\simres simres
copy simulations\specs specs

'Crear grupo para guardar estimaciones
group estim

' Crear series
for !i=1 to 3*@wcount(%ns)
	%spec = specs(!i)	
	series {%spec}
	estim.add {%spec}

next

'Desempaquetar la matriz en el grupo
mtos(simres, estim)




'==================
'   Plot
'==================


' Dickey Fuller distributions
series normal = nrnd

%iterate_through = estim.@members
!i = 1
for %spec1 %spec2 %spec3 {%iterate_through}
	group _temp {%spec1} {%spec2} {%spec3} normal
	freeze(fig{!i}) _temp.distplot(s) kernel()
	fig{!i}.axis(b) range(-.5,8)
	fig{!i}.addtext(t) Distribucion Dickey Fuller
	fig{!i}.axis(b) range(-5,3)
	fig{!i}.draw(line, bottom, pattern(1), linewidth(2), top) 0
	!i = !i +1
next 



table(7,  3*@wcount(%ns)) crit_values
' Critical Values for the Unit Root Test
!counter=2

crit_values(2, 1) = "1%"
crit_values(3, 1) = "5%"
crit_values(4, 1) = "10%"



for %spec {%iterate_through}

	crit_values(1, !counter) = %spec
	crit_values(2, !counter) =@quantile({%spec}, 0.01)
	crit_values(3, !counter) = @quantile({%spec}, 0.05)
	crit_values(4, !counter) =@quantile({%spec}, 0.10)

	!counter = !counter+1
next


