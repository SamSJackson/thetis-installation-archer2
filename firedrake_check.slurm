#!/bin/bash
#
#SBATCH --account=<project>
#SBATCH --partition=standard
#SBATCH --qos=short
#
#SBATCH --job-name=firedrake-check
#SBATCH --output=slurm-%x-%j.out
#SBATCH --error=slurm-%x-%j.out
#
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=3
#
#SBATCH --time=00:20:00
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

BUILD_DIR=/work/<project>/<project>/<user>
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

# run firedrake-check using slurm mpi executable
echo -e "\nfiredrake-check"
firedrake-check --mpiexec='srun -n'