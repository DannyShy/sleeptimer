import Foundation

// MARK: - Runtime localization engine (instant hot-reload, no restart)

let strings: [String: [String: String]] = [

    // ── ContentView ─────────────────────────────────────────────
    "Doze": [
        "sk": "Doze", "de": "Doze",
        "fr": "Doze", "es": "Doze",
        "pt-BR": "Doze"
    ],
    "Check for Updates...": [
        "sk": "Skontrolovať aktualizácie…", "de": "Nach Updates suchen…",
        "fr": "Vérifier les mises à jour…", "es": "Buscar actualizaciones…",
        "pt-BR": "Buscar atualizações…"
    ],
    "Send Feedback...": [
        "sk": "Odoslať spätnú väzbu…", "de": "Feedback senden…",
        "fr": "Envoyer des commentaires…", "es": "Enviar comentarios…",
        "pt-BR": "Enviar feedback…"
    ],
    "Settings...": [
        "sk": "Nastavenia…", "de": "Einstellungen…",
        "fr": "Réglages…", "es": "Ajustes…",
        "pt-BR": "Ajustes…"
    ],
    "Quit Doze": [
        "sk": "Ukončiť Doze", "de": "Doze beenden",
        "fr": "Quitter Doze", "es": "Salir de Doze",
        "pt-BR": "Encerrar Doze"
    ],
    "30 min": [:],
    "45 min": [:],
    "1h": [:],
    "Custom": [
        "sk": "Vlastné", "de": "Benutzerdefiniert",
        "fr": "Personnalisé", "es": "Personalizado",
        "pt-BR": "Personalizado"
    ],
    "Mac will sleep at": [
        "sk": "Mac sa uspí o", "de": "Mac schläft um",
        "fr": "Le Mac entrera en veille à", "es": "El Mac dormirá a las",
        "pt-BR": "O Mac entrará em repouso às"
    ],
    "Start Timer": [
        "sk": "Spustiť časovač", "de": "Timer starten",
        "fr": "Démarrer", "es": "Iniciar temporizador",
        "pt-BR": "Iniciar timer"
    ],
    "Cancel": [
        "sk": "Zrušiť", "de": "Abbrechen",
        "fr": "Annuler", "es": "Cancelar",
        "pt-BR": "Cancelar"
    ],
    "Time remaining": [
        "sk": "Zostávajúci čas", "de": "Verbleibende Zeit",
        "fr": "Temps restant", "es": "Tiempo restante",
        "pt-BR": "Tempo restante"
    ],
    "HOURS": [
        "sk": "HODINY", "de": "STUNDEN",
        "fr": "HEURES", "es": "HORAS",
        "pt-BR": "HORAS"
    ],
    "MINUTES": [
        "sk": "MINÚTY", "de": "MINUTEN",
        "fr": "MINUTES", "es": "MINUTOS",
        "pt-BR": "MINUTOS"
    ],

    // ── SettingsView ────────────────────────────────────────────
    "Doze Settings": [
        "sk": "Nastavenia Doze", "de": "Doze Einstellungen",
        "fr": "Réglages de Doze", "es": "Ajustes de Doze",
        "pt-BR": "Ajustes do Doze"
    ],
    "General": [
        "sk": "Všeobecné", "de": "Allgemein",
        "fr": "Général", "es": "General",
        "pt-BR": "Geral"
    ],
    "Timer": [
        "sk": "Časovač", "de": "Timer",
        "fr": "Minuterie", "es": "Temporizador",
        "pt-BR": "Timer"
    ],
    "Shortcuts": [
        "sk": "Skratky", "de": "Kurzbefehle",
        "fr": "Raccourcis", "es": "Atajos",
        "pt-BR": "Atalhos"
    ],
    "Open at Login": [
        "sk": "Otvoriť pri prihlásení", "de": "Beim Anmelden öffnen",
        "fr": "Ouvrir à la connexion", "es": "Abrir al iniciar sesión",
        "pt-BR": "Abrir ao iniciar sessão"
    ],
    "Show Icon in Dock": [
        "sk": "Zobraziť ikonu v Docku", "de": "Symbol im Dock anzeigen",
        "fr": "Afficher l'icône dans le Dock", "es": "Mostrar icono en el Dock",
        "pt-BR": "Mostrar ícone no Dock"
    ],
    "Language": [
        "sk": "Jazyk", "de": "Sprache",
        "fr": "Langue", "es": "Idioma",
        "pt-BR": "Idioma"
    ],
    "Appearance": [
        "sk": "Vzhľad", "de": "Erscheinungsbild",
        "fr": "Apparence", "es": "Apariencia",
        "pt-BR": "Aparência"
    ],
    "Light": [
        "sk": "Svetlý", "de": "Hell",
        "fr": "Clair", "es": "Claro",
        "pt-BR": "Claro"
    ],
    "Dark": [
        "sk": "Tmavý", "de": "Dunkel",
        "fr": "Sombre", "es": "Oscuro",
        "pt-BR": "Escuro"
    ],
    "System": [
        "sk": "Systém", "de": "System",
        "fr": "Système", "es": "Sistema",
        "pt-BR": "Sistema"
    ],
    "Default Duration": [
        "sk": "Predvolená doba", "de": "Standarddauer",
        "fr": "Durée par défaut", "es": "Duración predeterminada",
        "pt-BR": "Duração padrão"
    ],
    "Last used": [
        "sk": "Posledná použitá", "de": "Zuletzt verwendet",
        "fr": "Dernière utilisée", "es": "Última utilizada",
        "pt-BR": "Última usada"
    ],
    "Warning Sound": [
        "sk": "Zvuk upozornenia", "de": "Warnton",
        "fr": "Son d'avertissement", "es": "Sonido de advertencia",
        "pt-BR": "Som de aviso"
    ],
    "Play sound 60s before sleeping": [
        "sk": "Prehrať zvuk 60s pred uspatím", "de": "Ton 60s vor dem Ruhezustand",
        "fr": "Jouer un son 60s avant la veille", "es": "Reproducir sonido 60s antes de dormir",
        "pt-BR": "Tocar som 60s antes do repouso"
    ],
    "Menu Bar": [
        "sk": "Panel menu", "de": "Menüleiste",
        "fr": "Barre des menus", "es": "Barra de menús",
        "pt-BR": "Barra de menus"
    ],
    "Show countdown in Menu Bar": [
        "sk": "Zobraziť odpočet v paneli menu", "de": "Countdown in Menüleiste anzeigen",
        "fr": "Afficher le compte à rebours", "es": "Mostrar cuenta regresiva",
        "pt-BR": "Mostrar contagem regressiva"
    ],
    "After start": [
        "sk": "Po spustení", "de": "Nach dem Start",
        "fr": "Après le démarrage", "es": "Al iniciar",
        "pt-BR": "Após iniciar"
    ],
    "Close window": [
        "sk": "Zavrieť okno", "de": "Fenster schließen",
        "fr": "Fermer la fenêtre", "es": "Cerrar la ventana",
        "pt-BR": "Fechar janela"
    ],
    "Show Doze": [
        "sk": "Zobraziť Doze", "de": "Doze anzeigen",
        "fr": "Afficher Doze", "es": "Mostrar Doze",
        "pt-BR": "Mostrar Doze"
    ],
    "Start Default Timer": [
        "sk": "Spustiť predvolený časovač", "de": "Standard-Timer starten",
        "fr": "Démarrer minuterie par défaut", "es": "Iniciar temporizador predeterminado",
        "pt-BR": "Iniciar timer padrão"
    ],
    "Click a field and press a key combination to record.": [
        "sk": "Kliknite na pole a stlačte kombináciu klávesov.", "de": "Klicken Sie auf ein Feld und drücken Sie eine Tastenkombination.",
        "fr": "Cliquez sur un champ et appuyez sur une combinaison de touches.", "es": "Haga clic en un campo y presione una combinación de teclas.",
        "pt-BR": "Clique em um campo e pressione uma combinação de teclas para gravar."
    ],
    "Type shortcut…": [
        "sk": "Zadajte skratku…", "de": "Kurzbefehl eingeben…",
        "fr": "Saisissez un raccourci…", "es": "Escriba un atajo…",
        "pt-BR": "Digite um atalho…"
    ],
    "None": [
        "sk": "Žiadna", "de": "Keine",
        "fr": "Aucun", "es": "Ninguno",
        "pt-BR": "Nenhum"
    ],
    "Export logs": [
        "sk": "Exportovať záznamy", "de": "Protokolle exportieren",
        "fr": "Exporter les journaux", "es": "Exportar registros",
        "pt-BR": "Exportar registros"
    ],
    "Version": [
        "sk": "Verzia", "de": "Version",
        "fr": "Version", "es": "Versión",
        "pt-BR": "Versão"
    ],

    // ── SettingsManager (Send Feedback) ─────────────────────────
    "Please describe your issue or suggestion below:": [
        "sk": "Popíšte, prosím, váš problém alebo návrh nižšie:",
        "de": "Bitte beschreiben Sie Ihr Problem oder Ihren Vorschlag unten:",
        "fr": "Veuillez décrire votre problème ou suggestion ci-dessous :",
        "es": "Describa su problema o sugerencia a continuación:",
        "pt-BR": "Descreva seu problema ou sugestão abaixo:"
    ],
    "Diagnostic report is attached automatically.": [
        "sk": "Diagnostická správa je priložená automaticky.",
        "de": "Der Diagnosebericht wird automatisch angehängt.",
        "fr": "Le rapport de diagnostic est joint automatiquement.",
        "es": "El informe de diagnóstico se adjunta automáticamente.",
        "pt-BR": "O relatório de diagnóstico é anexado automaticamente."
    ],
    "Please attach the diagnostics file you just saved and describe your issue below.": [
        "sk": "Priložte, prosím, práve uložený diagnostický súbor a nižšie popíšte váš problém.",
        "de": "Bitte hängen Sie die soeben gespeicherte Diagnosedatei an und beschreiben Sie Ihr Problem unten.",
        "fr": "Veuillez joindre le fichier de diagnostic que vous venez d’enregistrer et décrire votre problème ci-dessous.",
        "es": "Adjunte el archivo de diagnóstico que acaba de guardar y describa su problema a continuación.",
        "pt-BR": "Anexe o arquivo de diagnóstico que você acabou de salvar e descreva seu problema abaixo."
    ],

    // ── CountdownWarningDialog ──────────────────────────────────
    "Mac will sleep soon": [
        "sk": "Mac sa o chvíľu uspí", "de": "Mac wird bald schlafen",
        "fr": "Le Mac va bientôt entrer en veille", "es": "El Mac dormirá pronto",
        "pt-BR": "O Mac entrará em repouso em breve"
    ],
    "Time remaining until sleep:": [
        "sk": "Zostávajúci čas do uspatia:", "de": "Verbleibende Zeit bis zum Ruhezustand:",
        "fr": "Temps restant avant la veille :", "es": "Tiempo restante antes de dormir:",
        "pt-BR": "Tempo restante até o repouso:"
    ],
    "Cancel Timer": [
        "sk": "Zrušiť časovač", "de": "Timer abbrechen",
        "fr": "Annuler la minuterie", "es": "Cancelar temporizador",
        "pt-BR": "Cancelar timer"
    ],
    "Snooze 5 minutes": [
        "sk": "Odložiť o 5 minút", "de": "5 Minuten schlummern",
        "fr": "Reporter de 5 minutes", "es": "Posponer 5 minutos",
        "pt-BR": "Adiar 5 minutos"
    ],
]

/// Language code for the current @AppStorage("appLanguage") value
let langToCode: [String: String] = [
    "English": "en", "Slovak": "sk", "German": "de",
    "French": "fr", "Spanish": "es", "Portuguese": "pt-BR"
]

/// Look up a localized string at runtime. Returns the English key if no translation exists.
func L(_ key: String) -> String {
    #if DEBUG
    if strings[key] == nil { print("⚠️ Missing localization key: \"\(key)\"") }
    #endif
    let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "English"
    let code = langToCode[lang] ?? "en"
    if code == "en" { return key }
    return strings[key]?[code] ?? key
}
