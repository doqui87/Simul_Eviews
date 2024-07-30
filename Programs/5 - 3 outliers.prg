'=======================================
' Introducción a la econometría
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' 	OBSERVACIONES ATÍPICAS E INFLUYENTES
'=======================================

' En esta simulación distinguimos entre 
'		A) Observaciones atípicas - Outliers
' 				Observaciones que tienen una perturbación inusualmente alta
'		B Observaciones influyentes
'				Observaciones que además de ser atípicas tienen una alta palanca (leverage)
'				La palanca (h , de la HAT matrix) depende de qué tan alejada de la media de la 
'					distribución esté la observación atípica

'	SIMULACION
'			x ~ U(0;1)
'			y ~ N(x, s)
'			Una observación se fija en (x0, x0+desvio)

 '	FIGURAS
'			FIG1 muestra el leverage y la influenca para una combinación de X0 y desvios
				

'	ACTIVIDADES
'			Volver al dataset CPS09mar y considerar la muestra de single asian male 
'				estimar log(wage)~education experience experience^2/100 y obtener
'						- DFFits (ie, yhat vs y_hat en el leave-one-out) y encontrar la observación más influyente
'						- Calcular el leverage hi de esa obervacion




'++ Setear PARAMETROS
!n=20

%xs = "0.5 1 2"
%desvios = "2 3 8" 
%leverage = "baja media alta"
%influencia= "baja media alta"


!s = .5


'++ Crear Workfile 
wfclose(noerr)
wfcreate outliers u 1 !n
delete *


' Crear la variable independiente
series  x = rnd
series y  = x + !s*nrnd
series y2
series outlier = 0

' Estimar Lave-one-out
smpl  @first @last-1

equation eqloo.ls y c x
!a1 = c(1)
!b1 = c(2)



'++++++++++++++++
!count = 0
for !x=1 to @wcount(%xs)
	for !y=1 to @wcount(%desvios)
		!count = !count+1

		' Extraer data del outlier
		smpl @last @last
		%x0 =@word(%xs, !x) 
		%desvio =@word(%desvios, !y) 
		%lev = @word(%leverage, !x) 
		%inf =  @word(%influencia, !y) 

		' Reemplazar
		x = {%x0}
		y= {%x0}+!s * {%desvio}
		y2=y

		' Estimar MCO full sample
		smpl @all
		equation eq{!count}.ls y c x
		!a2 = c(1)
		!b2 = c(2)



		' Crear Scatterplot
		group xy x y  y2
		freeze(zfig{!count}) xy.scat user(icept=!a1, slope=!b1)  user(icept=!a2, slope=!b2)
		zfig{!count}.options -legend
		zfig{!count}.addtext(t,just(c), font(garamond, 18, b)) {%lev} palanca y {%inf} Influencia
		zfig{!count}.setelem(1) symbol(2) symsize(2) fillcolor(blue)
		zfig{!count}.setelem(2) symbol(2) symsize(6)
		zfig{!count}.setelem(3) lcolor(blue)
		zfig{!count}.setelem(4) lcolor(red)


	next
next


'++ Crear Fig1
%figlist = @wlookup("zfig?", "GRAPH")
string f = %figlist
graph Fig1.merge {%figlist}
fig1.addtext(t,just(c), font(garamond, 24, b)) Palanca e Influencia


