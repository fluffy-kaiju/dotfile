;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(defvar my-schemastore-catalog-url "https://www.schemastore.org/api/json/catalog.json")
(defvar my-schemastore-catalog-file (expand-file-name "schema-store-catalog.json" user-emacs-directory))

(defun my-update-json-schemas ()
  "Download the latest JSON Schema Store catalog manually."
  (interactive)
  (message "Downloading SchemaStore catalog...")
  (url-copy-file my-schemastore-catalog-url my-schemastore-catalog-file t)
  (message "SchemaStore catalog updated! Restart Eglot to apply changes."))

(defun my-load-json-schemas ()
  "Read the downloaded SchemaStore catalog and return the schemas array."
  (when (file-exists-p my-schemastore-catalog-file)
    (let* ((json-object-type 'plist)
           (json-array-type  'vector)
           (json-key-type    'keyword)
           (catalog (json-read-file my-schemastore-catalog-file)))
      (plist-get catalog :schemas))))

;; Your existing Tramp config
(setq enable-remote-dir-locals t)

(after! tramp
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path))

(use-package! prisma-mode
  :mode "\\.prisma\\'"
  :config
  ;; Register the prisma server with eglot
  ;; (set-eglot-client! 'prisma-mode '("prisma-language-server" "--stdio"))
  (set-eglot-client! 'prisma-mode '("/home/dev/.local/share/pnpm/prisma-language-server" "--stdio"))
  ;; Ensure eglot starts automatically when opening prisma files
  (add-hook 'prisma-mode-hook #'eglot-ensure))


(after! eglot
  ;; 1. (Optional) Ensure catalog exists
  (unless (file-exists-p my-schemastore-catalog-file)
    (my-update-json-schemas))

  ;; 2. Combine configs
  (let ((prisma-config '(:prisma []))
        (yaml-config '(:yaml (:schemaStore (:enable t) :format (:enable t))))
        ;; Use a backtick here so the comma can trigger the function call
        (json-schemas `(:json (:format (:enable t)
                               :validate (:enable t)
                               :schemas ,(my-load-json-schemas)))))

    (setq-default eglot-workspace-configuration
                  `(,@prisma-config
                    ,@yaml-config
                    ,@json-schemas))))
  ;; (add-to-list 'eglot-server-programs
  ;;               '(dockerfile-mode . ("" "--stdio"))
  ;;              )
   ; Use ,@ because json-schemas is now a full lirt

(setq jsonrpc-default-request-timeout 60) ; Increase to 30 seconds
(after! eglot
  (setq eglot-connect-timeout 60))  ; default is 30s
(use-package! eldoc-box
  :hook (eglot-managed-mode . eldoc-box-hover-at-point-mode)
  :config
  (setq eldoc-box-max-pixel-width 500
        eldoc-box-max-pixel-height 300))
(setq eldoc-display-functions (delete 'eldoc-display-in-echo-area eldoc-display-functions))

(use-package! elcord
  :config
  ;; Enable elcord globally
  (elcord-mode 1))
  ;; You can also use dolist here if you have multiple to add:
(dolist (mode '(
                (js-ts-mode . "javascript-mode_icon")
                (typescript-ts-mode . "typescript-mode_icon")))
                
    (add-to-list 'elcord-mode-icon-alist mode))

;; (dolist (text '(
;;                 (js-ts-mode . "javascript-mode_icon")
;;                 ))
    ;; (add-to-list 'elcord-mode-text-alist text)))

(use-package! platformio-mode)

;; Enable ccls for all c++ files, and platformio-mode only
;; when needed (platformio.ini present in project root).
(add-hook 'c++-mode-hook (lambda ()
                           (eglot-ensure)
                           (platformio-conditionally-enable)))
