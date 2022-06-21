#!/bin/bash
#============ PBS Options ============
#QSUB -ug gr20001
#QSUB -q gr20001a
#QSUB -r n
#QSUB -W 120:00
#QSUB -A p=8:t=1:c=68:m=90G

#============ Shell Script ============
set -x

date
export EMSES_DEBUG=no
aprun -n $(($QSUB_PROCS*64)) -d $QSUB_THREADS -N 64 ./mpiemses3D plasma.inp
echo ...done
python generate_xdmf3.py nd*.h5 rhobk00_0000.h5
python generate_xdmf3.py rho00_0000.h5
python generate_xdmf3.py phisp00_0000.h5
python generate_xdmf3.py ex00_0000.h5 ey00_0000.h5 ez00_0000.h5
python generate_xdmf3.py j1x00_0000.h5 j1y00_0000.h5 j1z00_0000.h5 j2x00_0000.h5 j2y00_0000.h5 j2z00_0000.h5 j3x00_0000.h5 j3y00_0000.h5 j3z00_0000.h5
date
