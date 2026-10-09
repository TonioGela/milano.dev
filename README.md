# milano.dev

La bacheca per i developers a Milano. Sito statico costruito con [Zola](https://www.getzola.org) e pacchettizzato con [nix](https://nix.dev).

## Aggiungere un evento, meetup, workshop o un'attività

[Modificare sources.json](https://github.com/TonioGela/milano.dev/edit/main/sources.json) aggiungendo uno url a meetup, eventbrite o luma. Una [Github Action scritta in scala.js](https://github.com/TonioGela/events-parsing) si preoccuperà di parsare la pagina e ottenere la lista dei prossimi eventi. 
Alternativamente aggiungere un evento custom nel formato:
```json
{
    "meetupName": "Some meetup",
    "url": "https://www.some.com/",
    "date": "2026-10-20T09:30:00+02:00",
    "dateTo": "2026-10-23T18:00:00+02:00",
    "title": "The most beautiful event about Some",
    "venue": "Some venue"
}
```
