#!/bin/ksh 
$ORACLE_HOME/bin/tkprof $1 $1.prf sort=fchela 
/bin/cat $1.prf
