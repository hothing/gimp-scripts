(define (script-fu-cut-corners 	image 
				drawable
				radius
				only-top)
	(gimp-context-push)
	(gimp-image-set-active-layer image drawable)
	(gimp-image-undo-group-start image)

	; Добавляем альфа-канал (прозрачность)
	(gimp-layer-add-alpha drawable)
	; Выделяем все изображение, cкругляем уголки выделения
	(gimp-round-rect-select image 0 0 (car (gimp-image-width image))
		        (car (gimp-image-height image)) 
			radius radius CHANNEL-OP-REPLACE TRUE FALSE 0 0)
	; Инвертируем выделение
	(gimp-selection-invert image)
	; Если требуется подрезать только верхние уголки...
	(if (= only-top TRUE)
		; ...то вычитаем из выделения область изображения
		; охватывающую оба нижних уголка
		(gimp-rect-select image 
				0
				(- (car (gimp-image-height image)) radius) 
				(car (gimp-image-width image)) 
				radius 
				CHANNEL-OP-SUBTRACT 
				FALSE 
				0))
	; Удаляем выделенные области
	(gimp-edit-clear drawable)
	; Снимаем выделение
	(gimp-selection-none image)
	
	(gimp-image-undo-group-end image)
	(gimp-displays-flush)
	(gimp-context-pop)
)

(script-fu-register "script-fu-cut-corners"
	"Screenshot: delete corners (Win7)"
	"x"
	"Pupkin <pupkin@example.com>"
	"Gehörn und Spitzbeine GmbH"
	"2010/10/6"
	"RGB*"
	SF-IMAGE      	"Image"                 	0
	SF-DRAWABLE   	"Drawable"              	0
	SF-ADJUSTMENT 	"Radius (0 - 20 px)"	'(8 0 20 1 10 0 0)
	SF-TOGGLE	  	"Only opper edges"		FALSE
	
)

(script-fu-menu-register "script-fu-cut-corners"
                         "<Image>/Filters/Screenshots")