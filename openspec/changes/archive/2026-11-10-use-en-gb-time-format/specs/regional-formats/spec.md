## MODIFIED Requirements

### Requirement: Regional formats follow European/Dutch conventions
Every NixOS host built from this flake's shared system module SHALL format numbers, currency amounts, paper size and measurement units according to the Dutch (Netherlands) locale, and dates and times in a 24-hour, day-before-month numeric style, while weekday and month names remain English, independent of the system language.

#### Scenario: Numbers use Dutch separators
- **WHEN** a locale-aware program formats the number 1234.56 on such a host
- **THEN** it uses a comma as the decimal separator (`1234,56`)

#### Scenario: Dates and times use European conventions
- **WHEN** a locale-aware program prints the date and time on such a host
- **THEN** the clock is 24-hour, the numeric date puts the day before the month (`10/11/26`), weeks start on Monday, and weekday and month names are English (for example `Tue`, `Nov`)

#### Scenario: Locale is available on the host
- **WHEN** a host built from the shared system module has been activated
- **THEN** `locale -a` lists `nl_NL.utf8` and `en_GB.utf8`
