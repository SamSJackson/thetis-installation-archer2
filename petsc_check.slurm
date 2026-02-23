#!/bin/bash
#
#SBATCH --account=<project>
#SBATCH --partition=standard
#SBATCH --qos=short
#
#SBATCH --job-name=petsc-check
#SBATCH --output=slurm-%x-%j.out
#SBATCH --error=slurm-%x-%j.out
#
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
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

module load PrgEnv-gnu/8.4.0

BUILD_DIR=/work/<project>/<project>/<user>
PETSC_DIR=${BUILD_DIR}/petsc
PETSC_ARCH=arch-fd-default

echo PETSC_DIR=${PETSC_DIR}
echo PETSC_ARCH=${PETSC_ARCH}

cd ${PETSC_DIR}
# avoid srun warning messages causing tests to fail on output diffs
MPIEXEC_TAIL="--quiet --slurmd-debug=quiet" make check