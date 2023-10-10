#!/bin/bash
#SBATCH -p gr20001b
#SBATCH --rsc p=128:t=1:c=1
#SBATCH -t 72:00:00
#SBATCH -o stdout.%J.log
#SBATCH -e stderr.%J.log

# set -x

module load fftw
module load hdf5/1.12.2_intel-2022.3-impi

export EMSES_DEBUG=no

date

srun ./mpiemses3D plasma.inp

date

# Postprocessing(visualization code, etc.)

echo ...done

python generate_xdmf3.py nd*.h5 rhobk00_0000.h5
python generate_xdmf3.py rho00_0000.h5
python generate_xdmf3.py phisp00_0000.h5
python generate_xdmf3.py ex00_0000.h5 ey00_0000.h5 ez00_0000.h5
python generate_xdmf3.py j1x00_0000.h5 j1y00_0000.h5 j1z00_0000.h5 j2x00_0000.h5 j2y00_0000.h5 j2z00_0000.h5 j3x00_0000.h5 j3y00_0000.h5 j3z00_0000.h5
date
