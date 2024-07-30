'=======================================
' Introducción a la econometría
' 	Un enfoque basado en simulación
'	Guido Ianni
'
' 	ESTIMADORES DE LA VARIANZA
'=======================================

' Este programa simula 3 estimadores de la varianza de una VA
'	@mean(x)
'	@sumsq(x-!mu)/!n
'	@sumsq(x-@mean(x))/!n
'	@sumsq(x-@mean(x))/(!n-1)




' ++Seteo PARÁMETROS
!n=10				' El tamaño de la muestra
!R=1000			' La cantidad de replicaciones
!mu=7			' Media de X
!sigma=10		' Su desvío




'++ Creo WorkFile
wfclose(noerr)
wfcreate(wf=WFile, page=simulations) u 1 !R
delete *
smpl 1 !n


'++ matriz SIMRES que guarda resultados de las simulaciones
matrix (!R,3) simres 'de dimensión !Rx4

'++ Loopeo, 
'      en cada iteración calculo la media y los 3 estimadores de la varianza
for !rep=1 to !R
	genr x=!mu+!sigma*nrnd
	simres(!rep,1)=@sumsq(x-!mu)/!n
	simres(!rep,2)=@sumsq(x-@mean(x))/!n
	simres(!rep,3)=@sumsq(x-@mean(x))/(!n-1) 'Correción de Bessel
next



'=======================================
' 	Volcar simulaciones en nueva pagina
'=======================================


'Creamos página
pagecreate(page=simresults) u 1 !R

'Inicializamos series
series media 
series varmu
series varN 
series varN_1
group sigma_hats varmu varN varN_1

' Copiar resultados simulaciones
copy simulations\simres simres

mtos(simres,sigma_hats)


'Mostrar estadísticas DESCRIPTIVAS
freeze(descriptive) sigma_hats.stats

group sigmas_std

for !i=1 to sigma_hats.count
	%name = sigma_hats.@seriesname (!i)
	series {%name}_std = {%name}/!sigma
	sigmas_std.add {%name}_std
next
freeze(Fig1) sigmas_std.distplot(m) hist(anchor=0, scale=dens) theory(dist=chisq)
fig1.addtext(t,just(c), font(Garamond, 18,b)) Distribucion de los estimadores
fig1.align(3,.8,0)

