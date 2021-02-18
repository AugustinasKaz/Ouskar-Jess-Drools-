
;; **********************************************************************
;;                           Frame_lt.clp
;;
;; keletas paprastu komponentu GUI    sasaja  su Jess
;;
;; **********************************************************************

;; ******************************

(import java.awt.*)
(import jess.awt.*)

;; ******************************
;; globalus kintamieji matomi visame Jess programos    "skope"

(defglobal ?*f* = 0)
(defglobal ?*m* = 0)
(defglobal ?*t* = 0)
(defglobal ?*b* = 0)
(defglobal ?*b1* = 0)
;; ******************************
;; Funkcijos kurios iskvieciamos sios aplikacijos remuose

(deffunction create-frame ()
  (bind ?*f* (new Frame "Jess GUI demonstracija"))
  (set ?*f* background (new Color 222 250 155))
  (set ?*f* layout (new GridLayout 14 8)))



; funkcija prideda ekrano komponentus 

(deffunction add-widgets ()
  (?*f* add (new Label "Pasirinkite kas jus toks: "))
  (bind ?*m* (new Choice))
  (?*m* addItem "Studentas")
  (?*m* addItem "Lektorius")
  (?*m* addItem "Profesorius")
  (?*m* addItem "Destytojas")
  (?*f* add ?*m*)


  (?*f* add (new Label "Cia galite ivesti bet koki teksta: "))
  (?*f* add (new Label " Koks tavo vidurkis? "))
    
  
  (add-widgets2)         ; tiesiog galima iskviesti funkcija kuri prides tekstini lauka

  (?*f* add (new Label " "))
  (?*f* add (new Label "Klavisas kuris is tikro nieko nedaro bet"))
  (?*f* add (new Label "galima prikabinti ActionListener frame_lt.clp programoje"))
  (?*f* add (new Label "ir iskviesti norima funkcija : "))


  (add-widgets3)         ; cia kita funkcija kuri prides paspaudimo klavisa     
  
  )

; pridedame tekstini lauka prie musu formos

(deffunction add-widgets2 ()
  

  (bind ?*t* (new TextField "9.5 " 30 ))

  (?*f* add ?*t*)
  
 )

; pridedame push klavisa prie musu formos

(deffunction add-widgets3 ()
  
  (bind ?*b* (new java.awt.Button "Sveiki atvyke i labor. darbus"))

  (?*f* add ?*b* )
  


  (?*f* add (new Label " "))
  (?*f* add (new Label "Jei norite uzdaryti forma spauskite"))

  (bind ?*b1* (new java.awt.Button "Baigti darbus"))
  (?*f* add ?*b1* )


 )



; prie kiekvieno komponento pridedame vartotojo veiksmu stebejimo komponentus

(deffunction add-behaviours ()
  (?*f* addWindowListener
        (new WindowListener frame-handler (engine)))     ; formos stebejimo funkcija bus      frame-handler        
  (?*m* addItemListener
        (new ItemListener menu-handler (engine)))        ; pasirinkimo is listo funkcija bus    menu-handler 

  (?*t* addActionListener
        (new ActionListener  menu-handler2 (engine)))     ; paspaudus enter tekstinemia lauke     funkcija menu-handler2 bus iskviesta

  (?*b1* addActionListener
        (new ActionListener  frame-handler2 (engine)))     ; paspaudus enter tekstinemia lauke     funkcija menu-handler2 bus iskviesta
        
        )


; funkcia kuri iskviecia pagrindini freima

(deffunction show-frame ()
  (?*f* validate)
  (?*f* pack)
  (?*f* show))


; kai manipuliuojate pagrindiniu freima si funkcija patikrina ar tai formos uzdarymo veikasmas ir uzdaro forma

(deffunction frame-handler (?event)
  (if (= (?event getID) (get-member ?event WINDOW_CLOSING)) then 
    (call (get ?event source) dispose)
    (call System exit 0)
    
    ))

(deffunction frame-handler2 (?event)
    (call System exit 0)
    
    )



; funkcija iskvieciama kai kas nors pasirinkta is listo

(deffunction menu-handler (?event)
  (printout t "Jusu pasirinkimas teisingas. Jus pasirinkote: " (call (get ?event item) toString) crlf)
  
      
  )

; kai paspaudete Enter teksto lauke si funkcija iskvieciama

(deffunction menu-handler2 (?event)
  (printout t "Jus pasirinkote: " (call (get ?event source) getText) crlf)
  
      
  )



;; ******************************
;; Cia komandos kurias nuosekliai Jess paleidzia 
;; Tiesiog iskvieciamos 4 funkcijos 

(create-frame)
(add-widgets)
(add-behaviours)
(show-frame)
