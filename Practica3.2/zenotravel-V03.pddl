(define (domain zeno-travel)


(:requirements
  :typing
  :fluents
  :derived-predicates
  :negative-preconditions
  :universal-preconditions
  :disjuntive-preconditions
  :conditional-effects
  :htn-expansion

  ; Requisitos adicionales para el manejo del tiempo
  :durative-actions
  :metatags
 )

(:types aircraft person city - object)
(:constants slow fast - object)
(:predicates (at ?x - (either person aircraft) ?c - city)
             (in ?p - person ?a - aircraft)
             (different ?x ?y) (igual ?x ?y)
             (hay-fuel-para-ir-rapido ?a ?c1 ?c2)
             (hay-fuel-para-ir-normal ?a ?c1 ?c2)
             )
(:functions (fuel ?a - aircraft)
            (fuel-limit) ;;Limite de fuel a usar en el problema 
            (distance ?c1 - city ?c2 - city)
            (slow-speed ?a - aircraft)
            (fast-speed ?a - aircraft)
            (slow-burn ?a - aircraft)
            (fast-burn ?a - aircraft)
            (capacity ?a - aircraft)
            (refuel-rate ?a - aircraft)
            (total-fuel-used)
            (boarding-time)
            (debarking-time)
            )

;; el consecuente "vac�o" se representa como "()" y significa "siempre verdad"
(:derived
  (igual ?x ?x) ())

(:derived 
  (different ?x ?y) (not (igual ?x ?y)))



;; este literal derivado se utiliza para deducir, a partir de la información en el estado actual, 
;; si hay fuel suficiente para que el avión ?a vuele de la ciudad ?c1 a la ?c2
;; el antecedente de este literal derivado comprueba si el fuel actual de ?a es mayor que 1. 
;; En este caso es una forma de describir que no hay restricciones de fuel. Pueden introducirse una
;; restricción más copleja  si en lugar de 1 se representa una expresión más elaborada (esto es objeto de
;; los siguientes ejercicios).
(:derived 
  
  (hay-fuel-para-ir-normal ?a - aircraft ?c1 - city ?c2 - city)
  (>= (fuel ?a) (distance ?c1 ?c2)))

(:derived 
  
  (hay-fuel-para-ir-rapido ?a - aircraft ?c1 - city ?c2 - city)
  (>= (fuel ?a) (* (distance ?c1 ?c2) (fast-burn ?a))))

(:task transport-person
	:parameters (?p - person ?c - city)
	
  (:method Case1 ; si la persona est� en la ciudad no se hace nada
	 :precondition (at ?p ?c)
	 :tasks ()
   )
	 
   
   (:method Case2 ;si no est� en la ciudad destino, pero avion y persona est�n en la misma ciudad
	  :precondition (and (at ?p - person ?c1 - city)
			                 (at ?a - aircraft ?c1 - city))
				     
	  :tasks ( 
	  	      (board ?p ?a ?c1)
		        (mover-avion ?a ?c1 ?c)
		        (debark ?p ?a ?c )))

   (:method Case3 ;Persona y avion no estan en la misma ciudad
   	:precondition (and (at ?p - person ?c1 - city)
   											(at ?a - aircraft ?c2 - city))
   	:tasks (
   			(mover-avion ?a ?c2 ?c1)
   			(board ?p ?a ?c1)
   			(mover-avion ?a ?c1 ?c)
   			(debark ?p ?a ?c))
    )
	)

(:task mover-avion
 :parameters (?a - aircraft ?c1 - city ?c2 -city)
 ;(:method fuel-suficiente ;; este método se escogerá para usar la acción fly siempre que el avión tenga fuel para
;                          ;; volar desde ?c1 a ?c2
;			  ;; si no hay fuel suficiente el método no se aplicará y la descomposición de esta tarea
;			  ;; se intentará hacer con otro método. Cuando se agotan todos los métodos posibles, la
;			  ;; descomponsición de la tarea mover-avión "fallará". 
;			  ;; En consecuencia HTNP hará backtracking y escogerá otra posible vía para descomponer
;			  ;; la tarea mover-avion (por ejemplo, escogiendo otra instanciación para la variable ?a)
;  :precondition (hay-fuel ?a ?c1 ?c2)
;  :tasks (
;          (fly ?a ?c1 ?c2)
;         )
;   )

;  (:method repost-needed
;    :precondition (not (hay-fuel ?a ?c1 ?c2))
;    :tasks (
;        (refuel ?a ?c1)
;        ;(fly ?a ?c1 ?c2)
;        )
;    )

  (:method fly-fast ;;Caso en el que el avion tiene combustible suficiente como para ir rapido a la ciudad de destino.
    :precondition (and  (hay-fuel-para-ir-rapido ?a ?c1 ?c2)
                        (<= (+ (total-fuel-used) 
                            (* (distance ?c1 ?c2) (fast-burn ?a)))
                         (- (fuel-limit) 200))) ;;Al ir rapido siempre se deja fuel para poder ir despacio de una ciudad a otra pasando por 
                                                ;;una intermedia, asi siempre se puede completar el objetivo.
      :tasks (
        (zoom ?a ?c1 ?c2))
    )

    (:method repost-and-fly-fast ; Caso en el que el avion puede ir rapido al destino pero tiene que repostar primero.
    :precondition (and (not (hay-fuel-para-ir-rapido ?a ?c1 ?c2))
                        (<= (+ (total-fuel-used)
                              (* (distance ?c1 ?c2) (fast-burn ?a)))
                        (- (fuel-limit) 200)))
      :tasks (
        (refuel ?a ?c1)
        (zoom ?a ?c1 ?c2))
    )

  (:method fly-slow ;Caso en el que el avion tiene fuel pero no puede ir rapido al destino.
    :precondition (and  (hay-fuel-para-ir-normal ?a ?c1 ?c2)
                             (<= (+ (total-fuel-used) (* (distance ?c1 ?c2) (slow-burn ?a))) (fuel-limit)))
                          
      :tasks (
        (fly ?a ?c1 ?c2))
  )

  (:method repost-and-fly-slow ;Caso en el que el avion tiene que repostar y ademar ir despacio.
    :precondition (and (not (hay-fuel-para-ir-normal ?a ?c1 ?c2))
                            (<= (+ (total-fuel-used) (* (distance ?c1 ?c2) (slow-burn ?a))) (fuel-limit)))
                      
      :tasks (
        (refuel ?a ?c1)
        (fly ?a ?c1 ?c2))
    )

  )
 
(:import "Primitivas-Zenotravel.pddl") 


)
