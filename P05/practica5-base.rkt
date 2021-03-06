#lang plai
;Según yo este base es identica a la de la practica 4, solo que en lugar de definir FAE definimos el RCFAEL.
;Los parse son identicos, las bisquedas son iguales, no hay pedo con eso.

;Bindings for RCFAELS
(define-type Binding
  [bind (name symbol?) (val RCFAELS?)])

;RCFAELS type definition, for desugar
(define-type RCFAELS
  [numS (n number?)]
  [boolS (v boolean?)]
  [idS (name symbol?)]
  [funS (params (listof symbol?))
        (body RCFAELS?)]
  [appS (fun RCFAELS?)
        (args (listof RCFAELS?))]
  [opS (f procedure?)
       (args RCFAELS?)]
  [binopS (f procedure?)
          (l RCFAELS?)
          (r RCFAELS?)]
  [withS (bindings (listof bind?))(body RCFAELS?)]
  [with*S (bindings 
           (listof bind?))(body RCFAELS?)]
  [if0S (cond RCFAELS?)
        (then RCFAELS?)
        (else RCFAELS?)]
  [recS (id RCFAELS?) (expr RCFAELS?) (body RCFAELS?)]
  [equal?S (id1 RCFAELS?)
           (id2 RCFAELS?)]
  [MListS (e RCFAELS?)
          (lst RCFAELS?)] )


;RCFAEL type definition
(define-type RCFAEL
  [id (name symbol?)]
  [num (n number?)]
  [bool (v boolean?)]
  [Mlist (e RCFAEL?) (lst RCFAEL?)]
  [with (name symbol?) (named-expr RCFAEL?) (body RCFAEL?)]
  [rec (id RCFAEL?) (expr RCFAEL?) (body RCFAEL?)]
  [fun (params (listof symbol?))
       (body RCFAEL?)]
  [if0 (cond RCFAEL?)
        (then RCFAEL?)
        (else RCFAEL?)]
  [isequal? (id1 RCFAEL?)
          (id2 RCFAEL?)]
  [app (fun RCFAEL?)
       (args (listof RCFAEL?))]
  [binop (f procedure?)
         (l RCFAEL?)
         (r RCFAEL?)]
  [op (f procedure?)
      (args RCFAEL?)])


;Type-Value
(define-type RCFAEL-Value
  [numV (n number?)]
  [closureV (param (listof symbol?))
	    (body RCFAEL?)
	    (env Env?)]
  [boolV (b boolean?)] )

(define-type MList
  [MEmpty]
  [MCons (e RCFAEL-Value?) (lst MList?)])

;Enviroment definition
(define-type Env
  [mtSub]
  [aSub (name symbol?)
        (value RCFAEL-Value?)
        (env Env?)]
  [aRecSub (name symbol?)
           (value boxed-RCFAEL-Value?)
           (env Env?)])

;box
(define (boxed-RCFAEL-Value? v)
  (and (box? v)
       (RCFAEL-Value? (unbox v))))

; FUNCIONES AUXILIARES 
; WE NEED TO MODIFY FROM DOWN HERE.

;; A::= <number>|<symbol>|listof(<A>)
;; B::= (list <symbol> <A>)
;; parse-bindings: listof(B) -> listof(bind?)
;; "Parsea" la lista de bindings lst en sintaxis concreta
;; mientras revisa la lista de id's en busca de repetidos.
;; (define (parse-bindings lst)
(define (parse-bindings lst allow)
  (let ([bindRep (buscaRepetido lst (lambda (e1 e2) (symbol=? (car e1) (car e2))))])
    (if (or (boolean? bindRep) allow)
	(map (lambda (b) (bind (car b) (parse (cadr b)))) lst)
	(error 'parse-bindings (string-append "El id " (symbol->string (car bindRep)) " está repetido")))))

(define (elige s)
  (case s
    [(+) +]
    [(-) -]
    [(*) *]
    [(/) /]
    [(<) <]
    [(<=) <=]
    [(>) >]
    [(>=) >=]
    [(and) (lambda (x y) (and x y))]
    [(or) (lambda (x y) (or x y))] ))

(define (eligeUn s)
  (case s
    [(inc) add1]
    [(dec) sub1]
    [(zero?) zero?]
    [(num?) num?]
    [(neg) not]
    [(bool?) boolean?]
    [(first) first]
    [(rest) rest]
    [(empty?) empty?]
    [(list?) list?]))


;; buscaRepetido: listof(X) (X X -> boolean) -> X
;; Dada una lista, busca repeticiones dentro de la misma
;; usando el criterio comp. Regresa el primer elemento repetido
;; o falso eoc.
;; (define (buscaRepetido l comp)
(define (buscaRepetido l comp)
  (cond
   [(empty? l) #f]
   [(member? (car l) (cdr l) comp) (car l)]
   [else (buscaRepetido (cdr l) comp)]))

;; member?: X listof(Y) (X Y -> boolean) -> boolean
;; Determina si x está en l usando "comparador" para
;; comparar x con cada elemento de la lista.
;; (define (member? x l comparador)
(define (member? x l comparador)
  (cond
   [(empty? l) #f]
   [(comparador (car l) x) #t]
   [else (member? x (cdr l) comparador)]))

;; A::= <number>|<symbol>|listof(<A>)
;; parse: A -> RCFAELS
(define (parse sexp)
  (cond
   [(number? sexp) (numS sexp)]
   [(boolean? sexp) (boolS sexp)]
   [(symbol? sexp) (idS sexp)]
   [(list? sexp)
    (case (car sexp)
      [(equal?) (isequal? (parse (cadr sexp)) (parse (caddr sexp)))]
      [(if)(if0S (parse(cadr sexp)) (parse(caddr sexp))(parse(cadddr sexp)))]
      [(with) (withS (parse-bindings (cadr sexp) #f) (parse (caddr sexp)))]
      [(with*) (with*S (parse-bindings (cadr sexp) #t) (parse (caddr sexp)))]
      [(fun) (funS (cadr sexp) (parse (caddr sexp)))]
      [(+ - / * < > <= >= and or) (binopS (elige (car sexp)) (parse (cadr sexp)) (parse (caddr sexp)))]
      [(inc dec zero? num? neg bool? first rest empty? list?) (opS (eligeUn (car sexp)) (parse (cadr sexp)))]
      [else (appS (parse (car sexp)) (map parse (cdr sexp)))])]))