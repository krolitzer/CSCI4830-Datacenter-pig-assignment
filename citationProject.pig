-- Citation Project In Pig
-- Christopher Costello 10/14/14
-- DataCenter Scale Computing Fall 2014 - Dirk Grunwald

cites = load 'input/cite75_99.txt' using PigStorage(',') as (citing:long, cited:long);
pats = load 'input/apat63_99.txt' using PigStorage(',') 
   as (ipatent : long, gyear : int, gdate : int, appyear : int, 
     country : chararray , postate : chararray,
     assignee, asscode,
     claims : int, nclass, cat, subcat, 
     cmade : int, creceive : int, ratiocit : float ,
     general, original, fwdaplag, bckgtlag, 
     selfctub, selfctlb, secdupbd, secdlwbd);

a = filter pats by country == '"US"';
b = foreach a generate ipatent, postate;

j = join b by ipatent, cites by cited;

-- Join together citing cited with state info
halfWay = foreach j generate ipatent, postate, citing;
fullJoin = join halfWay by citing, b by ipatent;
gg = group fullJoin by halfWay::b::postate;

--Count all states
allStates = foreach gg generate group, (double)COUNT(fullJoin);

-- Group and count states that reference themselves
ff = foreach gg generate group, flatten($1);
sameStates = filter ff by fullJoin::halfWay::b::postate == fullJoin::b::postate;
groupedSame = group sameStates by fullJoin::halfWay::b::postate;
countSameStates = foreach groupedSame generate group, (double)COUNT($1);

-- Put the counts together and calculate stats
joinAllCounted = join countSameStates by $0, allStates by $0;
finalStats = foreach joinAllCounted generate $0, ($1 / $3);
dump finalStats;