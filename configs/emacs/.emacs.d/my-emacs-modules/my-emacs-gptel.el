(use-package gptel
  :ensure t
  :config
  (setq gptel-backend
        (gptel-make-openai
         "OpenRouter"
         :key (let ((match (car (auth-source-search :host "openrouter.ai"))))
                (if match
                    (let ((secret (plist-get match :secret)))
                      (if (functionp secret)
                          (funcall secret)
                        secret))
                  (error "No API key found for openrouter.ai")))
         :endpoint "https://openrouter.ai/api/v1/chat/completions"
         :models '("openai/gpt-4o"
                   "anthropic/claude-3-opus"
                   "mistralai/mistral-7b-instruct"
                   "google/gemini-pro"
                   "openai/gpt-3.5-turbo")
         :stream t))

  (setq gptel-model "openai/gpt-4o")
  (global-set-key (kbd "C-c h") #'gptel))

(provide 'my-emacs-gptel)
