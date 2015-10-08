#lang plai

;;Array
(define-type Array
  [MArray (n number?)
          (l list?)])

(define ar (MArray 3 '(1 2 3)))

;MList
(define-type MList
  [MEmpty]
  [MCons (e any?)(l MList?)])

;;Para aceptar elementos de cualquier tipo
(define (any? e) #t)

;;NTree
(define-type NTree
  [TLEmpty]
  [NodeN (num number?)(lst list?)])

;;Position
(define-type Position
  [2D-Point(x number?) (y number?)])

;;Figure
(define-type Figure
  [Circle (e Position?) (n number?)]
  [Square(e Position?) (n number?)]
  [Rectangle(e Position?) (high number?) (lng number?)])


;;Area
(define (area fig)
  (type-case Figure fig
    [Circle (e n)(* pi (* n n))]
    [Square (e n)(* n n)]
    [Rectangle (e high lng) (* high lng)]))


;;Coordinates
(define-type Coordinates
  [GPS (lat number?)
       (long number?)])

;;Location
(define-type Location
  [building (name string?)
            (loc GPS?)])


;; Coordenadas GPS
(define gps-satelite (GPS 19.510482 -99.23411900000002))
(define gps-ciencias (GPS 19.3239411016 -99.179806709))
(define gps-zocalo (GPS 19.432721893261117 -99.13332939147949))
(define gps-perisur (GPS 19.304135 -99.19001000000003))
(define plaza-satelite (building "Plaza Satelite" gps-satelite))
(define ciencias (building "Facultad de Ciencias" gps-ciencias))
(define zocalo (building "Zocalo" gps-zocalo))
(define plaza-perisur (building "Plaza Perisur" gps-perisur))

(define plazas (MCons plaza-satelite (MCons plaza-perisur (MEmpty))))

; Función SetValueA
(define (setvalueA n p ar)
  (type-case Array ar 
    [MArray (i list)
            (cond
              [(equal? p 0) "Array out of bounds"]
              [(> p i) "Array out of bounds"]
              [else (MArray i (replace list n p))] )]))

; Replace(lista, n elemento a cambiar, i indice)
(define (replace list n p)
  (cond
    ;este es el caso de escape de la lista.
    [(equal? p 1) (cons n (cdr list))]
    [else (cons (car list) (replace (cdr list) n (- p 1)))] ))

;Test para setvalueA
(test (setvalueA 5 0 (MArray 0 '())) "Array out of bounds")
(test (setvalueA 6 3 (MArray 3 '(1 2 3))) (MArray 3 '(1 2 6)))
(test (setvalueA 6 7 (MArray 10 '(0 1 2 3 4 5 5 7 8 9))) (MArray 10 '(0 1 2 3 4 5 6 7 8 9))) 