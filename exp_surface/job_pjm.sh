#!/bin/bash
#PJM -L  "node=3"            # volume of node
#PJM --mpi proc=128          # MPI process number
#PJM -L  "rscgrp=small"      # resource group
#PJM -L  "elapse=10:00:00"   # time limit
#PJM -x PJM_LLIO_GFSCACHE=/vol0004 # specify when using spack
#PJM -g hp240400

#loading modules
. /vol0004/apps/oss/spack/share/spack/setup-env.sh
spack load /yhazdvl
spack load /upvlzyl

#https://www.fugaku.r-ccs.riken.jp/doc_root/ja/user_guides/FugakuSpackGuide/intro.html#os
#Known issue: Path of dynamic link libraries of the operating system
export LD_LIBRARY_PATH=/lib64:$LD_LIBRARY_PATH

export EMSES_DEBUG=no

date

rm *_0000.h5
mpiexec ./mpiemses3D plasma.inp

date

# Postprocessing(visualization code, etc.)

echo ...done

python generate_xdmf3.py nd*.h5 rhobk00_0000.h5
python generate_xdmf3.py rho00_0000.h5
python generate_xdmf3.py phisp00_0000.h5
python generate_xdmf3.py ex00_0000.h5 ey00_0000.h5 ez00_0000.h5
python generate_xdmf3.py j1x00_0000.h5 j1y00_0000.h5 j1z00_0000.h5 j2x00_0000.h5 j2y00_0000.h5 j2z00_0000.h5 j3x00_0000.h5 j3y00_0000.h5 j3z00_0000.h5
date
