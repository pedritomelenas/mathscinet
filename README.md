# mathscinet

This is a simple enhancement of the [mathscinet](https://www.ctan.org/pkg/mathscinet) package.

- We added a new search field: the MR Author ID. Now the script can be called by using `-i`, or equivalently `--authorid`.

- The search now does not restrict to a single page (probably around 20 items), but to the whole set of papers fulfilling the search options.

```
./mathscinet-RID.PL -i 601396 > prueba.bib
```
