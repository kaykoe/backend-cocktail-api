## https://solvro-cocktail-api-e8ab17c93fe3.herokuapp.com/
#### Kroki do zdeployownia:
1. Sklonowałem repozytorium, zainstalowałem nodejs, zainstalowałem zależności aplikacji, odpaliłem testy, żeby upewnić się że wszystko działa lokalnie
2. Zdecydowałem zhostować stronę na [Heroku](heroku.com), więc zainstalowałem ich CLI
3. Stworzyłem na Heroku Pipeline, i odpaliłem do aplikacji bazę danych
4. Zobaczyłem, że do automatycznego deploymentu z githuba po zmianach na gałęzi main muszę mieć dostęp do repozytorium które chcę zdeployować, więc zforkowałem repo i dodałem je u siebie do lokalnego klona jako upstream.
5. Jako że zmienne konfiguracyjne bazy danych Heroku Postgres mogą się zmienić, napisałem dwa skrypty w bashu:
	- Skrypt [build.sh](https://github.com/kaykoe/backend-cocktail-api/blob/main/build.sh) tworzy docelowy plik .env. Jako że w kontenerze w którym działa nasza aplikacja jest dostępna tylko pełny url bazy danych, a to z tamtąd trzeba wydobyć sekrety do bazy danych, musiałem go rozdzielić na poszczególne elementy które były potrzebne. Zmienna PORT jest exportowana na kontenerze. Oprócz tego to właśnie ten skrypt wykonuje się przy kolejnych deploymentach aby je zbudować, więc jest tam też zawarte polecenie do budowania projektu, i kopiowanie pliku .env do katalogu build, bo inaczej aplikacja nie miala dostępu do tych zmiennych.
	- Skrypt [setup.sh](https://github.com/kaykoe/backend-cocktail-api/blob/main/setup.sh) odpala się kiedy odpalamy nowy kontener, i aktualizuje sekrety z bazy danych.
6. Napisałem też plik [Procfile](https://github.com/kaykoe/backend-cocktail-api/blob/main/Procfile), który mówi Heroku jak ma uruchomić aplikację, co przydaje się aby zmusić je do odpalenia jej z katalogu build. W pliku [package.json](https://github.com/kaykoe/backend-cocktail-api/blob/main/package.json) zmieniłem skrypt budowania (npm run build) bo jego używa Heroku, tak aby wykonywał mój skrypt build.sh.
7. W pliku konfiguracyjnym bazy danych [/config/database.ts](https://github.com/kaykoe/backend-cocktail-api/blob/main/config/database.ts) dodałem obsługę ssl, inaczej aplikacja nie współpracowała z bazą danych
8. Wygenerowałem nową zmienną środowiskową APP_KEY i ustawiłem ją bezpośrednio w Heroku, bo jest to sekret i nie może się znaleźć w publicznym repo, więc takie rozwiązanie było najprostsze i najsensowniejsze.
9. Wykonałem migrację i seeding bazy danych
10. Sprawdziłem czy wszystko działa lokalnie korzystając z polecenia `heroku local` 
11. Zdeployowałem aplikację na heroku.
---
Aplikacja ma automatyczny deployment, (oczywiście na moim forku), skalowanie horyzontalne to kwestia droższego tieru na Heroku,
ja oczywiście skorzystałem z tego który zmieścił się w pakiecie studenckim i on go niestety nie ma.
Jeżeli chodzi o cache to brakło mi czasu żeby to wdrożyć.
Z tego co udało mi się dowiedzieć na Heroku kontenery są od siebie kompletnie odizolowane bez wyjątków,
a system plików który jest im udostępniany na czas działania nie jest trwały względem wyłączania więc,
więc z tego co mi się udało dowiedzieć wygląda na to że wspólny wolumen odpada.
Cron mogłem zrobić, ale przez to o czym przed chwilą wspomniałem, z tego co rozumiem traci to sens.
Jeżeli chodzi o sugestie, to Heroku sugeruje sourcowanie zmiennej środowiskowej DATABASE_URL podczas runtime'u aplikacji,
aby uniknąć utraty dostępu do bazy danych przy zmianie konfiguracji, próbowałem przejrzeć trochę kod i dokumentację,
i zobaczyć czy da się skorzystać z pełnego url zamiast rozbitego na poszczególne fragmenty,
ale nie jestem obeznany z js więc zgubiłem się w tym kodzie bibliotekowym.
No więc oczywiście jeżeli aplikacja z góry byłaby tworzona na tą platformę, to należałoby wziąć to pod uwagę,
bo w tym momencie jeżeli zmieni nam się url do bazy danych,
to zmienne środowiskowe które są z niego wyciągane zmienią się dopiero po zrestartowaniu kontenera, co trzeba by było zrobić ręcznie.