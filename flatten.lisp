;;;; How to flatten a list in Common Lisp
(defun flatten (lst)
  (let ((new-list nil)) 
    (dolist (item lst)
      (if (listp item)
          (dolist (item2 (flatten item))                      
            (setq new-list (append new-list (list item2))))        
          (setq new-list (append new-list (list item)))))
    new-list))
