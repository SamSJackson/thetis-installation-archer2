#!/bin/bash
#
#SBATCH --account=<budget-code>
#SBATCH --partition=standard
#SBATCH --qos=standard
#
#SBATCH --job-name=thetis-example
#SBATCH --output=slurm-%x-%j.out
#SBATCH --error=slurm-%x-%j.out
#
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=64
#
#SBATCH --time=01:00:00
#
#SBATCH --distribution=block:block
#
#SBATCH --hint=nomultithread
#
#SBATCH --exclusive
#
#SBATCH --requeue

# exit on first error
set -e

# setup firedrake environment

module load PrgEnv-gnu/8.4.0

BUILD_DIR=/work/<project>/<project>/<username>
FDVENV=fd-default

export PETSC_DIR=${BUILD_DIR}/petsc
export PETSC_ARCH=arch-${FDVENV}
VENV=${BUILD_DIR}/${FDVENV}

echo "PETSC_DIR=${PETSC_DIR}"
echo "PETSC_ARCH=${PETSC_ARCH}"
echo "VENV=${VENV}"
. ${VENV}/bin/activate

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${PETSC_DIR}/${PETSC_ARCH}/lib/

# Firedrake needs access to the MPI shared libraries
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${CRAY_MPICH_DIR}/lib-abi-mpich

# Default value set to placate warning when firedrake imports
export OMP_NUM_THREADS=1

# Default value set to placate matplotlib
if [ ! -d ${BUILD_DIR}/.config ] ; then
  mkdir -p ${BUILD_DIR}/.config
fi

export MPLCONFIGDIR=${BUILD_DIR}/.config/mpl

# set the cache directories. They must be in /work to be
# available from the compute nodes. Create them in the
# venv directory so different builds don't conflict.
if [ -z ${PYOP2_CACHE_DIR} ] ; then
   export PYOP2_CACHE_DIR=${VIRTUAL_ENV}/.cache/pyop2
fi

if [ -z ${FIREDRAKE_TSFC_KERNEL_CACHE_DIR} ] ; then
   export FIREDRAKE_TSFC_KERNEL_CACHE_DIR=${VIRTUAL_ENV}/.cache/tsfc
fi

if [ -z ${XDG_CACHE_HOME} ] ; then
   export XDG_CACHE_HOME=${VIRTUAL_ENV}/.cache/
fi

# ntasks-per-node must be L3CORES * (NODESIZE/L3SIZE)
# Hence, alter NODESIZE such that the above equation matches total number of processors per node

L3CORES=2
L3SIZE=4
NODESIZE=128

CPU_MAP=$(python3 -c "print(','.join(map(str,filter(lambda i: (i%${L3SIZE})<${L3CORES}, range(${NODESIZE})))))")

SRUN_ARGS="--distribution=block:block --hint=nomultithread --cpu-bind=map_cpu:${CPU_MAP}"

# run firedrake-check using slurm mpi executable
srun ${SRUN_ARGS} python <script_name.py>  
