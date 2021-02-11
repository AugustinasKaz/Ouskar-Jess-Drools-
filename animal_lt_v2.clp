
;;;======================================================
;;;   Self Learning Decision Tree Program
;;;
;;;     This program tries to determine the animal you are
;;;     thinking of by asking questions.
;;;
;;;     Jess Version 4.2 Example
;;;
;;;     To execute, merely load the file.
;;;======================================================


; Apraðomas pagrindinis þiniø bazës freimas su pagrindiniais slotais
(deftemplate node 
   (slot name)
   (slot type)
   (slot question)
   (slot yes-node)
   (slot no-node)
   (slot answer))



    

; jeigu einamuoju momentu nera fakto su pavadinimu root tai inicializuojame faktu baze pakraudami is failo 
; "examples/animal.dat"
; bei pakrauname nauja fakta current-node kurio reiksme root   
; Jess pasiziuri ir randa  faktu faile "examples/animal.dat" kur yra  root irasas ir 
; inicializuojama taisykle  ask-decision-node-question     
; Si taisykle suveikia pati pirmoji kai paleidziame  (reset) ir(run)     
; Prisiminkime, kad taisyklë suveiks tik vienà kartà faktui -> (not (node (name root)))


(defrule initialize-1
   (not (node (name root)))
   =>
   (load-facts "examples/animal.dat")
   (assert (current-node root)))


; (declare (salience 100)) privercia sistema iskviesti sia taisykle
; pirmiaus kitu   komanda (salience 100) padidina prioriteta 100 salyginiu punktu - zenklas sumazintu
; tas padaryta del to kad pirmas zingsnis kuri mes padarome tai nustatome globalu sistemos skaitliuka
; pagal fakta next-gensym-idx is failo "examples/animal.dat" kuris lygu 16  jei sistema nebuvo apmokyta su naujais faktais
; Tad si taisykle bus antra kuria paleis JESS variklis
; pagal fakta next-gensym-idx is failo "examples/animal.dat" kuris lygu 16  jei sistema nebuvo apmokyta su naujais faktais

(defrule initialize-2
  (declare (salience 100))            ; padidinam taisykles prioriteta
  ?fact <- (next-gensym-idx ?idx)     ; priskiriame kintamajam  ?fact fakto  next-gensym-idx identifikatoriu 
  =>
 (retract ?fact)                      ; ismetam fakta ?fact is faktu bazes  
 (setgen ?idx))                       ; inicializuojame globalu sistemos skaitliuka (16) ziurim faila "examples/animal.dat"




; Si taisykle atsakinga uz vartotojui uzduodamus klausimus
; sistema perbega faktu medi kuris aprasytas faile "examples/animal.dat" 
; ir aktivizuoja ta saka kuri sutampa su faktu kurio pavadinimas current-node
; atsakymas nuskaitomas su komanda read


(defrule ask-decision-node-question
   ?node <- (current-node ?name)    ; Tas pats kintamasis  ?name     Pastaba:  Fakto adreso priskyrimas kintamajam  ?node  neturi jokios itakos nes jis paskui niekur nenaudojamas
   (node (name ?name)               ; ir cia ?name  privercia sustoti ties faktu  current-node ?name
         (type decision)
         (question ?question))
   (not (answer ?))                 ; patikriname kad nebutu jokio atsakymo
   =>
   (printout t ?question " (yes or no) ")
   (assert (answer (read))))


; jei atsakymas nelygus yes arba no tada 
; atsakymo faktas ismetamas

(defrule bad-answer
   ?answer <- (answer ~yes&~no)
   =>
   (retract ?answer))


; jei atsakymas yes
; persokama prie faktu medzio sakos kurios pavadinimas irasytas prie yes-node sloto 

(defrule proceed-to-yes-branch
   ?node <- (current-node ?name)
   (node (name ?name)
         (type decision)
         (yes-node ?yes-branch))
   ?answer <- (answer yes)
   =>
   (retract ?node ?answer)    ; ismetame faktus su adresu  ?node ir  ?answer
   (assert (current-node ?yes-branch)))  ; priskiriame fakta (current-node ?yes-branch)

; jei atsakymas no
; persokama prie faktu medzio sakos kurios pavadinimas irasytas prie no-node sloto 


(defrule proceed-to-no-branch
   ?node <- (current-node ?name)
   (node (name ?name)
         (type decision)
         (no-node ?no-branch))
   ?answer <- (answer no)
   =>
   (retract ?node ?answer)
   (assert (current-node ?no-branch))) 



; Taisykle suveikia kai uzsokame ant atsakymo t.y.  (type answer)

(defrule ask-if-answer-node-is-correct
   ?node <- (current-node ?name)
   (node (name ?name) (type answer) (answer ?value))
   (not (answer ?))
   =>
   (printout t "I guess it is a " ?value crlf)
   (printout t "Am I correct? (yes or no) ")
   (assert (answer (read))))


; Jeigu patvirtiname kad sistema atpejo
; Tai sistema pasiulo dar karta pameginti
(defrule answer-node-guess-is-correct
   ?node <- (current-node ?name)
   (node (name ?name) (type answer))
   ?answer <- (answer yes)
   =>
   (assert (ask-try-again))
   (retract ?node ?answer))


; Jeigu nepatvirtiname kad sistema atpejo
; Tai sistema aktivizuoja sistemos taisykliu pakeitima
; Suveikia taisykle replace-answer-node

(defrule answer-node-guess-is-incorrect
   ?node <- (current-node ?name)
   (node (name ?name) (type answer))
   ?answer <- (answer no)
   =>
   (assert (replace-answer-node ?name))
   (retract ?answer ?node))

; Kai nera fakto answer ir faktas ask-try-again teigiamas viskas is naujo
(defrule ask-try-again
   (ask-try-again)
   (not (answer ?))
   =>
   (printout t "Try again? (yes or no) ")
   (assert (answer (read))))



 
 ;  Jeigu norime dar karta is naujo tai si taisykle ta padaro
   
(defrule one-more-time
   ?phase <- (ask-try-again)
   ?answer <- (answer yes)
   =>
   (retract ?phase ?answer)
   (assert (current-node root)))

; Issaugom naujus faktus ir iseinam is sistemos
(defrule no-more
   ?phase <- (ask-try-again)
   ?answer <- (answer no)
   =>
   (retract ?phase ?answer)
   (bind ?g (gensym*))
   (assert (next-gensym-idx (sub-string 4 (str-length ?g) ?g)))
   (save-facts "examples/animal.dat" node next-gensym-idx))


; Taisykle skirta pakoreguoti faktu medi
; Kai sistema atsake neteisingai

(defrule replace-answer-node
   ?phase <- (replace-answer-node ?name)
   ?data <- (node (name ?name) 
                  (type answer) 
                  (answer ?value))
   =>
   (retract ?phase)
   ; Determine what the guess should have been
   (printout t "What is the animal? ")
   (bind ?new-animal (read))
   ; Get the question for the guess
   (printout t "What question when answered yes ")
   (printout t "will distinguish " crlf "   a ")
   (printout t ?new-animal " from a " ?value "? ")
   (bind ?question (readline))
   (printout t "Now I can guess " ?new-animal crlf)
   ; Create the new learned nodes
   (bind ?newnode1 (gensym*))
   (bind ?newnode2 (gensym*))
   (modify ?data (type decision)
                 (question ?question)
                 (yes-node ?newnode1)
                 (no-node ?newnode2))
   (assert (node (name ?newnode1)
                 (type answer) 
                 (answer ?new-animal)))
   (assert (node (name ?newnode2)
                 (type answer)
                 (answer ?value)))
   ; Determine if the player wants to try again
   (assert (ask-try-again)))


(reset)
(run)
