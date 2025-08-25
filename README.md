# em_tth_assignment

Effective Mobile Take-To-Home assignment

[the assignment](https://docs.360.yandex.ru/docs/view?url=ya-disk-public%3A%2F%2FQ8qQ3aa67rXXF%2FDHzLsU3tj8y6FUqx%2BDmemuH4LjjrLOguBpjRXwpwLi%2BUgAM2UXsLK2WbwBkR%2F%2FqfmVHoPilw%3D%3D&name=%D0%A2%D0%B5%D1%81%D1%82%D0%BE%D0%B2%D0%BE%D0%B5%20%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5%20Flutter.docx&nosw=1)

## Architectural Overview

- **Data layer**:
  - _Http_: `dio`
    Interacts with the `rickandmortyapi`, gets characters page by page
  - _Persistence_: `shared_preferences`, `sqlite`
    Shared Preferences keeps the meta information about the data (info) and app theme information
    Sqlite keeps the downloaded characters
- **Logic layer**: `bloc`
  `CharactersBloc` interacts with the API and the database, fetches, saves, modifies, and loads the characters data.
  `ThemeCubit` sets and reads the application theme
- **Presentation layer**
  Displays characters on 2 screens, Characters and Favorite
  Interacts with the Logic layer
The application also has a `utils` folder which contains constants and a String extension (`isNulOrEmpty`)
    
## Choice of technologies
- `dio`: one of the most if not the most popular http packages for Dart. Easy to use, has extensive documentation.
- `shared_preferences` for metadata and theme: It is perfect for keeping simple independed pieces of information. Relational database is not very suitable for this job in my opinion because I would have to do additional work to make sure that there is always only one version of the metadata in the table (or I would have to introduce data versioning). 
- `sqlite`: the most popular relational database for Dart. Provides all the benefits of a relational database.
- `bloc`: Enforces a certain type of architecture. Event-driven (separates presentation from logic).

## Some other code choices
A lot of design choices in this project were motivated by the fact that this is a small one-day application without any prospects of further development. This is the reason why I deliberately desided to not include localization, gorouter for better BottomNavigationBar, interfaces, or multiple layers of models.
