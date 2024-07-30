'=======================================
' Introducción a la econometría
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' DIFICULTADES MCO - HETEROSCEDASTICIDAD
'=======================================

' Ahora hacemos una demostración de los problemas de la heteroscedasticidad. Para eso 
'
'	Sim 1:	y_con ~ N(mu, sigma^2)
'				y_sin ~ N(mu, @mean(sigma)^2)
'				mu = b1 + b2*x
'				sigma = h(x)
'
'	Sim 2: 	log(y_nl)=c1 + c2 * log(x) + u
'				u~N(0, s)
'
'===============
'   MOSTRAMOS
'===============
'	Fig1: 
'			Las consecuencias de la heteroscedasticidad en el scatter de (x, y_sin) y (x, y_con)
'
'	Fig2: 
'			Que la heteroscedasticidad puede aparecer por un error de especificación, 
'				si estimo y_nl ~ x  [el true_model sería log(y_nl) ~ log(x) ] 
'				puedo tener heteroscedastacidad (y autocorrelación) 
'				por no haber estimado la forma funcional adecuada
'	Fig 3:
'			Cómo la presencia de heteroscedasticidad dificulta la estimación de los parámetros
'				a través de una simulación MonteCarlo 
'				de la distribucion de beta_hat en los modelos SIM1 y SIM2
'				


'===============
'   ACTIVIDADES
'===============

' Realizar diagnóstico de heteroscedasticidad en el modelo y_con ~ x
' Corregirlo haciendo una estimación robusta (HC1 y HC2)
' Agregar otros regresores y observar scatter ++ y vs regresores ++ y también  ++resids vs yfitted++



'======================
'			SIMULAR
'======================

'++ Setear PARAMETROS
!n = 300
!R = 100

!xmin=0.2

' SIM1
!b1= 2
!b2= 5

%sigma = "!s1*exp(!s2*x)"
!s1 = 1
!s2 = 1.5

' SIM2
!c1 = 1
!c2 =1.5
!s = .3

'++ Crear Workfile y borrar contenido
wfclose(noerr)
wfcreate(wf=Het, page=simulations) u 1 !n
delete *





'==================
'			SIM1
'==================

'+++ MONTE CARLO+++++

matrix (!R, 2) simres
series  x = !xmin+ rnd
series sigma ={%sigma}

' Loop
for !i=1 to !R
	scalar iter = !i	
	'++ Crear series

	series y_con  = !b1 + !b2*x + sigma*nrnd
	series y_sin = !b1 + !b2*x + @mean(sigma)*nrnd

'	++Estimar MCO
	equation eq_sin.ls y_sin c x
	equation eq_con.ls y_con c x

'	++Guardar betas de las estimaciones
	simres(!i, 1) =  eq_sin.@coefs(2)
	simres(!i, 2) =  eq_con.@coefs(2)
	
next


'==================
'   SIMRESTULS PAGE
'==================
'Crear pagina con resultados de simulaciones
pagecreate(page=simresults) u 1 !R


'Inicializar las series para guardar los resultados
series b_sin
series b_con

group statistics b_sin b_con

'Displaynames
b_sin.displayname sin het
b_con.displayname con het


'++Copiar resultados
copy simulations\simres simres

'Matrix-to-Series conversion
mtos(simres, statistics)


'==================
'   SIMULATIONS PAGE
'==================
pageselect simulations

' Displaynames
y_sin.displayname y_homosc
y_con.displayname y_heterosc


' Grupos
group gxy_sin x y_sin
group gxy_con x y_con

'==================
'			SIM2
'==================

'++ Crear Series
series log(y_nl) = !c1 + !c2* log(x) + !s*nrnd
equation eq_nl.ls y_nl c x
equation eq_nl_log.ls log(y_nl) c log(x)

'++Make forecast y resids
eq_nl.makeresids resids_nl
eq_nl_log.makeresids resids_nl_log
eq_nl.fit(e, g) ynl_f
eq_nl_log.fit(e, g) ynl_log_f


'++Grupos
group gxy_sin x y_sin
group gxy_con x y_con
group gxy_nl x y_nl
group gxy_nl_log log(x) log(y_nl)
group gsfig2c ynl_f resids_nl
group gsfig2d ynl_log_f resids_nl_log



'======================
'			PLOTEAR
'======================


' FIG1
freeze(zfig1a) gxy_sin.scat linefit()
zfig1a.addtext(t, just(c), font(garamond, 12, b))  Caso Homoscedastico

freeze(zfig1b) gxy_con.scat linefit()
zfig1b.addtext(t, just(c), font(garamond, 12, b))  Caso Heteroscedastico

graph fig1.merge zfig1a zfig1b
fig1.addtext(t, just(c), font(garamond, 18, b))  Scatterplots X vs Y con linefit(MCO)
fig1.align(2,1,1)


'FIG2
freeze(zfig2a) gxy_nl.scat linefit()
freeze(zfig2b) gxy_nl_log.scat linefit()
freeze(zfig2c) gsfig2c.scat
freeze(zfig2d) gsfig2d.scat

zfig2a.addtext(t, just(c), font(garamond, 12, b))  X vs Y
zfig2b.addtext(t, just(c), font(garamond, 12, b))  log(x) vs log(y)
zfig2c.addtext(t, just(c), font(garamond, 12, b))  yhat vs uhat modelo lin-lin
zfig2d.addtext(t, just(c), font(garamond, 12, b))  yhat vs uhat modelo log-log


graph fig2.merge zfig2a zfig2b zfig2c zfig2d
fig2.addtext(t, just(c), font(garamond, 18, b))  Heteroscedasticidad por error de especificacion
fig2.align(2,1,1.5)

freeze(fig_extra)  zfig1b zfig2a
fig_extra.addtext(t, just(c), font(garamond,18, b))  Son ambos modelos verdaderamente heteroscedasticos?
fig_extra.align(2,1,1.5)

'FIG3
pageselect simresults

freeze(fig3) statistics.distplot(s) theory()
fig3.addtext(t, just(c), font(garamond, 18, b))  Histogramas de beta_hat 
pageselect simulations
copy simresults\fig3 fig3





