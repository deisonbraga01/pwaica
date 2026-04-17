(() => {
  const APP_BASE_URL = "https://icamedtec.com.br/app";
  const API_URL = `${APP_BASE_URL}/api/login-patient.php`;
  const REQUEST_TIMEOUT_MS = 15000;
  async function fetchWithTimeout(url, options = {}, timeoutMs = REQUEST_TIMEOUT_MS) {
    const controller = new AbortController();
    const timeoutId = window.setTimeout(() => controller.abort(), timeoutMs);
    try {
      const requestOptions = {
        ...options,
        signal: controller.signal
      };
      return await fetch(url, requestOptions);
    } finally {
      window.clearTimeout(timeoutId);
    }
  }


  function onlyDigits(value) {
    return (value || "").replace(/\D+/g, "");
  }

  function formatCpf(value) {
    const digits = onlyDigits(value).slice(0, 11);
    const parts = [];
    if (digits.length > 0) parts.push(digits.slice(0, 3));
    if (digits.length > 3) parts.push(digits.slice(3, 6));
    if (digits.length > 6) parts.push(digits.slice(6, 9));
    const suffix = digits.length > 9 ? digits.slice(9, 11) : "";
    let formatted = "";
    if (parts.length > 0) formatted = parts[0];
    if (parts.length > 1) formatted += "." + parts[1];
    if (parts.length > 2) formatted += "." + parts[2];
    if (suffix) formatted += "-" + suffix;
    return formatted;
  }

  function getCaretFromDigitIndex(formattedValue, digitIndex) {
    if (digitIndex <= 0) return 0;
    let digitsSeen = 0;
    for (let i = 0; i < formattedValue.length; i++) {
      if (/\d/.test(formattedValue[i])) {
        digitsSeen += 1;
      }
      if (digitsSeen >= digitIndex) {
        return i + 1;
      }
    }
    return formattedValue.length;
  }

  function setStatus(message, type) {
    const el = document.getElementById("login-status");
    if (!el) return;
    el.textContent = message || "";
    el.classList.remove("status-message--error", "status-message--success");
    if (type === "error") el.classList.add("status-message--error");
    if (type === "success") el.classList.add("status-message--success");
  }

  function setNetworkStatus(message, type) {
    const el = document.getElementById("network-status");
    if (!el) return;
    el.textContent = message || "";
    el.classList.remove("status-message--error", "status-message--success");
    if (type === "error") el.classList.add("status-message--error");
    if (type === "success") el.classList.add("status-message--success");
  }

  function setLoading(isLoading) {
    const btn = document.getElementById("login-button");
    if (!btn) return;
    btn.disabled = isLoading;
    btn.textContent = isLoading ? "Enviando..." : "Acessar Clínica";
  }

  async function handleSubmit(event) {
    event.preventDefault();
    const cpfInput = document.getElementById("cpf-input");
    if (!cpfInput) return;

    const raw = cpfInput.value;
    const digits = onlyDigits(raw);

    if (digits.length === 0) {
      setStatus("Informe seu CPF para continuar.", "error");
      return;
    }

    if (digits.length !== 11) {
      setStatus("Informe um CPF com 11 dígitos.", "error");
      return;
    }

    setLoading(true);
    setStatus("Gerando link de acesso, aguarde...", "success");

    try {
      const response = await fetchWithTimeout(API_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ cpf: digits })
      });

      if (!response.ok) {
        let detail = "";
        try {
          const data = await response.json();
          detail =
            data && (data.message || data.error)
              ? " - " + (data.message || data.error)
              : "";
        } catch (_) {
          // ignore JSON parsing errors
        }
        setStatus(
          "Não foi possível gerar o link de acesso (erro " +
            response.status +
            detail +
            ").",
          "error"
        );
        return;
      }

      let data;
      try {
        data = await response.json();
      } catch (e) {
        setStatus("Resposta inesperada do servidor.", "error");
        return;
      }

      if (data && data.magic_link) {
        setStatus("Redirecionando para o acesso seguro...", "success");
        window.location.href = data.magic_link;
      } else {
        setStatus(
          "Não foi possível localizar o link de acesso na resposta.",
          "error"
        );
      }
    } catch (error) {
      const isTimeout = error instanceof DOMException && error.name === "AbortError";
      if (!navigator.onLine) {
        setStatus(
          "Você está offline. Conecte-se à internet e tente novamente.",
          "error"
        );
      } else if (isTimeout) {
        setStatus(
          "A solicitação demorou mais do que o esperado. Tente novamente.",
          "error"
        );
      } else {
        setStatus(
          "Ocorreu um erro de comunicação. Tente novamente em instantes.",
          "error"
        );
      }
    } finally {
      setLoading(false);
    }
  }

  document.addEventListener("DOMContentLoaded", () => {
    const form = document.getElementById("login-form");
    const cpfInput = document.getElementById("cpf-input");

    if (cpfInput) {
      cpfInput.addEventListener("input", (e) => {
        const target = e.target;
        const currentValue = target.value;
        const selectionStart = target.selectionStart ?? currentValue.length;
        const digitsBeforeCursor = onlyDigits(
          currentValue.slice(0, selectionStart)
        ).length;
        const formatted = formatCpf(currentValue);
        const nextCursor = getCaretFromDigitIndex(formatted, digitsBeforeCursor);
        target.value = formatted;
        target.setSelectionRange(nextCursor, nextCursor);
      });
    }

    if (form) {
      form.addEventListener("submit", handleSubmit);
    }

    function refreshNetworkStatus() {
      if (navigator.onLine) {
        setNetworkStatus("Conexão ativa.", "success");
      } else {
        setNetworkStatus(
          "Sem internet no momento. Você pode visualizar esta tela e tentar novamente quando reconectar.",
          "error"
        );
      }
    }

    window.addEventListener("online", refreshNetworkStatus);
    window.addEventListener("offline", refreshNetworkStatus);
    refreshNetworkStatus();

    // Em runtime nativo, links externos abrem no navegador/safari.
    document.addEventListener("click", (event) => {
      const target = event.target;
      if (!(target instanceof Element)) return;
      const anchor = target.closest("a[href]");
      if (!anchor) return;
      if (anchor.getAttribute("target") !== "_blank") return;

      const href = anchor.getAttribute("href");
      if (!href) return;

      const capacitor = window.Capacitor;
      const browser = capacitor?.Plugins?.Browser;
      if (!browser || typeof browser.open !== "function") return;

      event.preventDefault();
      browser.open({ url: href }).catch(() => {
        window.open(href, "_blank", "noopener,noreferrer");
      });
    });

    if ("serviceWorker" in navigator) {
      window.addEventListener("load", () => {
        navigator.serviceWorker
          .register("./sw.js")
          .catch(() => {
            // silencioso: PWA continua funcionando no modo web normal
          });
      });
    }
  });
})();

