

(message "Reading .emacs")

(server-start)

;;; Set up my load path

(let ((default-directory "~/elisp"))
  (normal-top-level-add-subdirs-to-load-path))

(let ((default-directory "~/git-repos"))
  (normal-top-level-add-to-load-path '("ag.el"
                                       "dash.el"
                                       "elnode"
                                       "emacs-db"
                                       "emacs-fakir"
                                       "emacs-kv"
                                       "emacs-kv"
                                       "emacs-noflet"
                                       "emacs-request"
                                       "emacs-web"
                                       "esxml"
                                       "esxml"
                                       "flymake-easy"
                                       "flymake-jslint"
                                       "git-modes"
                                       "js2-mode"
                                       "magit"
                                       "multiple-cursors"
                                       "org-mode/lisp"
                                       "org-trello"
                                       "popwin-el"
                                       "predictive"
                                       "s.el"
                                       "smex"
                                       "yasnippet" )))





(setq-default indent-tabs-mode nil)
(setq visible-bell t)
(set-mouse-color "white")

(setq user-mail-address "giles@jujutsu.org.uk")

(defalias 'yes-or-no-p 'y-or-n-p)

(require 'dired-x)



(require 'ag)

;;; Javascript


(require 'js2-mode)


(require 'js-comint)
;; Use node as our repl
(setq inferior-js-program-command "node")
(setenv "NODE_NO_READLINE" "1")
(setq inferior-js-program-command "/usr/bin/java org.mozilla.javascript.tools.shell.Main")
(add-hook 'js2-mode-hook '(lambda () 
			    (local-set-key "\C-x\C-e" 'js-send-last-sexp)
			    (local-set-key "\C-\M-x" 'js-send-last-sexp-and-go)
			    (local-set-key "\C-cb" 'js-send-buffer)
			    (local-set-key "\C-c\C-b" 'js-send-buffer-and-go)
			    (local-set-key "\C-cl" 'js-load-file-and-go)
			    ))



(require 'flymake-jslint)
(add-hook 'js2-mode-hook 'flymake-jslint-load)


;;; yasnippet

(require 'yasnippet)
(yas-global-mode 1)


;; Authentication credentials are held on .authinfo

(require 'message)
;; In order to use gmail's smtp server, I needed to install gnutls on OSX.
(setq message-insert-canlock nil
      message-send-mail-function 'smtpmail-send-it
      smtpmail-default-smtp-server "smtp.gmail.com"
      smtpmail-smtp-server "smtp.gmail.com"
      smtpmail-smtp-service 587)
      smtpmail-starttls-credentials '(("smtp.gmail.com" 587 nil nil))






(require 'flyspell)
(setq ispell-program-name "aspell")
(setq ispell-list-command "list")
;; uk dictionary installed via port install aspell-dict-en
;; language customisations occue in .aspell.conf:
;; lang en
;; master en_GB



(defun grc-text-hook ()
  (flyspell-mode)
  (abbrev-mode)
  (auto-fill-mode 1))




(add-hook 'text-mode-hook 'grc-text-hook)


(message "Initialising AucTeX")

(add-to-list 'load-path "/opt/local/share/emacs/site-lisp")
(require 'tex-site)
(setq-default TeX-PDF-mode t)

(load "auctex.el" nil t t)
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)



(require 'eldoc)
(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)


; Mark support in the presence of transient mark mode
; http://www.masteringemacs.org/articles/2010/12/22/fixing-mark-commands-transient-mark-mode/
(defun push-mark-no-activate ()
  "Pushes `point' to `mark-ring' and does not activate the region
Equivalent to \\[set-mark-command] when \\[transient-mark-mode] is disabled"
  (interactive)
  (push-mark (point) t nil)
  (message "Pushed mark to ring"))
(global-set-key (kbd "C-`") 'push-mark-no-activate)



(defun jump-to-mark ()
  "Jumps to the local mark, respecting the `mark-ring' order.
This is the same as using \\[set-mark-command] with the prefix argument."
  (interactive)
  (set-mark-command 1))
(global-set-key (kbd "M-`") 'jump-to-mark)

(defun exchange-point-and-mark-no-activate ()
  "Identical to \\[exchange-point-and-mark] but will not activate the region."
  (interactive)
  (exchange-point-and-mark)
  (deactivate-mark nil))
(define-key global-map [remap exchange-point-and-mark] 'exchange-point-and-mark-no-activate)



; http://emacswiki.org/emacs/InteractivelyDoThings
(require 'ido)
(ido-mode 'both)
(setq ido-auto-merge-delay-time 999)


;;; https://github.com/nonsequitur/smex/
;;; Faster completion for M-p 

(require 'smex)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; This is your old M-x.
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)


;;;; BBDB 
;; Note that when building BBDB from scratch from CVS you need to do a 
;; `make autoloads' before 'make'

(require 'bbdb)
(bbdb-initialize 'gnus 'message)
(add-hook 'gnus-startup-hook 'bbdb-insinuate-gnus)
(bbdb-insinuate-message)

(setq bbdb-file "~/.emacs.d/bbdb")           ;; keep ~/ clean; set before loading


;; This block was initially lifted from
;; http://emacs-fu.blogspot.co.uk/2009/08/managing-e-mail-addresses-with-bbdb.html
(setq 
    bbdb-offer-save 1                        ;; 1 means save-without-asking
    bbdb-use-pop-up nil                        ;; allow popups for addresses
    bbdb-electric-p nil                        ;; be disposable with SPC
    bbdb-popup-target-lines  1               ;; very small
    bbdb-dwim-net-address-allow-redundancy t ;; always use full name
    bbdb-quiet-about-name-mismatches t 
    bbdb-always-add-address t                ;; add new addresses to existing...
                                             ;; ...contacts automatically
    bbdb-canonicalize-redundant-nets-p t     ;; x@foo.bar.cx => x@bar.cx
    bbdb-completion-type nil                 ;; complete on anything
    bbdb-complete-name-allow-cycling t       ;; cycle through matches
                                             ;; this only works partially
    bbbd-message-caching-enabled t           ;; be fast
    bbdb-elided-display t                    ;; single-line addresses

    ;; auto-create addresses from mail
    bbdb/news-auto-create-p 'bbdb-ignore-some-messages-hook   
    bbdb-ignore-some-messages-alist ;; don't ask about fake addresses
    ;; NOTE: there can be only one entry per header (such as To, From)
    ;; http://flex.ee.uec.ac.jp/texi/bbdb/bbdb_11.html

    '(( "From" . "no.?reply\\|DAEMON\\|daemon\\|facebook\\|twitter\\|linkedin\\|github")))



(setq bbdb-auto-notes-alist
      '(("Organization" (".*" company 0))))




(require 'clojure-mode)

(add-hook 'clojure-mode-hook 'show-paren-mode)

(add-hook 'slime-repl-mode-hook 'show-paren-mode)
;;; 


(message "Initialising org-mode")

(require 'org)

(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)
(define-key global-map "\C-cc" 'org-capture)

(setq org-use-sub-superscripts nil)

;; Capture template
(setq org-capture-templates
      '(("t" "Scheduled task" entry
     (file "")
     "\n\n** TODO %^{Title?}\nSCHEDULED: <%<%Y-%m-%d %a>>\n%?"
     :Empty-lines 1)
	("n" "Note" entry
	 (file "")
	 "\n\n**  %?\n"
	 :Empty-lines 1)
	("w" "" entry ;; 'w' for 'org-protocol'
       (file+headline "www.org" "Notes")
       "* %^{Title}\n\n  Source: %u, %c\n\n  %i")))


(setq org-default-notes-file (concat org-directory "/notes.org"))

; enable logging
(setq org-log-done 'time)


;; Make org-table mode available in email
(add-hook 'message-mode-hook 'turn-on-orgtbl)

(require 'footnote)
(add-hook 'message-mode-hook 'footnote-mode)






(setq org-babel-tangle-lang-exts (quote (("clojure" . "clj") ("emacs-lisp" . "el"))))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((ditaa . t))) 

(setq org-src-preserve-indentation t)

;; org and yasnippet workaround
(defun yas/org-very-safe-expand ()
  (let ((yas/fallback-behavior 'return-nil)) (yas/expand)))

(add-hook 'org-mode-hook
	  (lambda ()
	    (make-variable-buffer-local 'yas/trigger-key)
	    (setq yas/trigger-key [tab])
	    (add-to-list 'org-tab-first-hook 'yas/org-very-safe-expand)
	    (define-key yas/keymap [tab] 'yas/next-field)))


;; Beamer in org 8 and later
(require 'ox-beamer)



;; mobile org
(require 'org-mobile)
;; Set to the name of the file where new notes will be stored
(setq org-mobile-inbox-for-pull "~/org/flagged.org")
;; Set to <your Dropbox root directory>/MobileOrg.
(setq org-mobile-directory "~/Dropbox/MobileOrg")

;; Enable encryption-decryption
(setq org-mobile-use-encryption nil)


;;; Simple calendar sync using external shell script

(defun grc-org-update-calendar ()
  (interactive)
  (start-process "update-org-calendar"
		 nil
		 "/Users/grc/bin/update-org-calendar"))


(defvar grc-org-calendar-update-timer 
      (run-with-timer 1 (* 20 60) 'grc-org-update-calendar )
      "Timer used to reresh org calendar from google calendar.")



(setq ediff-window-setup-function 'ediff-setup-windows-plain)
(setq ediff-split-window-function 'split-window-horizontally)



(require 'magit)

(eval-after-load 'info 
  '(progn (info-initialize)
	  (add-to-list 'Info-directory-list "~/git-repos.magit")))



(global-set-key (kbd "C-c ?") 'magit-status)


(setq vc-follow-symlinks t) ;; don't ask when following symlinks to a controlled file




;;; Org Trello integration

(require 'dash)

(require 'request)








(require 'noflet)
(require 'fakir)
(require 'elnode)
(require 's)
(require 'web)
(require 'db)

(require 'org-trello)


;; Sunrise/Sunset stuff
(require 'solar)
(setq calendar-latitude 51.6 calendar-longitude 1.1) ; Warborough, Oxfordshire


;;; ERC
;; Note that this is now developed wthin emacs, not the Savannah repository
(require 'erc)
(add-hook 'erc-mode-hook 'flyspell-mode)
(add-hook 'erc-mode-hook 'abbrev-mode)
(setq erc-hide-list '("JOIN" "PART" "QUIT" "NAMES" "MODE"))

 ;;; change header line face if disconnected
(defface erc-header-line-disconnected
  '((t (:foreground "black" :background "indianred")))
  "Face to use when ERC has been disconnected.")
    
(defun erc-update-header-line-show-disconnected ()
  "Use a different face in the header-line when disconnected."
  (erc-with-server-buffer
    (cond ((erc-server-process-alive) 'erc-header-line)
	  (t 'erc-header-line-disconnected))))
    
(setq erc-header-line-face-method 'erc-update-header-line-show-disconnected)

(require 'erc-image)
(add-to-list 'erc-modules 'image)
(erc-update-modules)

(require 'tls)

(load "~/grc-config/erc-auth.el")       ; credentials for pexip slack account

(defun pex ()
  (interactive)
  (erc-tls :server "pexip.irc.slack.com"
       :nick "giles"
       :password pexip-slack-password))

(setq erc-autojoin-channels-alist
      '(("irc.pexnote.com" "#pexnote") ; our server is still announcing the old FQDN
	("freenode.net" "#emacs" "#zsh" "#stumpwm")))




;; Lisp

(setq inferior-lisp-program "sbcl")
(load (expand-file-name "~/quicklisp/slime-helper.el"))

;; Add hook to assorted lisp modes
(mapc (lambda (hook) (add-hook hook 'paredit-mode))
      '(clojure-mode-hook
	slime-repl-mode-hook
	emacs-lisp-mode-hook
	ielm-mode-hook))

(autoload 'paredit-mode "paredit"
  "Turn on pseudo-structural editing of Lisp code."
  t)

; By default paredit-splice-sexp is bount to M-s which stomps on a lot
; of useful key bindings, so fix that.  Similarly the `\' behaviour is
; weird.
(eval-after-load 'paredit
  '(progn 
     (define-key paredit-mode-map "\M-s" nil) 
     (define-key paredit-mode-map "\C-cs" 'paredit-splice-sexp)
     (define-key paredit-mode-map "\\" nil)))

(require 'browse-kill-ring)
(browse-kill-ring-default-keybindings)





;;; TRAMP Mode

(require 'tramp)

;; multi hop configuration

(add-to-list 'tramp-default-proxies-alist
	     '(nil "\\`root\\'" "/ssh:%h:"))
(add-to-list 'tramp-default-proxies-alist
	     '((regexp-quote (system-name)) nil nil))

(add-to-list
 'tramp-default-proxies-alist
 '("nagios-uk" "root" "/ssh:%h:"))



;;; Setting appropriate smtp-user
;; gmail authentication means that the from header in an email is
;; overwritten with the email address associated with the account
;; you're using to send taht mail.  So we want to be able to change
;; the credntials used to log in to gmail depending on where the email
;; is meant to come from.
;;
;; authinfo can contain multiple machine lines, each with a different
;; user name and password.  `smtpmail-smtp-user' will use a set of
;; credentials corresponding to the given user name.  So in
;; `message-send-hook' we set `smtpmail-smtp-user' to an appropriate
;; value depending on who we're sending as.


(defun grc-from-field ()
  (interactive)
  (save-excursion
    (save-restriction
      (message-narrow-to-headers-or-head)
      (message-fetch-field "From"))))

(defun grc-smtp-user ()
  (interactive)
  (let ((from-field (grc-from-field)))
    (cond 
     ((string-match "jujutsu" from-field) "gileschamberlin@gmail.com")
     ((string-match "pexip" from-field) "giles@pexip.com"))))

(defun grc-set-smtp-user ()
  (setq smtpmail-smtp-user (grc-smtp-user))
  (message "Setting smtp-user to %s" smtpmail-smtp-user))

(add-hook 'message-send-hook 'grc-set-smtp-user)












(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))

(package-initialize)




;; Python stuff

(require 'python)
(setq python-check-command "epylint")


(require 'vc)
(require 'vc-git)


;; puppet
(require 'puppet-mode)
(add-to-list 'auto-mode-alist '("\\.pp$" . puppet-mode))


;; eshell


(require 'eshell)

(setq eshell-history-size 1024)
(require 'em-smart)
(eshell-smart-initialize)

(defun grc-eshell-last-arg ()
  (last eshell-last-arguments))

(defun grc-eshell-keys ()
  (local-set-key (kbd "M-.") 'grc-eshell-last-arg))

(add-hook 'eshell-mode-hook 'grc-eshell-keys )



(require 'tex-site)
(require 'pcmpl-git)
(require 'pcmpl-lein)


;; boxquote provides the ability to add nicely formatted textblocks to
;; emails etc.  If it's not on the system it's not a disaster.
(require 'boxquote nil t) 




(defvar find-file-root-prefix (if (featurep 'xemacs) "/[sudo/root@localhost]" "/sudo:root@localhost:" )
  "*The filename prefix used to open a file with `find-file-root'.")

(defvar find-file-root-history nil
  "History list for files found using `find-file-root'.")

(defvar find-file-root-hook nil
  "Normal hook for functions to run after finding a \"root\" file.")

(defun find-file-root ()
  "*Open a file as the root user.
   Prepends `find-file-root-prefix' to the selected file name so that it
   maybe accessed via the corresponding tramp method."

  (interactive)
  (require 'tramp)
  (let* ( ;; We bind the variable `file-name-history' locally so we can
	 ;; use a separate history list for "root" files.
	 (file-name-history find-file-root-history)
	 (name (or buffer-file-name default-directory))
	 (tramp (and (tramp-tramp-file-p name)
		     (tramp-dissect-file-name name)))
	 path dir file)

    ;; If called from a "root" file, we need to fix up the path.
    (when tramp
      (setq path (tramp-file-name-localname tramp)
	    dir (file-name-directory path)))

    (when (setq file (read-file-name "Find file (UID = 0): " dir path))
      (find-file (concat find-file-root-prefix file))
      ;; If this all succeeded save our new history list.
      (setq find-file-root-history file-name-history)
      ;; allow some user customization
      (run-hooks 'find-file-root-hook))))

(global-set-key [(control x) (control r)] 'find-file-root)



;;; Control of video endpoints
(require 'grc-video)
(setq grc-video-endpoints
    '(("work-snoopy" . "10.44.1.66")))

(global-set-key "\C-cv" 'grc-bbdb-video-dial)



(require 'misc)
(define-key global-map [(meta ?z)] 'zap-up-to-char) ; Rebind M-z 


;; multiple cursors

(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

;;; esxml is an XML to sexpr librray used by my vidconf package





;;; popwin.el from git@github.com:m2ym/popwin-el.git

(require 'popwin)
(popwin-mode 1)


;;;; Pexip MCU functionality

(require 'pexip)
(defconst pexip-production "10.47.2.49"
  "Address of management node of production MCU")
(global-set-key "\C-cp" (lambda ()(interactive) (pex-insert-version pexip-production)))









(message "Custom variables")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(TeX-view-program-selection
   (quote
    (((output-dvi style-pstricks)
      "dvips and gv")
     (output-dvi "xdvi")
     (output-pdf "xpdf")
     (output-html "xdg-open"))))
 '(browse-url-browser-function (quote eww-browse-url))
 '(browse-url-generic-program "/Users/grc/bin/conkeror")
 '(canlock-password "7eb9fe24d5c7742671cba67f3eba35dd151d0cdc")
 '(gnus-ignored-from-addresses (quote ("giles@jujutsu\\.org\\.uk" "giles@pexip\\.com")))
 '(org-agenda-files
   (quote
    ("~/org/home.org" "~/org/calendar.org" "~/org/notes.org")))
 '(org-entities-user
   (quote
    (("space" "\\ " nil " " " " " " " ")
     ("grcbreak" "\\\\" nil "" "" "" ""))))
 '(org-latex-pdf-process
   (quote
    ("lualatex -shell-escape -interaction nonstopmode -output-directory %o %f" "lualatex -shell-escape -interaction nonstopmode -output-directory %o %f" "lualatex -shell-escape -interaction nonstopmode -output-directory %o %f")))
 '(org-latex-to-pdf-process (quote ("LATEX='pdflatex -shell-escape' texi2dvi %f")))
 '(send-mail-function (quote smtpmail-send-it)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(erc-input-face ((t (:foreground "yellow"))))
 '(error ((t (:foreground "red1" :weight bold))))
 '(eshell-prompt ((t (:foreground "chartreuse" :weight normal))))
 '(font-lock-function-name-face ((t (:foreground "aquamarine"))))
 '(org-todo ((t (:foreground "gold" :weight bold))))
 '(region ((t (:background "CadetBlue4")))))

;; Local Variables:
;; mode: emacs-lisp
;; End:
(put 'narrow-to-region 'disabled nil)
