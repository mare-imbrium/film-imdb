# film-imdb

This relates to the massive IMDB dataset which contains millions of actors, directors and movies, lots of TV data which I am not interested in, and many actors and directors with the same name as famous ones.

I have largely moved away from this dataset due to the errors and non-standardness of the format.
I have spent months correcting the issues in the data, and there are still minor issues. Since there is no specific format, there is no telling what new errors will creep in with each update of the data.

I have therefore gone back to using the OMDB json files and the wiki pages for movies that actually matter to me, and not the millions in the IMDB dataset.


-----

The queries I need and which files serve them best:

One overall menu, that gives the best answers going to the relevant
directories.

1. Cast of a movie:
   dataset, use cast.sql. However, this stores only top 9 for a film.

2. Full cast: probably need imdb_data and use the long program.
   The one that uses the dat file ?? But this can mix up multiple movies
   that match pattern.

3. Movies of a star ?
   `testindex.sh` in imdb which can give all, pruned or topbilled very
   fast
   rename it. and let topbilled and pruned or movies-only be an option

4. Movies of a director. testindex again

5. what about the json database for friendlier selection of movies and
   basic data of a movie ?

6. Determining a movie name or a star name. `im.sh` has program to find
   out. but need to be case insensitive. fuzzy
   Last search should be stored somewhere so one can go across files
   and it will be default. 
   searchactor.sh

[s] when a movie name is given first see in index if multiple movies, and
make a selection. if only one then okay - started in some places but
needs to be made common for all places and maybe sourced.

CAST table should have year so we can sort movies of a character by
year.

# get movies with multiple actors:
select title  from cast where name = "Astaire, Fred" or name = "Rogers,
Ginger" group by title having count(title) > 1;

Consolidate data in one database minus TV/VG entries:

movie (unique), director/s, year, actors (join them), running time
etc. plot ttid ? wiki entry ?


ttid - movie, from json db by adding year and seeking

[ ] actor - movie (m2m) - full unpruned. billing should not have <1>
director - movie (m2m) # while creating this, or later, join actors or
dir of a movie and update the movie table.

create a mapping from json database to imdb database by adding year, so
searches are easier.
e.g. casablanca + 1942 maps to Casablanca (1942)
similarly, names of actors and directors will be reversed, and possibly
(I) added to make a mapping.


