;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Mundos de Belkan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Autor: Rafael Leyva Ruiz.
;Asignatura TSI (Tecnicas de los Sistemas inteligentes)
;grado en ingenieria informatica especialidad en computacion y sistemas inteligentes
;2015-2016

;Definicion del dominio para el problema de los mundos de Belkan.
(define (domain BELKAN-DOMAIN)
	(:requirements :strips :typing)
	(:types robot zona personaje objeto tipo mochila)
	;Declaracion de los predicados del mundo de Belkan
	(:functions
		(total-fuel) ;;representa  la  energia del problema
		(coste-zona ?z - tipo)
		(suma-puntos ?x - objeto ?y - personaje)
		(capacidad-mochila)
		(ocupado-mochila)
		(puntos)
		(entregados)
	)
	(:predicates
			(en ?x - zona ?y - personaje)
			(esta ?x - zona ?y - objeto)
			(ubicado ?x - zona ?y - robot)
			(tiene ?x - personaje ?y - objeto)
			(carga ?x - robot ?y - mochila ?z - objeto)
			(manovacia)
			(cogido ?x - objeto)
			(cargado ?x - objeto)
			(clase ?x - zona ?y - tipo)
			(camino ?x - zona ?y - zona)
			(permite-avanzar ?x - tipo ?y - objeto)
			(no-necesita-objeto ?x - tipo)
	)

	;ACC: Coger(x)
	;LP: libre(x)^manovacia
	;lS: manovacia^libre(x)
	;LA: tengo(x)
	(:action coger
		:parameters (?x - objeto ?y - zona ?z - robot)
		:precondition (and  (manovacia)(esta ?y ?x)(ubicado ?y ?z))
		:effect (and (not (manovacia))(cogido ?x)(not (esta ?y ?x))))

	;ACC: cargar(x) (Carga en la mochila)
	;LP: cogido(x)^mochilavacia
	;lS: cogido(x)
	;LA: manovacia^cargado(x)
	(:action cargar
	  :parameters (?x - objeto ?y - robot)
	  :precondition (and (cogido ?x)
	  				(> (-(capacidad-mochila)(ocupado-mochila)) 0))
	  :effect (and (increase (ocupado-mochila) 1)(not (cogido ?x))(manovacia)(cargado ?x)))
	;ACC:sacar-mochila
	;LP:
	(:action sacar-mochila
	  :parameters (?x - objeto ?y - robot)
	  :precondition (and (manovacia)(cargado ?x))
	  				;(>= (ocupado-mochila)1))
	  :effect (and (cogido ?x)(decrease (ocupado-mochila) 1)(not (cargado ?x))(not (manovacia))))
	
	;ACC: dar(x, y)
	;LP: tengo(x)^¬(tiene(y, x))
	;lS: tengo(x)
	;LA: tiene(y, x)^manovacia
	(:action dar
		:parameters (?x - objeto ?y - personaje ?z - robot ?t - zona)
		:precondition (and (cogido ?x) (not (tiene ?y ?x))(en ?t ?y)(ubicado ?t ?z))
		:effect (and (tiene ?y ?x) (manovacia) (not (cogido ?x))(increase (entregados) 1)(decrease (puntos) (suma-puntos ?x ?y))) 
		;;en los probl del ejercicio 6 se arranca con 50 puntos y se resta con cada entrega
	)

	;ACC:dejar(x)
	;LP:(tengo(x))
	;lS:(tengo(x))
	;LA:(manovacia)
	:(:action dejar
	  :parameters (?x - objeto ?y - zona ?z - robot)
	  :precondition (and (cogido ?x)(ubicado ?y ?z))
	  :effect (and (manovacia)(not (cogido ?x))(esta ?y ?x)))

	;ACC: (mover(x, y)
	;LP: en(x)^¬en(y)^camino(x, y)
	;lS: en(y)
	;LA: en(x)
	(:action mover
		:parameters (?z - robot ?x - zona ?y - zona ?t - tipo ?q - objeto)
		:precondition (and (not (ubicado ?y ?z))(ubicado ?x ?z)(camino ?x ?y)
						(or(cogido ?q)(cargado ?q))(and (clase ?y ?t)(or(permite-avanzar ?t ?q)(no-necesita-objeto ?t)))
						(>=(-(total-fuel)(coste-zona ?t))0))
		:effect (and (ubicado ?y ?z)(not (ubicado ?x ?z))(decrease (total-fuel) (coste-zona ?t)))
	)
)