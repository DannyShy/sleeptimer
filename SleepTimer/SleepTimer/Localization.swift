import Foundation

// MARK: - Runtime localization engine (instant hot-reload, no restart)

private let strings: [String: [String: String]] = [

    // ── ContentView ─────────────────────────────────────────────
    "Sleep Timer": [
        "sk": "Časovač spánku", "de": "Schlaf-Timer",
        "fr": "Minuterie de sommeil", "es": "Temporizador de sueño"
    ],
    "Check for Updates...": [
        "sk": "Skontrolovať aktualizácie…", "de": "Nach Updates suchen…",
        "fr": "Vérifier les mises à jour…", "es": "Buscar actualizaciones…"
    ],
    "Send Feedback...": [
        "sk": "Odoslať spätnú väzbu…", "de": "Feedback senden…",
        "fr": "Envoyer des commentaires…", "es": "Enviar comentarios…"
    ],
    "Settings...": [
        "sk": "Nastavenia…", "de": "Einstellungen…",
        "fr": "Réglages…", "es": "Ajustes…"
    ],
    "Quit Sleep Timer": [
        "sk": "Ukončiť Časovač spánku", "de": "Schlaf-Timer beenden",
        "fr": "Quitter Minuterie", "es": "Salir del Temporizador"
    ],
    "30 min": [:],
    "45 min": [:],
    "1h": [:],
    "Custom": [
        "sk": "Vlastné", "de": "Benutzerdefiniert",
        "fr": "Personnalisé", "es": "Personalizado"
    ],
    "Mac will sleep at": [
        "sk": "Mac sa uspí o", "de": "Mac schläft um",
        "fr": "Le Mac s'endormira à", "es": "El Mac dormirá a las"
    ],
    "Start Timer": [
        "sk": "Spustiť časovač", "de": "Timer starten",
        "fr": "Démarrer", "es": "Iniciar temporizador"
    ],
    "Cancel": [
        "sk": "Zrušiť", "de": "Abbrechen",
        "fr": "Annuler", "es": "Cancelar"
    ],
    "Time remaining": [
        "sk": "Zostávajúci čas", "de": "Verbleibende Zeit",
        "fr": "Temps restant", "es": "Tiempo restante"
    ],
    "HOURS": [
        "sk": "HODINY", "de": "STUNDEN",
        "fr": "HEURES", "es": "HORAS"
    ],
    "MINUTES": [
        "sk": "MINÚTY", "de": "MINUTEN",
        "fr": "MINUTES", "es": "MINUTOS"
    ],

    // ── SettingsView ────────────────────────────────────────────
    "Sleep Timer Settings": [
        "sk": "Nastavenia časovača", "de": "Schlaf-Timer Einstellungen",
        "fr": "Réglages de la minuterie", "es": "Ajustes del temporizador"
    ],
    "General": [
        "sk": "Všeobecné", "de": "Allgemein",
        "fr": "Général", "es": "General"
    ],
    "Timer": [
        "sk": "Časovač", "de": "Timer",
        "fr": "Minuterie", "es": "Temporizador"
    ],
    "Shortcuts": [
        "sk": "Skratky", "de": "Kurzbefehle",
        "fr": "Raccourcis", "es": "Atajos"
    ],
    "Open at Login": [
        "sk": "Otvoriť pri prihlásení", "de": "Beim Anmelden öffnen",
        "fr": "Ouvrir à la connexion", "es": "Abrir al iniciar sesión"
    ],
    "Show Icon in Dock": [
        "sk": "Zobraziť ikonu v Docku", "de": "Symbol im Dock anzeigen",
        "fr": "Afficher l'icône dans le Dock", "es": "Mostrar icono en el Dock"
    ],
    "Language": [
        "sk": "Jazyk", "de": "Sprache",
        "fr": "Langue", "es": "Idioma"
    ],
    "Appearance": [
        "sk": "Vzhľad", "de": "Erscheinungsbild",
        "fr": "Apparence", "es": "Apariencia"
    ],
    "Light": [
        "sk": "Svetlý", "de": "Hell",
        "fr": "Clair", "es": "Claro"
    ],
    "Dark": [
        "sk": "Tmavý", "de": "Dunkel",
        "fr": "Sombre", "es": "Oscuro"
    ],
    "System": [
        "sk": "Systém", "de": "System",
        "fr": "Système", "es": "Sistema"
    ],
    "Default Duration": [
        "sk": "Predvolená doba", "de": "Standarddauer",
        "fr": "Durée par défaut", "es": "Duración predeterminada"
    ],
    "Last used": [
        "sk": "Posledná použitá", "de": "Zuletzt verwendet",
        "fr": "Dernière utilisée", "es": "Última utilizada"
    ],
    "Warning Sound": [
        "sk": "Zvuk upozornenia", "de": "Warnton",
        "fr": "Son d'avertissement", "es": "Sonido de advertencia"
    ],
    "Play sound 60s before sleeping": [
        "sk": "Prehrať zvuk 60s pred uspatím", "de": "Ton 60s vor dem Ruhezustand",
        "fr": "Jouer un son 60s avant la veille", "es": "Reproducir sonido 60s antes de dormir"
    ],
    "Menu Bar": [
        "sk": "Panel menu", "de": "Menüleiste",
        "fr": "Barre des menus", "es": "Barra de menús"
    ],
    "Show countdown in Menu Bar": [
        "sk": "Zobraziť odpočet v paneli menu", "de": "Countdown in Menüleiste anzeigen",
        "fr": "Afficher le compte à rebours", "es": "Mostrar cuenta regresiva"
    ],
    "Show Sleep Timer": [
        "sk": "Zobraziť časovač", "de": "Schlaf-Timer anzeigen",
        "fr": "Afficher la minuterie", "es": "Mostrar temporizador"
    ],
    "Start Default Timer": [
        "sk": "Spustiť predvolený časovač", "de": "Standard-Timer starten",
        "fr": "Démarrer minuterie par défaut", "es": "Iniciar temporizador predeterminado"
    ],
    "Click a field and press a key combination to record.": [
        "sk": "Kliknite na pole a stlačte kombináciu klávesov.", "de": "Klicken Sie auf ein Feld und drücken Sie eine Tastenkombination.",
        "fr": "Cliquez sur un champ et appuyez sur une combinaison de touches.", "es": "Haga clic en un campo y presione una combinación de teclas."
    ],
    "Type shortcut…": [
        "sk": "Zadajte skratku…", "de": "Kurzbefehl eingeben…",
        "fr": "Saisissez un raccourci…", "es": "Escriba un atajo…"
    ],
    "None": [
        "sk": "Žiadna", "de": "Keine",
        "fr": "Aucun", "es": "Ninguno"
    ],
    "Export logs": [
        "sk": "Exportovať záznamy", "de": "Protokolle exportieren",
        "fr": "Exporter les journaux", "es": "Exportar registros"
    ],

    // ── CountdownWarningDialog ──────────────────────────────────
    "Mac will sleep soon": [
        "sk": "Mac sa o chvíľu uspí", "de": "Mac wird bald schlafen",
        "fr": "Le Mac va bientôt s'endormir", "es": "El Mac dormirá pronto"
    ],
    "Time remaining until sleep:": [
        "sk": "Zostávajúci čas do uspatia:", "de": "Verbleibende Zeit bis zum Ruhezustand:",
        "fr": "Temps restant avant la veille :", "es": "Tiempo restante antes de dormir:"
    ],
    "Cancel Timer": [
        "sk": "Zrušiť časovač", "de": "Timer abbrechen",
        "fr": "Annuler la minuterie", "es": "Cancelar temporizador"
    ],
    "Snooze 5 minutes": [
        "sk": "Odložiť o 5 minút", "de": "5 Minuten schlummern",
        "fr": "Reporter de 5 minutes", "es": "Posponer 5 minutos"
    ],
]

/// Language code for the current @AppStorage("appLanguage") value
private let langToCode: [String: String] = [
    "English": "en", "Slovak": "sk", "German": "de",
    "French": "fr", "Spanish": "es"
]

/// Look up a localized string at runtime. Returns the English key if no translation exists.
func L(_ key: String) -> String {
    let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "English"
    let code = langToCode[lang] ?? "en"
    if code == "en" { return key }
    return strings[key]?[code] ?? key
}
