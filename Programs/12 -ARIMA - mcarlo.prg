'=======================================
' Econometría de Series de Tiempo
' 	Un enfoque basado en simulación
'	Guido Ianni
'		Evaluación y combinación de pronósticos
'=======================================


'Esta simulación ilustra que la estimación por OLS de un modelo AR(1) es:
'		- Sesgada
'		- Pero consistente

'======================
' Calibración PARAMETROS
'======================

%ns = "20 50 200" 	'tamaño muestral estimaciones
!R = 10000				' Repeticiones replicaciones Monte Carlo

!n_max = 200

!rho = .8

'======================
' 		Preliminares
'======================

'Fijar el directorio de trabajo 
%runpath = @runpath
cd %runpath


'++ Creo WorkFile
wfclose(noerr) 
wfcreate(wf=Sim_data, page=simulations) u 0 !n_max
delete *



'==================
'		SIMULAR
'==================

'Inicializar y
series y = 0

'Crear matriz para guardar resultados de las simulaciones
matrix(!R, @wcount(%ns)) simres
matrix(!R, @wcount(%ns)) simres_mle
alpha(@wcount(%ns)) sample_size
scalar rho = !rho
'Run Monte Carlo experiment
!col = 1
for %n {%ns}
	' Ffijar muestra "util"
	smpl 1 {%n}

	'Estimar R veces un modelo AR(1)
	for !rep=1 to !R
  		series u = nrnd
  		series y = !rho*y(-1) + u
		equation eq.ls y c y(-1)
		simres(!rep,!col)=eq.@coefs(2) 
		equation eq2.ls y c ar(1)
		simres_mle(!rep,!col)=eq2.@coefs(2)
  next

sample_size(!col) = %n
!col= !col+1

next


'==================
'   NEW PAGE
'==================
'Crear pagina con resultados de simulaciones
pagecreate(page=simresults) u 1 !R

copy simulations\simres simres
copy simulations\simres_mle simres_mle
copy simulations\sample_size sample_size

group estim
group estim_mle


' Crear series
for !i=1 to @wcount(%ns)
	%n = sample_size(!i)	
	series rho_{%n}
	estim.add rho_{%n}

	series rho_mle{%n}
	estim_mle.add rho_mle{%n}
next

mtos(simres, estim)
mtos(simres_mle, estim_mle)

freeze(fig1_kde) estim.distplot(s) kernel(k=n)
fig1_kde.axis(b) range(-.5,8)
fig1_kde.addtext(t) convergencia de rho_hat en un modelo AR(1) - OLS
fig1_kde.axis(b) range(-0,1.2)
fig1_kde.draw(line, bottom, pattern(1), linewidth(2), top) !rho 

freeze(fig2_normal) estim.distplot(s) theory()
fig2_normal.axis(b) range(-.5,8)
fig2_normal.addtext(t) convergencia de rho_hat en un modelo AR(1) - OLS
fig2_normal.axis(b) range(-0,1.2)
fig2_normal.draw(line, bottom, pattern(1), linewidth(2), top) !rho

freeze(fig3_kde_mle) estim_mle.distplot(s) kernel(k=n)
fig3_kde_mle.axis(b) range(-.5,8)
fig3_kde_mle.addtext(t) convergencia de rho_hat en un modelo AR(1) - OLS
fig3_kde_mle.axis(b) range(-0,1.2)
fig3_kde_mle.draw(line, bottom, pattern(1), linewidth(2), top) !rho

freeze(fig4_normal_mle) estim_mle.distplot(s) theory()
fig4_normal_mle.axis(b) range(-.5,8)
fig4_normal_mle.addtext(t) convergencia de rho_hat en un modelo AR(1) - OLS
fig4_normal_mle.axis(b) range(-0,1.2)
fig4_normal_mle.draw(line, bottom, pattern(1), linewidth(2), top) !rho




