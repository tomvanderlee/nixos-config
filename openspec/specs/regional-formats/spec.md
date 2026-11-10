# regional-formats Specification

## Purpose

Keeps the system language English while formatting numbers, dates and times, currency, paper size and measurement units according to European/Dutch conventions on every NixOS host.

## Requirements

### Requirement: System language stays English
Every NixOS host built from this flake's shared system module SHALL keep English as its language for interface text and messages.

#### Scenario: Messages remain English
- **WHEN** a locale-aware program prints a translatable message on a host built from the shared system module
- **THEN** the message is in English

### Requirement: Regional formats follow European/Dutch conventions
Every NixOS host built from this flake's shared system module SHALL format numbers, currency amounts, paper size and measurement units according to the Dutch (Netherlands) locale, and dates and times in a 24-hour, day-before-month-compatible European style, while weekday and month names remain English, independent of the system language.

#### Scenario: Numbers use Dutch separators
- **WHEN** a locale-aware program formats the number 1234.56 on such a host
- **THEN** it uses a comma as the decimal separator (`1234,56`)

#### Scenario: Dates and times use European conventions
- **WHEN** a locale-aware program prints the date and time on such a host
- **THEN** the clock is 24-hour, the date is in numeric year-month-day form (`2026-11-10`), weeks start on Monday, and weekday and month names are English (for example `Tuesday`, `November`)

#### Scenario: Locale is available on the host
- **WHEN** a host built from the shared system module has been activated
- **THEN** `locale -a` lists `nl_NL.utf8` and `en_DK.utf8`

### Requirement: A host can override the locale
A NixOS host built from this flake SHALL be able to override the system language with its own `hosts/<name>/configuration.nix` without conflicting with the shared default.

#### Scenario: Host sets its own default locale
- **WHEN** a host's configuration sets `i18n.defaultLocale` at normal priority
- **THEN** that host uses the chosen language while keeping the regional formats
