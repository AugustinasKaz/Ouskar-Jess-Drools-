;; Two globals to hold our two FuzzyVariables for temperature and pressure
(defglobal ?*tempFvar* = (new nrc.fuzzy.FuzzyVariable "temperature" 0.0 100.0 "C"))
(defglobal ?*pressFvar* = (new nrc.fuzzy.FuzzyVariable "pressure" 0.0 10.0 "kilo-pascals"))

;; An initialization rule that adds the terms to the FuzzyVariables and
;; asserts the input FuzzyValue 'temperature is very medium'
(defrule init
  =>
   (load-package nrc.fuzzy.jess.FuzzyFunctions)
   (bind ?xHot  (create$ 25.0 35.0))
   (bind ?yHot  (create$ 0.0 1.0))
   (bind ?xCold (create$ 5.0 15.0))
   (bind ?yCold (create$ 1.0 0.0))
   ;; terms for the temperature Fuzzy Variable
   (?*tempFvar* addTerm "hot" ?xHot ?yHot 2)
   (?*tempFvar* addTerm "cold" ?xCold ?yCold 2)
   (?*tempFvar* addTerm "veryHot" "very hot")
   (?*tempFvar* addTerm "medium" "not hot and (not cold)")
   ;; terms for the pressure Fuzzy Variable
   (?*pressFvar* addTerm "low" (new nrc.fuzzy.ZFuzzySet 2.0 5.0))
   (?*pressFvar* addTerm "medium" (new nrc.fuzzy.PIFuzzySet 5.0 2.5))
   (?*pressFvar* addTerm "high" (new nrc.fuzzy.SFuzzySet 2.0 5.0))

   ;; add the fuzzy input -- temperature is very medium
   (assert (theTemp (new nrc.fuzzy.FuzzyValue ?*tempFvar* "very medium")))
)

;; the rule 'if temperature hot then pressure low or medium'
(defrule temp-hot-press-lowOrMedium
   (theTemp ?t&:(fuzzy-match ?t "hot"))
 =>
   (assert (thePress (new nrc.fuzzy.FuzzyValue ?*pressFvar* "low or medium")))
)

;; a rule to print some interesting things
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


			  

 ;;(reset)
   ;;(run)       <--- uses the initial default MamdaniMinMaxMinRuleExecutor
(reset)
(call nrc.fuzzy.FuzzyRule
         setDefaultRuleExecutor (new nrc.fuzzy.LarsenProductMaxMinRuleExecutor))
(run) 	