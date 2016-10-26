#!/bin/sh
# Exports project "$1" as a PNG file "$2".
gimp --no-interface --batch '
(let*
  (
    (input "'"$1"'")
    (output "'"$2"'")
    (image (car
      (gimp-file-load RUN-NONINTERACTIVE input input)))
    (drawable (car
      (gimp-image-merge-visible-layers image CLIP-TO-IMAGE)))
  )
  (gimp-layer-resize-to-image-size drawable)
  (file-png-save RUN-NONINTERACTIVE image drawable output output 0 9 1 0 0 0 1)
  (gimp-image-delete image)
  (gimp-quit 0)
)
'
