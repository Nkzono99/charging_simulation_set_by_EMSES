#!/bin/bash
#SBATCH -p gr20001a
#SBATCH --rsc p=32:t=1:c=1
#SBATCH -t 168:00:00
#SBATCH -o stdout.%J.log
#SBATCH -e stderr.%J.log

set -x
export LD_LIBRARY_PATH="/LARGE0/gr20001/KUspace-share/common/hdf5-lib/hdf5-1.14.3-240410/lib:/LARGE0/gr20001/KUspace-share/common/fftw-lib/fftw-3.3.10-240410/lib:$LD_LIBRARY_PATH"

module load fftw
module load hdf5/1.12.2_intel-2022.3-impi

export EMSES_DEBUG=no

date

rm *_0000.h5
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
