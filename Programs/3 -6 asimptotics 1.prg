'=======================================
' Introducción a la econometría
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' 	Modelo de Regresión - Resultados Asintóticos
'=======================================
' 								Todo lo que puede salir mal
'													  saldrá mal
'														(Murphy)


' Esta simulación se centra en las propiedades asintóticas
'	de los modelos de regresión

' Mostramos esencialemente 3 resultados
'	(Fig1) y=f(x) no sigue una distribución normal
'				pero beta_hat converge a corr(XY) Sigma(y)/Sigma(x), aunque muy lento

'	(Fig2) El TCL garantiza normalidad asintótica de beta_hat
'				pero incluso con "n suficientemente grande" 
'				podemos estar muy lejos de la normalidad
'	(Fig3)	 Esto también lo mostramos simulando y~XB + e | donde e~DoblePareto(a)
'				

'======================
' Seteo PARAMETROS
'======================

'++ Sim1 | y=f(x) no es normal
%ns = "25 100 800"

!nmax = 100000
!R = 5000

!rho = (@sqrt(5)-1)/2
!sigmax = (2*(1-!rho^2))^ (-1)
!sigmay = (1-!rho^2)^ (-1)



'++ Sim2|  y~XB + e | donde e~DoblePareto(a)
%as = "2.05 2.1 2.2 2.4 3"
!n=100
!beta1 = 0
!beta2 = 1



'==================
'		SIMULAR
'==================

'++ Creo WorkFile
wfclose(noerr) 
wfcreate(wf=Multivariate, page=simulations) u 1 !nmax
delete *


matrix(!R, @wcount(%ns)) simres

'++ Simulo series recorriendo el loop
!counter =1
for %n {%ns}
	smpl @first {%n}
	for !i=1 to !R

		series etax = nrnd
		series etay = !rho * etax + @sqrt(1-!rho^2) * nrnd
		series log(x) = etax * !sigmax
		series log(y) = etay * !sigmay
		equation eq1.ls y  c x
		simres(!i, !counter) = eq1.@coefs(2)

next
!counter = !counter+1
next



'==================
'   NEW PAGE
'==================
'Crear pagina con resultados de simulaciones
pagecreate(page=simresults) u 1 !R

copy simulations\simres simres 



for %n {%ns}
	series beta{%n}
next


'===========
'   FIGURAS
'===========
'+ Histogramas beta_hat
group g1 beta*
mtos(simres, G1)
freeze(fig1) g1.distplot(s) freqpoly(binw=user, binval=0.8, scale=dens)
fig1.axis(b) range(-.5,8)
fig1.addtext(t) convergencia de beta_hat con distribucion empirica "desconocida"

'+ Q-Q Plots beta_hat
!ns = @wcount(%ns)
%last_n = @word(%ns,!ns)
freeze(fig2) beta{%last_n}.qqplot theory()








'=================================
' Sim2|  y~XB + e | donde e~DoblePareto(a)
'=================================

'++ Esencialmente REPITO

pagecreate(page=pareto_error) u 1 !n

matrix(!R, @wcount(%as)) simres2


'++ SIMULO D-PARETO++

!counter = 1
for %a {%as}
	for !i=1 to !R
		series x = nrnd
		series e{!counter} = @rpareto(1, {%a}) * ((-1)^(nrnd>0))
		series y{!counter} = !beta1+!beta2*x + e{!counter}		
		equation eq1.ls y{!counter}  c x
		simres2(!i, !counter) = (eq1.@coefs(2)-!beta2)*@sqrt(!n*({%a}-2)/{%a})
	next
	!counter = !counter+1
next

'++ vuelvo a SIMRESULTS
pageselect simresults

!counter = 1
for %a {%as}
	series pareto{!counter}
	pareto{!counter}.displayname a={%a}
	!counter = !counter+1
next

group beta_par pareto*
copy pareto_error\simres2 simres2
mtos(simres2, beta_par)



'======================
' 	  FIGURAS PARETO
'======================

'++ HISTOGRAMAS beta_hat
freeze(fig3_h) beta_par.distplot(s) kernel(k=n)
fig3_H.axis(b) range(-2.5,2.5)
fig3_H.addtext(t, just(c), font(garamond, 18, b)) Densidad del estimador OLS normalizado \ncon error doble pareto
fig3_H.legend -display


'++ Q-Q Plots beta_hat
freeze(fig3_QQ) beta_par.qqplot(m) theory()
fig3_QQ.addtext(t, just(c), font(garamond, 18, b)) QQ plots del estimador OLS normalizado \ncon error doble pareto


'======================
' 	  Actividades
'======================

' Repetir el análisis anterior pero haciendo

'		y=beta +e donde e es una potencia estandarizada de la normal
'		e = u^k - @mean(u^k) * (@mean(u^2k)-(@mean(u^k))^2)^(1/2)
'		con u~N(0,1)
'		fijar n=100 y %ks = "1 4 6 8"

'		bonus: probar potencias impares ¿notan algo raro?


