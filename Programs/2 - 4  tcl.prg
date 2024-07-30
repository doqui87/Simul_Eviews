'=======================================
' Introducción a la econometría
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' 	TEOREMA CENTRAL DEL LIMITE
'=======================================

' El teorema central del límite establece que

' Sea x~iid(mu, sigma^2) [cualquiera sea la distribución de x]

' entonces (@mean(x)-!mu) * @sqrt(n) * sigma converge en distribución a una N(0,1)

' Esta simulación pretende ilustrar el Teorema


' ++Seteo PARÁMETROS

'Pick one:
%distribuciones ="rnd nrnd 2+3*nrnd @rchisq(4) 10*@rchisq(2) (rnd>0.75)*nrnd+(1-(rnd>0.75))*@chisq(2)"

%distr = "rnd"			' Distribución de X


%ns = "1 2 10 100"		' Muestras a probar
!R = 10000				' Cantidad de replicaciones MC


'++ Crear worfile
wfclose(noerr)
wfcreate TCL u 1 !R
delete *

'++ Crear SIMRES
matrix(!R, @wcount(%ns)) simres

group medias
!col = 1


'==================
'   SIMULAR
'==================

for %n {%ns}

	smpl 1 {%n}
	
	for !rep=1 to !R
		series x{%n} = {%distr}
		simres(!rep, !col) = @mean(x{%n})

	next


series media{%n}
media{%n}.displayname @mean({%distr}) con n={%n}
medias.add media{%n}
!col = !col+1
next


'=======================
'   CARGAR SIMULACIONES
'=======================

smpl @all
mtos(simres, medias)

'Studentizar las medias
%grouplist = medias.@members

for %ser {%grouplist}

	series {%ser} = ({%ser} - @mean({%ser}))/@stdev({%ser})

next


'===========
'   FIGURAS
'===========
'++  HISTOGRAMAS
freeze(Fig1_hist) medias.distplot hist(scale=dens)  theory
fig1_hist.addtext(t,just(c), font(Garamond, 18,b)) TCL: Distribucion de @mean(x) estandarizada para

'++  Q-Q Plots
freeze(Fig2_QQ) medias.qqplot(m) theory(p1=0, p2=1)
fig2_qq.addtext(t,just(c), font(Garamond, 18,b)) TCL: Q-Q plots para


