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
	(:types robot zona personaje objeto)
	;Declaracion de los predicados del mundo de Belkan
	(:predicates
			(en ?x - zona ?y - personaje)
			(esta ?x - zona ?y - objeto)
			(ubicado ?x - zona ?y - robot)
			(tiene ?x - personaje ?y - objeto)
			(manovacia)
			(tengo ?x - objeto)
			(camino ?x - zona ?y - zona)
	)

	;ACC: Coger(x)
	;LP: libre(x)^manovacia
	;lS: manovacia^libre(x)
	;LA: tengo(x)
	(:action coger
		:parameters (?x - objeto ?y - zona ?z - robot)
		:precondition (and  (manovacia)(esta ?y ?x)(ubicado ?y ?z))
		:effect (and (not (manovacia)) (tengo ?x)))
	
	;ACC: dar(x, y)
	;LP: tengo(x)^¬(tiene(y, x))
	;lS: tengo(x)
	;LA: tiene(y, x)^manovacia
	(:action dar
		:parameters (?x - objeto ?y - personaje ?z - robot ?t - zona)
		:precondition (and (tengo ?x) (not (tiene ?y ?x))(en ?t ?y)(ubicado ?t ?z))
		:effect (and (tiene ?y ?x) (manovacia) (not (tengo ?x)))
	)

	;ACC:dejar(x)
	;LP:(tengo(x))
	;lS:(tengo(x))
	;LA:(manovacia)
	:(:action dejar
	  :parameters (?x - objeto ?y - zona ?z - robot)
	  :precondition (and (tengo ?x)(ubicado ?y ?z))
	  :effect (and (manovacia)(not (tengo ?x))(esta ?y ?x)))

	;ACC: (mover(x, y)
	;LP: en(x)^¬en(y)^camino(x, y)
	;lS: en(y)
	;LA: en(x)
	(:action mover
		:parameters (?z - robot ?x - zona ?y - zona)
		:precondition (and (not (ubicado ?y ?z))(ubicado ?x ?z)(camino ?x ?y))
		:effect (and (ubicado ?y ?z)(not (ubicado ?x ?z)))
	)
)