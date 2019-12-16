(define (script-fu-wave-crop image 
				drawable
				ampl-factor
				reverse-phase)
	(gimp-context-push)
	(gimp-image-set-active-layer image drawable)
	(gimp-image-undo-group-start image)
	; Проверяем наличие выделения
	(if (= (car (gimp-selection-bounds image)) FALSE)
	(gimp-message "Кадрирование не выполнено, так как отсутствует выделение.")
	(let* (
			; Получаем координаты углов выделения
			(selection-box (cdr (gimp-selection-bounds image)))
			; Получаем координаты верхнего левого угла выделения
			(x1 (car selection-box))
			(y1 (cadr selection-box))
			; Получаем координаты нижнего правого угла выделения
			(x2 (caddr selection-box))
			(y2 (cadddr selection-box))
			; Получаем размеры изображения
			(image-width (car (gimp-image-width image)))
		        (image-height (car (gimp-image-height image)))
		)
	; Проверяем, не выделено ли все изображение
	(if (and (= x1 0) (= y1 0) (= x2 image-width) (= y2 image-height))
		(gimp-message "Кадрирование не выполнено, так как выделено все изображение.")
		(let* (
			; Создаем массив координат точек для gimp-free-select.
			; Для каждой точки требуется 2 элемента (x и y координаты)
			(points (cons-array 
				(* (+ (* 2 (- x2 x1)) (* 2 (- y2 y1))) 2)
				'double))
			(i 0)
			; Вычисляем коэффициенты, влияющие на амплитуду волн
			(ampl-x (* (- y2 y1) ampl-factor 0.005))
			(ampl-y (* (- x2 x1) ampl-factor 0.005))
			; В вычислениях понадобится значение "два пи"
			(2pi 6.2832)
			(x x1)
			(y y1)
			)
		; Если нужна обратная фаза
		(if (= reverse-phase TRUE) 
			(begin
				; меняем знак коэфициентов
				(set! ampl-x (- ampl-x))
				(set! ampl-y (- ampl-y))
			)
		)
		; Идем от верхнего левого к верхнему правому углу выделения
		(while (< x x2)
			(aset points i x)
			; Если верхний край выделения 
			; не совпадает с краем изображения,
			(if (> y1 0)
				; то движемся по волнистой линии,
				(aset points (+ i 1) 
					(+ y1 (* ampl-y
					(sin (* 2pi (/ (- x x1) (- x2 x1)))))))
				; иначе - по прямой.
				(aset points (+ i 1) 0)
			)
			(set! i (+ i 2))
			(set! x (+ x 1))
		)
		; Идем от верхнего правого к нижнему правому углу выделения
		(while (< y y2)
			; Если правый край выделения 
			; не совпадает с краем изображения,
			(if (< x2 image-width)
				; то движемся по волнистой линии,
				(aset points i 
					(+ x2 (* ampl-x 
					(sin (- (* 2pi (/ (- y y1) (- y2 y1))))))))
				; иначе - по прямой.
				(aset points i image-width)
			)
			(aset points (+ i 1) y)
			(set! i (+ i 2))
			(set! y (+ y 1))
		)
		; Идем от нижнего правого к нижнему левому углу выделения
		(while (> x x1)
			(aset points i x)
			; Если нижний край выделения 
			; не совпадает с краем изображения,
			(if (< y2 image-height)
				; то движемся по волнистой линии,
				(aset points (+ i 1) 
					(+ y2 (* ampl-y 
					(sin (* 2pi (/ (- x x1) (- x2 x1)))))))
				; иначе - по прямой.
				(aset points (+ i 1) image-height)
			)
			(set! i (+ i 2))
			(set! x (- x 1))
		)
		; Идем от нижнего левого к верхнему левому углу выделения
		(while (> y y1)
			; Если левый край выделения 
			; не совпадает с краем изображения,
			(if (> x1 0)
				; то движемся по волнистой линии,
				(aset points i 
					(+ x1 (* ampl-x 
					(sin (- (* 2pi (/ (- y y1) (- y2 y1))))))))
				; иначе - по прямой.
				(aset points i 0)
			)
			(aset points (+ i 1) y)
			(set! i (+ i 2))
			(set! y (- y 1))
		)
		; Создаем новое выделение по координатам точкек
		(gimp-free-select image i points CHANNEL-OP-REPLACE TRUE FALSE 0)
		; Инвертируем выделение
		(gimp-selection-invert image)
		; Добавляем прозрачность
		(gimp-layer-add-alpha drawable)
		; Удаляем выделенную часть изображения
		(gimp-edit-clear drawable)
		; Снимаем выделение
		(gimp-selection-none image)
		; Отсекаем пустоту
		(plug-in-autocrop 1 image drawable)
		)
	) ) )
	(gimp-image-undo-group-end image)
	(gimp-displays-flush)
	(gimp-context-pop)
)

(script-fu-register "script-fu-wave-crop"
	"Screenshot: crop with waves"
	"Откадрировать изображение с эффектом волны по текущему выделению."
	"Pupkin <pupkin@example.com>"
	"Gehörn und Spitzbeine GmbH"
	"2010/10/6"
	"RGB* GRAY*"
	SF-IMAGE      	"Image"                   	0
	SF-DRAWABLE   	"Drawable"                	0
	SF-ADJUSTMENT  "Wave (0 - calm, 10 - tsunami)"  '(3 0 10 1 0 0)
	SF-TOGGLE      "Inverted"		       	FALSE
)

(script-fu-menu-register "script-fu-wave-crop"
                         "<Image>/Filters/Screenshots")
