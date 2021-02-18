; inicializuojame du globalius fuzzy kintamuosius
; pirmame bus aprasyta temperaturos fuzzy koncepcija
; antrame - slegio

(defglobal ?*tempFvar* = (new nrc.fuzzy.FuzzyVariable "temperature" 0.0 100.0 "C"))
(defglobal ?*pressFvar* = (new nrc.fuzzy.FuzzyVariable "pressure" 0.0 10.0 "kilo-pascals"))



; si taisykle neturi jokiu faktu todel ji suveiks pirmoji
; kitu taisykliu faktai bus nustatyti tik po sios taisykles suveikimo

(defrule init
  =>
   (load-package nrc.fuzzy.jess.FuzzyFunctions)
   (bind ?xHot  (create$ 25.0 35.0))  ; xHot priskiriama du reziai nusakantys nuo kokios iki kokios temperaturos skaitome kad vanduo karstas
   (bind ?yHot  (create$ 0.0 1.0))    
   (bind ?xCold (create$ 5.0 15.0))
   (bind ?yCold (create$ 1.0 0.0))

   ; toliau pridedame temperaturos Fuzzy kintamajam 4 temperatura apibudinancias kategorijas
   ; pirmos 2 pagal x asies rezius   likusios dvi interpretuojamos is sakiniu very hot  ir not hot and (not cold)
   
   (?*tempFvar* addTerm "hot" ?xHot ?yHot 2)
   (?*tempFvar* addTerm "cold" ?xCold ?yCold 2)
   (?*tempFvar* addTerm "veryHot" "very hot")
   (?*tempFvar* addTerm "medium" "not hot and (not cold)")
   
   
   ; prodedam 3 slegio kategorijas
   (?*pressFvar* addTerm "low" (new nrc.fuzzy.ZFuzzySet 2.0 5.0))
   (?*pressFvar* addTerm "medium" (new nrc.fuzzy.PIFuzzySet 5.0 2.5))
   (?*pressFvar* addTerm "high" (new nrc.fuzzy.SFuzzySet 2.0 5.0))

   ; inicializuojam pirma fakta kuris privers suveikti taisykle: temp-hot-press-lowOrMedium
   (assert (theTemp (new nrc.fuzzy.FuzzyValue ?*tempFvar* "very medium")))
)

; si taisykle suveiks ir kai temperatura   very medium    nes ju reziai persidengia
(defrule temp-hot-press-lowOrMedium
   (theTemp ?t&:(fuzzy-match ?t "hot"))       ; hot     persidengia su   very medium    
 =>
   (assert (thePress (new nrc.fuzzy.FuzzyValue ?*pressFvar* "low or medium")))    ; naujas faktas kuris privers suveikti do-the-printing taisykle
)

;; atspausdiname keleta fuzzy kintamuju
(defrule do-the-printing
   (theTemp ?t)
   (thePress ?p)
 =>
   (printout t "Temp is: " (?t toString) crlf "Press is: " (?p toString) crlf)
   (bind ?theFzVals
        (create$ (new nrc.fuzzy.FuzzyValue ?*tempFvar* "hot") ?t)
   )
   (printout t (call nrc.fuzzy.FuzzyValue plotFuzzyValues "*+" ?theFzVals) crlf)
   (printout t (call (new nrc.fuzzy.FuzzyValue ?*pressFvar* "low or medium")
                      plotFuzzyValue "*") crlf)
   (printout t (?p plotFuzzyValue "*") crlf)
)



(reset)
(call nrc.fuzzy.FuzzyRule
         setDefaultRuleExecutor (new nrc.fuzzy.LarsenProductMaxMinRuleExecutor))
(run)   
