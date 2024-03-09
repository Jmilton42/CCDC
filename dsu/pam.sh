#!/bin/bash
#PAM_RHOST, PAM_RUSER, PAM_SERVICE, PAM_TTY, PAM_USER and PAM_TYPE

/usr/bin/curl "$WEBHOOK_URL" -H "Content-Type: application/json" -d "{\"content\": \"PAM_RHOST: $PAM_RHOST\\nPAM_RUSER: $PAM_RUSER\\nPAM_SERVICE: $PAM_SERVICE\\nPAM_TTY: $PAM_TTY\\nPAM_USER: $PAM_USER\\nPAM_TYPE: $PAM_TYPE\"}"
