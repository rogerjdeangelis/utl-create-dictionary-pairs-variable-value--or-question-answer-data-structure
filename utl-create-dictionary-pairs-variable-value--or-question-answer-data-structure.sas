Create dictionary pairs variable value or question answer data structure

  Three Solutions

      1. Datastep and sort by PGStat (best?)
      2. Transpose sort
      3. SQL only  (may nt be that slow in Terdata or Exadata)
      
Recent nice addition and the fastest by
Keintz, Mark
mkeintz@wharton.upenn.edu

data _null_;
  if 0 then set have nobs=nrows;
  array v {*} _numeric_;
  call symput("nrows",cats(nrows));
  call symput("ncols",cats(dim(v)));
run;

data want (keep=col val);
  set have end=end_of_have;
  array x {&nrows,&ncols} _temporary_;
  array vals {*} _numeric_;
  do _c=1 to &ncols;
    x{_n_,_c}=vals{_c};
 end;
  if end_of_have;
  do _c=1 to &ncols;
    col=vname(vals{_c});
    do _r=1 to &nrows;
      val=x{_r,_c};
      output;
    end;
  end;
run;



github
https://tinyurl.com/y74e4nol
https://github.com/rogerjdeangelis/utl-create-dictionary-pairs-variable-value--or-question-answer-data-structure

see SAS Forum
https://tinyurl.com/yau54jgd
https://communities.sas.com/t5/SAS-Programming/How-to-assign-all-column-names-and-respectively-their-values-in/m-p/523700

PGStats profile
https://communities.sas.com/t5/user/viewprofilepage/user-id/462


INPUT
=====

* MAKE DATA;

data have;
  input a b c d e f g h i;
cards4;
01 02 03 04 05 06 07 08 09 10
02 03 04 05 06 07 08 09 10 11
;;;;
run;quit;

 WORK.HAVE total obs=3                         | RULES
                                               |
  A    B    C    D    E    F    G     H     I  |  COL  VAL
                                               |
  1    2    3    4    5    6    7     8     9  |   A    1
  2    3    4    5    6    7    8     9    10  |   A    2
                                               |
                                               |   B    2
                                               |   B    3
                                               | ..
                                               |
                                               |   I    9
                                               |   I   10

EXAMPLE OUTPUT
--------------

 WORK.WANT total obs=18

  COL    VAL

   A       1
   A       2
   B       2
   B       3
   C       3
   C       4
   D       4
   D       5
   E       5
   E       6
   F       6
   F       7
   G       7
   G       8
   H       8
   H       9
   I       9
   I      10


PROCEESS
========

  1. Datastep and sort by PGStat (best?)

     data want;
        set have;
        array _a a--i;
        do _i = 1 to dim(_a);
            col = vname(_a{_i});
            val = _a{_i};
            if not missing(val) then output;
            end;
        keep col val;
     run;

     proc sort data=want;
        by col;
     run;

  2. Transpose sort

     proc transpose data=have out=havXpo(drop=a--i rename=(_name_=col col1=val));
       by a b c d e f g h i;
       var a b c d e f g h i;
     run;quit;

     proc sort data=havXpo out=want;
       by col;
     run;quit;

  3. SQL only

     %array(cols,values=a b c d e f g h i);
     proc sql;
        create
           table want as
        %do_over(cols,phrase=%str(
           select "?"  as col, ? as val from have),between=outer union corr
        )
     ;quit;

OUTPUT
======
 see above


