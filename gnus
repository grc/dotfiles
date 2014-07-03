(require 'nnir)

(setq gnus-always-read-dribble-file t)
(setq gnutls-min-prime-bits 727) 	; back to the gnutls default

(setq gnus-summary-line-format "%U%R%z%d%I%(%[%4L: %-23,23f%]%) %s\n")


(setq gnus-select-method  '(nnimap "personal"
				   (nnimap-stream ssl)
				   (nnimap-address "imap.gmail.com")
				   (nnimap-server-port 993)))

(setq gnus-secondary-select-methods
   '((nnimap "work"
           (nnimap-stream ssl)
           (nnimap-address "imap.gmail.com")
	   (nnimap-server-port 993))
     (nntp "news.gmane.org")))

(add-hook 'gnus-group-mode-hook 'gnus-topic-mode)

(setq message-forward-as-mime nil)


;;; gnus-alias to select an identity to post as

(require 'gnus-alias)
(setq gnus-alias-identity-alist 
      '(("work"
	 nil
	 "giles@pexip.com"
	 "Pexip"
	 nil
	 nil
	 "Giles Chamberlin")
	("jujutsu"
	 nil
	 "giles@jujutsu.org.uk"
	 nil
	 ""
	 "Giles")
	("sjld"
	 nil
	 "giles@sjld.co.uk"
	 nil
	 ""
	 "Giles")))

(gnus-alias-init)
(setq gnus-alias-default-identity "work")
(define-key message-mode-map [f8] 'gnus-alias-select-identity)



(setq mm-discouraged-alternatives '("text/html" "text/richtext"))



;;; ical integration 


(add-to-list 'load-path "~/git-repos/ical-event")
(require 'gnus-calendar)
(gnus-calendar-setup)
    
;; to enable optional iCalendar->Org sync functionality
;; NOTE: both the capture file and the headline(s) inside must already exist
(setq gnus-calendar-org-capture-file "~/org/notes.org")
(setq gnus-calendar-org-capture-headline '("Calendar"))
(gnus-calendar-org-setup)



;; Demons
(require 'gnus-demon)
(gnus-demon-add-handler 'gnus-demon-scan-news 15 5)



;; Local Variables:
;; mode: emacs-lisp
;; End:
