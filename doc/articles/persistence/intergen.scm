(load "heappic.scm")

(define (draw)
  (translate (make-point 100 100))
  ;(background-grid)
  ;;
  (bind ((proot (show-heap 0 'll "Persistent"))
         (troot (show-heap 1 'ul "Transient"))
         (a (obj 1 2 1))
         (b (obj 1 4 1))
         (c (obj 1 2 3))
         (h (obj 1 4 4))
         (i (obj 1 6 4))
         (l (obj 1 8 4))
         ;;
         (d (obj 0 2 2))
         (e (obj 0 2 4))
         (f (obj 0 4 3))
         (g (obj 0 6 3))
         (j (obj 0 6 1))
         (k (obj 0 8 1)))
    ;;
    (define (label n name)
      (n 'draw)
      (cshow (x (n 'at)) (- (y (n 'at)) 2) name))
    ;;
    (setfont *label-font*)
    (label a "a")
    (label b "b")
    (label c "c")
    (label d "d")
    (label e "e")
    (label f "f")
    (label g "g")
    (label h "h")
    (label i "i")
    (label j "j")
    (label k "k")
    (label l "l")
    ;;
    (edge a b)
    (edge a c)
    (edge c d)
    (edge e f)
    (edge f g)
    (edge f h)
    (edge h i)
    (edge i j)
    (edge j k)
    (edge k l)
    ;;
    (edge proot e)
    (edge troot a)
    (values)))


